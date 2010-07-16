Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F20896B02A4
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 06:13:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6GADXvT006294
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Jul 2010 19:13:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B6F45DE6E
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:13:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E2D6045DE4D
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:13:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B58AFEF8001
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:13:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CE861DB803A
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:13:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
In-Reply-To: <20100716191006.7369.A69D9226@jp.fujitsu.com>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
Message-Id: <20100716191256.736C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Jul 2010 19:13:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently, mem_cgroup_shrink_node_zone() initialize sc.nr_to_reclaim as 0.
It mean shrink_zone() only scan 32 pages and immediately return even if
it doesn't reclaim any pages.

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1691ad0..bd1d035 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1932,6 +1932,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone, int nid)
 {
 	struct scan_control sc = {
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
