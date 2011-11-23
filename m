Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D74916B00CB
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 04:19:39 -0500 (EST)
Date: Wed, 23 Nov 2011 09:19:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/7] mm: compaction: make isolate_lru_page() filter-aware
 again
Message-ID: <20111123091933.GL19415@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <1321900608-27687-6-git-send-email-mgorman@suse.de>
 <20111122173018.GD15253@barrios-laptop.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111122173018.GD15253@barrios-laptop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2011 at 02:30:18AM +0900, Minchan Kim wrote:
> > <SNIP>
> > +	/*
> > +	 * To minimise LRU disruption, the caller can indicate that it only
> > +	 * wants to isolate pages it will be able to operate on without
> > +	 * blocking - clean pages for the most part.
> > +	 *
> > +	 * ISOLATE_CLEAN means that only clean pages should be isolated. This
> > +	 * is used by reclaim when it is cannot write to backing storage
> > +	 *
> > +	 * ISOLATE_ASYNC_MIGRATE is used to indicate that it only wants to pages
> > +	 * that it is possible to migrate without blocking with a ->migratepage
> > +	 * handler
> > +	 */
> > +	if (mode & (ISOLATE_CLEAN|ISOLATE_ASYNC_MIGRATE)) {
> > +		/* All the caller can do on PageWriteback is block */
> > +		if (PageWriteback(page))
> > +			return ret;
> > +
> > +		if (PageDirty(page)) {
> > +			struct address_space *mapping;
> > +
> > +			/* ISOLATE_CLEAN means only clean pages */
> > +			if (mode & ISOLATE_CLEAN)
> > +				return ret;
> > +
> > +			/*
> > +			 * Only the ->migratepage callback knows if a dirty
> > +			 * page can be migrated without blocking. Skip the
> > +			 * page unless there is a ->migratepage callback.
> > +			 */
> > +			mapping = page_mapping(page);
> > +			if (!mapping || !mapping->a_ops->migratepage)
> 
> I didn't review 4/7 carefully yet.

Thanks for reviewing the others.

> In case of page_mapping is NULL, move_to_new_page calls migrate_page
> which is non-blocking function. So, I guess it could be migrated without blocking.
>  

Well spotted

                        /*
                         * Only pages without mappings or that have a
                         * ->migratepage callback are possible to
                         * migrate without blocking
                         */
                        mapping = page_mapping(page);
                        if (mapping && !mapping->a_ops->migratepage)
                                return ret;

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
