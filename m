Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 23F1A6B004D
	for <linux-mm@kvack.org>; Sat, 21 Jan 2012 15:53:45 -0500 (EST)
Received: by iadj38 with SMTP id j38so3561621iad.14
        for <linux-mm@kvack.org>; Sat, 21 Jan 2012 12:53:44 -0800 (PST)
Date: Sat, 21 Jan 2012 12:53:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] mm: msync: fix issues of sys_msync on tmpfs
In-Reply-To: <1327036719-1965-1-git-send-email-zumeng.chen@windriver.com>
Message-ID: <alpine.LSU.2.00.1201211206380.1290@eggly.anvils>
References: <1327036719-1965-1-git-send-email-zumeng.chen@windriver.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zumeng Chen <zumeng.chen@windriver.com>
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, mingo@elte.hu, ralf@linux-mips.org, bruce.ashfield@windriver.com, linux-mm@kvack.org, linux-mips@linux-mips.org

On Fri, 20 Jan 2012, Zumeng Chen wrote:

> This patch fixes two issues as follows:

Two issues?  You write of a cache aliasing issue, I don't see a second.

> 
> For some filesystem with fsync == noop_fsync, there is not so much thing
> to do, so sys_msync just passes by for all arches but some CPUs.
> 
> For some CPUs with cache aliases(dmesg|grep alias), it maybe has an issue,
> which reported by msync test suites in ltp-full when the memory of memset
> used by msync01 runs into cache alias randomly.
> 
> Consider the following scenario used by msync01 in ltp-full:
>   fildes = open(TEMPFILE, O_RDWR | O_CREAT, 0666)) < 0);
>   .../* initialization fildes by write(fildes); */
>   addr = mmap(0, page_sz, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED,
> 	 fildes, 0);
>   /* set buf with memset */
>   memset(addr + OFFSET_1, 1, BUF_SIZE);
> 
>   /* msync the addr before using, or MS_SYNC*/
>   msync(addr, page_sz, MS_ASYNC)

Actually, that MS_ASYNC msync() does nothing at all but validate its
arguments these days, even on filesystems with an effective fsync(). 
We write out dirty pages to disk in good time, msync() or not.

> 
>   /* Tries to read fildes */
>   lseek(fildes, (off_t) OFFSET_1, SEEK_SET) != (off_t) OFFSET_1) {
>   nread = read(fildes, read_buf, sizeof(read_buf));

My grasp of cache aliasing issues is very poor, please excuse me if I'm
wrong; but I don't think a patch to msync() should be necessary at all
(and ltp's msync01 test is testing nothing more than args to msync()).

In the case of tmpfs, that read() system call above should route through
to mm/shmem.c do_shmem_file_read(), which contains these same lines as
the more common mm/filemap.c do_generic_file_read():

	/* If users can be writing to this page using arbitrary
	 * virtual addresses, take care about potential aliasing
	 * before reading the page on the kernel side.
	 */
	if (mapping_writably_mapped(mapping))
		flush_dcache_page(page);

The mapping_writably_mapped() test ought to be succeeding in this case
(please check with printk's, perhaps some change has messed that up),
so flush_dcache_page(page) should be called, and any aliasing issues
resolved before the data is copied back to userspace.

I assume your problem is on MIPS, since you copied Ralf and linux-mips:
if the MIPS flush_dcache_page() is not working right, then you'll need
to follow up with them.

Hugh

> 
>   /* Then test the result */
>   if (read_buf[count] != 1) {
> 
> The test result is random too for CPUs with cache alias. So in this
> situation, we have to flush the related vma to make sure the read is
> correct.
> 
> Signed-off-by: Zumeng Chen <zumeng.chen@windriver.com>

> ---
>  mm/msync.c |   30 ++++++++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/msync.c b/mm/msync.c
> index 632df45..0021a7e 100644
> --- a/mm/msync.c
> +++ b/mm/msync.c
> @@ -13,6 +13,14 @@
>  #include <linux/file.h>
>  #include <linux/syscalls.h>
>  #include <linux/sched.h>
> +#include <asm/cacheflush.h>
> +
> +/* Cache aliases should be taken into accounts when msync. */
> +#ifdef cpu_has_dc_aliases
> +#define CPU_HAS_CACHE_ALIAS cpu_has_dc_aliases
> +#else
> +#define CPU_HAS_CACHE_ALIAS 0
> +#endif
>  
>  /*
>   * MS_SYNC syncs the entire file - including mappings.
> @@ -78,6 +86,28 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
>  		}
>  		file = vma->vm_file;
>  		start = vma->vm_end;
> +
> +		/*
> +		 * For some filesystems with fsync == noop_fsync, msync just
> +		 * passes by but some CPUs.
> +		 * For CPUs with cache alias, msync has to flush the related
> +		 * vma explicitly to make sure data coherency between memory
> +		 * and cache, which includes MS_SYNC or MS_ASYNC. That is to
> +		 * say, cache aliases should not be an async factor, so does
> +		 * msync on other arches without cache aliases.
> +		 */
> +		if (file && file->f_op && file->f_op->fsync == noop_fsync) {
> +			if (CPU_HAS_CACHE_ALIAS)
> +				flush_cache_range(vma, vma->vm_start,
> +							vma->vm_end);
> +			if (start >= end) {
> +				error = 0;
> +				goto out_unlock;
> +			}
> +			vma = find_vma(mm, start);
> +			continue;
> +		}
> +
>  		if ((flags & MS_SYNC) && file &&
>  				(vma->vm_flags & VM_SHARED)) {
>  			get_file(file);
> -- 
> 1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
