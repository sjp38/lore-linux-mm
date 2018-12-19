Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 028B98E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 21:07:32 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n50so23839024qtb.9
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 18:07:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 37si1038407qvb.136.2018.12.18.18.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 18:07:30 -0800 (PST)
Date: Tue, 18 Dec 2018 21:07:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181219020723.GD4347@redhat.com>
References: <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> On 12/18/18 1:30 AM, Jan Kara wrote:
> > On Mon 17-12-18 10:34:43, Matthew Wilcox wrote:
> >> On Mon, Dec 17, 2018 at 01:11:50PM -0500, Jerome Glisse wrote:
> >>> On Mon, Dec 17, 2018 at 08:58:19AM +1100, Dave Chinner wrote:
> >>>> Sure, that's a possibility, but that doesn't close off any race
> >>>> conditions because there can be DMA into the page in progress while
> >>>> the page is being bounced, right? AFAICT this ext3+DIF/DIX case is
> >>>> different in that there is no 3rd-party access to the page while it
> >>>> is under IO (ext3 arbitrates all access to it's metadata), and so
> >>>> nothing can actually race for modification of the page between
> >>>> submission and bouncing at the block layer.
> >>>>
> >>>> In this case, the moment the page is unlocked, anyone else can map
> >>>> it and start (R)DMA on it, and that can happen before the bio is
> >>>> bounced by the block layer. So AFAICT, block layer bouncing doesn't
> >>>> solve the problem of racing writeback and DMA direct to the page we
> >>>> are doing IO on. Yes, it reduces the race window substantially, but
> >>>> it doesn't get rid of it.
> >>>
> >>> So the event flow is:
> >>>     - userspace create object that match a range of virtual address
> >>>       against a given kernel sub-system (let's say infiniband) and
> >>>       let's assume that the range is an mmap() of a regular file
> >>>     - device driver do GUP on the range (let's assume it is a write
> >>>       GUP) so if the page is not already map with write permission
> >>>       in the page table than a page fault is trigger and page_mkwrite
> >>>       happens
> >>>     - Once GUP return the page to the device driver and once the
> >>>       device driver as updated the hardware states to allow access
> >>>       to this page then from that point on hardware can write to the
> >>>       page at _any_ time, it is fully disconnected from any fs event
> >>>       like write back, it fully ignore things like page_mkclean
> >>>
> >>> This is how it is to day, we allowed people to push upstream such
> >>> users of GUP. This is a fact we have to live with, we can not stop
> >>> hardware access to the page, we can not force the hardware to follow
> >>> page_mkclean and force a page_mkwrite once write back ends. This is
> >>> the situation we are inheriting (and i am personnaly not happy with
> >>> that).
> >>>
> >>> >From my point of view we are left with 2 choices:
> >>>     [C1] break all drivers that do not abide by the page_mkclean and
> >>>          page_mkwrite
> >>>     [C2] mitigate as much as possible the issue
> >>>
> >>> For [C2] the idea is to keep track of GUP per page so we know if we
> >>> can expect the page to be written to at any time. Here is the event
> >>> flow:
> >>>     - driver GUP the page and program the hardware, page is mark as
> >>>       GUPed
> >>>     ...
> >>>     - write back kicks in on the dirty page, lock the page and every
> >>>       thing as usual , sees it is GUPed and inform the block layer to
> >>>       use a bounce page
> >>
> >> No.  The solution John, Dan & I have been looking at is to take the
> >> dirty page off the LRU while it is pinned by GUP.  It will never be
> >> found for writeback.
> >>
> >> That's not the end of the story though.  Other parts of the kernel (eg
> >> msync) also need to be taught to stay away from pages which are pinned
> >> by GUP.  But the idea is that no page gets written back to storage while
> >> it's pinned by GUP.  Only when the last GUP ends is the page returned
> >> to the list of dirty pages.
> > 
> > We've been through this in:
> > 
> > https://lore.kernel.org/lkml/20180709194740.rymbt2fzohbdmpye@quack2.suse.cz/
> > 
> > back in July. You cannot just skip pages for fsync(2). So as I wrote above -
> > memory cleaning writeback can skip pinned pages. Data integrity writeback
> > must be able to write pinned pages. And bouncing is one reasonable way how
> > to do that.
> > 
> > This writeback decision is pretty much independent from the mechanism by
> > which we are going to identify pinned pages. Whether that's going to be
> > separate counter in struct page, using page->_mapcount, or separately
> > allocated data structure as you know promote.
> > 
> > I currently like the most the _mapcount suggestion from Jerome but I'm not
> > really attached to any solution as long as it performs reasonably and
> > someone can make it working :) as I don't have time to implement it at
> > least till January.
> > 
> 
> OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> *only* the tracking pinned pages aspect), given that it is the lightest weight
> solution for that.  
> 
> So as I understand it, this would use page->_mapcount to store both the real
> mapcount, and the dma pinned count (simply added together), but only do so for
> file-backed (non-anonymous) pages:
> 
> 
> __get_user_pages()
> {
> 	...
> 	get_page(page);
> 
> 	if (!PageAnon)
> 		atomic_inc(page->_mapcount);
> 	...
> }
> 
> put_user_page(struct page *page)
> {
> 	...
> 	if (!PageAnon)
> 		atomic_dec(&page->_mapcount);
> 
> 	put_page(page);
> 	...
> }
> 
> ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> had in mind?

Mostly, with the extra two observations:
    [1] We only need to know the pin count when a write back kicks in
    [2] We need to protect GUP code with wait_for_write_back() in case
        GUP is racing with a write back that might not the see the
        elevated mapcount in time.

So for [2]

__get_user_pages()
{
    get_page(page);

    if (!PageAnon) {
        atomic_inc(page->_mapcount);
+       if (PageWriteback(page)) {
+           // Assume we are racing and curent write back will not see
+           // the elevated mapcount so wait for current write back and
+           // force page fault
+           wait_on_page_writeback(page);
+           // force slow path that will fault again
+       }
    }
}

For [1] only needing pin count during write back turns page_mkclean into
the perfect spot to check for that so:

int page_mkclean(struct page *page)
{
    int cleaned = 0;
+   int real_mapcount = 0;
    struct address_space *mapping;
    struct rmap_walk_control rwc = {
        .arg = (void *)&cleaned,
        .rmap_one = page_mkclean_one,
        .invalid_vma = invalid_mkclean_vma,
+       .mapcount = &real_mapcount,
    };

    BUG_ON(!PageLocked(page));

    if (!page_mapped(page))
        return 0;

    mapping = page_mapping(page);
    if (!mapping)
        return 0;

    // rmap_walk need to change to count mapping and return value
    // in .mapcount easy one
    rmap_walk(page, &rwc);

    // Big fat comment to explain what is going on
+   if ((page_mapcount(page) - real_mapcount) > 0) {
+       SetPageDMAPined(page);
+   } else {
+       ClearPageDMAPined(page);
+   }

    // Maybe we want to leverage the int nature of return value so that
    // we can express more than cleaned/truncated and express cleaned/
    // truncated/pinned for benefit of caller and that way we do not
    // even need one bit as page flags above.

    return cleaned;
}

You do not want to change page_mapped() i do not see a need for that.

Then the whole discussion between Jan and Dave seems to indicate that
the bounce mechanism will need to be in the fs layer and that we can
not reuse the bio bounce mechanism. This means that more work is needed
at the fs level for that (so that fs do not freak on bounce page).

Note that they are few gotcha where we need to preserve the pin count
ie mostly in truncate code path that can remove page from page cache
and overwrite the mapcount in the process, this would need to be fixed
to not overwrite mapcount so that put_user_page does not set the map
count to an invalid value turning the page into a bad state that will
at one point trigger kernel BUG_ON();

I am not saying block truncate, i am saying make sure it does not
erase pin count and keep truncating happily. The how to handle truncate
is a per existing GUP user discussion to see what they want to do for
that.

Obviously a bit deeper analysis of all spot that use mapcount is needed
to check that we are not breaking anything but from the top of my head
i can not think of anything bad (migrate will abort and other things will
assume the page is mapped even it is only in hardware page table, ...).

Cheers,
J�r�me
