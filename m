Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDE58E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 21:00:13 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u195-v6so6059445ith.2
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 18:00:13 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o186-v6si10518420ith.83.2018.09.10.18.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 18:00:12 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 5/8] mm: enable concurrent LRU removals
Date: Mon, 10 Sep 2018 20:59:46 -0400
Message-Id: <20180911005949.5635-2-daniel.m.jordan@oracle.com>
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

The previous patch used the concurrent algorithm serially to see that it
was stable for one task.  Now in release_pages, take lru_lock as reader
instead of writer to allow concurrent removals from one or more LRUs.

Suggested-by: Yosef Lev <levyossi@icloud.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swap.c | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 613b841bd208..b1030eb7f459 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -737,8 +737,8 @@ void release_pages(struct page **pages, int nr)
 		 * same pgdat. The lock is held only if pgdat != NULL.
 		 */
 		if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
-			write_unlock_irqrestore(&locked_pgdat->lru_lock,
-						flags);
+			read_unlock_irqrestore(&locked_pgdat->lru_lock,
+					       flags);
 			locked_pgdat = NULL;
 		}
 
@@ -748,9 +748,8 @@ void release_pages(struct page **pages, int nr)
 		/* Device public page can not be huge page */
 		if (is_device_public_page(page)) {
 			if (locked_pgdat) {
-				write_unlock_irqrestore(
-						      &locked_pgdat->lru_lock,
-						      flags);
+				read_unlock_irqrestore(&locked_pgdat->lru_lock,
+						       flags);
 				locked_pgdat = NULL;
 			}
 			put_zone_device_private_or_public_page(page);
@@ -763,9 +762,8 @@ void release_pages(struct page **pages, int nr)
 
 		if (PageCompound(page)) {
 			if (locked_pgdat) {
-				write_unlock_irqrestore(
-						      &locked_pgdat->lru_lock,
-						      flags);
+				read_unlock_irqrestore(&locked_pgdat->lru_lock,
+						       flags);
 				locked_pgdat = NULL;
 			}
 			__put_compound_page(page);
@@ -776,14 +774,14 @@ void release_pages(struct page **pages, int nr)
 			struct pglist_data *pgdat = page_pgdat(page);
 
 			if (pgdat != locked_pgdat) {
-				if (locked_pgdat) {
-					write_unlock_irqrestore(
-					      &locked_pgdat->lru_lock, flags);
-				}
+				if (locked_pgdat)
+					read_unlock_irqrestore(
+						      &locked_pgdat->lru_lock,
+						      flags);
 				lock_batch = 0;
 				locked_pgdat = pgdat;
-				write_lock_irqsave(&locked_pgdat->lru_lock,
-						   flags);
+				read_lock_irqsave(&locked_pgdat->lru_lock,
+						  flags);
 			}
 
 			lruvec = mem_cgroup_page_lruvec(page, locked_pgdat);
@@ -800,7 +798,7 @@ void release_pages(struct page **pages, int nr)
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (locked_pgdat)
-		write_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+		read_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_unref_page_list(&pages_to_free);
-- 
2.18.0
