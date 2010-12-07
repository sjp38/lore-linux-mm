Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4160F6B008C
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 10:07:28 -0500 (EST)
Received: by pwi6 with SMTP id 6so19745pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 07:07:23 -0800 (PST)
Date: Wed, 8 Dec 2010 00:07:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-ID: <20101207150710.GA26613@barrios-desktop>
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
 <20101207144923.GB2356@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101207144923.GB2356@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 07, 2010 at 03:49:24PM +0100, Johannes Weiner wrote:
> On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
> > Changelog since v3:
> >  - Change function comments - suggested by Johannes
> >  - Change function name - suggested by Johannes
> >  - add only dirty/writeback pages to deactive pagevec
> 
> Why the extra check?
> 
> > @@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
> >  			if (lock_failed)
> >  				continue;
> >  
> > -			ret += invalidate_inode_page(page);
> > -
> > +			ret = invalidate_inode_page(page);
> > +			/*
> > +			 * If the page is dirty or under writeback, we can not
> > +			 * invalidate it now.  But we assume that attempted
> > +			 * invalidation is a hint that the page is no longer
> > +			 * of interest and try to speed up its reclaim.
> > +			 */
> > +			if (!ret && (PageDirty(page) || PageWriteback(page)))
> > +				deactivate_page(page);
> 
> The writeback completion handler does not take the page lock, so you
> can still miss pages that finish writeback before this test, no?

Yes. but I think it's rare and even though it happens, it's not critical.
> 
> Can you explain why you felt the need to add these checks?

invalidate_inode_page can return 0 although the pages is !{dirty|writeback}.
Look invalidate_complete_page. As easiest example, if the page has buffer and
try_to_release_page can't release the buffer, it could return 0.

I want to check this.

> 
> Thanks!
> 
> 	Hannes

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
