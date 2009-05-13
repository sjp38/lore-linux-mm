Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F28B96B00B9
	for <linux-mm@kvack.org>; Tue, 12 May 2009 23:08:08 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D38DpA005671
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 12:08:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E52945DE50
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:08:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E9F845DE53
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:08:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 459B71DB803F
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:08:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E75631DB803E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:08:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <20090513120155.5879.A69D9226@jp.fujitsu.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com>
Message-Id: <20090513120729.5885.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 12:08:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] zone_reclaim_mode is always 0 by default

Current linux policy is, if the machine has large remote node distance,
 zone_reclaim_mode is enabled by default because we've be able to assume to 
large distance mean large server until recently.

Unfrotunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
memory controller. IOW it's NUMA from software view.

Some Core i7 machine has large remote node distance and zone_reclaim don't
fit desktop and small file server. it cause performance degression.

Thus, zone_reclaim == 0 is better by default. sorry, HPC gusy. 
you need to turn zone_reclaim_mode on manually now.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c |    7 -------
 1 file changed, 7 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2494,13 +2494,6 @@ static void build_zonelists(pg_data_t *p
 		int distance = node_distance(local_node, node);
 
 		/*
-		 * If another node is sufficiently far away then it is better
-		 * to reclaim pages in a zone before going off node.
-		 */
-		if (distance > RECLAIM_DISTANCE)
-			zone_reclaim_mode = 1;
-
-		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
 		 * distance group to make it round-robin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
