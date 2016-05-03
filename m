Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60D686B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 06:12:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x7so31598367qkd.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 03:12:06 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id m1si1389677qkd.271.2016.05.03.03.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 03:12:04 -0700 (PDT)
Received: by mail-qg0-x22b.google.com with SMTP id w36so5981347qge.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 03:12:04 -0700 (PDT)
Date: Tue, 3 May 2016 12:11:54 +0200
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
Message-ID: <20160503101153.GA7241@gmail.com>
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nicolas Morey Chaisemartin <devel@morey-chaisemartin.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Mon, May 02, 2016 at 09:04:02PM -0700, Hugh Dickins wrote:
> On Fri, 29 Apr 2016, Nicolas Morey Chaisemartin wrote:
> 
> > Hi everyone,
> > 
> > This is a repost from a different address as it seems the previous one ended in Gmail junk due to a domain error..
> 
> linux-kernel is a very high volume list which few are reading:
> that also will account for your lack of response so far
> (apart from the indefatigable Alan).
> 
> I've added linux-mm, and some people from another thread regarding
> THP and get_user_pages() pins which has been discussed in recent days.
> 
> Make no mistake, the issue you're raising here is definitely not the
> same as that one (which is specifically about the new THP refcounting
> in v4.5+, whereas you're reporting a problem you've seen in both a
> v3.10-based kernel and in v4.5).  But I think their heads are in
> gear, much more so than mine, and likely to spot something.
> 
> > I added more info found while blindly debugging the issue.
> > 
> > Short version:
> > I'm having an issue with direct DMA transfer from a device to host memory.
> > It seems some of the data is not transferring to the appropriate page.
> > 
> > Some more details:
> > I'm debugging a home made PCI driver for our board (Kalray), attached to a x86_64 host running centos7 (3.10.0-327.el7.x86_64)
> > 
> > In the current case, a userland application transfers back and forth data through read/write operations on a file.
> > On the kernel side, it triggers DMA transfers through the PCI to/from our board memory.
> > 
> > We followed what pretty much all docs said about direct I/O to user buffers:
> > 
> > 1) get_user_pages() (in the current case, it's at most 16 pages at once)
> > 2) convert to a scatterlist
> > 3) pci_map_sg
> > 4) eventually coalesce sg (Intel IOMMU is enabled, so it's usually possible)
> > 4) A lot of DMA engine handling code, using the dmaengine layer and virt-dma
> > 5) wait for transfer complete, in the mean time, go back to (1) to schedule more work, if any
> > 6) pci_unmap_sg
> > 7) for read (card2host) transfer, set_page_dirty_lock
> > 8) page_cache_release
> > 
> > In 99,9999% it works perfectly.
> > However, I have one userland application where a few pages are not written by a read (card2host) transfer.
> > The buffer is memset them to a different value so I can check that nothing has overwritten them.
> > 
> > I know (PCI protocol analyser) that the data left our board for the "right" address (the one set in the sg by pci_map_sg).
> > I tried reading the data between the pci_unmap_sg and the set_page_dirty, using
> >         uint32_t *addr = page_address(trans->pages[0]);
> >         dev_warn(&pdata->pdev->dev, "val = %x\n", *addr);
> > and it has the expected value.
> > But if I try to copy_from_user (using the address coming from userland, the one passed to get_user_pages), the data has not been written and I see the memset value.
> > 
> > New infos:
> > 
> > The issue happens with IOMMU on or off.
> > I compiled a kernel with DMA_API_DEBUG enabled and got no warnings or errors.
> > 
> > I digged a little bit deeper with my very small understanding of linux mm and I discovered that:
> >  * we are using transparent huge pages
> >  * the page 'not transferred' are the last few of a huge page
> > More precisely:
> > - We have several transfer in flight from the same user buffer
> > - Each transfer is 16 pages long
> > - At one point in time, we start transferring from another huge page (transfers are still in flight from the previous one)
> > - When a transfer from the previous huge page completes, I dumped at the mapcount of the pages from the previous transfers,
> >   they are all to 0. The pages are still mapped to dma at this point.
> > - A get_user_page to the address of the completed transfer returns return a different struct page * then the on I had.
> > But this is before I have unmapped/put_page them back. From my understanding this should not have happened.
> > 
> > I tried the same code with a kernel 4.5 and encountered the same issue
> > 
> > Disabling transparent huge pages makes the issue disapear
> > 
> > Thanks in advance
> 
> It does look to me as if pages are being migrated, despite being pinned
> by get_user_pages(): and that would be wrong.  Originally I intended
> to suggest that THP is probably merely the cause of compaction, with
> compaction causing the page migration.  But you posted very interesting
> details in an earlier mail on 27th April from <nmorey@kalray.eu>:
> 
> > I ran some more tests:
> > 
> > * Test is OK if transparent huge tlb are disabled
> > 
> > * For all the page where data are not transfered, and only those pages, a call to get_user_page(user vaddr) just before dma_unmap_sg returns a different page from the original one.
> > [436477.927279] mppa 0000:03:00.0: org_page= ffffea0009f60080 cur page = ffffea00074e0080
> > [436477.927298] page:ffffea0009f60080 count:0 mapcount:1 mapping:          (null) index:0x2
> > [436477.927314] page flags: 0x2fffff00008000(tail)
> > [436477.927354] page dumped because: org_page
> > [436477.927369] page:ffffea00074e0080 count:0 mapcount:1 mapping:          (null) index:0x2
> > [436477.927382] page flags: 0x2fffff00008000(tail)
> > [436477.927421] page dumped because: cur_page
> > 
> > I'm not sure what to make of this...
> 
> That (on the older kernel I think) seems clearly to show that a THP
> itself has been migrated: which makes me suspect NUMA migration of
> mispaced THPs - migrate_misplaced_transhuge_page().  I'd hoped to
> find something obviously wrong there, but haven't quite managed
> to bring my brain fully to bear on it, and hope the others Cc'ed
> will do so more quickly (or spot the error of your ways instead).
> 
> I do find it suspect, how the migrate_page_copy() is done rather
> early, while the old page is still mapped in the pagetable.  And
> odd how it inserts the new pmd for a moment, before checking old
> page_count and backing out.  But I don't see how either of those
> would cause the trouble you see, where the migration goes ahead.

So i do not think there is a bug migrate_misplaced_transhuge_page()
but i think something is wrong in it see attached patch. I still
want to convince myself i am not missing anything before posting
that one.


Now about this bug, dumb question but do you do get_user_pages with
write = 1 because if your device is writting to the page then you
must set write to 1.

get_user_pages(vaddr, nrpages, 1, 0|1, pages, NULL|vmas);


Cheers,
Jerome

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-mm-numa-thp-fix-assumptions-of-migrate_misplaced_tra.patch"
Content-Transfer-Encoding: 8bit


--G4iJoqBmSsgzjUCe--
