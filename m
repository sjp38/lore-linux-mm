Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C27238E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 20:55:42 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so38293301qka.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 17:55:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si1122632qvb.181.2019.01.02.17.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 17:55:41 -0800 (PST)
Date: Wed, 2 Jan 2019 20:55:33 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190103015533.GA15619@redhat.com>
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
> 
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
> 

Ok so i found a solution for that. First GUP must wait for racing
write back. If GUP see a valid write-able PTE and the page has
write back flag set then it must back of as if the PTE was not
valid to force fault. It is just a race with page_mkclean and we
want ordering between the two. Note this is not strictly needed
so we can relax that but i believe this ordering is better to do
in GUP rather then having each single user of GUP test for this
to avoid the race.

GUP increase mapcount only after checking that it is not racing
with writeback it also set a page flag (SetPageDMAPined(page)).

When clearing a write-able pte we set a special entry inside the
page table (might need a new special swap type for this) and change
page_mkclean_one() to clear to 0 those special entry.


Now page_mkclean:

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
+   int mapcount1, mapcount2;

    BUG_ON(!PageLocked(page));

    if (!page_mapped(page))
        return 0;

    mapping = page_mapping(page);
    if (!mapping)
        return 0;

+   mapcount1 = page_mapcount(page);

    // rmap_walk need to change to count mapping and return value
    // in .mapcount easy one
    rmap_walk(page, &rwc);

+   if (PageDMAPined(page)) {
+       int rc2;
+
+       if (mapcount1 == real_count) {
+           /* Page is no longer pin, no zap pte race */
+           ClearPageDMAPined(page);
+           goto out;
+       }
+       /* No new mapping of the page so mp1 < rc is illegal. */
+       VM_BUG_ON(mapcount1 < real_count);
+       /* Page might be pin. */
+       mapcount2 = page_mapcount(page);
+       if (mapcount2 > real_count) {
+           /* Page is pin for sure. */
+           goto out;
+       }
+       /* We had a race with zap pte we need to rewalk again. */
+       rc2 = real_mapcount;
+       real_mapcount = 0;
+       rwc.rmap_one = page_pin_one;
+       rmap_walk(page, &rwc);
+       if (mapcount2 <= (real_count + rc2)) {
+           /* Page is no longer pin */
+           ClearPageDMAPined(page);
+       }
+       /* At this point the page pin flag reflect pin status of the page */
+   }
+
+out:
    ...
}

The page_pin_one() function count the number of special PTE entry so
which match the count of pte that have been zapped since the first
reverse map walk.

So worst case a page that was pin by a GUP would need 2 reverse map
walk during page_mkclean(). Moreover this is only needed if we race
with something that clear pte. I believe this is an acceptable worst
case. I will work on some RFC patchset next week (once i am down with
email catch up).


I do not think i made mistake here, i have been torturing my mind
trying to think of any race scenario and i believe it holds to any
racing zap and page_mkclean()

Cheers,
J�r�me
