Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA71B6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 05:15:19 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id oAUAAWkO002260
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:10:32 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAUAFGS82474078
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:15:16 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAUAFGvl018705
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:15:16 +1100
Subject: [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 30 Nov 2010 15:45:12 +0530
Message-ID: <20101130101506.17475.34536.stgit@localhost6.localdomain6>
In-Reply-To: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch moves zone_reclaim and associated helpers
outside CONFIG_NUMA. This infrastructure is reused
in the patches for page cache control that follow.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 include/linux/mmzone.h |    4 ++--
 mm/vmscan.c            |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4890662..aeede91 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -302,12 +302,12 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
-#ifdef CONFIG_NUMA
-	int node;
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
 	unsigned long		min_unmapped_pages;
+#ifdef CONFIG_NUMA
+	int node;
 	unsigned long		min_slab_pages;
 #endif
 	struct per_cpu_pageset __percpu *pageset;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8cc90d5..325443a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2644,7 +2644,6 @@ static int __init kswapd_init(void)
 
 module_init(kswapd_init)
 
-#ifdef CONFIG_NUMA
 /*
  * Zone reclaim mode
  *
@@ -2854,7 +2853,6 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	return ret;
 }
-#endif
 
 /*
  * page_evictable - test whether a page is evictable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
