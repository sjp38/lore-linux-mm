Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BCB36B02A4
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 06:43:24 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6PAhMfU006354
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 25 Jul 2010 19:43:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0419F45DE79
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 19:43:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4B2345DE6F
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 19:43:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B00C21DB8040
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 19:43:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ACC21DB803A
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 19:43:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background writeback
In-Reply-To: <20100723105719.GE5300@csn.ul.ie>
References: <20100723094515.GD5043@localhost> <20100723105719.GE5300@csn.ul.ie>
Message-Id: <20100725192955.40D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 25 Jul 2010 19:43:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

sorry for the delay.

> Will you be picking it up or should I? The changelog should be more or less
> the same as yours and consider it
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> It'd be nice if the original tester is still knocking around and willing
> to confirm the patch resolves his/her problem. I am running this patch on
> my desktop at the moment and it does feel a little smoother but it might be
> my imagination. I had trouble with odd stalls that I never pinned down and
> was attributing to the machine being commonly heavily loaded but I haven't
> noticed them today.
> 
> It also needs an Acked-by or Reviewed-by from Kosaki Motohiro as it alters
> logic he introduced in commit [78dc583: vmscan: low order lumpy reclaim also
> should use PAGEOUT_IO_SYNC]

My reviewing doesn't found any bug. however I think original thread have too many guess
and we need to know reproduce way and confirm it.

At least, we need three confirms.
 o original issue is still there?
 o DEF_PRIORITY/3 is best value?
 o Current approach have better performance than Wu's original proposal? (below)


Anyway, please feel free to use my reviewed-by tag.

Thanks.



--- linux-next.orig/mm/vmscan.c	2010-06-24 14:32:03.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-22 16:12:34.000000000 +0800
@@ -1650,7 +1650,7 @@ static void set_lumpy_reclaim_mode(int p
 	 */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		sc->lumpy_reclaim_mode = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
+	else if (sc->order && priority < DEF_PRIORITY / 2)
 		sc->lumpy_reclaim_mode = 1;
 	else
 		sc->lumpy_reclaim_mode = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
