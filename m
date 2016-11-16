Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97DD76B0280
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 13:28:13 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so60303318qta.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 10:28:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r82si22484461qki.152.2016.11.16.10.28.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 10:28:12 -0800 (PST)
Date: Wed, 16 Nov 2016 19:28:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
Message-ID: <20161116182809.GC26185@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
 <20161104193626.GU4611@redhat.com>
 <1805f956-1777-471c-1401-46c984189c88@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1805f956-1777-471c-1401-46c984189c88@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

Hello Mike,

On Tue, Nov 08, 2016 at 01:06:06PM -0800, Mike Kravetz wrote:
> -- 
> Mike Kravetz
> 
> From: Mike Kravetz <mike.kravetz@oracle.com>
> 
> userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing
> 
> The new routine copy_huge_page_from_user() uses kmap_atomic() to map
> PAGE_SIZE pages.  However, this prevents page faults in the subsequent
> call to copy_from_user().  This is OK in the case where the routine
> is copied with mmap_sema held.  However, in another case we want to
> allow page faults.  So, add a new argument allow_pagefault to indicate
> if the routine should allow page faults.
> 
> A patch (mm/hugetlb: fix huge page reservation leak in private mapping
> error paths) was recently submitted and is being added to -mm tree.  It
> addresses the issue huge page reservations when a huge page is allocated,
> and free'ed before being instantiated in an address space.  This would
> typically happen in error paths.  The routine __mcopy_atomic_hugetlb has
> such an error path, so it will need to call restore_reserve_on_error()
> before free'ing the huge page.  restore_reserve_on_error is currently
> only visible in mm/hugetlb.c.  So, add it to a header file so that it
> can be used in mm/userfaultfd.c.  Another option would be to move
> __mcopy_atomic_hugetlb into mm/hugetlb.c

It would have been better to split this in two patches.

> @@ -302,8 +302,10 @@ static __always_inline ssize_t
> __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>  out_unlock:
>  	up_read(&dst_mm->mmap_sem);
>  out:
> -	if (page)
> +	if (page) {
> +		restore_reserve_on_error(h, dst_vma, dst_addr, page);
>  		put_page(page);
> +	}
>  	BUG_ON(copied < 0);

If the revalidation fails dst_vma could even be NULL.

We get there with page not NULL only if something in the revalidation
fails effectively... I'll have to drop the above change as the fix
will hurt more than the vma reservation not being restored. Didn't
think too much about it, but there was no obvious way to restore the
reservation of a vma, after we drop the mmap_sem. However if we don't
drop the mmap_sem, we'd recurse into it, and it'll deadlock in current
implementation if a down_write is already pending somewhere else. In
this specific case fairness is not an issue, but it's not checking
it's the same thread taking it again, so it's doesn't allow to recurse
(checking it's the same thread would make it slower).

I also fixed the gup support for userfaultfd, could you review it?
Beware, untested... will test it shortly with qemu postcopy live
migration with hugetlbfs instead of THP (that currently gracefully
complains about FAULT_FLAG_ALLOW_RETRY missing, KVM ioctl returns
badaddr and DEBUG_VM=y clearly showed the stack trace of where
FAULT_FLAG_ALLOW_RETRY was missing).

I think this enhancement is needed by Oracle too, so that you don't
get an error from I/O syscalls, and you instead get an userfault.

We need to update the selftest to trigger userfaults not only with the
CPU but with O_DIRECT too.

Note, the FOLL_NOWAIT is needed to offload the userfaults to async
page faults. KVM tries an async fault first (FOLL_NOWAIT, nonblocking
= NULL), if that fails it offload a blocking (*nonblocking = 1) fault
through async page fault kernel thread while guest scheduler schedule
away the blocked process. So the userfaults behave like SSD swapins
from disk hitting on a single guest thread and not the whole host vcpu
thread. Clearly hugetlbfs cannot ever block for I/O, FOLL_NOWAIT is
only useful to avoid blocking in the vcpu thread in
handle_userfault().
