Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8AE8E0008
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so15212809pgt.11
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226133352.303666865@intel.com>
Date: Wed, 26 Dec 2018 21:15:07 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 21/21] mm/vmscan.c: shrink anon list if can migrate to PMEM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0013-vmscan-disable-0-swap-space-optimization.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

Fix OOM by making in-kernel DRAM=>PMEM migration reachable.

Here we assume these 2 possible demotion paths:
- DRAM migrate to PMEM
- PMEM to swap device

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux.orig/mm/vmscan.c	2018-12-23 20:38:44.310446223 +0800
+++ linux/mm/vmscan.c	2018-12-23 20:38:44.306446146 +0800
@@ -2259,7 +2259,7 @@ static bool inactive_list_is_low(struct
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
 	 */
-	if (!file && !total_swap_pages)
+	if (!file && (is_node_pmem(pgdat->node_id) && !total_swap_pages))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2340,7 +2340,8 @@ static void get_scan_count(struct lruvec
 	enum lru_list lru;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
+	if (is_node_pmem(pgdat->node_id) &&
+	    (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
