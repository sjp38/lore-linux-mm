Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 509D86B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:17:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s207so120946092oie.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:17:47 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40111.outbound.protection.outlook.com. [40.107.4.111])
        by mx.google.com with ESMTPS id x47si3970953otd.277.2016.08.19.06.17.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 06:17:46 -0700 (PDT)
Subject: Re: [PATCH 0/1] soft_dirty: fix soft_dirty during THP split
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <57B70796.4080408@virtuozzo.com>
Date: Fri, 19 Aug 2016 16:20:22 +0300
MIME-Version: 1.0
In-Reply-To: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 08/19/2016 03:41 PM, Andrea Arcangeli wrote:
> Hello,
> 
> while adding proper userfaultfd_wp support with bits in pagetable and
> swap entry to avoid false positives WP userfaults through
> swap/fork/KSM/etc.. I've been adding a framework that mostly mirrors
> soft dirty.
> 
> So I noticed in one place I had to add uffd_wp support to the
> pagetables that wasn't covered by soft_dirty and I think it should
> have.
> 
> Example: in the THP migration code migrate_misplaced_transhuge_page()
> pmd_mkdirty is called unconditionally after mk_huge_pmd.
> 
> 	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
> 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> 
> That sets soft dirty too (it's a false positive for soft dirty, the
> soft dirty bit could be more finegrined and transfer the bit like
> uffd_wp will do..  pmd/pte_uffd_wp() enforces the invariant that when
> it's set pmd/pte_write is not set).
> 
> However in the THP split there's no unconditional pmd_mkdirty after
> mk_huge_pmd and pte_swp_mksoft_dirty isn't called after the migration
> entry is created. The code sets the dirty bit in the struct page
> instead of setting it in the pagetable (which is fully equivalent as
> far as the real dirty bit is concerned, as the whole point of
> pagetable bits is to be eventually flushed out of to the page, but
> that is not equivalent for the soft-dirty bit that gets lost in
> translation).
> 
> This was found by code review only and totally untested as I'm working
> to actually replace soft dirty and I don't have time to test potential
> soft dirty bugfixes as well :).
> 
> 
> ---
> Changing topic slightly: some considerations about soft dirty vs
> userfaultfd_wp follows.
> 
> I'm optimistic once userfaultfd WP support is fully accurate with
> pmd/pte_uffd_wp tracking enabled, we can then remove soft dirty some
> time after that.

And (!) after non-cooperative patches are functional too.

> Not even the qemu precopy code uses soft dirty, instead it prefers to
> set the dirty bitmap in software, after every guest memory
> modification, even if it means setting the same dirty bit over and
> over again.
> 
> We considered soft dirty, but the cost of scanning all pagetables like
> soft dirty has to do is excessive and it doesn't scale: it's O(N)
> where N is the number of pages in the program/virtual machine. If
> there's a terabyte of RAM the cost would be excessive (especially
> considering we're tracking faults at 4k granularity and soft dirty
> wouldn't even give it at such granularity). As opposed we use the new
> x86 virt hardware feature that notifies KVM of a list of virtual
> addresses that are dirty, in an array that sends a notification and
> blocks in a vmexit when it gets full. That feature is not requiring us
> to scan all shadow pagetables in order to leave the memory read-write
> and avoid write faults during precopy dirty logging.
> 
> userfaultfd WP tracking can provide the same information that the
> hardware shadow pagetables feature provides, without having to stop
> and scan all pagetables at every precopy pass. So it would remove the
> complexity issues from dirty tracking.
> 
> Most important for most usages soft dirty is not enough regardless of
> performance considerations, as it can't block the fault,
> userfaultfd_wp can do that as well instead. Throttling the write
> faults is fundamental to be able to guarantee a maximum amount of
> allocations in the snapshot use case, i.e. postcopy live snapshotting
> and redis snapshotting with userfault thread and dropping fork()
> (fork() in fact cannot throttle the write faults, nor decide the
> granularity of the COW faults in the parent which is why redis
> under performs with THP on).
> 
> Clearly soft dirty is better than mprotect + sigsegv for
> non-cooperative usages like checkpoint but I believe userfaultfd_wp
> would be even better for that, despite it will schedule. Perhaps later
> we could add an async queue mode to enable and disable at runtime, so
> the userfault could be still notified to userland through uffd
> asynchronously, despite the faulting thread continues running without
> blocking.

Yes. Another problem of soft-dirty that will be addressed by uffd is
simultaneous memory tracking of two ... scanners (?) E.g. when we
reset soft-dirty to track the mem and then some other software comes
and tries to do the same, the whole soft-dirty state becomes screwed.
With uffd we'll at least have the ability for the first tracker to
keep the 2nd one off the tracking task.

> Yet another difference is that soft dirty exposes the memory
> granularity the kernel decided to use internally, so it'll report 2mb
> dirty if THP could have been allocated or 4kb dirty if it
> couldn't. With userfaultfd it's always userland that decides the
> granularity of the faults and userland cannot possibly notice any
> difference in behavior or runtime depending on THP being used or
> not. Of course for userland to give a chance to the kernel to avoid
> splitting THPs in the user faulted regions, userland would need to use
> a 2MB granularity in the UFFDIO ioclts (i.e. calling
> UFFDIO_WRITEPROTECT with 2MB aligned "start, end" addreses etc..).
> 
> Said that for the time being I'm trying to allow soft dirty and
> userfaultfd_wp to work simultaneously on the same "vmas", so that they
> stay orthogonal.
> 
> userfaultfd_wp already works for test programs and it shall be safe as
> far as the kernel safety is concerned but I don't think swap is being
> handled right in the current code and the pmd/pte_(swp)_uffd_wp
> pagetable bitflag I'm adding should fix it.
> 
> Andrea Arcangeli (1):
>   soft_dirty: fix soft_dirty during THP split
> 
>  mm/huge_memory.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
