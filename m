Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 511AA6B000C
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 14:48:20 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id n8-v6so1181630ybo.9
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 11:48:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n186-v6sor2343296ywc.51.2018.10.09.11.48.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 11:48:19 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Date: Tue,  9 Oct 2018 14:47:32 -0400
Message-Id: <20181009184732.762-4-hannes@cmpxchg.org>
In-Reply-To: <20181009184732.762-1-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Make it easier to catch bugs in the shadow node shrinker by adding a
counter for the shadow nodes in circulation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  1 +
 mm/vmstat.c            |  1 +
 mm/workingset.c        | 12 ++++++++++--
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4179e67add3d..d82e80d82aa6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -161,6 +161,7 @@ enum node_stat_item {
 	NR_SLAB_UNRECLAIMABLE,
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
+	WORKINGSET_NODES,
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_RESTORE,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d08ed044759d..6038ce593ce3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1143,6 +1143,7 @@ const char * const vmstat_text[] = {
 	"nr_slab_unreclaimable",
 	"nr_isolated_anon",
 	"nr_isolated_file",
+	"workingset_nodes",
 	"workingset_refault",
 	"workingset_activate",
 	"workingset_restore",
diff --git a/mm/workingset.c b/mm/workingset.c
index f564aaa6b71d..cfdf6adf7e7c 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -378,11 +378,17 @@ void workingset_update_node(struct xa_node *node)
 	 * as node->private_list is protected by the i_pages lock.
 	 */
 	if (node->count && node->count == node->nr_values) {
-		if (list_empty(&node->private_list))
+		if (list_empty(&node->private_list)) {
 			list_lru_add(&shadow_nodes, &node->private_list);
+			__inc_lruvec_page_state(virt_to_page(node),
+						WORKINGSET_NODES);
+		}
 	} else {
-		if (!list_empty(&node->private_list))
+		if (!list_empty(&node->private_list)) {
 			list_lru_del(&shadow_nodes, &node->private_list);
+			__dec_lruvec_page_state(virt_to_page(node),
+						WORKINGSET_NODES);
+		}
 	}
 }
 
@@ -472,6 +478,8 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	}
 
 	list_lru_isolate(lru, item);
+	__dec_lruvec_page_state(virt_to_page(node), WORKINGSET_NODES);
+
 	spin_unlock(lru_lock);
 
 	/*
-- 
2.19.0
