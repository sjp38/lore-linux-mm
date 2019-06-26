Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 154A9C48BD5
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:04:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCC9320883
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:04:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCC9320883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D1056B0006; Tue, 25 Jun 2019 20:04:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A6088E0003; Tue, 25 Jun 2019 20:04:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570788E0002; Tue, 25 Jun 2019 20:04:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 207FC6B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:04:15 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id p14so228858plq.1
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:04:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=S797eYnzFdTMMfjZJVlwmlDvblrr20h1Xd/x4lcf5OU=;
        b=riR+0wkK7nhWCJIwRFfK/0fWlly4F5MJdSLeGNqJ3jywC9f6hFsnxg20sIEr54PSsg
         nfGC5v2QasUPl5AxsAqXHPgnzOYok1cet7txSBEHqtH5sHoJHpfXv6yFFRJPzTAHe940
         GLb3Z3z5VoCxMQ0vN+A9qh2IBHskZpEI7/xUoReycGPkRgX1aQyMxEpVhxXMVDbQpkQw
         tY4ue4zRlusz/SkQH5FmmNXLspRtyhhEDyYRXSjT/rpXOw5Ak6V6iZctPqX5Zgp5rnJM
         5v6BaaJntLV1o0qN7+uG+RzpjJqJB/cccJzvYyJQkQRkzgQH+JLaXw8TDnSb6O+ncISs
         oTkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXKZIPMoAl4G7mTlHfxQIDdjj/T04Bl0B+qfAKXZl2qZ0GBNDOw
	rObEXSw6QL6aYCx5pNkW5Hjx5zLqinI2YfJuSpLu2SHyxYB7ZFyavMbYVOeyFWEIggan5lJe7ew
	Qpp/CgZukjRuv3PuDfRD47r5sK1CTqbE5uuWb70i8Nrpln4cO1pSsr6OxxE8sOq0tag==
X-Received: by 2002:a17:90a:360c:: with SMTP id s12mr704058pjb.30.1561507454736;
        Tue, 25 Jun 2019 17:04:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm/blPXQZO+JfBS61gPdg8MmNlVLFvlwYjJUYSXc8HOQFZrIaV7aof5RcY8Q0WQRg/UfOJ
X-Received: by 2002:a17:90a:360c:: with SMTP id s12mr703929pjb.30.1561507453259;
        Tue, 25 Jun 2019 17:04:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561507453; cv=none;
        d=google.com; s=arc-20160816;
        b=oVYUEYqxwLnwlwHIfd9oVxn4i9i1F8KHjq372TO9fnUxbNgh68py/IT/dBH1eZmWjT
         GFi6o+SDagKzuxqslDagyPoHb3BCo0oVgKEuM94dHsov538jpOSyvl9QSDurdJ4ICv3N
         JizR4Q2E/PDouyWeWnD5Q/1LL7LzlHacMACoysmpS/8EQPqpykZc/NV4k0vBylXxOd1J
         X4Yl0n/wB5X8aMQGfOp9GWNYf5beRnadjdShUSxUjZDdOSXGgWnXqhK7WHmuMIsiOlkj
         OSJnPVThSDqT/p53LNBb3wulBPNIHLwbJqH+OVxHvYRW5k72zxbHkr42lnRG3rW5s7wq
         Lu5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=S797eYnzFdTMMfjZJVlwmlDvblrr20h1Xd/x4lcf5OU=;
        b=xTTVC7PD+tA4goR5Z5of/ATRnUUsRCh0MaMTCe1HThsM4ctK8A402UCGa0bN0wX0vj
         6WpbT7tlQY/vg6+NJTk3yb15A1pMZBrxP39apmpLVa4SXFP4MphdifaV4XdHp47cljKt
         XipR5CcdV5SjZ4kmDI6hL94xRCr9qMQE74ozgg+fp/28NjejL4CQf20tiOqVFKThkp3i
         idjNU1EA7hEquxNWZDZ1jAbqCvPQ7ZKGE0aZQJCwFGVYTWU4jAFY04B1FU4BdHbCnq1U
         q0WATpnWz/TIzcqBtPv5JaRHSI/IMhysYmZzJcaIDx0VUi/B6mRyZw2UNbGmCPNK+6xj
         6Ttw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id y135si10968724pfg.200.2019.06.25.17.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 17:04:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVCYVJX_1561507375;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCYVJX_1561507375)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 08:03:03 +0800
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
Subject: [v4 PATCH 4/4] mm: thp: make deferred split shrinker memcg aware
Date: Wed, 26 Jun 2019 08:02:41 +0800
Message-Id: <1561507361-59349-5-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently THP deferred split shrinker is not memcg aware, this may cause
premature OOM with some configuration. For example the below test would
run into premature OOM easily:

$ cgcreate -g memory:thp
$ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
$ cgexec -g memory:thp transhuge-stress 4000

transhuge-stress comes from kernel selftest.

It is easy to hit OOM, but there are still a lot THP on the deferred
split queue, memcg direct reclaim can't touch them since the deferred
split shrinker is not memcg aware.

Convert deferred split shrinker memcg aware by introducing per memcg
deferred split queue.  The THP should be on either per node or per memcg
deferred split queue if it belongs to a memcg.  When the page is
immigrated to the other memcg, it will be immigrated to the target
memcg's deferred split queue too.

Reuse the second tail page's deferred_list for per memcg list since the
same THP can't be on multiple deferred split queues.

Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/huge_mm.h    |  9 +++++++
 include/linux/memcontrol.h |  4 +++
 include/linux/mm_types.h   |  1 +
 mm/huge_memory.c           | 63 ++++++++++++++++++++++++++++++++++++++--------
 mm/memcontrol.c            | 24 ++++++++++++++++++
 5 files changed, 90 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c15..7738509 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,15 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+static inline struct list_head *page_deferred_list(struct page *page)
+{
+	/*
+	 * Global or memcg deferred list in the second tail pages is
+	 * occupied by compound_head.
+	 */
+	return &page[2].deferred_list;
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1dcb763..77a313c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -311,6 +311,10 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct deferred_split deferred_split_queue;
+#endif
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8ec38b1..4eabf80 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -139,6 +139,7 @@ struct page {
 		struct {	/* Second tail page of compound page */
 			unsigned long _compound_pad_1;	/* compound_head */
 			unsigned long _compound_pad_2;
+			/* For both global and memcg */
 			struct list_head deferred_list;
 		};
 		struct {	/* Page table pages */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81cf759..b00570d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -492,11 +492,25 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline struct list_head *page_deferred_list(struct page *page)
+#ifdef CONFIG_MEMCG
+static inline struct deferred_split *get_deferred_split_queue(struct page *page)
 {
-	/* ->lru in the tail pages is occupied by compound_head. */
-	return &page[2].deferred_list;
+	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
+	struct pglist_data *pgdat = NODE_DATA(page_to_nid(page));
+
+	if (memcg)
+		return &memcg->deferred_split_queue;
+	else
+		return &pgdat->deferred_split_queue;
 }
+#else
+static inline struct deferred_split *get_deferred_split_queue(struct page *page)
+{
+	struct pglist_data *pgdat = NODE_DATA(page_to_nid(page));
+
+	return &pgdat->deferred_split_queue;
+}
+#endif
 
 void prep_transhuge_page(struct page *page)
 {
@@ -2658,7 +2672,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct page *head = compound_head(page);
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue = get_deferred_split_queue(page);
 	struct anon_vma *anon_vma = NULL;
 	struct address_space *mapping = NULL;
 	int count, mapcount, extra_pins, ret;
@@ -2794,8 +2808,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 void free_transhuge_page(struct page *page)
 {
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue = get_deferred_split_queue(page);
 	unsigned long flags;
 
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
@@ -2809,8 +2822,10 @@ void free_transhuge_page(struct page *page)
 
 void deferred_split_huge_page(struct page *page)
 {
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue = get_deferred_split_queue(page);
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
+#endif
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
@@ -2820,6 +2835,11 @@ void deferred_split_huge_page(struct page *page)
 		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
 		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
 		ds_queue->split_queue_len++;
+#ifdef CONFIG_MEMCG
+		if (memcg)
+			memcg_set_shrinker_bit(memcg, page_to_nid(page),
+					       deferred_split_shrinker.id);
+#endif
 	}
 	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 }
@@ -2827,8 +2847,19 @@ void deferred_split_huge_page(struct page *page)
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
+	struct deferred_split *ds_queue;
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+
+#ifdef CONFIG_MEMCG
+	if (!sc->memcg) {
+		ds_queue = &pgdata->deferred_split_queue;
+		return READ_ONCE(ds_queue->split_queue_len);
+	}
+
+	ds_queue = &sc->memcg->deferred_split_queue;
+#else
+	ds_queue = &pgdata->deferred_split_queue;
+#endif
 	return READ_ONCE(ds_queue->split_queue_len);
 }
 
@@ -2836,12 +2867,21 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue;
 	unsigned long flags;
 	LIST_HEAD(list), *pos, *next;
 	struct page *page;
 	int split = 0;
 
+#ifdef CONFIG_MEMCG
+	if (sc->memcg)
+		ds_queue = &sc->memcg->deferred_split_queue;
+	else
+		ds_queue = &pgdata->deferred_split_queue;
+#else
+	ds_queue = &pgdata->deferred_split_queue;
+#endif
+
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	/* Take pin on all head pages to avoid freeing them under us */
 	list_for_each_safe(pos, next, &ds_queue->split_queue) {
@@ -2888,7 +2928,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE |
+		 SHRINKER_NONSLAB,
 };
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a..5730608 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4585,6 +4585,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	spin_lock_init(&memcg->deferred_split_queue.split_queue_lock);
+	INIT_LIST_HEAD(&memcg->deferred_split_queue.split_queue);
+	memcg->deferred_split_queue.split_queue_len = 0;
+#endif
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
@@ -4955,6 +4960,14 @@ static int mem_cgroup_move_account(struct page *page,
 		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
 	}
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (compound && !list_empty(page_deferred_list(page))) {
+		spin_lock(&from->deferred_split_queue.split_queue_lock);
+		list_del_init(page_deferred_list(page));
+		from->deferred_split_queue.split_queue_len--;
+		spin_unlock(&from->deferred_split_queue.split_queue_lock);
+	}
+#endif
 	/*
 	 * It is safe to change page->mem_cgroup here because the page
 	 * is referenced, charged, and isolated - we can't race with
@@ -4963,6 +4976,17 @@ static int mem_cgroup_move_account(struct page *page,
 
 	/* caller should have done css_get */
 	page->mem_cgroup = to;
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (compound && list_empty(page_deferred_list(page))) {
+		spin_lock(&to->deferred_split_queue.split_queue_lock);
+		list_add_tail(page_deferred_list(page),
+			      &to->deferred_split_queue.split_queue);
+		to->deferred_split_queue.split_queue_len++;
+		spin_unlock(&to->deferred_split_queue.split_queue_lock);
+	}
+#endif
+
 	spin_unlock_irqrestore(&from->move_lock, flags);
 
 	ret = 0;
-- 
1.8.3.1

