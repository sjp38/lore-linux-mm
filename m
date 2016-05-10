Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3718E6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 06:01:27 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id s68so14962308qkb.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 03:01:27 -0700 (PDT)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id u35si868719qge.42.2016.05.10.03.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 03:01:26 -0700 (PDT)
Received: by mail-qk0-x231.google.com with SMTP id n62so3035508qkc.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 03:01:26 -0700 (PDT)
Date: Tue, 10 May 2016 12:01:16 +0200
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
Message-ID: <20160510100104.GA18820@gmail.com>
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
 <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Morey Chaisemartin <devel@morey-chaisemartin.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 10, 2016 at 09:04:36AM +0200, Nicolas Morey Chaisemartin wrote:
> Le 05/03/2016 a 12:11 PM, Jerome Glisse a ecrit :
> > On Mon, May 02, 2016 at 09:04:02PM -0700, Hugh Dickins wrote:
> >> On Fri, 29 Apr 2016, Nicolas Morey Chaisemartin wrote:
> >>
> >>> Hi everyone,
> >>>
> >>> This is a repost from a different address as it seems the previous one ended in Gmail junk due to a domain error..
> >> linux-kernel is a very high volume list which few are reading:
> >> that also will account for your lack of response so far
> >> (apart from the indefatigable Alan).
> >>
> >> I've added linux-mm, and some people from another thread regarding
> >> THP and get_user_pages() pins which has been discussed in recent days.
> >>
> >> Make no mistake, the issue you're raising here is definitely not the
> >> same as that one (which is specifically about the new THP refcounting
> >> in v4.5+, whereas you're reporting a problem you've seen in both a
> >> v3.10-based kernel and in v4.5).  But I think their heads are in
> >> gear, much more so than mine, and likely to spot something.
> >>
> >>> I added more info found while blindly debugging the issue.
> >>>
> >>> Short version:
> >>> I'm having an issue with direct DMA transfer from a device to host memory.
> >>> It seems some of the data is not transferring to the appropriate page.
> >>>
> >>> Some more details:
> >>> I'm debugging a home made PCI driver for our board (Kalray), attached to a x86_64 host running centos7 (3.10.0-327.el7.x86_64)
> >>>
> >>> In the current case, a userland application transfers back and forth data through read/write operations on a file.
> >>> On the kernel side, it triggers DMA transfers through the PCI to/from our board memory.
> >>>
> >>> We followed what pretty much all docs said about direct I/O to user buffers:
> >>>
> >>> 1) get_user_pages() (in the current case, it's at most 16 pages at once)
> >>> 2) convert to a scatterlist
> >>> 3) pci_map_sg
> >>> 4) eventually coalesce sg (Intel IOMMU is enabled, so it's usually possible)
> >>> 4) A lot of DMA engine handling code, using the dmaengine layer and virt-dma
> >>> 5) wait for transfer complete, in the mean time, go back to (1) to schedule more work, if any
> >>> 6) pci_unmap_sg
> >>> 7) for read (card2host) transfer, set_page_dirty_lock
> >>> 8) page_cache_release
> >>>
> >>> In 99,9999% it works perfectly.
> >>> However, I have one userland application where a few pages are not written by a read (card2host) transfer.
> >>> The buffer is memset them to a different value so I can check that nothing has overwritten them.
> >>>
> >>> I know (PCI protocol analyser) that the data left our board for the "right" address (the one set in the sg by pci_map_sg).
> >>> I tried reading the data between the pci_unmap_sg and the set_page_dirty, using
> >>>         uint32_t *addr = page_address(trans->pages[0]);
> >>>         dev_warn(&pdata->pdev->dev, "val = %x\n", *addr);
> >>> and it has the expected value.
> >>> But if I try to copy_from_user (using the address coming from userland, the one passed to get_user_pages), the data has not been written and I see the memset value.
> >>>
> >>> New infos:
> >>>
> >>> The issue happens with IOMMU on or off.
> >>> I compiled a kernel with DMA_API_DEBUG enabled and got no warnings or errors.
> >>>
> >>> I digged a little bit deeper with my very small understanding of linux mm and I discovered that:
> >>>  * we are using transparent huge pages
> >>>  * the page 'not transferred' are the last few of a huge page
> >>> More precisely:
> >>> - We have several transfer in flight from the same user buffer
> >>> - Each transfer is 16 pages long
> >>> - At one point in time, we start transferring from another huge page (transfers are still in flight from the previous one)
> >>> - When a transfer from the previous huge page completes, I dumped at the mapcount of the pages from the previous transfers,
> >>>   they are all to 0. The pages are still mapped to dma at this point.
> >>> - A get_user_page to the address of the completed transfer returns return a different struct page * then the on I had.
> >>> But this is before I have unmapped/put_page them back. From my understanding this should not have happened.
> >>>
> >>> I tried the same code with a kernel 4.5 and encountered the same issue
> >>>
> >>> Disabling transparent huge pages makes the issue disapear
> >>>
> >>> Thanks in advance
> >> It does look to me as if pages are being migrated, despite being pinned
> >> by get_user_pages(): and that would be wrong.  Originally I intended
> >> to suggest that THP is probably merely the cause of compaction, with
> >> compaction causing the page migration.  But you posted very interesting
> >> details in an earlier mail on 27th April from <nmorey@kalray.eu>:
> >>
> >>> I ran some more tests:
> >>>
> >>> * Test is OK if transparent huge tlb are disabled
> >>>
> >>> * For all the page where data are not transfered, and only those pages, a call to get_user_page(user vaddr) just before dma_unmap_sg returns a different page from the original one.
> >>> [436477.927279] mppa 0000:03:00.0: org_page= ffffea0009f60080 cur page = ffffea00074e0080
> >>> [436477.927298] page:ffffea0009f60080 count:0 mapcount:1 mapping:          (null) index:0x2
> >>> [436477.927314] page flags: 0x2fffff00008000(tail)
> >>> [436477.927354] page dumped because: org_page
> >>> [436477.927369] page:ffffea00074e0080 count:0 mapcount:1 mapping:          (null) index:0x2
> >>> [436477.927382] page flags: 0x2fffff00008000(tail)
> >>> [436477.927421] page dumped because: cur_page
> >>>
> >>> I'm not sure what to make of this...
> >> That (on the older kernel I think) seems clearly to show that a THP
> >> itself has been migrated: which makes me suspect NUMA migration of
> >> mispaced THPs - migrate_misplaced_transhuge_page().  I'd hoped to
> >> find something obviously wrong there, but haven't quite managed
> >> to bring my brain fully to bear on it, and hope the others Cc'ed
> >> will do so more quickly (or spot the error of your ways instead).
> >>
> >> I do find it suspect, how the migrate_page_copy() is done rather
> >> early, while the old page is still mapped in the pagetable.  And
> >> odd how it inserts the new pmd for a moment, before checking old
> >> page_count and backing out.  But I don't see how either of those
> >> would cause the trouble you see, where the migration goes ahead.
> > So i do not think there is a bug migrate_misplaced_transhuge_page()
> > but i think something is wrong in it see attached patch. I still
> > want to convince myself i am not missing anything before posting
> > that one.
> >
> >
> > Now about this bug, dumb question but do you do get_user_pages with
> > write = 1 because if your device is writting to the page then you
> > must set write to 1.
> >
> > get_user_pages(vaddr, nrpages, 1, 0|1, pages, NULL|vmas);
> >
> >
> > Cheers,
> > Jerome
> >
> > 0001-mm-numa-thp-fix-assumptions-of-migrate_misplaced_tra.patch
> >
> >
> > From 9ded2a5da75a5e736fb36a2c4e2511d9516ecc37 Mon Sep 17 00:00:00 2001
> > From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
> > Date: Tue, 3 May 2016 11:53:24 +0200
> > Subject: [PATCH] mm/numa/thp: fix assumptions of
> >  migrate_misplaced_transhuge_page()
> > MIME-Version: 1.0
> > Content-Type: text/plain; charset=UTF-8
> > Content-Transfer-Encoding: 8bit
> >
> > Fix assumptions in migrate_misplaced_transhuge_page() which is only
> > call by do_huge_pmd_numa_page() itself only call by __handle_mm_fault()
> > for pmd with PROT_NONE. This means that if the pmd stays the same
> > then there can be no concurrent get_user_pages / get_user_pages_fast
> > (GUP/GUP_fast). More over because migrate_misplaced_transhuge_page()
> > only do something is page is map once then there can be no GUP from
> > a different process. Finaly, holding the pmd lock assure us that no
> > other part of the kernel will take an extre reference on the page.
> >
> > In the end this means that the failure code path should never be
> > taken unless something is horribly wrong, so convert it to BUG_ON().
> >
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  mm/migrate.c | 31 +++++++++++++++++++++----------
> >  1 file changed, 21 insertions(+), 10 deletions(-)
> >
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 6c822a7..6315aac 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1757,6 +1757,14 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> >  	pmd_t orig_entry;
> >  
> >  	/*
> > +	 * What we do here is only valid if pmd_protnone(entry) is true and it
> > +	 * is map in only one vma numamigrate_isolate_page() takes care of that
> > +	 * check.
> > +	 */
> > +	if (!pmd_protnone(entry))
> > +		goto out_unlock;
> > +
> > +	/*
> >  	 * Rate-limit the amount of data that is being migrated to a node.
> >  	 * Optimal placement is no good if the memory bus is saturated and
> >  	 * all the time is being spent migrating!
> > @@ -1797,7 +1805,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> >  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> >  	ptl = pmd_lock(mm, pmd);
> >  	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
> > -fail_putback:
> >  		spin_unlock(ptl);
> >  		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> >  
> > @@ -1819,7 +1826,12 @@ fail_putback:
> >  		goto out_unlock;
> >  	}
> >  
> > -	orig_entry = *pmd;
> > +	/*
> > +	 * We are holding the lock so no one can set a new pmd and original pmd
> > +	 * is PROT_NONE thus no one can get_user_pages or get_user_pages_fast
> > +	 * (GUP or GUP_fast) from this point on we can not fail.
> > +	 */
> > +	orig_entry = entry;
> >  	entry = mk_pmd(new_page, vma->vm_page_prot);
> >  	entry = pmd_mkhuge(entry);
> >  	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> > @@ -1837,14 +1849,13 @@ fail_putback:
> >  	set_pmd_at(mm, mmun_start, pmd, entry);
> >  	update_mmu_cache_pmd(vma, address, &entry);
> >  
> > -	if (page_count(page) != 2) {
> > -		set_pmd_at(mm, mmun_start, pmd, orig_entry);
> > -		flush_pmd_tlb_range(vma, mmun_start, mmun_end);
> > -		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
> > -		update_mmu_cache_pmd(vma, address, &entry);
> > -		page_remove_rmap(new_page, true);
> > -		goto fail_putback;
> > -	}
> > +	/* As said above no one can get reference on the old page nor through
> > +	 * get_user_pages or get_user_pages_fast (GUP/GUP_fast) or through
> > +	 * any other means. To get reference on huge page you need to hold
> > +	 * pmd_lock and we are already holding that lock here and the page
> > +	 * is only mapped once.
> > +	 */
> > +	BUG_ON(page_count(page) != 2);
> >  
> >  	mlock_migrate_page(new_page, page);
> >  	page_remove_rmap(page, true);
> 
> Hi,
> 
> I backported the patch to 3.10 (had to copy paste pmd_protnone defitinition from 4.5) and it's working !
> I'll open a ticket in Redhat tracker to try and get this fixed in RHEL7.
> 
> I have a dumb question though: how can we end up in numa/misplaced memory code on a single socket system?
> 

This patch is not a fix, do you see bug message in kernel log ? Because if
you do that it means we have a bigger issue.

You did not answer one of my previous question, do you set get_user_pages
with write = 1 as a paremeter ?

Also it would be a lot easier if you were testing with lastest 4.6 or 4.5
not RHEL kernel as they are far appart and what might looks like same issue
on both might be totaly different bugs.

If you only really care about RHEL kernel then open a bug with Red Hat and
you can add me in bug-cc <jglisse@redhat.com>

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
