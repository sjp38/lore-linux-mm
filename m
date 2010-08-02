Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A32586B02E2
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 00:13:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o724DNcH005082
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Aug 2010 13:13:24 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B04F345DE54
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 13:13:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8943645DE51
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 13:13:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 67DD0EF8002
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 13:13:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 191281DB804C
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 13:13:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: synchronous lumpy reclaim don't call congestion_wait()
In-Reply-To: <20100801134117.GA2034@barrios-desktop>
References: <20100801180751.4B0E.A69D9226@jp.fujitsu.com> <20100801134117.GA2034@barrios-desktop>
Message-Id: <20100802131016.4F7D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 Aug 2010 13:13:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

> Hi KOSAKI, 
> 
> On Sun, Aug 01, 2010 at 06:12:47PM +0900, KOSAKI Motohiro wrote:
> > rebased onto Wu's patch
> > 
> > ----------------------------------------------
> > From 35772ad03e202c1c9a2252de3a9d3715e30d180f Mon Sep 17 00:00:00 2001
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Date: Sun, 1 Aug 2010 17:23:41 +0900
> > Subject: [PATCH] vmscan: synchronous lumpy reclaim don't call congestion_wait()
> > 
> > congestion_wait() mean "waiting for number of requests in IO queue is
> > under congestion threshold".
> > That said, if the system have plenty dirty pages, flusher thread push
> > new request to IO queue conteniously. So, IO queue are not cleared
> > congestion status for a long time. thus, congestion_wait(HZ/10) is
> > almostly equivalent schedule_timeout(HZ/10).
> Just a nitpick. 
> Why is it a problem?
> HZ/10 is upper bound we intended.  If is is rahter high, we can low it. 
> But totally I agree on this patch. It would be better to remove it 
> than lowing. 

because all of _unnecessary_ sleep is evil. the problem is, congestion_wait()
mean "wait until queue congestion will be cleared, iow, wait all of IO". 
but we want to wait until _my_ IO finished.

So, if flusher thread conteniously push new IO into the queue, that makes
big difference.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
