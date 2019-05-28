Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B079DC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:45:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64BFC208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:45:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64BFC208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7737B6B0276; Tue, 28 May 2019 08:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727396B027C; Tue, 28 May 2019 08:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B4DF6B027E; Tue, 28 May 2019 08:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01DD56B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:44:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f8so13948256pgp.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=FF8PtXCBZjUwZN9MncBHEp3PSXjlhKJu5GvSn2I51OE=;
        b=PSBx0XnKo8gfO0k1fxJ4AYgfswgQBO4VRnlhk6S8CjzzGRJiz8TXlgFSKr/9S5WNgC
         04tbqzvQ5vU+aHVRKmVJ/yhgmSIx5GFDpS8KjB8lS/puTykmwoQlTw+Gw3no9uhzUSSu
         5TjSuzFI1P7K5IDFLRQLSg2eKP3IrUj2GG6Fb/IzdnkfrHE/SV7JXwqW9QpRzCW0iwQC
         ScdL7gaNt8RdN/Yq/n0q7sKJ8BHZgNMHdgYcbqnOzwnin81197hoSEiH7zasY6DVctcg
         blYw77V9Iy6Vhno5LsMMD9BtSL1syB+WyXrJN68quxtsIptlB6tYZpxUz3iD8FOTBMka
         rhKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUBFneW2lnuBGr7GQTU5N3WLID9/tX/nHvwoeUlu36Tg8R4xBSV
	QhKadkIuZ7sjhXILM/pq/c+7gPPTaRkKqs6xW7ukDDYFShyM2dn6kMgdTM4Tmq1HgfAI03J3LK0
	sjd++RlIIhEYVOVsca4w8357f+/tz/5Wkj5PborlclnUxNSajr+DCerDReYTIBVzXXw==
X-Received: by 2002:a63:cc4e:: with SMTP id q14mr129600560pgi.84.1559047498589;
        Tue, 28 May 2019 05:44:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyW78vS6F40StZqYGtQZ7Pnw+OID5lAkgZvhcg4e7ufepSi3Q8GIV0r0Yk8BuwU+QMkNtu6
X-Received: by 2002:a63:cc4e:: with SMTP id q14mr129600407pgi.84.1559047497040;
        Tue, 28 May 2019 05:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559047497; cv=none;
        d=google.com; s=arc-20160816;
        b=g/Y5kki90vcMHrchSaivIBW9/gEEbxmINslHrYyLfECVZdVstJKr0LZpdpyzphrFYo
         oXqeNbKT1iN0n9FFBDQiSyJqMSlEiueihpulIFYia0cmsXG1lDq9MHenqH9THCgHY6Tc
         AoOXytlp05O+frh7jNwjhfN1ZSb8kMjICTt1NtqApdgZo6MReKZKLUUVq/HBlAzfcW7x
         24PfezHM+ULBpMFazjaP7t9nDydkkw/Myqh5MXijXdRbzbU9AybTPvIaClqEPUrCPNt3
         1hWPa+iOPrIge511bVpdMLanP9YXsuyLoeJH/g68znW+j6LEwRhjcT3Icoamcu1kXiNl
         qlrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=FF8PtXCBZjUwZN9MncBHEp3PSXjlhKJu5GvSn2I51OE=;
        b=xU1nuGSsqpZGC4lShBn33YVLXdga5QSEYN0d4vLRlVD3Hws8bJRQjTcA4YtSvGzYOw
         +DvVi9YLGY36T1VHf5Jch5t275nao4nxW/znC83ThsbqqTBUfU1PMVIUAkQ5itOFhw9v
         XNZZyzcY0NCj9f7/CXWUerolv271VCM7k/ReJ032l6dmvaBwtvskvYFShY8sFOpn6Fq+
         NfkagLBFZqL7CCW7OdSWp/emO3Nr3OK51Suozk1FGYOgj6i2OT0ouaeJPoQU1EC5xEDR
         yMZHz7M3B1J2CM/7B0voIbL34rbVrb12fwcn43vdK4wUVAZs9X1ukC1ZpuIoq81ud/NC
         c3/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id y1si21288026pgf.211.2019.05.28.05.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TStMl0v_1559047475;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TStMl0v_1559047475)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 28 May 2019 20:44:42 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] mm: thp: make deferred split shrinker memcg aware
Date: Tue, 28 May 2019 20:44:22 +0800
Message-Id: <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
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
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/huge_mm.h    |  24 ++++++
 include/linux/memcontrol.h |   6 ++
 include/linux/mm_types.h   |   7 +-
 mm/huge_memory.c           | 182 +++++++++++++++++++++++++++++++++------------
 mm/memcontrol.c            |  20 +++++
 mm/swap.c                  |   4 +
 6 files changed, 194 insertions(+), 49 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c15..f6d1cde 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,26 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+static inline struct list_head *page_deferred_list(struct page *page)
+{
+	/*
+	 * Global deferred list in the second tail pages is occupied by
+	 * compound_head.
+	 */
+	return &page[2].deferred_list;
+}
+
+static inline struct list_head *page_memcg_deferred_list(struct page *page)
+{
+	/*
+	 * Memcg deferred list in the second tail pages is occupied by
+	 * compound_head.
+	 */
+	return &page[2].memcg_deferred_list;
+}
+
+extern void del_thp_from_deferred_split_queue(struct page *);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -368,6 +388,10 @@ static inline bool thp_migration_supported(void)
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
index bc74d6a..9ff5fab 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -316,6 +316,12 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct list_head split_queue;
+	unsigned long split_queue_len;
+	spinlock_t split_queue_lock;
+#endif
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8ec38b1..405f5e6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -139,7 +139,12 @@ struct page {
 		struct {	/* Second tail page of compound page */
 			unsigned long _compound_pad_1;	/* compound_head */
 			unsigned long _compound_pad_2;
-			struct list_head deferred_list;
+			union {
+				/* Global THP deferred split list */
+				struct list_head deferred_list;
+				/* Memcg THP deferred split list */
+				struct list_head memcg_deferred_list;
+			};
 		};
 		struct {	/* Page table pages */
 			unsigned long _pt_pad_1;	/* compound_head */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9..0b9cfe1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -492,12 +492,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline struct list_head *page_deferred_list(struct page *page)
-{
-	/* ->lru in the tail pages is occupied by compound_head. */
-	return &page[2].deferred_list;
-}
-
 void prep_transhuge_page(struct page *page)
 {
 	/*
@@ -505,7 +499,10 @@ void prep_transhuge_page(struct page *page)
 	 * as list_head: assuming THP order >= 2
 	 */
 
-	INIT_LIST_HEAD(page_deferred_list(page));
+	if (mem_cgroup_disabled())
+		INIT_LIST_HEAD(page_deferred_list(page));
+	else
+		INIT_LIST_HEAD(page_memcg_deferred_list(page));
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
@@ -2664,6 +2661,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	bool mlocked;
 	unsigned long flags;
 	pgoff_t end;
+	struct mem_cgroup *memcg = head->mem_cgroup;
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -2744,17 +2742,30 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	/* Prevent deferred_split_scan() touching ->_refcount */
-	spin_lock(&pgdata->split_queue_lock);
+	if (!memcg)
+		spin_lock(&pgdata->split_queue_lock);
+	else
+		spin_lock(&memcg->split_queue_lock);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
 	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
-		if (!list_empty(page_deferred_list(head))) {
-			pgdata->split_queue_len--;
-			list_del(page_deferred_list(head));
+		if (!memcg) {
+			if (!list_empty(page_deferred_list(head))) {
+				pgdata->split_queue_len--;
+				list_del(page_deferred_list(head));
+			}
+		} else {
+			if (!list_empty(page_memcg_deferred_list(head))) {
+				memcg->split_queue_len--;
+				list_del(page_memcg_deferred_list(head));
+			}
 		}
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
-		spin_unlock(&pgdata->split_queue_lock);
+		if (!memcg)
+			spin_unlock(&pgdata->split_queue_lock);
+		else
+			spin_unlock(&memcg->split_queue_lock);
 		__split_huge_page(page, list, end, flags);
 		if (PageSwapCache(head)) {
 			swp_entry_t entry = { .val = page_private(head) };
@@ -2771,7 +2782,10 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			dump_page(page, "total_mapcount(head) > 0");
 			BUG();
 		}
-		spin_unlock(&pgdata->split_queue_lock);
+		if (!memcg)
+			spin_unlock(&pgdata->split_queue_lock);
+		else
+			spin_unlock(&memcg->split_queue_lock);
 fail:		if (mapping)
 			xa_unlock(&mapping->i_pages);
 		spin_unlock_irqrestore(&pgdata->lru_lock, flags);
@@ -2791,17 +2805,40 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	return ret;
 }
 
-void free_transhuge_page(struct page *page)
+void del_thp_from_deferred_split_queue(struct page *page)
 {
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
 	unsigned long flags;
+	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	if (!list_empty(page_deferred_list(page))) {
-		pgdata->split_queue_len--;
-		list_del(page_deferred_list(page));
+	/*
+	 * The THP may be not on LRU at this point, e.g. the old page of
+	 * NUMA migration.  And PageTransHuge is not enough to distinguish
+	 * with other compound page, e.g. skb, THP destructor is not used
+	 * anymore and will be removed, so the compound order sounds like
+	 * the only choice here.
+	 */
+	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
+		if (!memcg) {
+			spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+			if (!list_empty(page_deferred_list(page))) {
+				pgdata->split_queue_len--;
+				list_del(page_deferred_list(page));
+			}
+			spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+		} else {
+			spin_lock_irqsave(&memcg->split_queue_lock, flags);
+			if (!list_empty(page_memcg_deferred_list(page))) {
+				memcg->split_queue_len--;
+				list_del(page_memcg_deferred_list(page));
+			}
+			spin_unlock_irqrestore(&memcg->split_queue_lock, flags);
+		}
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+}
+
+void free_transhuge_page(struct page *page)
+{
 	free_compound_page(page);
 }
 
@@ -2809,23 +2846,41 @@ void deferred_split_huge_page(struct page *page)
 {
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
 	unsigned long flags;
+	struct mem_cgroup *memcg;
 
 	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	if (list_empty(page_deferred_list(page))) {
-		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
-		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
-		pgdata->split_queue_len++;
+	memcg = compound_head(page)->mem_cgroup;
+	if (!memcg) {
+		spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+		if (list_empty(page_deferred_list(page))) {
+			count_vm_event(THP_DEFERRED_SPLIT_PAGE);
+			list_add_tail(page_deferred_list(page), &pgdata->split_queue);
+			pgdata->split_queue_len++;
+		}
+		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	} else {
+		spin_lock_irqsave(&memcg->split_queue_lock, flags);
+		if (list_empty(page_memcg_deferred_list(page))) {
+			count_vm_event(THP_DEFERRED_SPLIT_PAGE);
+			list_add_tail(page_memcg_deferred_list(page),
+				      &memcg->split_queue);
+			memcg->split_queue_len++;
+			memcg_set_shrinker_bit(memcg, page_to_nid(page),
+					       deferred_split_shrinker.id);
+		}
+		spin_unlock_irqrestore(&memcg->split_queue_lock, flags);
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 }
 
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
-	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	return READ_ONCE(pgdata->split_queue_len);
+	if (!sc->memcg) {
+		struct pglist_data *pgdata = NODE_DATA(sc->nid);
+		return READ_ONCE(pgdata->split_queue_len);
+	} else
+		return READ_ONCE(sc->memcg->split_queue_len);
 }
 
 static unsigned long deferred_split_scan(struct shrinker *shrink,
@@ -2837,22 +2892,40 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	struct page *page;
 	int split = 0;
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	/* Take pin on all head pages to avoid freeing them under us */
-	list_for_each_safe(pos, next, &pgdata->split_queue) {
-		page = list_entry((void *)pos, struct page, mapping);
-		page = compound_head(page);
-		if (get_page_unless_zero(page)) {
-			list_move(page_deferred_list(page), &list);
-		} else {
-			/* We lost race with put_compound_page() */
-			list_del_init(page_deferred_list(page));
-			pgdata->split_queue_len--;
+	if (!sc->memcg) {
+		spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+		/* Take pin on all head pages to avoid freeing them under us */
+		list_for_each_safe(pos, next, &pgdata->split_queue) {
+			page = list_entry((void *)pos, struct page, mapping);
+			page = compound_head(page);
+			if (get_page_unless_zero(page)) {
+				list_move(page_deferred_list(page), &list);
+			} else {
+				/* We lost race with put_compound_page() */
+				list_del_init(page_deferred_list(page));
+				pgdata->split_queue_len--;
+			}
+			if (!--sc->nr_to_scan)
+				break;
 		}
-		if (!--sc->nr_to_scan)
-			break;
+		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	} else {
+		spin_lock_irqsave(&sc->memcg->split_queue_lock, flags);
+		list_for_each_safe(pos, next, &sc->memcg->split_queue) {
+			page = list_entry((void *)pos, struct page, mapping);
+			page = compound_head(page);
+			if (get_page_unless_zero(page)) {
+				list_move(page_memcg_deferred_list(page), &list);
+			} else {
+				/* We lost race with put_compound_page() */
+				list_del_init(page_memcg_deferred_list(page));
+				sc->memcg->split_queue_len--;
+			}
+			if (!--sc->nr_to_scan)
+				break;
+		}
+		spin_unlock_irqrestore(&sc->memcg->split_queue_lock, flags);
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
@@ -2866,16 +2939,29 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		put_page(page);
 	}
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	list_splice_tail(&list, &pgdata->split_queue);
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-
+	if (!sc->memcg) {
+		spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+		list_splice_tail(&list, &pgdata->split_queue);
+		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	} else {
+		spin_lock_irqsave(&sc->memcg->split_queue_lock, flags);
+		list_splice_tail(&list, &sc->memcg->split_queue);
+		spin_unlock_irqrestore(&sc->memcg->split_queue_lock, flags);
+	}
 	/*
 	 * Stop shrinker if we didn't split any page, but the queue is empty.
 	 * This can happen if pages were freed under us.
 	 */
-	if (!split && list_empty(&pgdata->split_queue))
-		return SHRINK_STOP;
+	if (!split) {
+		if (!sc->memcg) {
+			if (list_empty(&pgdata->split_queue))
+				return SHRINK_STOP;
+		} else {
+			if (list_empty(&sc->memcg->split_queue))
+				return SHRINK_STOP;
+		}
+	}
+
 	return split;
 }
 
@@ -2883,7 +2969,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
 };
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e50a2db..6418fa0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4579,6 +4579,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	spin_lock_init(&memcg->split_queue_lock);
+	INIT_LIST_HEAD(&memcg->split_queue);
+	memcg->split_queue_len = 0;
+#endif
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
@@ -4949,6 +4954,21 @@ static int mem_cgroup_move_account(struct page *page,
 		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
 	}
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (compound && !list_empty(page_memcg_deferred_list(page))) {
+		spin_lock(&from->split_queue_lock);
+		list_del(page_memcg_deferred_list(page));
+		from->split_queue_len--;
+		spin_unlock(&from->split_queue_lock);
+
+		spin_lock(&to->split_queue_lock);
+		list_add_tail(page_memcg_deferred_list(page),
+			      &to->split_queue);
+		to->split_queue_len++;
+		spin_unlock(&to->split_queue_lock);
+	}
+#endif
+
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

