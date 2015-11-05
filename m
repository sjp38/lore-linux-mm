Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 20EF082F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 12:50:33 -0500 (EST)
Received: by wmnn186 with SMTP id n186so21177287wmn.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 09:50:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l66si9973225wmg.9.2015.11.05.09.50.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Nov 2015 09:50:31 -0800 (PST)
Subject: Re: [PATCH v2 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils> <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
 <20151019131308.GB15819@node.shutemov.name>
 <alpine.LSU.2.11.1510191218070.4652@eggly.anvils>
 <20151019201003.GA18106@node.shutemov.name> <56255FE4.5070609@suse.cz>
 <alpine.LSU.2.11.1510211544540.3905@eggly.anvils>
 <alpine.LSU.2.11.1510291147150.3450@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B96E5.4070600@suse.cz>
Date: Thu, 5 Nov 2015 18:50:29 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510291147150.3450@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 10/29/2015 07:49 PM, Hugh Dickins wrote:
> KernelThreadSanitizer (ktsan) has shown that the down_read_trylock() of
> mmap_sem in try_to_unmap_one() (when going to set PageMlocked on a page
> found mapped in a VM_LOCKED vma) is ineffective against races with
> exit_mmap()'s munlock_vma_pages_all(), because mmap_sem is not held when
> tearing down an mm.
> 
> But that's okay, those races are benign; and although we've believed for
> years in that ugly down_read_trylock(), it's unsuitable for the job, and
> frustrates the good intention of setting PageMlocked when it fails.
> 
> It just doesn't matter if here we read vm_flags an instant before or after
> a racing mlock() or munlock() or exit_mmap() sets or clears VM_LOCKED: the
> syscalls (or exit) work their way up the address space (taking pt locks
> after updating vm_flags) to establish the final state.
> 
> We do still need to be careful never to mark a page Mlocked (hence
> unevictable) by any race that will not be corrected shortly after.  The
> page lock protects from many of the races, but not all (a page is not
> necessarily locked when it's unmapped).  But the pte lock we just dropped
> is good to cover the rest (and serializes even with
> munlock_vma_pages_all(), so no special barriers required): now hold on to
> the pte lock while calling mlock_vma_page().  Is that lock ordering safe? 
> Yes, that's how follow_page_pte() calls it, and how page_remove_rmap()
> calls the complementary clear_page_mlock().
> 
> This fixes the following case (though not a case which anyone has
> complained of), which mmap_sem did not: truncation's preliminary
> unmap_mapping_range() is supposed to remove even the anonymous COWs of
> filecache pages, and that might race with try_to_unmap_one() on a
> VM_LOCKED vma, so that mlock_vma_page() sets PageMlocked just after
> zap_pte_range() unmaps the page, causing "Bad page state (mlocked)" when
> freed.  The pte lock protects against this.
> 
> You could say that it also protects against the more ordinary case, racing
> with the preliminary unmapping of a filecache page itself: but in our
> current tree, that's independently protected by i_mmap_rwsem; and that
> race would be why "Bad page state (mlocked)" was seen before commit
> 48ec833b7851 ("Revert mm/memory.c: share the i_mmap_rwsem").
> 
> Vlastimil Babka points out another race which this patch protects against.
> try_to_unmap_one() might reach its mlock_vma_page() TestSetPageMlocked a
> moment after munlock_vma_pages_all() did its Phase 1 TestClearPageMlocked:
> leaving PageMlocked and unevictable when it should be evictable.  mmap_sem
> is ineffective because exit_mmap() does not hold it; page lock ineffective
> because __munlock_pagevec() only takes it afterwards, in Phase 2; pte lock
> is effective because __munlock_pagevec_fill() takes it to get the page,
> after VM_LOCKED was cleared from vm_flags, so visible to try_to_unmap_one.
> 
> Kirill Shutemov points out that if the compiler chooses to implement a
> "vma->vm_flags &= VM_WHATEVER" or "vma->vm_flags |= VM_WHATEVER" operation
> with an intermediate store of unrelated bits set, since I'm here foregoing
> its usual protection by mmap_sem, try_to_unmap_one() might catch sight of
> a spurious VM_LOCKED in vm_flags, and make the wrong decision.  This does
> not appear to be an immediate problem, but we may want to define vm_flags
> accessors in future, to guard against such a possibility.
> 
> While we're here, make a related optimization in try_to_munmap_one(): if
> it's doing TTU_MUNLOCK, then there's no point at all in descending the
> page tables and getting the pt lock, unless the vma is VM_LOCKED.  Yes,
> that can change racily, but it can change racily even without the
> optimization: it's not critical.  Far better not to waste time here.
> 
> Stopped short of separating try_to_munlock_one() from try_to_munmap_one()
> on this occasion, but that's probably the sensible next step - with a
> rename, given that try_to_munlock()'s business is to try to set Mlocked.
> 
> Updated the unevictable-lru Documentation, to remove its reference to mmap
> semaphore, but found a few more updates needed in just that area.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
