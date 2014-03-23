Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id A38946B0099
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:51:08 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id wn1so4693399obc.39
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 09:51:08 -0700 (PDT)
Received: from mail-oa0-x22f.google.com (mail-oa0-x22f.google.com [2607:f8b0:4003:c02::22f])
        by mx.google.com with ESMTPS id wo3si15204827oeb.158.2014.03.23.09.51.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 09:51:07 -0700 (PDT)
Received: by mail-oa0-f47.google.com with SMTP id i11so4770779oag.6
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 09:51:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395436655-21670-2-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-2-git-send-email-john.stultz@linaro.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 23 Mar 2014 09:50:47 -0700
Message-ID: <CAHGf_=rKpOW5PSbAOZtg6GehJD6dOvRbBTSWV_2HOehw8xCa4g@mail.gmail.com>
Subject: Re: [PATCH 1/5] vrange: Add vrange syscall and handle
 splitting/merging and marking vmas
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi

On Fri, Mar 21, 2014 at 2:17 PM, John Stultz <john.stultz@linaro.org> wrote:
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
>         vrange - Mark or unmark range of memory as volatile
>
> SYNOPSIS
>         ssize_t vrange(unsigned_long start, size_t length,
>                          unsigned_long mode, unsigned_long flags,
>                          int *purged);
>
> DESCRIPTION
>         Applications can use vrange(2) to advise kernel that pages of
>         anonymous mapping in the given VM area can be reclaimed without
>         swapping (or can no longer be reclaimed without swapping).
>         The idea is that application can help kernel with page reclaim
>         under memory pressure by specifying data it can easily regenerate
>         and thus kernel can discard the data if needed.
>
>         mode:
>         VRANGE_VOLATILE
>                 Informs the kernel that the VM can discard in pages in
>                 the specified range when under memory pressure.
>         VRANGE_NONVOLATILE
>                 Informs the kernel that the VM can no longer discard pages
>                 in this range.
>
>         flags: Currently no flags are supported.
>
>         purged: Pointer to an integer which will return 1 if
>         mode == VRANGE_NONVOLATILE and any page in the affected range
>         was purged. If purged returns zero during a mode ==
>         VRANGE_NONVOLATILE call, it means all of the pages in the range
>         are intact.
>
>         If a process accesses volatile memory which has been purged, and
>         was not set as non volatile via a VRANGE_NONVOLATILE call, it
>         will recieve a SIGBUS.
>
> RETURN VALUE
>         On success vrange returns the number of bytes marked or unmarked.
>         Similar to write(), it may return fewer bytes then specified
>         if it ran into a problem.

This explanation doesn't match your implementation. You return the
last VMA - orig_start.
That said, when some hole is there at middle of the range marked (or
unmarked) bytes
aren't match the return value.


>
>         When using VRANGE_NON_VOLATILE, if the return value is smaller
>         then the specified length, then the value specified by the purged
>         pointer will be set to 1 if any of the pages specified in the
>         return value as successfully marked non-volatile had been purged.
>
>         If an error is returned, no changes were made.

At least, this explanation doesn't match the implementation. When you find file
mappings, you don't rollback prior changes.

>
> ERRORS
>         EINVAL This error can occur for the following reasons:
>                 * The value length is negative or not page size units.
>                 * addr is not page-aligned
>                 * mode not a valid value.
>                 * flags is not a valid value.
>
>         ENOMEM Not enough memory
>
>         ENOMEM Addresses in the specified range are not currently mapped,
>                or are outside the address space of the process.
>
>         EFAULT Purged pointer is invalid
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
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  arch/x86/syscalls/syscall_64.tbl |   1 +
>  include/linux/mm.h               |   1 +
>  include/linux/vrange.h           |   8 ++
>  mm/Makefile                      |   2 +-
>  mm/vrange.c                      | 173 +++++++++++++++++++++++++++++++++++++++
>  5 files changed, 184 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/vrange.h
>  create mode 100644 mm/vrange.c
>
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index a12bddc..7ae3940 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -322,6 +322,7 @@
>  313    common  finit_module            sys_finit_module
>  314    common  sched_setattr           sys_sched_setattr
>  315    common  sched_getattr           sys_sched_getattr
> +316    common  vrange                  sys_vrange
>
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c1b7414..a1f11da 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -117,6 +117,7 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_IO           0x00004000     /* Memory mapped I/O or similar */
>
>                                         /* Used by sys_madvise() */
> +#define VM_VOLATILE    0x00001000      /* VMA is volatile */
>  #define VM_SEQ_READ    0x00008000      /* App will access data sequentially */
>  #define VM_RAND_READ   0x00010000      /* App will not benefit from clustered reads */
>
> diff --git a/include/linux/vrange.h b/include/linux/vrange.h
> new file mode 100644
> index 0000000..6e5331e
> --- /dev/null
> +++ b/include/linux/vrange.h
> @@ -0,0 +1,8 @@
> +#ifndef _LINUX_VRANGE_H
> +#define _LINUX_VRANGE_H
> +
> +#define VRANGE_NONVOLATILE 0
> +#define VRANGE_VOLATILE 1

Maybe, moving uapi is better?

> +#define VRANGE_VALID_FLAGS (0) /* Don't yet support any flags */
> +
> +#endif /* _LINUX_VRANGE_H */
> diff --git a/mm/Makefile b/mm/Makefile
> index 310c90a..20229e2 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -16,7 +16,7 @@ obj-y                 := filemap.o mempool.o oom_kill.o fadvise.o \
>                            readahead.o swap.o truncate.o vmscan.o shmem.o \
>                            util.o mmzone.o vmstat.o backing-dev.o \
>                            mm_init.o mmu_context.o percpu.o slab_common.o \
> -                          compaction.o balloon_compaction.o \
> +                          compaction.o balloon_compaction.o vrange.o \
>                            interval_tree.o list_lru.o $(mmu-y)
>
>  obj-y += init-mm.o
> diff --git a/mm/vrange.c b/mm/vrange.c
> new file mode 100644
> index 0000000..2f8e2ce
> --- /dev/null
> +++ b/mm/vrange.c
> @@ -0,0 +1,173 @@
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
> +
> +/**
> + * do_vrange - Marks or clears VMAs in the range (start-end) as VM_VOLATILE
> + *
> + * Core logic of sys_volatile. Iterates over the VMAs in the specified
> + * range, and marks or clears them as VM_VOLATILE, splitting or merging them
> + * as needed.
> + *
> + * Returns the number of bytes successfully modified.
> + *
> + * Returns error only if no bytes were modified.
> + */
> +static ssize_t do_vrange(struct mm_struct *mm, unsigned long start,
> +                               unsigned long end, unsigned long mode,
> +                               unsigned long flags, int *purged)
> +{
> +       struct vm_area_struct *vma, *prev;
> +       unsigned long orig_start = start;
> +       ssize_t count = 0, ret = 0;
> +
> +       down_read(&mm->mmap_sem);

This should be down_write. VMA split and merge require write lock.


> +
> +       vma = find_vma_prev(mm, start, &prev);
> +       if (vma && start > vma->vm_start)
> +               prev = vma;
> +
> +       for (;;) {
> +               unsigned long new_flags;
> +               pgoff_t pgoff;
> +               unsigned long tmp;
> +
> +               if (!vma)
> +                       goto out;
> +
> +               if (vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
> +                                       VM_HUGETLB))
> +                       goto out;
> +
> +               /* We don't support volatility on files for now */
> +               if (vma->vm_file) {
> +                       ret = -EINVAL;
> +                       goto out;
> +               }
> +
> +               /* return ENOMEM if we're trying to mark unmapped pages */
> +               if (start < vma->vm_start) {
> +                       ret = -ENOMEM;
> +                       goto out;
> +               }
> +
> +               new_flags = vma->vm_flags;
> +
> +               tmp = vma->vm_end;
> +               if (end < tmp)
> +                       tmp = end;
> +
> +               switch (mode) {
> +               case VRANGE_VOLATILE:
> +                       new_flags |= VM_VOLATILE;
> +                       break;
> +               case VRANGE_NONVOLATILE:
> +                       new_flags &= ~VM_VOLATILE;
> +               }
> +
> +               pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
> +               prev = vma_merge(mm, prev, start, tmp, new_flags,
> +                                       vma->anon_vma, vma->vm_file, pgoff,
> +                                       vma_policy(vma));
> +               if (prev)
> +                       goto success;
> +
> +               if (start != vma->vm_start) {
> +                       ret = split_vma(mm, vma, start, 1);
> +                       if (ret)
> +                               goto out;
> +               }
> +
> +               if (tmp != vma->vm_end) {
> +                       ret = split_vma(mm, vma, tmp, 0);
> +                       if (ret)
> +                               goto out;
> +               }
> +
> +               prev = vma;
> +success:
> +               vma->vm_flags = new_flags;
> +
> +               /* update count to distance covered so far*/
> +               count = tmp - orig_start;
> +
> +               start = tmp;
> +               if (start < prev->vm_end)
> +                       start = prev->vm_end;
> +               if (start >= end)
> +                       goto out;
> +               vma = prev->vm_next;
> +       }
> +out:
> +       up_read(&mm->mmap_sem);
> +
> +       /* report bytes successfully marked, even if we're exiting on error */
> +       if (count)
> +               return count;
> +
> +       return ret;
> +}
> +
> +
> +/**
> + * sys_vrange - Marks specified range as volatile or non-volatile.
> + *
> + * Validates the syscall inputs and calls do_vrange(), then copies the
> + * purged flag back out to userspace.
> + *
> + * Returns the number of bytes successfully modified.
> + * Returns error only if no bytes were modified.
> + */
> +SYSCALL_DEFINE5(vrange, unsigned long, start, size_t, len, unsigned long, mode,
> +                       unsigned long, flags, int __user *, purged)
> +{
> +       unsigned long end;
> +       struct mm_struct *mm = current->mm;
> +       ssize_t ret = -EINVAL;
> +       int p = 0;
> +
> +       if (flags & ~VRANGE_VALID_FLAGS)
> +               goto out;
> +
> +       if (start & ~PAGE_MASK)
> +               goto out;
> +
> +       len &= PAGE_MASK;
> +       if (!len)
> +               goto out;

This code doesn't match the explanation of "not page size units."

> +
> +       end = start + len;
> +       if (end < start)
> +               goto out;
> +
> +       if (start >= TASK_SIZE)
> +               goto out;
> +
> +       if (purged) {
> +               /* Test pointer is valid before making any changes */
> +               if (put_user(p, purged))
> +                       return -EFAULT;
> +       }
> +
> +       ret = do_vrange(mm, start, end, mode, flags, &p);
> +
> +       if (purged) {
> +               if (put_user(p, purged)) {
> +                       /*
> +                        * This would be bad, since we've modified volatilty
> +                        * and the change in purged state would be lost.
> +                        */
> +                       WARN_ONCE(1, "vrange: purge state possibly lost\n");

Don't do that.
If userland app unmap the page between do_vrange and here, it's just
their fault, not kernel.
Therefore kernel warning make no sense. Please just move 1st put_user to here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
