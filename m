Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 666786B0088
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 10:57:11 -0500 (EST)
Date: Tue, 7 Dec 2010 16:56:46 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-ID: <20101207155645.GG2356@cmpxchg.org>
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
 <20101207144923.GB2356@cmpxchg.org>
 <20101207150710.GA26613@barrios-desktop>
 <20101207151939.GF2356@cmpxchg.org>
 <20101207152625.GB608@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101207152625.GB608@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 12:26:25AM +0900, Minchan Kim wrote:
> On Tue, Dec 07, 2010 at 04:19:39PM +0100, Johannes Weiner wrote:
> > On Wed, Dec 08, 2010 at 12:07:10AM +0900, Minchan Kim wrote:
> > > On Tue, Dec 07, 2010 at 03:49:24PM +0100, Johannes Weiner wrote:
> > > > On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
> > > > > Changelog since v3:
> > > > >  - Change function comments - suggested by Johannes
> > > > >  - Change function name - suggested by Johannes
> > > > >  - add only dirty/writeback pages to deactive pagevec
> > > > 
> > > > Why the extra check?
> > > > 
> > > > > @@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
> > > > >  			if (lock_failed)
> > > > >  				continue;
> > > > >  
> > > > > -			ret += invalidate_inode_page(page);
> > > > > -
> > > > > +			ret = invalidate_inode_page(page);
> > > > > +			/*
> > > > > +			 * If the page is dirty or under writeback, we can not
> > > > > +			 * invalidate it now.  But we assume that attempted
> > > > > +			 * invalidation is a hint that the page is no longer
> > > > > +			 * of interest and try to speed up its reclaim.
> > > > > +			 */
> > > > > +			if (!ret && (PageDirty(page) || PageWriteback(page)))
> > > > > +				deactivate_page(page);
> > > > 
> > > > The writeback completion handler does not take the page lock, so you
> > > > can still miss pages that finish writeback before this test, no?
> > > 
> > > Yes. but I think it's rare and even though it happens, it's not critical.
> > > > 
> > > > Can you explain why you felt the need to add these checks?
> > > 
> > > invalidate_inode_page can return 0 although the pages is !{dirty|writeback}.
> > > Look invalidate_complete_page. As easiest example, if the page has buffer and
> > > try_to_release_page can't release the buffer, it could return 0.
> > 
> > Ok, but somebody still tried to truncate the page, so why shouldn't we
> > try to reclaim it?  The reason for deactivating at this location is
> > that truncation is a strong hint for reclaim, not that it failed due
> > to dirty/writeback pages.
> > 
> > What's the problem with deactivating pages where try_to_release_page()
> > failed?
> 
> If try_to_release_page fails and the such pages stay long time in pagevec,
> pagevec drain often happens.

You mean because the pagevec becomes full more often?  These are not
many pages you get extra without the checks, the race window is very
small after all.

> I think such pages are rare so skip such pages doesn't hurt goal of
> this patch.

Well, you add extra checks, extra detail to this mechanism.  Instead
of just saying 'tried to truncate, failed, deactivate the page', you
add more ifs and buts.

There should be a real justification for it.  'It can not hurt' is not
a good justification for extra code and making a simple model more
complex.

'It will hurt without treating these pages differently' is a good
justification.  Remember that we have to understand and maintain all
this.  The less checks and operations we need to implement a certain
idea, the better.

Sorry for being so adamant about this, but I think these random checks
are a really sore point of mm code already.

[ For example, we tried discussing lumpy reclaim mode recently and
  none of us could reliably remember how it actually behaved.  There
  are so many special conditions in there that we already end up with
  some of them being dead code and the checks even contradicting each
  other. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
