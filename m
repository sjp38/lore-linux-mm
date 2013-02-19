Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 94F8E6B0009
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 05:25:40 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id w49so1182372yhw.29
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 02:25:39 -0800 (PST)
Message-ID: <5123531B.8090301@gmail.com>
Date: Tue, 19 Feb 2013 18:25:31 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: fincore()
References: <87a9rbh7b4.fsf@rustcorp.com.au> <20130211162701.GB13218@cmpxchg.org> <20130211141239.f4decf03.akpm@linux-foundation.org> <20130215063450.GA24047@cmpxchg.org>
In-Reply-To: <20130215063450.GA24047@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

Hi Johannes,
On 02/15/2013 02:34 PM, Johannes Weiner wrote:
> On Mon, Feb 11, 2013 at 02:12:39PM -0800, Andrew Morton wrote:
>> Also, having to mmap the file to be able to query pagecache state is a
>> hack.  Whatever happened to the fincore() patch?
> I don't know, but how about this one:
>
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch 1/2] mm: fincore()
>
> Provide a syscall to determine whether a given file's pages are cached
> in memory.  This is more elegant than mmapping the file for the sole
> purpose of using mincore(), and also works on NOMMU.

Who is the user of mincore()/fincore()? In which scenario user processes 
need to know their pages are resident in memory or not?

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   include/linux/syscalls.h |   2 +
>   mm/Makefile              |   2 +-
>   mm/fincore.c             | 128 +++++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 131 insertions(+), 1 deletion(-)
>   create mode 100644 mm/fincore.c
>
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 313a8e0..3ceab2a 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -897,4 +897,6 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
>   asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
>   			 unsigned long idx1, unsigned long idx2);
>   asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
> +asmlinkage long sys_fincore(unsigned int fd, loff_t start, loff_t len,
> +			    unsigned char __user * vec);
>   #endif
> diff --git a/mm/Makefile b/mm/Makefile
> index 185a22b..221cdae 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -17,7 +17,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>   			   util.o mmzone.o vmstat.o backing-dev.o \
>   			   mm_init.o mmu_context.o percpu.o slab_common.o \
>   			   compaction.o balloon_compaction.o \
> -			   interval_tree.o $(mmu-y)
> +			   interval_tree.o fincore.o $(mmu-y)
>   
>   obj-y += init-mm.o
>   
> diff --git a/mm/fincore.c b/mm/fincore.c
> new file mode 100644
> index 0000000..d504611
> --- /dev/null
> +++ b/mm/fincore.c
> @@ -0,0 +1,128 @@
> +#include <linux/syscalls.h>
> +#include <linux/pagemap.h>
> +#include <linux/file.h>
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +
> +static long do_fincore(struct address_space *mapping, pgoff_t pgstart,
> +		       unsigned long nr_pages, unsigned char *vec)
> +{
> +	pgoff_t pgend = pgstart + nr_pages;
> +	struct radix_tree_iter iter;
> +	void **slot;
> +	long nr = 0;
> +
> +	rcu_read_lock();
> +restart:
> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, pgstart) {
> +		unsigned char present;
> +		struct page *page;
> +
> +		/* Handle holes */
> +		if (iter.index != pgstart + nr) {
> +			if (iter.index < pgend)
> +				nr_pages = iter.index - pgstart;
> +			break;
> +		}
> +repeat:
> +		page = radix_tree_deref_slot(slot);
> +		if (unlikely(!page))
> +			continue;
> +
> +		if (radix_tree_exception(page)) {
> +			if (radix_tree_deref_retry(page)) {
> +				/*
> +				 * Transient condition which can only trigger
> +				 * when entry at index 0 moves out of or back
> +				 * to root: none yet gotten, safe to restart.
> +				 */
> +				WARN_ON(iter.index);
> +				goto restart;
> +			}
> +			present = 0;
> +		} else {
> +			if (!page_cache_get_speculative(page))
> +				goto repeat;
> +
> +			/* Has the page moved? */
> +			if (unlikely(page != *slot)) {
> +				page_cache_release(page);
> +				goto repeat;
> +			}
> +
> +			present = PageUptodate(page);
> +			page_cache_release(page);
> +		}
> +		vec[nr] = present;
> +
> +		if (++nr == nr_pages)
> +			break;
> +	}
> +	rcu_read_unlock();
> +
> +	if (nr < nr_pages)
> +		memset(vec + nr, 0, nr_pages - nr);
> +
> +	return nr_pages;
> +}
> +
> +/*
> + * The fincore(2) system call.
> + *
> + * fincore() returns the memory residency status of the given file's
> + * pages, in the range [start, start + len].
> + * The status is returned in a vector of bytes.  The least significant
> + * bit of each byte is 1 if the referenced page is in memory, otherwise
> + * it is zero.
> + *
> + * Because the status of a page can change after fincore() checks it
> + * but before it returns to the application, the returned vector may
> + * contain stale information.
> + *
> + * return values:
> + *  zero    - success
> + *  -EBADF  - fd isn't a valid open file descriptor
> + *  -EFAULT - vec points to an illegal address
> + *  -EINVAL - start is not a multiple of PAGE_CACHE_SIZE
> + */
> +SYSCALL_DEFINE4(fincore, unsigned int, fd, loff_t, start, loff_t, len,
> +		unsigned char __user *, vec)
> +{
> +	unsigned long nr_pages;
> +	pgoff_t pgstart;
> +	struct fd f;
> +	long ret;
> +
> +	if (start & ~PAGE_CACHE_MASK)
> +		return -EINVAL;
> +
> +	f = fdget(fd);
> +	if (!f.file)
> +		return -EBADF;
> +
> +	pgstart = start >> PAGE_CACHE_SHIFT;
> +	nr_pages = DIV_ROUND_UP(len, PAGE_CACHE_SIZE);
> +
> +	while (nr_pages) {
> +		unsigned char tmp[64];
> +
> +		ret = do_fincore(f.file->f_mapping, pgstart,
> +				 min(nr_pages, sizeof(tmp)), tmp);
> +		if (ret <= 0)
> +			break;
> +
> +		if (copy_to_user(vec, tmp, ret)) {
> +			ret = -EFAULT;
> +			break;
> +		}
> +
> +		nr_pages -= ret;
> +		pgstart += ret;
> +		vec += ret;
> +		ret = 0;
> +	}
> +
> +	fdput(f);
> +
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
