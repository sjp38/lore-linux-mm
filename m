Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 19EE96B006A
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:33:03 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECX0si025960
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:33:00 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 558A745DE4C
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:33:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 39EC845DE50
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:33:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 21D3C1DB8043
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:33:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C5C51DB803E
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:32:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 8/8] mm: Give up allocation if the task have fatal signal
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214213224.BBC6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:32:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

In OOM case, almost processes may be in vmscan. There isn't any reason
the killed process continue allocation. process exiting free lots pages
rather than greedy vmscan.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ca9cae1..8a9cbaa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1878,6 +1878,14 @@ rebalance:
 		goto got_pg;
 
 	/*
+	 * If the allocation is for userland page and we have fatal signal,
+	 * there isn't any reason to continue allocation. instead, the task
+	 * should exit soon.
+	 */
+	if (fatal_signal_pending(current) && (gfp_mask & __GFP_HIGHMEM))
+		goto nopage;
+
+	/*
 	 * If we failed to make any progress reclaiming, then we are
 	 * running out of options and have to consider going OOM
 	 */
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
