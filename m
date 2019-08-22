Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AB07C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 17:50:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8D342133F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 17:50:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8D342133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 339656B0345; Thu, 22 Aug 2019 13:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E9726B0346; Thu, 22 Aug 2019 13:50:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B2DD6B0347; Thu, 22 Aug 2019 13:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id EDB886B0345
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:50:42 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 80B25181AC9B4
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:50:42 +0000 (UTC)
X-FDA: 75850803924.12.blood74_231ca46a62639
X-HE-Tag: blood74_231ca46a62639
X-Filterd-Recvd-Size: 9454
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com [115.124.30.42])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:50:40 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0Ta9PNTk_1566496230;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0Ta9PNTk_1566496230)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 23 Aug 2019 01:50:37 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	cai@lca.pw,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v6 PATCH 1/4] mm: thp: extract split_queue_* into a struct
Date: Fri, 23 Aug 2019 01:50:24 +0800
Message-Id: <1566496227-84952-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566496227-84952-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1566496227-84952-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Put split_queue, split_queue_lock and split_queue_len into a struct in
order to reduce code duplication when we convert deferred_split to memcg
aware in the later patches.

Suggested-by: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Qian Cai <cai@lca.pw>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mmzone.h | 12 +++++++++---
 mm/huge_memory.c       | 45 +++++++++++++++++++++++++--------------------
 mm/page_alloc.c        |  8 +++++---
 3 files changed, 39 insertions(+), 26 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717..d8ec773 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -676,6 +676,14 @@ struct zonelist {
 extern struct page *mem_map;
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct deferred_split {
+	spinlock_t split_queue_lock;
+	struct list_head split_queue;
+	unsigned long split_queue_len;
+};
+#endif
+
 /*
  * On NUMA machines, each NUMA node would have a pg_data_t to describe
  * it's memory layout. On UMA machines there is a single pglist_data which
@@ -755,9 +763,7 @@ struct zonelist {
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	spinlock_t split_queue_lock;
-	struct list_head split_queue;
-	unsigned long split_queue_len;
+	struct deferred_split deferred_split_queue;
 #endif
 
 	/* Fields commonly accessed by the page reclaim scanner */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1334ede..e0d8e08 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2658,6 +2658,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct page *head = compound_head(page);
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
+	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
 	struct anon_vma *anon_vma = NULL;
 	struct address_space *mapping = NULL;
 	int count, mapcount, extra_pins, ret;
@@ -2744,17 +2745,17 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	/* Prevent deferred_split_scan() touching ->_refcount */
-	spin_lock(&pgdata->split_queue_lock);
+	spin_lock(&ds_queue->split_queue_lock);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
 	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
 		if (!list_empty(page_deferred_list(head))) {
-			pgdata->split_queue_len--;
+			ds_queue->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
-		spin_unlock(&pgdata->split_queue_lock);
+		spin_unlock(&ds_queue->split_queue_lock);
 		__split_huge_page(page, list, end, flags);
 		if (PageSwapCache(head)) {
 			swp_entry_t entry = { .val = page_private(head) };
@@ -2771,7 +2772,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			dump_page(page, "total_mapcount(head) > 0");
 			BUG();
 		}
-		spin_unlock(&pgdata->split_queue_lock);
+		spin_unlock(&ds_queue->split_queue_lock);
 fail:		if (mapping)
 			xa_unlock(&mapping->i_pages);
 		spin_unlock_irqrestore(&pgdata->lru_lock, flags);
@@ -2794,52 +2795,56 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 void free_transhuge_page(struct page *page)
 {
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
+	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
 	unsigned long flags;
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	if (!list_empty(page_deferred_list(page))) {
-		pgdata->split_queue_len--;
+		ds_queue->split_queue_len--;
 		list_del(page_deferred_list(page));
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 	free_compound_page(page);
 }
 
 void deferred_split_huge_page(struct page *page)
 {
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
+	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	if (list_empty(page_deferred_list(page))) {
 		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
-		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
-		pgdata->split_queue_len++;
+		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
+		ds_queue->split_queue_len++;
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 }
 
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	return READ_ONCE(pgdata->split_queue_len);
+	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	return READ_ONCE(ds_queue->split_queue_len);
 }
 
 static unsigned long deferred_split_scan(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
+	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
 	unsigned long flags;
 	LIST_HEAD(list), *pos, *next;
 	struct page *page;
 	int split = 0;
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	/* Take pin on all head pages to avoid freeing them under us */
-	list_for_each_safe(pos, next, &pgdata->split_queue) {
+	list_for_each_safe(pos, next, &ds_queue->split_queue) {
 		page = list_entry((void *)pos, struct page, mapping);
 		page = compound_head(page);
 		if (get_page_unless_zero(page)) {
@@ -2847,12 +2852,12 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		} else {
 			/* We lost race with put_compound_page() */
 			list_del_init(page_deferred_list(page));
-			pgdata->split_queue_len--;
+			ds_queue->split_queue_len--;
 		}
 		if (!--sc->nr_to_scan)
 			break;
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
@@ -2866,15 +2871,15 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		put_page(page);
 	}
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	list_splice_tail(&list, &pgdata->split_queue);
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
+	list_splice_tail(&list, &ds_queue->split_queue);
+	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 
 	/*
 	 * Stop shrinker if we didn't split any page, but the queue is empty.
 	 * This can happen if pages were freed under us.
 	 */
-	if (!split && list_empty(&pgdata->split_queue))
+	if (!split && list_empty(&ds_queue->split_queue))
 		return SHRINK_STOP;
 	return split;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de..df02a88 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6649,9 +6649,11 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static void pgdat_init_split_queue(struct pglist_data *pgdat)
 {
-	spin_lock_init(&pgdat->split_queue_lock);
-	INIT_LIST_HEAD(&pgdat->split_queue);
-	pgdat->split_queue_len = 0;
+	struct deferred_split *ds_queue = &pgdat->deferred_split_queue;
+
+	spin_lock_init(&ds_queue->split_queue_lock);
+	INIT_LIST_HEAD(&ds_queue->split_queue);
+	ds_queue->split_queue_len = 0;
 }
 #else
 static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
-- 
1.8.3.1


