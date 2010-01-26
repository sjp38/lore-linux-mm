Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9176B00A2
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 17:13:53 -0500 (EST)
Date: Tue, 26 Jan 2010 14:12:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Message-Id: <20100126141229.e1a81b29.akpm@linux-foundation.org>
In-Reply-To: <20100120215712.GO27212@frostnet.net>
References: <20100120215712.GO27212@frostnet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Frost <frost@cs.ucla.edu>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010 13:57:12 -0800
Chris Frost <frost@cs.ucla.edu> wrote:

> Add the fincore() system call. fincore() is mincore() for file descriptors.
> 
> The functionality of fincore() can be emulated with an mmap(), mincore(),
> and munmap(), but this emulation requires more system calls and requires
> page table modifications. fincore() can provide a significant performance
> improvement for non-sequential in-core queries.
> 
> Signed-off-by: Chris Frost <frost@cs.ucla.edu>
> Signed-off-by: Steve VanDeBogart <vandebo@cs.ucla.edu>
> ---
> 
> Notes on micro and macro performance and on a potential optimization:
> 
> For a microbenchmark that sequentially queries whether the pages of a large
> file are in memory fincore is 7-11x faster than mmap+mincore+munmap
> when querying one page a time (Pentium 4 running a 32 bit SMP kernel).
> When querying 1024 pages at a time the two approaches perform comparably.
> However, an application cannot always amortize calls; e.g., non-sequential
> reads. These improvements are increased significantly by amortizing the
> RCU work done by each find_get_page() call, but this optimization does
> not affect our macrobenchmarks (more in third paragraph).
> 
> We introduced this system call while modifying SQLite and the GIMP to
> request large prefetches for what would otherwise be non-sequential reads.
> As a macrobenchmark, we see a 125s SQLite query (72s system time) reduced
> to 75s (18s system time) by using fincore() instead of mincore(). This
> speedup of course varies by benchmark and benchmarks size; we've seen
> both minimal speedups and 1000x speedups. More on these benchmarks in the
> publication _Reducing Seek Overhead with Application-Directed Prefetching_
> in USENIX ATC 2009 and at http://libprefetch.cs.ucla.edu/.
> 
> In this patch find_get_page() is called for each page, which in turn
> calls rcu_read_lock(), for each page. We have found that amortizing
> these RCU calls, e.g., by introducing a variant of find_get_pages_contig()
> that does not skip missing pages, can speedup the above microbenchmark
> by 260x when querying many pages per system call. But we have not observed
> noticeable improvements to our macrobenchmarks. I'd be happy to also post
> this change or look further into it, but this seems like a reasonable
> first patch, at least.

I must say, the syscall appeals to my inner geek.  Lot of applications
are leaving a lot of time on the floor due to bad disk access patterns.
A really smart library which uses this facility could help all over
the place.

Is it likely that these changes to SQLite and Gimp would be merged into
the upstream applications?

> ...
>
> new file mode 100644
> index 0000000..6b74cc4
> --- /dev/null
> +++ b/fs/fincore.c
> @@ -0,0 +1,135 @@
> +/*
> + *	fs/fincore.c
> + *
> + * Copyright (C) 2009, 2010 Chris Frost, UC Regents
> + * Copyright (C) 2008 Steve VanDeBogart, UC Regents
> + */
> +
> +/*
> + * The fincore() system call.
> + */
> +#include <linux/fs.h>
> +#include <linux/file.h>
> +#include <linux/pagemap.h>
> +#include <linux/syscalls.h>
> +#include <linux/uaccess.h>
> +
> +static unsigned char fincore_page(struct address_space *mapping, pgoff_t pgoff)
> +{
> +	unsigned char present = 0;
> +	struct page *page = find_get_page(mapping, pgoff);
> +	if (page) {
> +		present = PageUptodate(page);
> +		page_cache_release(page);
> +	}
> +
> +	return present;
> +}

What Andi said.  This is crying out for a big radix-tree walk in the
inner loop.

> +/*
> + * The fincore(2) system call.
> + *
> + * fincore() returns the memory residency status of the pages backing
> + * a file range specified by fd and [start, start + len).
> + * The status is returned in a vector of bytes.  The least significant
> + * bit of each byte is 1 if the referenced page is in memory, otherwise
> + * it is zero.
> + *
> + * Because the status of a page can change after fincore() checks it
> + * but before it returns to the application, the returned vector may
> + * contain stale information.  Only locked pages are guaranteed to
> + * remain in memory.
> + *
> + * return values:
> + *  zero    - success
> + *  -EBADF  - fd is an illegal file descriptor
> + *  -EFAULT - vec points to an illegal address
> + *  -EINVAL - start is not a multiple of PAGE_CACHE_SIZE or start + len
> + *		is larger than the size of the file
> + *  -EAGAIN - A kernel resource was temporarily unavailable.
> + */
> +SYSCALL_DEFINE4(fincore, unsigned int, fd, loff_t, start, loff_t, len,
> +		unsigned char __user *, vec)
> +{
> +	long retval;
> +	loff_t pgoff = start >> PAGE_SHIFT;
> +	loff_t pgend;
> +	loff_t npages;
> +	struct file *filp;
> +	int fput_needed;
> +	loff_t file_nbytes;
> +	loff_t file_npages;
> +	unsigned char *tmp = NULL;
> +	unsigned char tmp_small[64];
> +	unsigned tmp_count;
> +	int i;

pgoff, pgend and npages should be pgoff_t, I think.  file_nbytes I
guess is OK, but maybe size_t.  file_npages should be pgoff_t.  And
death to tmp!

> +	/* Check the start address: needs to be page-aligned.. */
> +	if (start & ~PAGE_CACHE_MASK)
> +		return -EINVAL;
> +
> +	npages = len >> PAGE_SHIFT;
> +	npages += (len & ~PAGE_MASK) != 0;
> +
> +	pgend = pgoff + npages;
> +
> +	filp = fget_light(fd, &fput_needed);
> +	if (!filp)
> +		return -EBADF;
> +
> +	if (filp->f_dentry->d_inode->i_mode & S_IFBLK)
> +		file_nbytes = filp->f_dentry->d_inode->i_bdev->bd_inode->i_size << 9;
> +	else
> +		file_nbytes = filp->f_dentry->d_inode->i_size;

I think

	file_nbytes = i_size_read(filp->f_mapping->host->i_size);

is what you want here.


> +	file_npages = file_nbytes >> PAGE_SHIFT;
> +	file_npages += (file_nbytes & ~PAGE_MASK) != 0;

	file_npages = (file_nbytes + PAGE_SIZE - 1) >> PAGE_SHIFT;

> +	if (pgoff >= file_npages || pgend > file_npages) {
> +		retval = -EINVAL;
> +		goto done;
> +	}

Should this return -EINVAL, or should it just return "0": nothing there?

Bear in mind that this code is racy against truncate (I think?), and
this is "by design".  If that race does occur, we want to return
something graceful to userspace and I suggest that "nope, nothing
there" is a more graceful result that "erk, you screwed up".  Because
the application _didn't_ screw up: the pages were there when the
syscall was first performed.

> +	if (!access_ok(VERIFY_WRITE, vec, npages)) {
> +		retval = -EFAULT;
> +		goto done;
> +	}

Yeah, just remove this.  copy_to_user() will handle it.

> +	/*
> +	 * Allocate buffer vector page.
> +	 * Optimize allocation for small values of npages because the
> +	 * __get_free_page() call doubles fincore(2) runtime when npages == 1.
> +	 */
> +	if (npages <= sizeof(tmp_small)) {
> +		tmp = tmp_small;
> +		tmp_count = sizeof(tmp_small);
> +	} else {
> +		tmp = (void *) __get_free_page(GFP_USER);
> +		if (!tmp) {
> +			retval = -EAGAIN;
> +			goto done;
> +		}
> +		tmp_count = PAGE_SIZE;
> +	}
> +
> +	while (pgoff < pgend) {
> +		/*
> +		 * Do at most tmp_count entries per iteration, due to
> +		 * the temporary buffer size.
> +		 */
> +		for (i = 0; pgoff < pgend && i < tmp_count; pgoff++, i++)
> +			tmp[i] = fincore_page(filp->f_mapping, pgoff);
> +
> +		if (copy_to_user(vec, tmp, i)) {
> +			retval = -EFAULT;
> +			break;
> +		}
> +		vec += i;
> +	}
> +	retval = 0;
> +done:
> +	if (tmp && tmp != tmp_small)
> +		free_page((unsigned long) tmp);
> +	fput_light(filp, fput_needed);
> +	return retval;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
