Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF486B0038
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 11:47:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f66so14034882oib.1
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 08:47:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 19si974905oie.278.2017.10.21.08.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 08:47:09 -0700 (PDT)
Date: Sat, 21 Oct 2017 11:47:03 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm/mmu_notifier: avoid double notification when it
 is useless v2
Message-ID: <20171021154703.GA30458@redhat.com>
References: <20171017031003.7481-1-jglisse@redhat.com>
 <20171017031003.7481-2-jglisse@redhat.com>
 <20171019140426.21f51957@MiWiFi-R3-srv>
 <20171019032811.GC5246@redhat.com>
 <CAKTCnz=5GL_Bbu=kqywgW98uxpvYqCo2+KyzzGb67BmnKju3bw@mail.gmail.com>
 <20171019165823.GA3044@redhat.com>
 <1508565280.5662.6.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1508565280.5662.6.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Donnellan <andrew.donnellan@au1.ibm.com>, iommu@lists.linux-foundation.org, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-next <linux-next@vger.kernel.org>

On Sat, Oct 21, 2017 at 04:54:40PM +1100, Balbir Singh wrote:
> On Thu, 2017-10-19 at 12:58 -0400, Jerome Glisse wrote:
> > On Thu, Oct 19, 2017 at 09:53:11PM +1100, Balbir Singh wrote:
> > > On Thu, Oct 19, 2017 at 2:28 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > > > On Thu, Oct 19, 2017 at 02:04:26PM +1100, Balbir Singh wrote:
> > > > > On Mon, 16 Oct 2017 23:10:02 -0400
> > > > > jglisse@redhat.com wrote:
> > > > > 
> > > > > > From: Jerome Glisse <jglisse@redhat.com>
> > > > > > 
> > > > > > +           /*
> > > > > > +            * No need to call mmu_notifier_invalidate_range() as we are
> > > > > > +            * downgrading page table protection not changing it to point
> > > > > > +            * to a new page.
> > > > > > +            *
> > > > > > +            * See Documentation/vm/mmu_notifier.txt
> > > > > > +            */
> > > > > >             if (pmdp) {
> > > > > >  #ifdef CONFIG_FS_DAX_PMD
> > > > > >                     pmd_t pmd;
> > > > > > @@ -628,7 +635,6 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
> > > > > >                     pmd = pmd_wrprotect(pmd);
> > > > > >                     pmd = pmd_mkclean(pmd);
> > > > > >                     set_pmd_at(vma->vm_mm, address, pmdp, pmd);
> > > > > > -                   mmu_notifier_invalidate_range(vma->vm_mm, start, end);
> > > > > 
> > > > > Could the secondary TLB still see the mapping as dirty and propagate the dirty bit back?
> > > > 
> > > > I am assuming hardware does sane thing of setting the dirty bit only
> > > > when walking the CPU page table when device does a write fault ie
> > > > once the device get a write TLB entry the dirty is set by the IOMMU
> > > > when walking the page table before returning the lookup result to the
> > > > device and that it won't be set again latter (ie propagated back
> > > > latter).
> > > > 
> > > 
> > > The other possibility is that the hardware things the page is writable
> > > and already
> > > marked dirty. It allows writes and does not set the dirty bit?
> > 
> > I thought about this some more and the patch can not regress anything
> > that is not broken today. So if we assume that device can propagate
> > dirty bit because it can cache the write protection than all current
> > code is broken for two reasons:
> > 
> > First one is current code clear pte entry, build a new pte value with
> > write protection and update pte entry with new pte value. So any PASID/
> > ATS platform that allows device to cache the write bit and set dirty
> > bit anytime after that can race during that window and you would loose
> > the dirty bit of the device. That is not that bad as you are gonna
> > propagate the dirty bit to the struct page.
> 
> But they stay consistent with the notifiers, so from the OS perspective
> it notifies of any PTE changes as they happen. When the ATS platform sees
> invalidation, it invalidates it's PTE's as well.
> 
> I was speaking of the case where the ATS platform could assume it has
> write access and has not seen any invalidation, the OS could return
> back to user space or the caller with write bit clear, but the ATS
> platform could still do a write since it's not seen the invalidation.

I understood what you said and what is above apply. I am removing only
one of the invalidation not both. So with that patch the invalidation
is delayed after the page table lock drop but before dax/page_mkclean
returns. Hence any further activity will be read only on any device too
once we exit those functions.

The only difference is the window during which device can report dirty
pte. Before that patch the 2 "~bogus~" window were small:
  First window between pmd/pte_get_clear_flush and set_pte/pmd
  Second window between set_pte/pmd and mmu_notifier_invalidate_range

The first window stay the same, the second window is bigger, potentialy
lot bigger if thread is prempted before mmu_notifier_invalidate_range_end

But that is fine as in that case the page is reported as dirty and thus
we are not missing anything and the kernel code does not care about
seeing read only pte mark as dirty.

> 
> > 
> > Second one is if the dirty bit is propagated back to the new write
> > protected pte. Quick look at code it seems that when we zap pte or
> > or mkclean we don't check that the pte has write permission but only
> > care about the dirty bit. So it should not have any bad consequence.
> > 
> > After this patch only the second window is bigger and thus more likely
> > to happen. But nothing sinister should happen from that.
> > 
> > 
> > > 
> > > > I should probably have spell that out and maybe some of the ATS/PASID
> > > > implementer did not do that.
> > > > 
> > > > > 
> > > > > >  unlock_pmd:
> > > > > >                     spin_unlock(ptl);
> > > > > >  #endif
> > > > > > @@ -643,7 +649,6 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
> > > > > >                     pte = pte_wrprotect(pte);
> > > > > >                     pte = pte_mkclean(pte);
> > > > > >                     set_pte_at(vma->vm_mm, address, ptep, pte);
> > > > > > -                   mmu_notifier_invalidate_range(vma->vm_mm, start, end);
> > > > > 
> > > > > Ditto
> > > > > 
> > > > > >  unlock_pte:
> > > > > >                     pte_unmap_unlock(ptep, ptl);
> > > > > >             }
> > > > > > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> > > > > > index 6866e8126982..49c925c96b8a 100644
> > > > > > --- a/include/linux/mmu_notifier.h
> > > > > > +++ b/include/linux/mmu_notifier.h
> > > > > > @@ -155,7 +155,8 @@ struct mmu_notifier_ops {
> > > > > >      * shared page-tables, it not necessary to implement the
> > > > > >      * invalidate_range_start()/end() notifiers, as
> > > > > >      * invalidate_range() alread catches the points in time when an
> > > > > > -    * external TLB range needs to be flushed.
> > > > > > +    * external TLB range needs to be flushed. For more in depth
> > > > > > +    * discussion on this see Documentation/vm/mmu_notifier.txt
> > > > > >      *
> > > > > >      * The invalidate_range() function is called under the ptl
> > > > > >      * spin-lock and not allowed to sleep.
> > > > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > > > index c037d3d34950..ff5bc647b51d 100644
> > > > > > --- a/mm/huge_memory.c
> > > > > > +++ b/mm/huge_memory.c
> > > > > > @@ -1186,8 +1186,15 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
> > > > > >             goto out_free_pages;
> > > > > >     VM_BUG_ON_PAGE(!PageHead(page), page);
> > > > > > 
> > > > > > +   /*
> > > > > > +    * Leave pmd empty until pte is filled note we must notify here as
> > > > > > +    * concurrent CPU thread might write to new page before the call to
> > > > > > +    * mmu_notifier_invalidate_range_end() happens which can lead to a
> > > > > > +    * device seeing memory write in different order than CPU.
> > > > > > +    *
> > > > > > +    * See Documentation/vm/mmu_notifier.txt
> > > > > > +    */
> > > > > >     pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
> > > > > > -   /* leave pmd empty until pte is filled */
> > > > > > 
> > > > > >     pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, vmf->pmd);
> > > > > >     pmd_populate(vma->vm_mm, &_pmd, pgtable);
> > > > > > @@ -2026,8 +2033,15 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> > > > > >     pmd_t _pmd;
> > > > > >     int i;
> > > > > > 
> > > > > > -   /* leave pmd empty until pte is filled */
> > > > > > -   pmdp_huge_clear_flush_notify(vma, haddr, pmd);
> > > > > > +   /*
> > > > > > +    * Leave pmd empty until pte is filled note that it is fine to delay
> > > > > > +    * notification until mmu_notifier_invalidate_range_end() as we are
> > > > > > +    * replacing a zero pmd write protected page with a zero pte write
> > > > > > +    * protected page.
> > > > > > +    *
> > > > > > +    * See Documentation/vm/mmu_notifier.txt
> > > > > > +    */
> > > > > > +   pmdp_huge_clear_flush(vma, haddr, pmd);
> > > > > 
> > > > > Shouldn't the secondary TLB know if the page size changed?
> > > > 
> > > > It should not matter, we are talking virtual to physical on behalf
> > > > of a device against a process address space. So the hardware should
> > > > not care about the page size.
> > > > 
> > > 
> > > Does that not indicate how much the device can access? Could it try
> > > to access more than what is mapped?
> > 
> > Assuming device has huge TLB and 2MB huge page with 4K small page.
> > You are going from one 1 TLB covering a 2MB zero page to 512 TLB
> > each covering 4K. Both case is read only and both case are pointing
> > to same data (ie zero).
> > 
> > It is fine to delay the TLB invalidate on the device to the call of
> > mmu_notifier_invalidate_range_end(). The device will keep using the
> > huge TLB for a little longer but both CPU and device are looking at
> > same data.
> > 
> > Now if there is a racing thread that replace one of the 512 zeor page
> > after the split but before mmu_notifier_invalidate_range_end() that
> > code path would call mmu_notifier_invalidate_range() before changing
> > the pte to point to something else. Which should shoot down the device
> > TLB (it would be a serious device bug if this did not work).
> 
> OK.. This seems reasonable, but I'd really like to see if it can be
> tested

Well hard to test, many factors first each device might react differently.
Device that only store TLB at 4k granularity are fine. Clever device that
can store TLB for 4k, 2M, ... can ignore an invalidation that is smaller
than their TLB entry ie getting a 4K invalidation would not invalidate a
2MB TLB entry in the device. I consider this as buggy. I will go look at
the PCIE ATS specification one more time and see if there is any wording
related that. I might bring up a question to the PCIE standard body if not.

Second factor is that it is a race between split zero and a write fault.
I can probably do a crappy patch that msleep if split happens against a
given mm to increase the race window. But i would be testing against one
device (right now i can only access AMD IOMMUv2 devices with discret ATS
GPU)


> 
> > 
> > 
> > > 
> > > > Moreover if any of the new 512 (assuming 2MB huge and 4K pages) zero
> > > > 4K pages is replace by something new then a device TLB shootdown will
> > > > happen before the new page is set.
> > > > 
> > > > Only issue i can think of is if the IOMMU TLB (if there is one) or
> > > > the device TLB (you do expect that there is one) does not invalidate
> > > > TLB entry if the TLB shootdown is smaller than the TLB entry. That
> > > > would be idiotic but yes i know hardware bug.
> > > > 
> > > > 
> > > > > 
> > > > > > 
> > > > > >     pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> > > > > >     pmd_populate(mm, &_pmd, pgtable);
> > > > > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > > > > index 1768efa4c501..63a63f1b536c 100644
> > > > > > --- a/mm/hugetlb.c
> > > > > > +++ b/mm/hugetlb.c
> > > > > > @@ -3254,9 +3254,14 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> > > > > >                     set_huge_swap_pte_at(dst, addr, dst_pte, entry, sz);
> > > > > >             } else {
> > > > > >                     if (cow) {
> > > > > > +                           /*
> > > > > > +                            * No need to notify as we are downgrading page
> > > > > > +                            * table protection not changing it to point
> > > > > > +                            * to a new page.
> > > > > > +                            *
> > > > > > +                            * See Documentation/vm/mmu_notifier.txt
> > > > > > +                            */
> > > > > >                             huge_ptep_set_wrprotect(src, addr, src_pte);
> > > > > 
> > > > > OK.. so we could get write faults on write accesses from the device.
> > > > > 
> > > > > > -                           mmu_notifier_invalidate_range(src, mmun_start,
> > > > > > -                                                              mmun_end);
> > > > > >                     }
> > > > > >                     entry = huge_ptep_get(src_pte);
> > > > > >                     ptepage = pte_page(entry);
> > > > > > @@ -4288,7 +4293,12 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> > > > > >      * and that page table be reused and filled with junk.
> > > > > >      */
> > > > > >     flush_hugetlb_tlb_range(vma, start, end);
> > > > > > -   mmu_notifier_invalidate_range(mm, start, end);
> > > > > > +   /*
> > > > > > +    * No need to call mmu_notifier_invalidate_range() we are downgrading
> > > > > > +    * page table protection not changing it to point to a new page.
> > > > > > +    *
> > > > > > +    * See Documentation/vm/mmu_notifier.txt
> > > > > > +    */
> > > > > >     i_mmap_unlock_write(vma->vm_file->f_mapping);
> > > > > >     mmu_notifier_invalidate_range_end(mm, start, end);
> > > > > > 
> > > > > > diff --git a/mm/ksm.c b/mm/ksm.c
> > > > > > index 6cb60f46cce5..be8f4576f842 100644
> > > > > > --- a/mm/ksm.c
> > > > > > +++ b/mm/ksm.c
> > > > > > @@ -1052,8 +1052,13 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
> > > > > >              * So we clear the pte and flush the tlb before the check
> > > > > >              * this assure us that no O_DIRECT can happen after the check
> > > > > >              * or in the middle of the check.
> > > > > > +            *
> > > > > > +            * No need to notify as we are downgrading page table to read
> > > > > > +            * only not changing it to point to a new page.
> > > > > > +            *
> > > > > > +            * See Documentation/vm/mmu_notifier.txt
> > > > > >              */
> > > > > > -           entry = ptep_clear_flush_notify(vma, pvmw.address, pvmw.pte);
> > > > > > +           entry = ptep_clear_flush(vma, pvmw.address, pvmw.pte);
> > > > > >             /*
> > > > > >              * Check that no O_DIRECT or similar I/O is in progress on the
> > > > > >              * page
> > > > > > @@ -1136,7 +1141,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
> > > > > >     }
> > > > > > 
> > > > > >     flush_cache_page(vma, addr, pte_pfn(*ptep));
> > > > > > -   ptep_clear_flush_notify(vma, addr, ptep);
> > > > > > +   /*
> > > > > > +    * No need to notify as we are replacing a read only page with another
> > > > > > +    * read only page with the same content.
> > > > > > +    *
> > > > > > +    * See Documentation/vm/mmu_notifier.txt
> > > > > > +    */
> > > > > > +   ptep_clear_flush(vma, addr, ptep);
> > > > > >     set_pte_at_notify(mm, addr, ptep, newpte);
> > > > > > 
> > > > > >     page_remove_rmap(page, false);
> > > > > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > > > > index 061826278520..6b5a0f219ac0 100644
> > > > > > --- a/mm/rmap.c
> > > > > > +++ b/mm/rmap.c
> > > > > > @@ -937,10 +937,15 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
> > > > > >  #endif
> > > > > >             }
> > > > > > 
> > > > > > -           if (ret) {
> > > > > > -                   mmu_notifier_invalidate_range(vma->vm_mm, cstart, cend);
> > > > > > +           /*
> > > > > > +            * No need to call mmu_notifier_invalidate_range() as we are
> > > > > > +            * downgrading page table protection not changing it to point
> > > > > > +            * to a new page.
> > > > > > +            *
> > > > > > +            * See Documentation/vm/mmu_notifier.txt
> > > > > > +            */
> > > > > > +           if (ret)
> > > > > >                     (*cleaned)++;
> > > > > > -           }
> > > > > >     }
> > > > > > 
> > > > > >     mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> > > > > > @@ -1424,6 +1429,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > > > >                     if (pte_soft_dirty(pteval))
> > > > > >                             swp_pte = pte_swp_mksoft_dirty(swp_pte);
> > > > > >                     set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
> > > > > > +                   /*
> > > > > > +                    * No need to invalidate here it will synchronize on
> > > > > > +                    * against the special swap migration pte.
> > > > > > +                    */
> > > > > >                     goto discard;
> > > > > >             }
> > > > > > 
> > > > > > @@ -1481,6 +1490,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > > > >                      * will take care of the rest.
> > > > > >                      */
> > > > > >                     dec_mm_counter(mm, mm_counter(page));
> > > > > > +                   /* We have to invalidate as we cleared the pte */
> > > > > > +                   mmu_notifier_invalidate_range(mm, address,
> > > > > > +                                                 address + PAGE_SIZE);
> > > > > >             } else if (IS_ENABLED(CONFIG_MIGRATION) &&
> > > > > >                             (flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
> > > > > >                     swp_entry_t entry;
> > > > > > @@ -1496,6 +1508,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > > > >                     if (pte_soft_dirty(pteval))
> > > > > >                             swp_pte = pte_swp_mksoft_dirty(swp_pte);
> > > > > >                     set_pte_at(mm, address, pvmw.pte, swp_pte);
> > > > > > +                   /*
> > > > > > +                    * No need to invalidate here it will synchronize on
> > > > > > +                    * against the special swap migration pte.
> > > > > > +                    */
> > > > > >             } else if (PageAnon(page)) {
> > > > > >                     swp_entry_t entry = { .val = page_private(subpage) };
> > > > > >                     pte_t swp_pte;
> > > > > > @@ -1507,6 +1523,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > > > >                             WARN_ON_ONCE(1);
> > > > > >                             ret = false;
> > > > > >                             /* We have to invalidate as we cleared the pte */
> > > > > > +                           mmu_notifier_invalidate_range(mm, address,
> > > > > > +                                                   address + PAGE_SIZE);
> > > > > >                             page_vma_mapped_walk_done(&pvmw);
> > > > > >                             break;
> > > > > >                     }
> > > > > > @@ -1514,6 +1532,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > > > >                     /* MADV_FREE page check */
> > > > > >                     if (!PageSwapBacked(page)) {
> > > > > >                             if (!PageDirty(page)) {
> > > > > > +                                   /* Invalidate as we cleared the pte */
> > > > > > +                                   mmu_notifier_invalidate_range(mm,
> > > > > > +                                           address, address + PAGE_SIZE);
> > > > > >                                     dec_mm_counter(mm, MM_ANONPAGES);
> > > > > >                                     goto discard;
> > > > > >                             }
> > > > > > @@ -1547,13 +1568,39 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > > > >                     if (pte_soft_dirty(pteval))
> > > > > >                             swp_pte = pte_swp_mksoft_dirty(swp_pte);
> > > > > >                     set_pte_at(mm, address, pvmw.pte, swp_pte);
> > > > > > -           } else
> > > > > > +                   /* Invalidate as we cleared the pte */
> > > > > > +                   mmu_notifier_invalidate_range(mm, address,
> > > > > > +                                                 address + PAGE_SIZE);
> > > > > > +           } else {
> > > > > > +                   /*
> > > > > > +                    * We should not need to notify here as we reach this
> > > > > > +                    * case only from freeze_page() itself only call from
> > > > > > +                    * split_huge_page_to_list() so everything below must
> > > > > > +                    * be true:
> > > > > > +                    *   - page is not anonymous
> > > > > > +                    *   - page is locked
> > > > > > +                    *
> > > > > > +                    * So as it is a locked file back page thus it can not
> > > > > > +                    * be remove from the page cache and replace by a new
> > > > > > +                    * page before mmu_notifier_invalidate_range_end so no
> > > > > > +                    * concurrent thread might update its page table to
> > > > > > +                    * point at new page while a device still is using this
> > > > > > +                    * page.
> > > > > > +                    *
> > > > > > +                    * See Documentation/vm/mmu_notifier.txt
> > > > > > +                    */
> > > > > >                     dec_mm_counter(mm, mm_counter_file(page));
> > > > > > +           }
> > > > > >  discard:
> > > > > > +           /*
> > > > > > +            * No need to call mmu_notifier_invalidate_range() it has be
> > > > > > +            * done above for all cases requiring it to happen under page
> > > > > > +            * table lock before mmu_notifier_invalidate_range_end()
> > > > > > +            *
> > > > > > +            * See Documentation/vm/mmu_notifier.txt
> > > > > > +            */
> > > > > >             page_remove_rmap(subpage, PageHuge(page));
> > > > > >             put_page(page);
> > > > > > -           mmu_notifier_invalidate_range(mm, address,
> > > > > > -                                         address + PAGE_SIZE);
> > > > > >     }
> > > > > > 
> > > > > >     mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> > > > > 
> > > > > Looking at the patchset, I understand the efficiency, but I am concerned
> > > > > with correctness.
> > > > 
> > > > I am fine in holding this off from reaching Linus but only way to flush this
> > > > issues out if any is to have this patch in linux-next or somewhere were they
> > > > get a chance of being tested.
> > > > 
> > > 
> > > Yep, I would like to see some additional testing around npu and get Alistair
> > > Popple to comment as well
> > 
> > I think this patch is fine. The only one race window that it might make
> > bigger should have no bad consequences.
> > 
> > > 
> > > > Note that the second patch is always safe. I agree that this one might
> > > > not be if hardware implementation is idiotic (well that would be my
> > > > opinion and any opinion/point of view can be challenge :))
> > > 
> > > 
> > > You mean the only_end variant that avoids shootdown after pmd/pte changes
> > > that avoid the _start/_end and have just the only_end variant? That seemed
> > > reasonable to me, but I've not tested it or evaluated it in depth
> > 
> > Yes, patch 2/2 in this serie is definitly fine. It invalidate the device
> > TLB right after clearing pte entry and avoid latter unecessary invalidation
> > of same TLB.
> > 
> > Jerome
> 
> Balbir Singh.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
