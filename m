Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F2D6C6B008C
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 20:02:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB812OBX011954
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Dec 2010 10:02:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 511EF45DE6A
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:02:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3898045DD74
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:02:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC5541DB803B
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:02:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC263E18008
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:02:23 +0900 (JST)
Date: Wed, 8 Dec 2010 09:56:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-Id: <20101208095642.8128ab33.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=iNGT_p_VfW9GxdaKXLt2xBHM2jdwmCbF_u8uh@mail.gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
	<20101207144923.GB2356@cmpxchg.org>
	<20101207150710.GA26613@barrios-desktop>
	<20101207151939.GF2356@cmpxchg.org>
	<20101207152625.GB608@barrios-desktop>
	<20101207155645.GG2356@cmpxchg.org>
	<AANLkTi=iNGT_p_VfW9GxdaKXLt2xBHM2jdwmCbF_u8uh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010 07:51:25 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Dec 8, 2010 at 12:56 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Wed, Dec 08, 2010 at 12:26:25AM +0900, Minchan Kim wrote:
> >> On Tue, Dec 07, 2010 at 04:19:39PM +0100, Johannes Weiner wrote:
> >> > On Wed, Dec 08, 2010 at 12:07:10AM +0900, Minchan Kim wrote:
> >> > > On Tue, Dec 07, 2010 at 03:49:24PM +0100, Johannes Weiner wrote:
> >> > > > On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
> >> > > > > Changelog since v3:
> >> > > > > A - Change function comments - suggested by Johannes
> >> > > > > A - Change function name - suggested by Johannes
> >> > > > > A - add only dirty/writeback pages to deactive pagevec
> >> > > >
> >> > > > Why the extra check?
> >> > > >
> >> > > > > @@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
> >> > > > > A  A  A  A  A  A  A  A  A  A  A  if (lock_failed)
> >> > > > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  continue;
> >> > > > >
> >> > > > > - A  A  A  A  A  A  A  A  A  A  ret += invalidate_inode_page(page);
> >> > > > > -
> >> > > > > + A  A  A  A  A  A  A  A  A  A  ret = invalidate_inode_page(page);
> >> > > > > + A  A  A  A  A  A  A  A  A  A  /*
> >> > > > > + A  A  A  A  A  A  A  A  A  A  A * If the page is dirty or under writeback, we can not
> >> > > > > + A  A  A  A  A  A  A  A  A  A  A * invalidate it now. A But we assume that attempted
> >> > > > > + A  A  A  A  A  A  A  A  A  A  A * invalidation is a hint that the page is no longer
> >> > > > > + A  A  A  A  A  A  A  A  A  A  A * of interest and try to speed up its reclaim.
> >> > > > > + A  A  A  A  A  A  A  A  A  A  A */
> >> > > > > + A  A  A  A  A  A  A  A  A  A  if (!ret && (PageDirty(page) || PageWriteback(page)))
> >> > > > > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  deactivate_page(page);
> >> > > >
> >> > > > The writeback completion handler does not take the page lock, so you
> >> > > > can still miss pages that finish writeback before this test, no?
> >> > >
> >> > > Yes. but I think it's rare and even though it happens, it's not critical.
> >> > > >
> >> > > > Can you explain why you felt the need to add these checks?
> >> > >
> >> > > invalidate_inode_page can return 0 although the pages is !{dirty|writeback}.
> >> > > Look invalidate_complete_page. As easiest example, if the page has buffer and
> >> > > try_to_release_page can't release the buffer, it could return 0.
> >> >
> >> > Ok, but somebody still tried to truncate the page, so why shouldn't we
> >> > try to reclaim it? A The reason for deactivating at this location is
> >> > that truncation is a strong hint for reclaim, not that it failed due
> >> > to dirty/writeback pages.
> >> >
> >> > What's the problem with deactivating pages where try_to_release_page()
> >> > failed?
> >>
> >> If try_to_release_page fails and the such pages stay long time in pagevec,
> >> pagevec drain often happens.
> >
> > You mean because the pagevec becomes full more often? A These are not
> > many pages you get extra without the checks, the race window is very
> > small after all.
> 
> Right.
> It was a totally bad answer. The work in midnight makes my mind to be hurt. :)
> 
> Another point is that we can move such pages(!try_to_release_page,
> someone else holding the ref) into tail of inactive.
> We can't expect such pages will be freed sooner or later and it can
> stir lru pages unnecessary.
> On the other hand it's a _really_ rare so couldn't we move the pages into tail?
> If it can be justified, I will remove the check.
> What do you think about it?
> 

I wonder ...how about adding "victim" list for "Reclaim" pages ? Then, we don't need
extra LRU rotation.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
