Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0C358E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 06:09:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f31so12776596edf.17
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 03:09:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o27si6173670edc.257.2018.12.19.03.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 03:09:02 -0800 (PST)
Date: Wed, 19 Dec 2018 12:08:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181219110856.GA18345@quack2.suse.cz>
References: <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219020723.GD4347@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > solution for that.  
> > 
> > So as I understand it, this would use page->_mapcount to store both the real
> > mapcount, and the dma pinned count (simply added together), but only do so for
> > file-backed (non-anonymous) pages:
> > 
> > 
> > __get_user_pages()
> > {
> > 	...
> > 	get_page(page);
> > 
> > 	if (!PageAnon)
> > 		atomic_inc(page->_mapcount);
> > 	...
> > }
> > 
> > put_user_page(struct page *page)
> > {
> > 	...
> > 	if (!PageAnon)
> > 		atomic_dec(&page->_mapcount);
> > 
> > 	put_page(page);
> > 	...
> > }
> > 
> > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > had in mind?
> 
> Mostly, with the extra two observations:
>     [1] We only need to know the pin count when a write back kicks in
>     [2] We need to protect GUP code with wait_for_write_back() in case
>         GUP is racing with a write back that might not the see the
>         elevated mapcount in time.
> 
> So for [2]
> 
> __get_user_pages()
> {
>     get_page(page);
> 
>     if (!PageAnon) {
>         atomic_inc(page->_mapcount);
> +       if (PageWriteback(page)) {
> +           // Assume we are racing and curent write back will not see
> +           // the elevated mapcount so wait for current write back and
> +           // force page fault
> +           wait_on_page_writeback(page);
> +           // force slow path that will fault again
> +       }
>     }
> }

This is not needed AFAICT. __get_user_pages() gets page reference (and it
should also increment page->_mapcount) under PTE lock. So at that point we
are sure we have writeable PTE nobody can change. So page_mkclean() has to
block on PTE lock to make PTE read-only and only after going through all
PTEs like this, it can check page->_mapcount. So the PTE lock provides
enough synchronization.

> For [1] only needing pin count during write back turns page_mkclean into
> the perfect spot to check for that so:
> 
> int page_mkclean(struct page *page)
> {
>     int cleaned = 0;
> +   int real_mapcount = 0;
>     struct address_space *mapping;
>     struct rmap_walk_control rwc = {
>         .arg = (void *)&cleaned,
>         .rmap_one = page_mkclean_one,
>         .invalid_vma = invalid_mkclean_vma,
> +       .mapcount = &real_mapcount,
>     };
> 
>     BUG_ON(!PageLocked(page));
> 
>     if (!page_mapped(page))
>         return 0;
> 
>     mapping = page_mapping(page);
>     if (!mapping)
>         return 0;
> 
>     // rmap_walk need to change to count mapping and return value
>     // in .mapcount easy one
>     rmap_walk(page, &rwc);
> 
>     // Big fat comment to explain what is going on
> +   if ((page_mapcount(page) - real_mapcount) > 0) {
> +       SetPageDMAPined(page);
> +   } else {
> +       ClearPageDMAPined(page);
> +   }

This is the detail I'm not sure about: Why cannot rmap_walk_file() race
with e.g. zap_pte_range() which decrements page->_mapcount and thus the
check we do in page_mkclean() is wrong?

> 
>     // Maybe we want to leverage the int nature of return value so that
>     // we can express more than cleaned/truncated and express cleaned/
>     // truncated/pinned for benefit of caller and that way we do not
>     // even need one bit as page flags above.
> 
>     return cleaned;
> }
> 
> You do not want to change page_mapped() i do not see a need for that.
> 
> Then the whole discussion between Jan and Dave seems to indicate that
> the bounce mechanism will need to be in the fs layer and that we can
> not reuse the bio bounce mechanism. This means that more work is needed
> at the fs level for that (so that fs do not freak on bounce page).
> 
> Note that they are few gotcha where we need to preserve the pin count
> ie mostly in truncate code path that can remove page from page cache
> and overwrite the mapcount in the process, this would need to be fixed
> to not overwrite mapcount so that put_user_page does not set the map
> count to an invalid value turning the page into a bad state that will
> at one point trigger kernel BUG_ON();
>
> I am not saying block truncate, i am saying make sure it does not
> erase pin count and keep truncating happily. The how to handle truncate
> is a per existing GUP user discussion to see what they want to do for
> that.
> 
> Obviously a bit deeper analysis of all spot that use mapcount is needed
> to check that we are not breaking anything but from the top of my head
> i can not think of anything bad (migrate will abort and other things will
> assume the page is mapped even it is only in hardware page table, ...).

Hum, grepping for page_mapped() and page_mapcount(), this is actually going
to be non-trivial to get right AFAICT.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
