Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9F16B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 09:44:14 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2519932pzk.14
        for <linux-mm@kvack.org>; Tue, 31 May 2011 06:44:12 -0700 (PDT)
Date: Tue, 31 May 2011 22:44:05 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2 03/10] Change isolate mode from int type to enum type
Message-ID: <20110531134405.GC3490@barrios-laptop>
References: <cover.1306689214.git.minchan.kim@gmail.com>
 <6e08f148630ffe1e7fe6a4d31d4340a9a47f4473.1306689214.git.minchan.kim@gmail.com>
 <20110531133611.GC3190@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110531133611.GC3190@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, May 31, 2011 at 03:36:11PM +0200, Johannes Weiner wrote:
> On Mon, May 30, 2011 at 03:13:42AM +0900, Minchan Kim wrote:
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -957,23 +957,29 @@ keep_lumpy:
> >   *
> >   * returns 0 on success, -ve errno on failure.
> >   */
> > -int __isolate_lru_page(struct page *page, int mode, int file)
> > +int __isolate_lru_page(struct page *page, enum ISOLATE_PAGE_MODE mode,
> > +							int file)
> >  {
> > +	int active;
> >  	int ret = -EINVAL;
> > +	BUG_ON(mode & ISOLATE_BOTH &&
> > +		(mode & ISOLATE_INACTIVE || mode & ISOLATE_ACTIVE));
> >  
> >  	/* Only take pages on the LRU. */
> >  	if (!PageLRU(page))
> >  		return ret;
> >  
> > +	active = PageActive(page);
> > +
> >  	/*
> >  	 * When checking the active state, we need to be sure we are
> >  	 * dealing with comparible boolean values.  Take the logical not
> >  	 * of each.
> >  	 */
> > -	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
> > +	if (mode & ISOLATE_ACTIVE && !active)
> >  		return ret;
> >  
> > -	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
> > +	if (mode & ISOLATE_INACTIVE && active)
> >  		return ret;
> 
> What happened to the check for file pages?

Shame on me. I should not change old behavior.
Will fix on v3.

Thanks, Hannes.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
