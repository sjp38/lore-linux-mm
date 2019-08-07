Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3A58C31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8636821743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:18:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8636821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D8C6B0282; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 881C26B0280; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54DC66B027E; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3686B0280
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t19so56084937pgh.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 19:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wKDd6yINnW0YWActj13+KXIn9ppzHTAKH5mNS4QaN/8=;
        b=L5m1gGG97x5IxnfHCo6fHglwnV/1RjeC5otd4ENTzXfOHEA6i2spYwN+eStrZ4/a5q
         9nne0DRSANyXdKl0meGiW8KSwKAMnpoAYt6ZSkZQt1HdHMzefkLjPOpBedfwD1UzXXMP
         JCWs1kvImA+vNe8AhyBGl0TQJE4Ot3vu8MvWwPGBmvY41JWKvwBuZWJY20Ar9HQ45IO4
         IW7x6xmYAawAuplqdw+NUbvbgGeDBfgEAUwHs3ojGiBFdk1n8qiV2fE5aGpV0Sgnluxt
         gZWHgLihp5japPXbNfh5F36GM4QWhe83wbsjAhu0nt7mqOb+NRYSjw4xVnBeUjPRuI3R
         cjrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW5xhKSdI71+nlnv/JNXOX0602CXRMPQ0i8uoiV2wq9xATYC0u6
	v5V2tOOrpV/IUoSh1UfGyhQaxiPju5UnXcKGUJBoJBLXr7gmi8y/r6FvYG1Asqyl2D9UrJ48B24
	V8Xq+GTVQNclLNzCz2J2OuUpv+vvAEdIUcnSO4kYphB4q1KvJEyTZcmymQ6Fwgv4CTA==
X-Received: by 2002:a17:902:324:: with SMTP id 33mr5795043pld.340.1565144296720;
        Tue, 06 Aug 2019 19:18:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRNw7aYsdg+He26eKQe8Ihz085ouc2/5pLxbIjJcw51H0ogu5xw2DVRSxYA7siEV5pFgOi
X-Received: by 2002:a17:902:324:: with SMTP id 33mr5794980pld.340.1565144295321;
        Tue, 06 Aug 2019 19:18:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565144295; cv=none;
        d=google.com; s=arc-20160816;
        b=CPIy+kQ7HXBJxmJxhfgTkPNXtkgim/Q8b0YMOsHc8ZrMi8zJ/p3Z6JHerj5Anx4ztA
         gQeNo9ii4fJf2xLK8TcVNkyx+iTpoyeXiDHiag36NosZzHgxtYATtScl6NwF7b5DQGPw
         fhZogUoVuZbFMPu/iZ6FSgmivMkldiHRgHrwJ6dJ30vMraLy8QcbpXcsAtfGcBw6EqOZ
         nJPdP4WXL0zp2EVXY1m2SzUGVhPYkAsUAAwgdQBRRct4HgvtULHMAHqCLEvJkPhJsP2t
         oAzIu/ZLmZ7UlTwfn3rUwHbgAbZzwwPtiCo5pM+ZGrwbdDnx7tLaar+GOPoh6PUaUH1E
         j8Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wKDd6yINnW0YWActj13+KXIn9ppzHTAKH5mNS4QaN/8=;
        b=EHvQMCE4YPHqkStAHmat6cguEGb3LW1I5egpLu+e/PNAd5js9c5Eta4ZDCe1HvpN9y
         4qIf7cN5TCbi++hg5LoMt/1SApX3c+11e6ENhEmePCUoXeu4vjkS/vzxCvvvDoJlqVEJ
         m3/eqblT1FQhR29RbcKJGXZLwVZm+zM7oE6pb1fh5Jecrl8DDuSO4XXVmer3KOP88jrQ
         P6Ol8nScEO5fBvVerY7wVT/pkl+HZkYAo0G2Sr5p+oJa5t2KMZHLcsQY74VH0eDykFxm
         oLGM7sGe5+1N10vY1r+/M2QGA8QcRdCRntC6wtglUhvp+st0TgL9n5D4Rwn3L47h7Xna
         4f7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id a91si8519853pld.254.2019.08.06.19.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 19:18:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TYr3obk_1565144286;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYr3obk_1565144286)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 07 Aug 2019 10:18:13 +0800
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
Subject: [v5 PATCH 1/4] mm: thp: extract split_queue_* into a struct
Date: Wed,  7 Aug 2019 10:17:54 +0800
Message-Id: <1565144277-36240-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
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
Cc: Qian Cai <cai@lca.pw>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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

