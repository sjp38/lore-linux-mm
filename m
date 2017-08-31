Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 601C76B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 20:47:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p13so24072302qtp.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 17:47:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si6383098qte.3.2017.08.30.17.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 17:47:25 -0700 (PDT)
Date: Wed, 30 Aug 2017 20:47:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170831004719.GF9445@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
 <003685D9-4DA9-42DC-AF46-7A9F8A43E61F@gmail.com>
 <20170830212514.GI13559@redhat.com>
 <75825BFF-8ACC-4CAB-93EB-AD9673747518@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <75825BFF-8ACC-4CAB-93EB-AD9673747518@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, iommu <iommu@lists.linux-foundation.org>

On Wed, Aug 30, 2017 at 04:25:54PM -0700, Nadav Amit wrote:
> [cca??ing IOMMU people, which for some reason are not cca??d]
> 
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > On Wed, Aug 30, 2017 at 11:00:32AM -0700, Nadav Amit wrote:
> >> It is not trivial to flush TLBs (primary or secondary) without holding the
> >> page-table lock, and as we recently encountered this resulted in several
> >> bugs [1]. The main problem is that even if you perform the TLB flush
> >> immediately after the PT-lock is released, you cause a situation in which
> >> other threads may make decisions based on the updated PTE value, without
> >> being aware that a TLB flush is needed.
> >> 
> >> For example, we recently encountered a Linux bug when two threads run
> >> MADV_DONTNEED concurrently on the same address range [2]. One of the threads
> >> may update a PTE, setting it as non-present, and then deferring the TLB
> >> flush (for batching). As a result, however, it would cause the second
> >> thread, which also changes the PTEs to assume that the PTE is already
> >> non-present and TLB flush is not necessary. As a result the second core may
> >> still hold stale PTEs in its TLB following MADV_DONTNEED.
> > 
> > The source of those complex races that requires taking into account
> > nested tlb gather to solve it, originates from skipping primary MMU
> > tlb flushes depending on the value of the pagetables (as an
> > optimization).
> > 
> > For mmu_notifier_invalidate_range_end we always ignore the value of
> > the pagetables and mmu_notifier_invalidate_range_end always runs
> > unconditionally invalidating the secondary MMU for the whole range
> > under consideration. There are no optimizations that attempts to skip
> > mmu_notifier_invalidate_range_end depending on the pagetable value and
> > there's no TLB gather for secondary MMUs either. That is to keep it
> > simple of course.
> > 
> > As long as those mmu_notifier_invalidate_range_end stay unconditional,
> > I don't see how those races you linked, can be possibly relevant in
> > evaluating if ->invalidate_range (again only for iommuv2 and
> > intel-svm) has to run inside the PT lock or not.
> 
> Thanks for the clarifications. It now makes much more sense.
> 
> > 
> >> There is a swarm of such problems, and some are not too trivial. Deferring
> >> TLB flushes needs to be done in a very careful manner.
> > 
> > I agree it's not trivial, but I don't think any complexity comes from
> > above.
> > 
> > The only complexity is about, what if the page is copied to some other
> > page and replaced, because the copy is the only case where coherency
> > could be retained by the primary MMU. What if the primary MMU starts
> > working on the new page in between PT lock release and
> > mmu_notifier_invalidate_range_end, while the secondary MMU is stuck on
> > the old page? That is the only problem we deal with here, the copy to
> > other page and replace. Any other case that doesn't involve the copy
> > seems non coherent by definition, and you couldn't measure it.
> > 
> > I can't think of a scenario that requires the explicit
> > mmu_notifier_invalidate_range call before releasing the PT lock, at
> > least for try_to_unmap_one.
> > 
> > Could you think of a scenario where calling ->invalidate_range inside
> > mmu_notifier_invalidate_range_end post PT lock breaks iommuv2 or
> > intel-svm? Those two are the only ones requiring
> > ->invalidate_range calls, all other mmu notifier users are safe
> > without running mmu_notifier_invalidate_range_end under PT lock thanks
> > to mmu_notifier_invalidate_range_start blocking the secondary MMU.
> > 
> > Could you post a tangible scenario that invalidates my theory that
> > those mmu_notifier_invalidate_range calls inside PT lock would be
> > superfluous?
> > 
> > Some of the scenarios under consideration:
> > 
> > 1) migration entry -> migration_entry_wait -> page lock, plus
> >   migrate_pages taking the lock so it can't race with try_to_unmap
> >   from other places
> > 2) swap entry -> lookup_swap_cache -> page lock (page not really replaced)
> > 3) CoW -> do_wp_page -> page lock on old page
> > 4) KSM -> replace_page -> page lock on old page
> > 5) if the pte is zapped as in MADV_DONTNEED, no coherency possible so
> >   it's not measurable that we let the guest run a bit longer on the
> >   old page past PT lock release
> 
> For both CoW and KSM, the correctness is maintained by calling
> ptep_clear_flush_notify(). If you defer the secondary MMU invalidation
> (i.e., replacing ptep_clear_flush_notify() with ptep_clear_flush() ), you
> will cause memory corruption, and page-lock would not be enough.

Just to add up, the IOMMU have its own CPU page table walker and it can
walk the page table at any time (not the page table current to current
CPU, IOMMU have an array that match a PASID with a page table and device
request translation for a given virtual address against a PASID).

So this means the following can happen with ptep_clear_flush() only:

  CPU                          | IOMMU
                               | - walk page table populate tlb at addr A
  - clear pte at addr A        |
  - set new pte                |

Device is using old page and CPU new page :(

But with ptep_clear_flush_notify()

  CPU                          | IOMMU
                               | - walk page table populate tlb at addr A
  - clear pte at addr A        |
  - notify -> invalidate_range | > flush IOMMU/device tlb
  - set new pte                |

So now either the IOMMU see the empty pte and trigger a page fault (this is
if there is a racing IOMMU ATS right after the IOMMU/device tlb flush but
before setting the new pte) or it see the new pte. Either way both IOMMU
and CPU have a coherent view of what a virtual address points to.

> 
> BTW: I see some calls to ptep_clear_flush_notify() which are followed
> immediately after by set_pte_at_notify(). I do not understand why it makes
> sense, as both notifications end up doing the same thing - invalidating the
> secondary MMU. The set_pte_at_notify() in these cases can be changed to
> set_pte(). No?

Andrea explained to me the historical reasons set_pte_at_notify call the
change_pte callback and it was intended so that KVM could update the
secondary page table directly without having to fault. It is now a pointless
optimization as the call to range_start() happening in all the places before
any set_pte_at_notify() invalidate the secondary page table and thus will
lead to page fault for the vm. I have talk with Andrea on way to bring back
this optimization.

> > If you could post a multi CPU trace that shows how iommuv2 or
> > intel-svm are broken if ->invalidate_range is run inside
> > mmu_notifier_invalidate_range_end post PT lock in try_to_unmap_one it
> > would help.
> > 
> > Of course if we run mmu_notifier_invalidate_range inside PT lock and
> > we remove ->invalidate_range from mmu_notifier_invalidate_range_stop
> > all will be obviously safe, so we could just do it to avoid thinking
> > about the above, but the resulting code will be uglier and less
> > optimal (even when disarmed there will be dummy branches I wouldn't
> > love) and I currently can't see why it wouldn't be safe.
> > 
> > Replacing a page completely without any relation to the old page
> > content allows no coherency anyway, so even if it breaks you cannot
> > measure it because it's undefined.
> > 
> > If the page has a relation with the old contents and coherency has to
> > be provided for both primary MMU and secondary MMUs, this relation
> > between old and new page during the replacement, is enforced by some
> > other mean besides the PT lock, migration entry on locked old page
> > with migration_entry_wait and page lock in migrate_pages etc..
> 
> I think that basically you are correct, and assuming that you always
> notify/invalidate unconditionally any PTE range you read/write, you are
> safe. Yet, I want to have another look at the code. Anyhow, just deferring
> all the TLB flushes, including those of set_pte_at_notify(), is likely to
> result in errors.

Yes we need the following sequence for IOMMU:
 - clear pte
 - invalidate IOMMU/device TLB
 - set new pte

Otherwise the IOMMU page table walker can populate IOMMU/device tlb with
stall entry.

Note that this is not necessary for all the case. For try_to_unmap it
is fine for instance to move the IOMMU tlb shoot down after changing the
CPU page table as we are not pointing the pte to a different page. Either
we clear the pte or we set a swap entry and as long as the page that use
to be pointed by the pte is not free before the IOMMU tlb flush then we
are fine.

In fact i think the only case where we need the above sequence (clear,
flush secondary tlb, set new pte) is for COW. I think all other cases
we can get rid of invalidate_range() from inside the page table lock
and rely on invalidate_range_end() to call unconditionaly.

I might ponder on all this for more cleanup for mmu_notifier as i have
some optimization that i have line up for it but this is next cycle
material. For 4.13 i believe the current patchset is the safest way
to go.

JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
