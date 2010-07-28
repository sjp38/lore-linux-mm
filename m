Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 119356B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 05:43:45 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S9hiN1029636
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 28 Jul 2010 18:43:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1050945DE54
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 18:43:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AECE45DE4F
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 18:43:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B0B3E38007
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 18:43:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C59E08007
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 18:43:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
In-Reply-To: <20100728091032.GD5300@csn.ul.ie>
References: <20100728084654.GA26776@localhost> <20100728091032.GD5300@csn.ul.ie>
Message-Id: <20100728183625.4A7F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 28 Jul 2010 18:43:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jul 28, 2010 at 04:46:54PM +0800, Wu Fengguang wrote:
> > The wait_on_page_writeback() call inside pageout() is virtually dead co=
de.
> >=20
> >         shrink_inactive_list()
> >           shrink_page_list(PAGEOUT_IO_ASYNC)
> >             pageout(PAGEOUT_IO_ASYNC)
> >           shrink_page_list(PAGEOUT_IO_SYNC)
> >             pageout(PAGEOUT_IO_SYNC)
> >=20
> > Because shrink_page_list/pageout(PAGEOUT_IO_SYNC) is always called afte=
r
> > a preceding shrink_page_list/pageout(PAGEOUT_IO_ASYNC), the first
> > pageout(ASYNC) converts dirty pages into writeback pages, the second
> > shrink_page_list(SYNC) waits on the clean of writeback pages before
> > calling pageout(SYNC). The second shrink_page_list(SYNC) can hardly run
> > into dirty pages for pageout(SYNC) unless in some race conditions.
> >=20
>=20
> It's possible for the second call to run into dirty pages as there is a
> congestion_wait() call between the first shrink_page_list() call and the
> second. That's a big window.
>=20
> > And the wait page-by-page behavior of pageout(SYNC) will lead to very
> > long stall time if running into some range of dirty pages.
>=20
> True, but this is also lumpy reclaim which is depending on a contiguous
> range of pages. It's better for it to wait on the selected range of pages
> which is known to contain at least one old page than excessively scan and
> reclaim newer pages.

Today, I was successful to reproduce the Andres's issue. and I disagree thi=
s
opinion.
The root cause is, congestion_wait() mean "wait until clear io congestion".=
 but
if the system have plenty dirty pages, flusher threads are issueing IO cont=
eniously.
So, io congestion is not cleared long time. eventually, congestion_wait(BLK=
_RW_ASYNC, HZ/10)
become to equivalent to sleep(HZ/10).

I would propose followint patch instead.

And I've found synchronous lumpy reclaim have more serious problem. I woule=
 like to
explain it as another mail.

Thanks.



=46rom 0266fb2c23aef659cd4e89fccfeb464f23257b74 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 27 Jul 2010 14:36:44 +0900
Subject: [PATCH] vmscan: synchronous lumpy reclaim don't call congestion_wa=
it()

congestion_wait() mean "waiting for number of requests in IO queue is
under congestion threshold".
That said, if the system have plenty dirty pages, flusher thread push
new request to IO queue conteniously. So, IO queue are not cleared
congestion status for a long time. thus, congestion_wait(HZ/10) is
almostly equivalent schedule_timeout(HZ/10).

If the system 512MB memory, DEF_PRIORITY mean 128kB scan and 4096 times
shrink_inactive_list call. 4096 times 0.1sec stall makes crazy insane
long stall. That shouldn't.

In the other hand, this synchronous lumpy reclaim donesn't need this
congestion_wait() at all. shrink_page_list(PAGEOUT_IO_SYNC) cause to
call wait_on_page_writeback() and it provide sufficient waiting.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97170eb..2aa16eb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1304,8 +1304,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct=
 zone *zone,
 	 */
 	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
 			sc->lumpy_reclaim_mode) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
-
 		/*
 		 * The attempt at page out may have made some
 		 * of the pages active, mark them inactive again.
--=20
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
