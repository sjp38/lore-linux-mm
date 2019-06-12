Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88688C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EC1220B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:57:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EC1220B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82A196B0010; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B3CC6B0266; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B6956B026A; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7686B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so12951922pfj.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:57:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=lrPPZ8NiUUMLO+yAkhLtS4Iy/Ao4Mc5vCsF4KS5LBdo=;
        b=AaRyVqbeEmeUBcpH+irFZSuQpqpdQ0qZVD0YYYixAT3n9jhU5hO8bFshyNIGJMYgc2
         1jx0RLF7G3b1A5BDXC0Z2UxoNFLd9t5AM/NdTLmo3UpTUiSlp4/5tEdP3xH6Hg1suoCU
         PEBMYFn01DcR3DQH7gL7aw4jZbH9PGRcezL1UFcchEJcSjOtm0IzImv7oEhl8erS7lVp
         05UChgo0/Ws+fz20ueNkDlshRM9N6NzugAlor0qzNoD8r/LMsZBQZDpV0dgyRvkE7ui4
         lA6LjGc8DmfjEsygNnOq96iw/hVEKVzWygM47H2TeNgZd5YYDTrkqmrGu/39pBHMcmyb
         UbPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVVKX+FilXhmp0AEzgqdU+1AeaDA+XoU3vY101ggOxzqrxFwfxj
	4gE2UrVO9RLjz9L4LGqC+zlkJysWwGHHyZDT/1pkpfuDB1rEkL0orT986G91QqqHZ1fLodImzFS
	cDY5SnjS4rBIHzGYWe2/VXtSgLk1hyxzT0bzIX2p8vNNpRdLyhiUwB5K/xZ8+3L08lw==
X-Received: by 2002:aa7:8ac9:: with SMTP id b9mr78530703pfd.260.1560376637578;
        Wed, 12 Jun 2019 14:57:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxN7sqxDwYvIfmFNNTbGpE4Gq2zHXAzFnCI+dwrKWVhNdA3rU5I+WCyh2OXg2pm/z1e293v
X-Received: by 2002:aa7:8ac9:: with SMTP id b9mr78530642pfd.260.1560376636097;
        Wed, 12 Jun 2019 14:57:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560376636; cv=none;
        d=google.com; s=arc-20160816;
        b=HlE/xr9Bkpy5f5Bia3yTt8OjjP/UyFX4aubFFUUhFq9S+6KHMUtfAe5Qe1h4j6DT3c
         83H30s07dcwG9fnl8RxPzds8OcVpU6Gq0+GyggX/GE2Gh6yXsfiRdt7iZefWqBXxFKe3
         Tjq9DiMTmGSC8eu66QvXmzPK9B/Iij99dkqQZ888if+YQlrYQ114jBY/0Oikzv0XklPl
         QJ02l7pyCQMf9G8slaJW3gzQ/f6qMBNs4bsjcjF/jBK5sxJLsqjaYGUz/Sv+3PdGuh/1
         pa61MDje9gODHLIxPy0MlIUYZO5c8vqYL5OmFmoWYru7JOI6icPBh2Hw09xIHaczzgMZ
         kS/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=lrPPZ8NiUUMLO+yAkhLtS4Iy/Ao4Mc5vCsF4KS5LBdo=;
        b=QNdX5vleGeOZcIodoVW2VJc4Q8d4XSPfl0+yLFrmpExiUIG/sr2aPj179FJsHqiGee
         38autqigT43NC4ohXVl9Pumg0r8pR24k6wLx7H5wQhsvVzZVydCL2ApyY7VNyR0ml+D5
         UK2snqMEflgLvgwgrsd7wllvv/20++y9Gw1FnIL0k3hW9xuDiauj3YdSG3JCzTH9q+v5
         LcmnDHsRWDheEAl1y8ywzgJUVNsKb8gNVW68/hTagPSkdiz6mbQ1cbFfQzocwmR+DEPH
         Hc2ZXF/DySXzEMbXLgFNuKFsUYVIIRdGtro8XyGYia57RSv5/J2gbrJHRWDOYsuhAYj8
         nkNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id i124si103259pfe.139.2019.06.12.14.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 14:57:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU0Hbt._1560376624;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU0Hbt._1560376624)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 05:57:13 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 1/4] mm: thp: extract split_queue_* into a struct
Date: Thu, 13 Jun 2019 05:56:46 +0800
Message-Id: <1560376609-113689-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Put split_queue, split_queue_lock and split_queue_len into a struct in
order to reduce code duplication when we convert deferred_split to memcg
aware in the later patches.

Suggested-by: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mmzone.h | 12 +++++++++---
 mm/huge_memory.c       | 45 +++++++++++++++++++++++++--------------------
 mm/page_alloc.c        |  8 +++++---
 3 files changed, 39 insertions(+), 26 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394ca..7799166 100644
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
index 9f8bce9..81cf759 100644
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
index 3b13d39..a82104a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6581,9 +6581,11 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
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

