Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 225418E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:34:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so831743edc.6
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:34:16 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si2764035ejz.304.2019.01.15.00.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 00:34:14 -0800 (PST)
Date: Tue, 15 Jan 2019 09:34:12 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190115083412.GD29524@quack2.suse.cz>
References: <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz>
 <20190114172124.GA3702@redhat.com>
 <fdece7f8-7e4f-f679-821f-1d05ed748c15@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fdece7f8-7e4f-f679-821f-1d05ed748c15@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon 14-01-19 11:09:20, John Hubbard wrote:
> On 1/14/19 9:21 AM, Jerome Glisse wrote:
> >>
> >> Also there is one more idea I had how to record number of pins in the page:
> >>
> >> #define PAGE_PIN_BIAS	1024
> >>
> >> get_page_pin()
> >> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
> >>
> >> put_page_pin();
> >> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
> >>
> >> page_pinned(page)
> >> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
> >>
> >> This is pretty trivial scheme. It still gives us 22-bits for page pins
> >> which should be plenty (but we should check for that and bail with error if
> >> it would overflow). Also there will be no false negatives and false
> >> positives only if there are more than 1024 non-page-table references to the
> >> page which I expect to be rare (we might want to also subtract
> >> hpage_nr_pages() for radix tree references to avoid excessive false
> >> positives for huge pages although at this point I don't think they would
> >> matter). Thoughts?
> > 
> > Racing PUP are as likely to cause issues:
> > 
> > CPU0                        | CPU1       | CPU2
> >                             |            |
> >                             | PUP()      |
> >     page_pinned(page)       |            |
> >       (page_count(page) -   |            |
> >        page_mapcount(page)) |            |
> >                             |            | GUP()
> > 
> > So here the refcount snap-shot does not include the second GUP and
> > we can have a false negative ie the page_pinned() will return false
> > because of the PUP happening just before on CPU1 despite the racing
> > GUP on CPU2 just after.
> > 
> > I believe only either lock or memory ordering with barrier can
> > guarantee that we do not miss GUP ie no false negative. Still the
> > bias idea might be usefull as with it we should not need a flag.
> > 
> > So to make the above safe it would still need the page write back
> > double check that i described so that GUP back-off if it raced with
> > page_mkclean,clear_page_dirty_for_io and the fs write page call back
> > which call test_set_page_writeback() (yes it is very unlikely but
> > might still happen).
> > 
> > 
> > I still need to ponder some more on all the races.
> > 
> 
> Tentatively, so far I prefer the _mapcount scheme, because it seems more
> accurate to add mapcounts than to overload the _refcount field. And the 
> implementation is going to be cleaner. And we've already figured out the
> races.

I think there's no difference WRT the races when using _mapcount or _count
bias to identify page pins. In fact the difference between what I suggested
and what you did are just that you update _count instead of _mapcount and
you can drop the rmap walk code and the page flag.

There are two reasons why I like using _count bias more:

1) I'm still not 100% convinced that some page_mapped() or page_mapcount()
check that starts to be true due to page being unmapped but pinned does not
confuse some code with bad consequences. The fact that the kernel boots
indicates that there's no common check that would get confused but full
audit of page_mapped() and page_mapcount() checks is needed to confirm
there isn't some cornercase missed and that is tedious. There are
definitely places that e.g. assert that page_mapcount() == 0 after all page
tables are unmapped and that is not necessarily true after your changes.

2) If the page gets pinned, we will report it as pinned until the next
page_mkclean() call. That can be quite a long time after page has been
really unpinned. In particular if the page was never dirtied (e.g. because
it was gup'ed only for read but there can be other reasons), it may never
happen that page_mkclean() is called and we won't be able to ever reclaim
such page. So we would have to also add some mechanism to eventually get
such pages cleaned up and that involves rmap walk for each such page which
is not quite cheap.

> For example, the following already survives a basic boot to graphics mode.
> It requires a bunch of callsite conversions, and a page flag (neither of which
> is shown here), and may also have "a few" gross conceptual errors, but take a 
> peek:

Thanks for writing this down! Some comments inline.

> +/*
> + * Manages the PG_gup_pinned flag.
> + *
> + * Note that page->_mapcount counting part of managing that flag, because the
> + * _mapcount is used to determine if PG_gup_pinned can be cleared, in
> + * page_mkclean().
> + */
> +static void track_gup_page(struct page *page)
> +{
> +	page = compound_head(page);
> +
> +	lock_page(page);
> +
> +	wait_on_page_writeback(page);

^^ I'd use wait_for_stable_page() here. That is the standard waiting
mechanism to use before you allow page modification.

> +
> +	atomic_inc(&page->_mapcount);
> +	SetPageGupPinned(page);
> +
> +	unlock_page(page);
> +}
> +
> +/*
> + * A variant of track_gup_page() that returns -EBUSY, instead of waiting.
> + */
> +static int track_gup_page_atomic(struct page *page)
> +{
> +	page = compound_head(page);
> +
> +	if (PageWriteback(page) || !trylock_page(page))
> +		return -EBUSY;
> +
> +	if (PageWriteback(page)) {
> +		unlock_page(page);
> +		return -EBUSY;
> +	}

Here you'd need some helper that would return whether
wait_for_stable_page() is going to wait. Like would_wait_for_stable_page()
but maybe you can come up with a better name.

> +	atomic_inc(&page->_mapcount);
> +	SetPageGupPinned(page);
> +
> +	unlock_page(page);
> +	return 0;
> +}
> +

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
