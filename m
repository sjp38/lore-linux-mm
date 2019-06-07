Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C41A4C46470
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:09:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73B26208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:09:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73B26208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECAA06B0266; Fri,  7 Jun 2019 02:09:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7CE96B026E; Fri,  7 Jun 2019 02:09:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6A7B6B026F; Fri,  7 Jun 2019 02:09:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 998D46B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:09:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w31so714889pgk.23
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:09:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=CvrhcwgLx+DQPTH553w/C/afgsBJvl+XQRhtjmQXj30=;
        b=UPsH4y+0UZ1AKYExmpzMNX8IUZ57OV4F87KVZDz+vBjlBwzCFhbh4cyKeNt4E0sZaP
         APA5n135RdMTJaLomslQIw0rJSXjgzoZrtzVOUTChsPCsqMXsfG0Oy7KVGu+4d4t/ED0
         ACy0PNChQTZkfxFolTyGEaPgU4KvhldSGF/mYWLyooy6tEbOERfSuC8fX/C9apyVvw/v
         xCNi6ZDWqwc5FrA8z9yBYReuLjxHX4CTYMSpvpCmWu1sZJ6cQBz/TL0I3hfC1x4AvyYi
         OYXZEEPeJh2ICgGNa5HAnJbZIHrXxUJ+sILbrNfsdPvCtJFgLbbybXDI/vhvgjmjvbZa
         ZzCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXUzXnANkwzh7e/O3DgTbzN4lhIyO4xtEuhqeJ41cejb1FChmay
	N9BgwAFW0OGVepqpCOKSgpQTPMv0GxRHwyrcMxzaJgx+uXQmDpxh6JQGj4RU7YGn+e/yqUrcLUw
	pwV5It6/WGo1YgxT6xUxEu7VNGehcCUKLqpc7dwJ5VeFQZx/RbBnW6ze6OLzvunXwxQ==
X-Received: by 2002:a17:90a:9289:: with SMTP id n9mr3744546pjo.35.1559887747076;
        Thu, 06 Jun 2019 23:09:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8oL8uPfLB7HdC0kP6mMPGrs9RGImOGAQGpeS7j/IFfugV7s9Qpec2sGkv5tyxyahiTQvi
X-Received: by 2002:a17:90a:9289:: with SMTP id n9mr3744459pjo.35.1559887745567;
        Thu, 06 Jun 2019 23:09:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559887745; cv=none;
        d=google.com; s=arc-20160816;
        b=DEpvD8tw9ApAg8Qk1VAM90IrKbJPiB1ohjfWR7zzlouN+EMrdpLXfhTwmps8qk4NuY
         3ugcLOEUCTEbgh45y4XiTpLGABPsRCw4lEkSXmZf7GNIiNaFwzMgoBT2YLTYFW2YJRLi
         bDm2kNyMjVqF4c69ghJsK6EkirflykjMHUbt6Qi9yZM9d49co8rSPp8z0zUIBRYz7N1d
         Hq57lk5EyR04ESx9cBj3Pe0FRc+pUPFTkWy6QWhnrYoIf1mk9Z9VYrAzMQHOZ4/WJPfv
         E5NIXwmx6cMs72JY8sZseri4wr8r2JjXM6p7JzUq+s+R6ncrt8lLIRGejkaRHSvkhQzC
         UnPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=CvrhcwgLx+DQPTH553w/C/afgsBJvl+XQRhtjmQXj30=;
        b=G1o7amFHHCwjmu69Y217iO/EsptuzjRNKaf874w8hjL5+I9Fw/U7JPtxrek2nd84Lr
         gelseklJyaafPM+r2Gu1QtTmRFJD2LuhtUYWvzir1GTZ4/LlbzG/5dIZJUxz37rfK5i/
         KuClHxR5WCthjWWP8va/Ja/FogWydM6YXbIfFLWtoOLwZ8xxUfMVlNHD0cxs67cqxu9s
         Gd29rBWlBb/6fVK88Bs3jKwF3cR7pB8UXz0XR0Wa6hzGbj3/Q+CJgRQJXN2FYD9zPkwD
         nGZ19Z/7026eOh6b2OXIs6DrPE2MAmB58K04JOVRfXERv/BnAyjwz53NdEjjo7CNG5Hb
         4/aA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id j23si930246pfh.215.2019.06.06.23.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 23:09:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R631e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TTcZLUN_1559887677;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTcZLUN_1559887677)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 07 Jun 2019 14:08:10 +0800
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
Subject: [PATCH 2/4] mm: thp: make deferred split shrinker memcg aware
Date: Fri,  7 Jun 2019 14:07:37 +0800
Message-Id: <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
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

And, move deleting THP from deferred split queue in page free before
memcg uncharge so that the page's memcg information is available.

Reuse the second tail page's deferred_list for per memcg list since the
same THP can't be on multiple deferred split queues.

Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/huge_mm.h    | 15 ++++++++++
 include/linux/memcontrol.h |  4 +++
 include/linux/mm_types.h   |  1 +
 mm/huge_memory.c           | 71 +++++++++++++++++++++++++++++++++-------------
 mm/memcontrol.c            | 19 +++++++++++++
 mm/swap.c                  |  4 +++
 6 files changed, 94 insertions(+), 20 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c15..8137c3a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,17 @@ static inline bool thp_migration_supported(void)
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
+extern void del_thp_from_deferred_split_queue(struct page *);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -368,6 +379,10 @@ static inline bool thp_migration_supported(void)
 {
 	return false;
 }
+
+static inline void del_thp_from_deferred_split_queue(struct page *page)
+{
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bc74d6a..5d3c10c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -316,6 +316,10 @@ struct mem_cgroup {
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
index 81cf759..3307697 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -492,10 +492,15 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline struct list_head *page_deferred_list(struct page *page)
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
 
 void prep_transhuge_page(struct page *page)
@@ -2658,7 +2663,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct page *head = compound_head(page);
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue = get_deferred_split_queue(page);
 	struct anon_vma *anon_vma = NULL;
 	struct address_space *mapping = NULL;
 	int count, mapcount, extra_pins, ret;
@@ -2792,25 +2797,36 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	return ret;
 }
 
-void free_transhuge_page(struct page *page)
+void del_thp_from_deferred_split_queue(struct page *page)
 {
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
-	unsigned long flags;
-
-	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
-	if (!list_empty(page_deferred_list(page))) {
-		ds_queue->split_queue_len--;
-		list_del(page_deferred_list(page));
+	/*
+	 * The THP may be not on LRU at this point, e.g. the old page of
+	 * NUMA migration.  And PageTransHuge is not enough to distinguish
+	 * with other compound page, e.g. skb, THP destructor is not used
+	 * anymore and will be removed, so the compound order sounds like
+	 * the only choice here.
+	 */
+	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
+		struct deferred_split *ds_queue = get_deferred_split_queue(page);
+		unsigned long flags;
+		spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
+			if (!list_empty(page_deferred_list(page))) {
+				ds_queue->split_queue_len--;
+				list_del(page_deferred_list(page));
+			}
+		spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 	}
-	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
+}
+
+void free_transhuge_page(struct page *page)
+{
 	free_compound_page(page);
 }
 
 void deferred_split_huge_page(struct page *page)
 {
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue = get_deferred_split_queue(page);
+	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
@@ -2820,6 +2836,9 @@ void deferred_split_huge_page(struct page *page)
 		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
 		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
 		ds_queue->split_queue_len++;
+		if (memcg)
+			memcg_set_shrinker_bit(memcg, page_to_nid(page),
+					       deferred_split_shrinker.id);
 	}
 	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 }
@@ -2827,8 +2846,15 @@ void deferred_split_huge_page(struct page *page)
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
-	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue;
+
+	if (!sc->memcg) {
+		struct pglist_data *pgdata = NODE_DATA(sc->nid);
+		ds_queue = &pgdata->deferred_split_queue;
+		return READ_ONCE(ds_queue->split_queue_len);
+	}
+
+	ds_queue = &sc->memcg->deferred_split_queue;
 	return READ_ONCE(ds_queue->split_queue_len);
 }
 
@@ -2836,12 +2862,17 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
+	struct deferred_split *ds_queue;
 	unsigned long flags;
 	LIST_HEAD(list), *pos, *next;
 	struct page *page;
 	int split = 0;
 
+	if (sc->memcg)
+		ds_queue = &sc->memcg->deferred_split_queue;
+	else
+		ds_queue = &pgdata->deferred_split_queue;
+
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	/* Take pin on all head pages to avoid freeing them under us */
 	list_for_each_safe(pos, next, &ds_queue->split_queue) {
@@ -2888,7 +2919,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
 };
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e50a2db..fe7e544 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4579,6 +4579,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
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
@@ -4949,6 +4954,20 @@ static int mem_cgroup_move_account(struct page *page,
 		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
 	}
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (compound && !list_empty(page_deferred_list(page))) {
+		spin_lock(&from->deferred_split_queue.split_queue_lock);
+		list_del(page_deferred_list(page));
+		from->deferred_split_queue.split_queue_len--;
+		spin_unlock(&from->deferred_split_queue.split_queue_lock);
+
+		spin_lock(&to->deferred_split_queue.split_queue_lock);
+		list_add_tail(page_deferred_list(page),
+			      &to->deferred_split_queue.split_queue);
+		to->deferred_split_queue.split_queue_len++;
+		spin_unlock(&to->deferred_split_queue.split_queue_lock);
+	}
+#endif
 	/*
 	 * It is safe to change page->mem_cgroup here because the page
 	 * is referenced, charged, and isolated - we can't race with
diff --git a/mm/swap.c b/mm/swap.c
index 3a75722..3348295 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -69,6 +69,10 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 	}
+
+	/* Delete THP from deferred split queue before memcg uncharge */
+	del_thp_from_deferred_split_queue(page);
+
 	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
 }
-- 
1.8.3.1

