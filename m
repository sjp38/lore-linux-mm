Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5216F8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:49:19 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c71so2362491qke.18
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:49:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x92si2158109qte.108.2018.12.20.08.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:49:18 -0800 (PST)
Date: Thu, 20 Dec 2018 11:49:12 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181220164912.GB3963@redhat.com>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181219110856.GA18345@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > > solution for that.  
> > > 
> > > So as I understand it, this would use page->_mapcount to store both the real
> > > mapcount, and the dma pinned count (simply added together), but only do so for
> > > file-backed (non-anonymous) pages:
> > > 
> > > 
> > > __get_user_pages()
> > > {
> > > 	...
> > > 	get_page(page);
> > > 
> > > 	if (!PageAnon)
> > > 		atomic_inc(page->_mapcount);
> > > 	...
> > > }
> > > 
> > > put_user_page(struct page *page)
> > > {
> > > 	...
> > > 	if (!PageAnon)
> > > 		atomic_dec(&page->_mapcount);
> > > 
> > > 	put_page(page);
> > > 	...
> > > }
> > > 
> > > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > > had in mind?
> > 
> > Mostly, with the extra two observations:
> >     [1] We only need to know the pin count when a write back kicks in
> >     [2] We need to protect GUP code with wait_for_write_back() in case
> >         GUP is racing with a write back that might not the see the
> >         elevated mapcount in time.
> > 
> > So for [2]
> > 
> > __get_user_pages()
> > {
> >     get_page(page);
> > 
> >     if (!PageAnon) {
> >         atomic_inc(page->_mapcount);
> > +       if (PageWriteback(page)) {
> > +           // Assume we are racing and curent write back will not see
> > +           // the elevated mapcount so wait for current write back and
> > +           // force page fault
> > +           wait_on_page_writeback(page);
> > +           // force slow path that will fault again
> > +       }
> >     }
> > }
> 
> This is not needed AFAICT. __get_user_pages() gets page reference (and it
> should also increment page->_mapcount) under PTE lock. So at that point we
> are sure we have writeable PTE nobody can change. So page_mkclean() has to
> block on PTE lock to make PTE read-only and only after going through all
> PTEs like this, it can check page->_mapcount. So the PTE lock provides
> enough synchronization.

This is needed, file back page can be map in any number of page table
and thus no PTE lock gonna protect anything in the end. More over with
GUP fast we really have to assume there is no lock that force ordering.

In fact in the above snipet that mapcount should not happen if there
is an on going write back.


> > For [1] only needing pin count during write back turns page_mkclean into
> > the perfect spot to check for that so:
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
> >     // rmap_walk need to change to count mapping and return value
> >     // in .mapcount easy one
> >     rmap_walk(page, &rwc);
> > 
> >     // Big fat comment to explain what is going on
> > +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > +       SetPageDMAPined(page);
> > +   } else {
> > +       ClearPageDMAPined(page);
> > +   }
> 
> This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> check we do in page_mkclean() is wrong?

Ok so i thought about this here is what we have:
    mp1 = page_mapcount(page);
    // let name rc1 the number of real count at mp1 time (this is
    // an ideal value that we can not get)

    rmap_walk(page, &rwc);
    // at this point let's name frc the number of real map count
    // found by rmap_walk

    mp2 = page_mapcount(page);
    // let name rc2 the number of real count at mp2 time (this is
    // an ideal value that we can not get)


So we have
    rc1 >= frc >= rc2
    pc1 = mp1 - rc1     // pin count at mp1 time
    pc2 = mp2 - rc2     // pin count at mp2 time

So we have:
    mp1 - rc1 <= mp1 - frc
    mp2 - rc2 >= mp2 - frc

>From the above:
    mp1 - frc <  0 impossible value mapcount can only go down so
                   frc <= mp1
    mp1 - frc == 0 -> the page is not pin
U1  mp1 - frc >  0 -> the page might be pin

U2  mp2 - frc <= 0 -> the page might be pin
    mp2 - frc >  0 -> the page is pin

They are two unknowns [U1] and [U2]:
    [U1]    a zap raced before rmap_walk() could account the zaped
            mapping (frc < rc1)
    [U2]    a zap raced after rmap_walk() accounted the zaped
            mapping (frc > rc2)

In both cases we can detect the race but we can not ascertain if page
is pin or not.

So we can do 2 things here:
    - try to recount the real mapping (it is bound to end as no
      new mapping can be added and thus mapcount can only go down)
    - assume false positive and uselessly bounce page that would
      not need bouncing if we were not unlucky

We could mitigate this with a flag GUP unconditionaly set it and page
mkclean clears it when mp1 - frc == 0 this way we never bounce page
that were never GUPed but we might keep bouncing a page that was GUPed
once in its lifetime until there is not race for it in page_mkclean.

I will ponder a bit more and see if i can get an idea on how to close
that race ie either close U1 or close U2.


> >     // Maybe we want to leverage the int nature of return value so that
> >     // we can express more than cleaned/truncated and express cleaned/
> >     // truncated/pinned for benefit of caller and that way we do not
> >     // even need one bit as page flags above.
> > 
> >     return cleaned;
> > }
> > 
> > You do not want to change page_mapped() i do not see a need for that.
> > 
> > Then the whole discussion between Jan and Dave seems to indicate that
> > the bounce mechanism will need to be in the fs layer and that we can
> > not reuse the bio bounce mechanism. This means that more work is needed
> > at the fs level for that (so that fs do not freak on bounce page).
> > 
> > Note that they are few gotcha where we need to preserve the pin count
> > ie mostly in truncate code path that can remove page from page cache
> > and overwrite the mapcount in the process, this would need to be fixed
> > to not overwrite mapcount so that put_user_page does not set the map
> > count to an invalid value turning the page into a bad state that will
> > at one point trigger kernel BUG_ON();
> >
> > I am not saying block truncate, i am saying make sure it does not
> > erase pin count and keep truncating happily. The how to handle truncate
> > is a per existing GUP user discussion to see what they want to do for
> > that.
> > 
> > Obviously a bit deeper analysis of all spot that use mapcount is needed
> > to check that we are not breaking anything but from the top of my head
> > i can not think of anything bad (migrate will abort and other things will
> > assume the page is mapped even it is only in hardware page table, ...).
> 
> Hum, grepping for page_mapped() and page_mapcount(), this is actually going
> to be non-trivial to get right AFAICT.

No that's not that scary a good chunk of all those are for anonymous
memory and many are obvious (like migrate, ksm, ...).

Cheers,
J�r�me
