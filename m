Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D08EC48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:03:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3366420883
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:03:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3366420883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CECE06B0007; Tue, 25 Jun 2019 20:03:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCD128E0002; Tue, 25 Jun 2019 20:03:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8B038E0002; Tue, 25 Jun 2019 20:03:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 803586B0007
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:03:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o19so355929pgl.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:03:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=lc9EZ7km2nMW/LkyUnIW6C5nTmcnU2WKuYzRTkNIjZo=;
        b=pb2GUxrkR+iz95XwKrmtoQAaibhhHeVaVqklt2Xr1LZhMQoWAdT+0KrNoMl4jTkn0Y
         VEFS1QxM6OQOn2kGeQvmqsvUjDs0pv7wOvXGO0OmgvzF1BWpLHd5bjrVPttFVGTrds/K
         x9+JBVy1y3rX1LpLrCXFzbcT9xX1N+TlkRbH8lIDgM7Te+TbSqv7WS6EAPHSfMAb/8mv
         hw9yJxIeCSfsVF7zsCmP+Q0a4DerlnIi74s0ZlkImit8xShJALziEcXHxVhY/e0zQ8yx
         o+kAF7/jsjzSzCtujCerTlOOskua0OWj9pRZhesQTFJtKRJzUVZVaka5bxOOh5lr3OnS
         q7Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW3BmdoSbExtQxLBqodPUWJMUtJD4bn1lCFznYIqcly6vX4VeV6
	k1nJbMeVQ9pcSQj7BGJN2vb6gZat3yF6SZf79wz5YOdpIVFv4v+qQ3zW0PvkhlHeuEYUgXqkOmD
	dIVIRzYwfTCeFYBa+PV54ns8YB3yqm8r99fsdCZsg7ZlxOtsxNNIHNb4XD2kNMVbHiA==
X-Received: by 2002:a63:3d02:: with SMTP id k2mr4191792pga.36.1561507388996;
        Tue, 25 Jun 2019 17:03:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH0n9uNsjFitSnIP6DLPPZZ6ehVnoK8b9H/zRoAj+YQygMBhbeeopikQs26AjE8CJ9QqYd
X-Received: by 2002:a63:3d02:: with SMTP id k2mr4191687pga.36.1561507387622;
        Tue, 25 Jun 2019 17:03:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561507387; cv=none;
        d=google.com; s=arc-20160816;
        b=WYNe1z4f5vAw0z36wB3V5I2sc2Gisc/y3+Czo+UhDrWrzmtbAystcZL839TdjIpN0g
         JsTkZbEUwO+Mni4bSlrBFJdVTaL63po+ypOdYnxq4iElngy38d5yjazR6GHy5PxzJlAI
         L46Bv/Rb04NpyA0J7+SDRtzb/st126o0QXIci40K9bZULeGT8KtKY0n2YfhpcH5p/NX5
         65GpYJx0Q14lnMZbbCCed4U+i1fB+5R4D/dG9L75YDq01J6v3r+jr1LgZV4PHfd16K0z
         5pCBAcPae/wDltoUQTSHZRocxSspshIJH77g69BUpScWILYmYFn26HGKic0DYGFTHej/
         KNdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=lc9EZ7km2nMW/LkyUnIW6C5nTmcnU2WKuYzRTkNIjZo=;
        b=L1RNR3Z/aotCorajISvq47wfjo0EMzXJTVa9MUIEqjh8Kv89vJzYPQhCMTdy8lPo3w
         Kz0GQIAJVGuSdt694qUGVse70L/XnXIIicHt40TLsHVxTqCc2w6Dc0qJvrbjVVFvfaps
         u1W1CfYCCldfFtzoE9E+RIqZnyd1xMdBP+HEvTTXZqVwr8pyigIeg6TFxnC7ty2TR3jt
         +OQ4ZU4xbTh3bkj5Oe5/cR7DcYJuErWEi+x9F2SzZ2hd7YjYF40PxR88gC1U4o53KZjt
         rbQo/ALdXWQ69U8TBkpVpr1JcXCuhvUKDQM1wP3VWQ5RW/sqOFPN9fd2cM1qls6RArX8
         3Tpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id k22si14611865pfk.90.2019.06.25.17.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 17:03:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R761e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVCYVJX_1561507375;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCYVJX_1561507375)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 08:03:02 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 1/4] mm: thp: extract split_queue_* into a struct
Date: Wed, 26 Jun 2019 08:02:38 +0800
Message-Id: <1561507361-59349-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
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
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
index d66bc8a..6c9cf1e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6582,9 +6582,11 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
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

