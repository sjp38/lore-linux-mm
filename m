Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 102408E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:44:18 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d35so42320941qtd.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:44:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b54si629236qvb.176.2019.01.03.06.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:44:16 -0800 (PST)
Date: Thu, 3 Jan 2019 09:44:06 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190103144405.GC3395@redhat.com>
References: <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com>
 <20190103092654.GA31370@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103092654.GA31370@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
> > On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> > > On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > > > On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > > > > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > > > > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > > > > solution for that.  
> > > > > 
> > > > > So as I understand it, this would use page->_mapcount to store both the real
> > > > > mapcount, and the dma pinned count (simply added together), but only do so for
> > > > > file-backed (non-anonymous) pages:
> > > > > 
> > > > > 
> > > > > __get_user_pages()
> > > > > {
> > > > > 	...
> > > > > 	get_page(page);
> > > > > 
> > > > > 	if (!PageAnon)
> > > > > 		atomic_inc(page->_mapcount);
> > > > > 	...
> > > > > }
> > > > > 
> > > > > put_user_page(struct page *page)
> > > > > {
> > > > > 	...
> > > > > 	if (!PageAnon)
> > > > > 		atomic_dec(&page->_mapcount);
> > > > > 
> > > > > 	put_page(page);
> > > > > 	...
> > > > > }
> > > > > 
> > > > > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > > > > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > > > > had in mind?
> > > > 
> > > > Mostly, with the extra two observations:
> > > >     [1] We only need to know the pin count when a write back kicks in
> > > >     [2] We need to protect GUP code with wait_for_write_back() in case
> > > >         GUP is racing with a write back that might not the see the
> > > >         elevated mapcount in time.
> > > > 
> > > > So for [2]
> > > > 
> > > > __get_user_pages()
> > > > {
> > > >     get_page(page);
> > > > 
> > > >     if (!PageAnon) {
> > > >         atomic_inc(page->_mapcount);
> > > > +       if (PageWriteback(page)) {
> > > > +           // Assume we are racing and curent write back will not see
> > > > +           // the elevated mapcount so wait for current write back and
> > > > +           // force page fault
> > > > +           wait_on_page_writeback(page);
> > > > +           // force slow path that will fault again
> > > > +       }
> > > >     }
> > > > }
> > > 
> > > This is not needed AFAICT. __get_user_pages() gets page reference (and it
> > > should also increment page->_mapcount) under PTE lock. So at that point we
> > > are sure we have writeable PTE nobody can change. So page_mkclean() has to
> > > block on PTE lock to make PTE read-only and only after going through all
> > > PTEs like this, it can check page->_mapcount. So the PTE lock provides
> > > enough synchronization.
> > > 
> > > > For [1] only needing pin count during write back turns page_mkclean into
> > > > the perfect spot to check for that so:
> > > > 
> > > > int page_mkclean(struct page *page)
> > > > {
> > > >     int cleaned = 0;
> > > > +   int real_mapcount = 0;
> > > >     struct address_space *mapping;
> > > >     struct rmap_walk_control rwc = {
> > > >         .arg = (void *)&cleaned,
> > > >         .rmap_one = page_mkclean_one,
> > > >         .invalid_vma = invalid_mkclean_vma,
> > > > +       .mapcount = &real_mapcount,
> > > >     };
> > > > 
> > > >     BUG_ON(!PageLocked(page));
> > > > 
> > > >     if (!page_mapped(page))
> > > >         return 0;
> > > > 
> > > >     mapping = page_mapping(page);
> > > >     if (!mapping)
> > > >         return 0;
> > > > 
> > > >     // rmap_walk need to change to count mapping and return value
> > > >     // in .mapcount easy one
> > > >     rmap_walk(page, &rwc);
> > > > 
> > > >     // Big fat comment to explain what is going on
> > > > +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > > > +       SetPageDMAPined(page);
> > > > +   } else {
> > > > +       ClearPageDMAPined(page);
> > > > +   }
> > > 
> > > This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> > > with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> > > check we do in page_mkclean() is wrong?
> > > 
> > 
> > Ok so i found a solution for that. First GUP must wait for racing
> > write back. If GUP see a valid write-able PTE and the page has
> > write back flag set then it must back of as if the PTE was not
> > valid to force fault. It is just a race with page_mkclean and we
> > want ordering between the two. Note this is not strictly needed
> > so we can relax that but i believe this ordering is better to do
> > in GUP rather then having each single user of GUP test for this
> > to avoid the race.
> > 
> > GUP increase mapcount only after checking that it is not racing
> > with writeback it also set a page flag (SetPageDMAPined(page)).
> > 
> > When clearing a write-able pte we set a special entry inside the
> > page table (might need a new special swap type for this) and change
> > page_mkclean_one() to clear to 0 those special entry.
> > 
> > 
> > Now page_mkclean:
> > 
> > int page_mkclean(struct page *page)
> > {
> >     int cleaned = 0;
> > +   int real_mapcount = 0;
> >     struct address_space *mapping;
> >     struct rmap_walk_control rwc = {
> >         .arg = (void *)&cleaned,
> >         .rmap_one = page_mkclean_one,
> >         .invalid_vma = invalid_mkclean_vma,
> > +       .mapcount = &real_mapcount,
> >     };
> > +   int mapcount1, mapcount2;
> > 
> >     BUG_ON(!PageLocked(page));
> > 
> >     if (!page_mapped(page))
> >         return 0;
> > 
> >     mapping = page_mapping(page);
> >     if (!mapping)
> >         return 0;
> > 
> > +   mapcount1 = page_mapcount(page);
> >     // rmap_walk need to change to count mapping and return value
> >     // in .mapcount easy one
> >     rmap_walk(page, &rwc);
> 
> So what prevents GUP_fast() to grab reference here and the test below would
> think the page is not pinned? Or do you assume that every page_mkclean()
> call will be protected by PageWriteback (currently it is not) so that
> GUP_fast() blocks / bails out?

So GUP_fast() becomes:

GUP_fast_existing() { ... }
GUP_fast()
{
    GUP_fast_existing();

    for (i = 0; i < npages; ++i) {
        if (PageWriteback(pages[i])) {
            // need to force slow path for this page
        } else {
            SetPageDmaPinned(pages[i]);
            atomic_inc(pages[i]->mapcount);
        }
    }
}

This is a minor slow down for GUP fast and it takes care of a
write back race on behalf of caller. This means that page_mkclean
can not see a mapcount value that increase. This simplify thing
we can relax that. Note that what this is doing is making sure
that GUP_fast never get lucky :) ie never GUP a page that is in
the process of being write back but has not yet had its pte
updated to reflect that.


> But I think that detecting pinned pages with small false positive rate is
> OK. The extra page bouncing will cost some performance but if it is rare,
> then we are OK. So I think we can go for the simple version of detecting
> pinned pages as you mentioned in some earlier email. We just have to be
> sure there are no false negatives.

What worry me is that a page might stays with the DMA pinned flag forever
if it keeps getting unlucky ie some process keeps mapping it after last
write back and keeps zapping that mapping while racing with page_mkclean.
This should be unlikely but nothing would prevent it. I am fine with
living with this but page might become a zombie GUP :)

Maybe we can start with the simple version and add big fat comment and see
if anyone complains about a zombie GUP ...

Cheers,
J�r�me
