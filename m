Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id EF2CE6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 15:03:57 -0500 (EST)
Received: by pdjp10 with SMTP id p10so22840370pdj.10
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 12:03:57 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id uc9si6209763pbc.189.2015.03.04.12.03.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 12:03:56 -0800 (PST)
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t24K2Mlf002355
	for <linux-mm@kvack.org>; Wed, 4 Mar 2015 12:03:55 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1sx4sr0kpp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Mar 2015 12:03:55 -0800
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 95631c02c2a911e4be880002c9521c9e-281ea390 for <linux-mm@kvack.org>;	Wed, 04
 Mar 2015 12:03:54 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH] vmscan: get_scan_count selects anon pages conservative
Date: Wed, 4 Mar 2015 12:03:53 -0800
Message-ID: <d8192a90f6f9b474b33ec732b88b8b2d7e8623cd.1425499261.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

kswapd is a per-node based. Sometimes there is imbalance between nodes,
node A is full of clean file pages (easy to reclaim), node B is
full of anon pages (hard to reclaim). With memory pressure, kswapd will
be waken up for both nodes. The kswapd of node B will try to swap, while
we prefer reclaim pages from node A first. The real issue here is we
don't have a mechanism to prevent memory allocation from a hard-reclaim
node (node B here) if there is an easy-reclaim node (node A) to reclaim
memory.

The swap can happen even with swapiness 0. Below is a simple script to
trigger it. cpu 1 and 8 are in different node, each has 72G memory:
truncate -s 70G img
taskset -c 8 dd if=img of=/dev/null bs=4k
taskset -c 1 usemem 70G

The swap can even easier to trigger because we have a protect mechanism
for situation file pages are less than high watermark. This logic makes
sense but could be more conservative.

This patch doesn't try to fix the kswapd imbalance issue above, but make
get_scan_count more conservative to select anon pages. The protect
mechanism is designed for situation file pages are rotated frequently.
In that situation, page reclaim should be in trouble, eg, priority is
lower. So let's only apply the protect mechanism in that situation. In
pratice, this fixes the swap issue in above test.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..31b03e6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1990,7 +1990,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * thrashing file LRU becomes infinitely more attractive than
 	 * anon pages.  Try to detect this based on file LRU size.
 	 */
-	if (global_reclaim(sc)) {
+	if (global_reclaim(sc) && sc->priority < DEF_PRIORITY - 2) {
 		unsigned long zonefile;
 		unsigned long zonefree;
 
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
