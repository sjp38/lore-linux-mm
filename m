Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 479CE6B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:11:52 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so50632218obc.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 15:11:52 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ht4si10512945obb.23.2015.03.31.15.11.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 15:11:51 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 1/2] mm: free large amount of 0-order pages in workqueue
Date: Tue, 31 Mar 2015 18:11:32 -0400
Message-Id: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mhocko@suse.cz, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Freeing pages became a rather costly operation, specially when multiple debug
options are enabled. This causes hangs when an attempt to free a large amount
of 0-order is made. Two examples are vfree()ing large block of memory, and
punching a hole in a shmem filesystem.

To avoid that, move any free operations that involve batching pages into a
list to a workqueue handler where they could be freed later.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/page_alloc.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 46 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5bd9711..812ca75 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1586,10 +1586,11 @@ out:
 	local_irq_restore(flags);
 }
 
-/*
- * Free a list of 0-order pages
- */
-void free_hot_cold_page_list(struct list_head *list, bool cold)
+static LIST_HEAD(free_hot_page_list);
+static LIST_HEAD(free_cold_page_list);
+static DEFINE_SPINLOCK(free_page_lock);
+
+static void __free_hot_cold_page_list(struct list_head *list, bool cold)
 {
 	struct page *page, *next;
 
@@ -1599,6 +1600,47 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 	}
 }
 
+static void free_page_lists_work(struct work_struct *work)
+{
+	LIST_HEAD(hot_pages);
+	LIST_HEAD(cold_pages);
+	unsigned long flags;
+
+	spin_lock_irqsave(&free_page_lock, flags);
+	list_cut_position(&hot_pages, &free_hot_page_list,
+					free_hot_page_list.prev);
+	list_cut_position(&cold_pages, &free_cold_page_list,
+					free_cold_page_list.prev);
+	spin_unlock_irqrestore(&free_page_lock, flags);
+
+	__free_hot_cold_page_list(&hot_pages, false);
+	__free_hot_cold_page_list(&cold_pages, true);
+}
+
+static DECLARE_WORK(free_page_work, free_page_lists_work);
+
+/*
+ * Free a list of 0-order pages
+ */
+void free_hot_cold_page_list(struct list_head *list, bool cold)
+{
+	unsigned long flags;
+
+	if (unlikely(!keventd_up())) {
+		__free_hot_cold_page_list(list, cold);
+		return;
+	}
+
+	spin_lock_irqsave(&free_page_lock, flags);
+	if(cold)
+		list_splice_tail(list, &free_cold_page_list);
+	else
+		list_splice_tail(list, &free_hot_page_list);
+	spin_unlock_irqrestore(&free_page_lock, flags);
+
+	schedule_work(&free_page_work);
+}
+
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
