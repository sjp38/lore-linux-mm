Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8C06B0073
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 05:21:24 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so4250079wgh.4
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 02:21:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mb19si4468311wic.24.2014.03.17.02.21.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 02:21:22 -0700 (PDT)
Date: Mon, 17 Mar 2014 10:21:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/3] vrange: Add vrange syscall and handle
 splitting/merging and marking vmas
Message-ID: <20140317092118.GA2210@quack.suse.cz>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
 <1394822013-23804-2-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394822013-23804-2-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 14-03-14 11:33:31, John Stultz wrote:
> This patch introduces the vrange() syscall, which allows for specifying
> ranges of memory as volatile, and able to be discarded by the system.
> 
> This initial patch simply adds the syscall, and the vma handling,
> splitting and merging the vmas as needed, and marking them with
> VM_VOLATILE.
> 
> No purging or discarding of volatile ranges is done at this point.
> 
> Example man page:
> 
> NAME
> 	vrange - Mark or unmark range of memory as volatile
> 
> SYNOPSIS
> 	int vrange(unsigned_long start, size_t length, int mode,
> 			 int *purged);
> 
> DESCRIPTION
> 	Applications can use vrange(2) to advise the kernel how it should
> 	handle paging I/O in this VM area.  The idea is to help the kernel
> 	discard pages of vrange instead of reclaiming when memory pressure
> 	happens. It means kernel doesn't discard any pages of vrange if
> 	there is no memory pressure.
  I'd say that the advantage is kernel doesn't have to swap volatile pages,
it can just directly discard them on memory pressure. You should also
mention somewhere vrange() is currently supported only for anonymous pages.
So maybe we can have the description like:
Applications can use vrange(2) to advise kernel that pages of anonymous
mapping in the given VM area can be reclaimed without swapping (or can no
longer be reclaimed without swapping). The idea is that application can
help kernel with page reclaim under memory pressure by specifying data
it can easily regenerate and thus kernel can discard the data if needed.

> 	mode:
> 	VRANGE_VOLATILE
> 		hint to kernel so VM can discard in vrange pages when
> 		memory pressure happens.
> 	VRANGE_NONVOLATILE
> 		hint to kernel so VM doesn't discard vrange pages
> 		any more.
> 
> 	If user try to access purged memory without VRANGE_NONVOLATILE call,
                ^^^ tries

> 	he can encounter SIGBUS if the page was discarded by kernel.
> 
> 	purged: Pointer to an integer which will return 1 if
> 	mode == VRANGE_NONVOLATILE and any page in the affected range
> 	was purged. If purged returns zero during a mode ==
> 	VRANGE_NONVOLATILE call, it means all of the pages in the range
> 	are intact.
> 
> RETURN VALUE
> 	On success vrange returns the number of bytes marked or unmarked.
> 	Similar to write(), it may return fewer bytes then specified
> 	if it ran into a problem.
  I believe you may need to better explain what is 'purged' argument good
for. Because in my naive understanding *purged == 1 iff return value !=
length.  I recall your discussion with Johannes about error conditions and
the need to return error but also the state of the range, is that right?
But that should be really explained somewhere so that poor application
programmer is aware of those corner cases as well.

> 
> 	If an error is returned, no changes were made.
> 
> ERRORS
> 	EINVAL This error can occur for the following reasons:
> 		* The value length is negative or not page size units.
> 		* addr is not page-aligned
> 		* mode not a valid value.
> 
> 	ENOMEM Not enough memory
> 
> 	EFAULT purged pointer is invalid
> 
> This a simplified implementation which reuses some of the logic
> from Minchan's earlier efforts. So credit to Minchan for his work.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Dhaval Giani <dgiani@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
  Some minor comments in the patch below...

> ---
>  arch/x86/syscalls/syscall_64.tbl |   1 +
>  include/linux/mm.h               |   1 +
>  include/linux/vrange.h           |   7 ++
>  mm/Makefile                      |   2 +-
>  mm/vrange.c                      | 150 +++++++++++++++++++++++++++++++++++++++
>  5 files changed, 160 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/vrange.h
>  create mode 100644 mm/vrange.c
> 
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index a12bddc..7ae3940 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -322,6 +322,7 @@
>  313	common	finit_module		sys_finit_module
>  314	common	sched_setattr		sys_sched_setattr
>  315	common	sched_getattr		sys_sched_getattr
> +316	common	vrange			sys_vrange
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c1b7414..a1f11da 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -117,6 +117,7 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
>  
>  					/* Used by sys_madvise() */
> +#define VM_VOLATILE	0x00001000	/* VMA is volatile */
>  #define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
>  #define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
>  
> diff --git a/include/linux/vrange.h b/include/linux/vrange.h
> new file mode 100644
> index 0000000..652396b
> --- /dev/null
> +++ b/include/linux/vrange.h
> @@ -0,0 +1,7 @@
> +#ifndef _LINUX_VRANGE_H
> +#define _LINUX_VRANGE_H
> +
> +#define VRANGE_NONVOLATILE 0
> +#define VRANGE_VOLATILE 1
> +
> +#endif /* _LINUX_VRANGE_H */
> diff --git a/mm/Makefile b/mm/Makefile
> index 310c90a..20229e2 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   util.o mmzone.o vmstat.o backing-dev.o \
>  			   mm_init.o mmu_context.o percpu.o slab_common.o \
> -			   compaction.o balloon_compaction.o \
> +			   compaction.o balloon_compaction.o vrange.o \
>  			   interval_tree.o list_lru.o $(mmu-y)
>  
>  obj-y += init-mm.o
> diff --git a/mm/vrange.c b/mm/vrange.c
> new file mode 100644
> index 0000000..acb4356
> --- /dev/null
> +++ b/mm/vrange.c
> @@ -0,0 +1,150 @@
> +#include <linux/syscalls.h>
> +#include <linux/vrange.h>
> +#include <linux/mm_inline.h>
> +#include <linux/pagemap.h>
> +#include <linux/rmap.h>
> +#include <linux/hugetlb.h>
> +#include <linux/mmu_notifier.h>
> +#include <linux/mm_inline.h>
> +#include "internal.h"
> +
> +static ssize_t do_vrange(struct mm_struct *mm, unsigned long start,
> +				unsigned long end, int mode, int *purged)
> +{
> +	struct vm_area_struct *vma, *prev;
> +	unsigned long orig_start = start;
> +	ssize_t count = 0, ret = 0;
> +	int lpurged = 0;
> +
> +	down_read(&mm->mmap_sem);
> +
> +	vma = find_vma_prev(mm, start, &prev);
> +	if (vma && start > vma->vm_start)
> +		prev = vma;
> +
> +	for (;;) {
> +		unsigned long new_flags;
> +		pgoff_t pgoff;
> +		unsigned long tmp;
> +
> +		if (!vma)
> +			goto out;
> +
> +		if (vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
> +					VM_HUGETLB))
> +			goto out;
> +
> +		/* We don't support volatility on files for now */
> +		if (vma->vm_file) {
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +
> +		new_flags = vma->vm_flags;
> +
> +		if (start < vma->vm_start) {
> +			start = vma->vm_start;
> +			if (start >= end)
> +				goto out;
> +		}
> +		tmp = vma->vm_end;
> +		if (end < tmp)
> +			tmp = end;
> +
> +		switch (mode) {
> +		case VRANGE_VOLATILE:
> +			new_flags |= VM_VOLATILE;
> +			break;
> +		case VRANGE_NONVOLATILE:
> +			new_flags &= ~VM_VOLATILE;
> +		}
> +
> +		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
> +		prev = vma_merge(mm, prev, start, tmp, new_flags,
> +					vma->anon_vma, vma->vm_file, pgoff,
> +					vma_policy(vma));
> +		if (prev)
> +			goto success;
> +
> +		if (start != vma->vm_start) {
> +			ret = split_vma(mm, vma, start, 1);
> +			if (ret)
> +				goto out;
> +		}
> +
> +		if (tmp != vma->vm_end) {
> +			ret = split_vma(mm, vma, tmp, 0);
> +			if (ret)
> +				goto out;
> +		}
> +
> +		prev = vma;
> +success:
> +		vma->vm_flags = new_flags;
> +		*purged = lpurged;
> +
> +		/* update count to distance covered so far*/
> +		count = tmp - orig_start;
> +
> +		if (prev && start < prev->vm_end)
  In which case 'prev' can be NULL? And when start >= prev->vm_end? In all
the cases I can come up with this condition seems to be true...

> +			start = prev->vm_end;
> +		if (start >= end)
> +			goto out;
> +		if (prev)
  Ditto regarding 'prev'...

> +			vma = prev->vm_next;
> +		else	/* madvise_remove dropped mmap_sem */
> +			vma = find_vma(mm, start);
  The comment regarding madvise_remove() looks bogus...

> +	}
> +out:
> +	up_read(&mm->mmap_sem);
> +
> +	/* report bytes successfully marked, even if we're exiting on error */
> +	if (count)
> +		return count;
> +
> +	return ret;
> +}
> +
> +SYSCALL_DEFINE4(vrange, unsigned long, start,
> +		size_t, len, int, mode, int __user *, purged)
> +{
> +	unsigned long end;
> +	struct mm_struct *mm = current->mm;
> +	ssize_t ret = -EINVAL;
> +	int p = 0;
> +
> +	if (start & ~PAGE_MASK)
> +		goto out;
> +
> +	len &= PAGE_MASK;
> +	if (!len)
> +		goto out;
> +
> +	end = start + len;
> +	if (end < start)
> +		goto out;
> +
> +	if (start >= TASK_SIZE)
> +		goto out;
> +
> +	if (purged) {
> +		/* Test pointer is valid before making any changes */
> +		if (put_user(p, purged))
> +			return -EFAULT;
> +	}
> +
> +	ret = do_vrange(mm, start, end, mode, &p);
> +
> +	if (purged) {
> +		if (put_user(p, purged)) {
> +			/*
> +			 * This would be bad, since we've modified volatilty
> +			 * and the change in purged state would be lost.
> +			 */
> +			WARN_ONCE(1, "vrange: purge state possibly lost\n");
> +		}
> +	}
> +
> +out:
> +	return ret;
> +}
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
