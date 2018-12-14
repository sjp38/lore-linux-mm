Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5565A8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:53:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so2979536edb.1
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:53:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cx1-v6si1805537ejb.63.2018.12.14.07.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 07:53:13 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3043FAD8B
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:53:12 +0000 (UTC)
Date: Fri, 14 Dec 2018 16:53:11 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] mm: migration: Factor out code to compute expected
 number of page references
Message-ID: <20181214155311.GG8896@quack2.suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-2-jack@suse.cz>
 <20181214151045.GG28934@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214151045.GG28934@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz

On Fri 14-12-18 15:10:46, Mel Gorman wrote:
> On Tue, Dec 11, 2018 at 06:21:38PM +0100, Jan Kara wrote:
> > Factor out function to compute number of expected page references in
> > migrate_page_move_mapping(). Note that we move hpage_nr_pages() and
> > page_has_private() checks from under xas_lock_irq() however this is safe
> > since we hold page lock.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  mm/migrate.c | 27 +++++++++++++++++----------
> >  1 file changed, 17 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f7e4bfdc13b7..789c7bc90a0c 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -428,6 +428,22 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
> >  }
> >  #endif /* CONFIG_BLOCK */
> >  
> > +static int expected_page_refs(struct page *page)
> > +{
> > +	int expected_count = 1;
> > +
> > +	/*
> > +	 * Device public or private pages have an extra refcount as they are
> > +	 * ZONE_DEVICE pages.
> > +	 */
> > +	expected_count += is_device_private_page(page);
> > +	expected_count += is_device_public_page(page);
> > +	if (page->mapping)
> > +		expected_count += hpage_nr_pages(page) + page_has_private(page);
> > +
> > +	return expected_count;
> > +}
> > +
> 
> I noticed during testing that THP allocation success rates under the
> mmtests configuration global-dhp__workload_thpscale-madvhugepage-xfs were
> terrible with massive latencies introduced somewhere in the series. I
> haven't tried chasing it down as it's relatively late but this block
> looked odd and I missed it the first time.

Interesting. I've run config-global-dhp__workload_thpscale and that didn't
show anything strange. But the numbers were fluctuating a lot both with and
without my patches applied. I'll have a look if I can reproduce this
sometime next week and look what could be causing the delays.

> This page->mapping test is relevant for the "Anonymous page without
> mapping" check but I think it's wrong. An anonymous page without mapping
> doesn't have a NULL mapping, it sets PAGE_MAPPING_ANON and the field can
> be special in other ways. I think you meant to use page_mapping(page)
> here, not page->mapping?

Yes, that's a bug. It should have been page_mapping(page). Thanks for
catching this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
