Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9786E6B00B6
	for <linux-mm@kvack.org>; Tue, 12 May 2009 23:07:43 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D37VNs025944
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 12:07:31 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71AB645DE52
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:07:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5204545DE51
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:07:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36BC51DB803F
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:07:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E9CD81DB803C
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:07:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/4] vmscan: zone_reclaim use may_swap
In-Reply-To: <20090513120155.5879.A69D9226@jp.fujitsu.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com>
Message-Id: <20090513120651.5882.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 12:07:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] vmscan: zone_reclaim use may_swap

Documentation/sysctl/vm.txt says

	zone_reclaim_mode:

	Zone_reclaim_mode allows someone to set more or less aggressive approaches to
	reclaim memory when a zone runs out of memory. If it is set to zero then no
	zone reclaim occurs. Allocations will be satisfied from other zones / nodes
	in the system.

	This is value ORed together of

	1	= Zone reclaim on
	2	= Zone reclaim writes dirty pages out
	4	= Zone reclaim swaps pages


So, "(zone_reclaim_mode & RECLAIM_SWAP) == 0" mean we don't want to reclaim
swap-backed pages. not mapped file.

Thus, may_swap is better than may_unmap.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2387,8 +2387,8 @@ static int __zone_reclaim(struct zone *z
 	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.may_swap = 1,
+		.may_unmap = 1,
+		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
