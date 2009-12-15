Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF1A16B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:45:31 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF0jTOt012915
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 09:45:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E67A45DE59
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:45:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 292EA45DE51
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:45:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CD1E1DB8046
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:45:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B26781DB8043
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:45:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead prepare_to_wait()
In-Reply-To: <4B264CCA.5010609@redhat.com>
References: <20091214212936.BBBA.A69D9226@jp.fujitsu.com> <4B264CCA.5010609@redhat.com>
Message-Id: <20091215085631.CDAD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 15 Dec 2009 09:45:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> > if we don't use exclusive queue, wake_up() function wake _all_ waited
> > task. This is simply cpu wasting.
> >
> > Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> 
> >   		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
> >   					0, 0)) {
> > -			wake_up(wq);
> > +			wake_up_all(wq);
> >   			finish_wait(wq,&wait);
> >   			sc->nr_reclaimed += sc->nr_to_reclaim;
> >   			return -ERESTARTSYS;
> 
> I believe we want to wake the processes up one at a time
> here.  If the queue of waiting processes is very large
> and the amount of excess free memory is fairly low, the
> first processes that wake up can take the amount of free
> memory back down below the threshold.  The rest of the
> waiters should stay asleep when this happens.

OK.

Actually, wake_up() and wake_up_all() aren't different so much.
Although we use wake_up(), the task wake up next task before
try to alloate memory. then, it's similar to wake_up_all().

However, there are few difference. recent scheduler latency improvement
effort reduce default scheduler latency target. it mean, if we have
lots tasks of running state, the task have very few time slice. too
frequently context switch decrease VM efficiency.
Thank you, Rik. I didn't notice wake_up() makes better performance than
wake_up_all() on current kernel.


Subject: [PATCH 9/8] replace wake_up_all with wake_up

Fix typo.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5adb7a..b3b4e77 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1644,7 +1644,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
 	return 0;
 
  found_lots_memory:
-	wake_up_all(wq);
+	wake_up(wq);
  stop_reclaim:
 	finish_wait(wq, &wait);
 	sc->nr_reclaimed += sc->nr_to_reclaim;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
