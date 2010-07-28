Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 656DA6B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:00:04 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6SA00Bv031488
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 28 Jul 2010 19:00:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D2645DE4F
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 19:00:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 78E0F45DE51
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 19:00:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 407B41DB8018
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 19:00:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E0E1DB8012
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 18:59:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
In-Reply-To: <20100728095058.GF5300@csn.ul.ie>
References: <20100728183625.4A7F.A69D9226@jp.fujitsu.com> <20100728095058.GF5300@csn.ul.ie>
Message-Id: <20100728185457.4A82.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Jul 2010 18:59:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jul 28, 2010 at 06:43:41PM +0900, KOSAKI Motohiro wrote:
> > > On Wed, Jul 28, 2010 at 04:46:54PM +0800, Wu Fengguang wrote:
> > > > The wait_on_page_writeback() call inside pageout() is virtually dead code.
> > > > 
> > > >         shrink_inactive_list()
> > > >           shrink_page_list(PAGEOUT_IO_ASYNC)
> > > >             pageout(PAGEOUT_IO_ASYNC)
> > > >           shrink_page_list(PAGEOUT_IO_SYNC)
> > > >             pageout(PAGEOUT_IO_SYNC)
> > > > 
> > > > Because shrink_page_list/pageout(PAGEOUT_IO_SYNC) is always called after
> > > > a preceding shrink_page_list/pageout(PAGEOUT_IO_ASYNC), the first
> > > > pageout(ASYNC) converts dirty pages into writeback pages, the second
> > > > shrink_page_list(SYNC) waits on the clean of writeback pages before
> > > > calling pageout(SYNC). The second shrink_page_list(SYNC) can hardly run
> > > > into dirty pages for pageout(SYNC) unless in some race conditions.
> > > > 
> > > 
> > > It's possible for the second call to run into dirty pages as there is a
> > > congestion_wait() call between the first shrink_page_list() call and the
> > > second. That's a big window.
> > > 
> > > > And the wait page-by-page behavior of pageout(SYNC) will lead to very
> > > > long stall time if running into some range of dirty pages.
> > > 
> > > True, but this is also lumpy reclaim which is depending on a contiguous
> > > range of pages. It's better for it to wait on the selected range of pages
> > > which is known to contain at least one old page than excessively scan and
> > > reclaim newer pages.
> > 
> > Today, I was successful to reproduce the Andres's issue. and I disagree this
> > opinion.
> 
> Is Andres's issue not covered by the patch "vmscan: raise the bar to
> PAGEOUT_IO_SYNC stalls" because wait_on_page_writeback() was the
> main problem?

Well, "vmscan: raise the bar to PAGEOUT_IO_SYNC stalls" is completely bandaid and
much IO under slow USB flash memory device still cause such problem even if the patch is applied.

But removing wait_on_page_writeback() doesn't solve the issue perfectly because current
lumpy reclaim have multiple sick. again, I'm writing explaining mail.....



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
