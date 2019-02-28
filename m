Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373FDC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D79EF218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D79EF218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2EA68E0001; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8F1A8E0006; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D09268E0001; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 385458E0005
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id g17so3718723lfh.19
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:35:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cSMU1W9Tabshk8qufE7l3kcq2SXYnLVCzZAl0OTk6QI=;
        b=C9cZH65aZTnPsvyBRHo0/FEVG+ISrBLjI27lQavqITiq3LtEMvfREfHdbr6ozzn8+A
         5arFISo2GxHiubHiRCiGuJq0VepXWN74+hkwSF6ca7e117AL2T1k9VdygbyUingq0mjZ
         IxJHUNvCRWb1VokwI05/NEeWVTmHUf3We92r9wYQ0jsCVp86YZD7OeByU5iydb5g86Vd
         Sf7VgDAPOHNzjka8+A/IziZhiBLGYzhUp8+kGJ9p8WKxjgIhLAuik6uFapkMNzAW+5+B
         qMY292ac8l9vJf+QVvE0Y8UNyPqvaqRypU8xW+06elBGkSeHhEvN6Yma+nY0t3sHic9T
         yIPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuaUcsb52RzJBUyiGfscalSSN7VxrzTK/2aAKUaqdt3Wk3RQI1Wh
	j3ItL0OGQz0LZAzY//wEGbIPfeQNBuc3ko/xK9DOtr2TGAK5EpBHWu1MxaTBFsAr0YasZ7Uk99h
	Txn89uC0UmoMCrrZ2q+XW4oC/vFNTUxKbui8wIzW+yP7ajvfVcwD1epY5P+pUtN+cWg==
X-Received: by 2002:a19:9112:: with SMTP id t18mr3484586lfd.19.1551342948514;
        Thu, 28 Feb 2019 00:35:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZOG0EcoZJbG1skKX/lVpAJpAA+/E3pBVF6xNFhhu5sQ6sZyb/ul24toLOVPcu6XQERW09c
X-Received: by 2002:a19:9112:: with SMTP id t18mr3484518lfd.19.1551342946886;
        Thu, 28 Feb 2019 00:35:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551342946; cv=none;
        d=google.com; s=arc-20160816;
        b=fy1/hR9pS3ogDi8ok6Eiwwo9/JN7+5A/QxmLycC5IgNRdo07EyyrHUZVN3rYaA4JCZ
         o+zLPPpOO3VEPJ8pZM/rM56j0KrsZ8+WOAbFYcny+HCTPZC/mXttzu0scsPdUyfx4i7/
         es1YBZg/Tp0nAH6qbfF2xosoABlBmLJtvKWxTj+cO6YY6b/2dkmKKEw7Icpeq2Vhef1P
         hDldWFvdg+o3Wsg1WZibCWIspOanekB88xqdzcT+BgM1EYhQ0aCSz4XRD9w9MD8J9Ihk
         1iHwBA/9jHotomCVvre+oNrz9PwjOSPNGZwDEh6VGPY4EicOjUszB9j8rzbfEfHkLs74
         l+dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cSMU1W9Tabshk8qufE7l3kcq2SXYnLVCzZAl0OTk6QI=;
        b=pccXFyqQrI1VLTRNxPorf6MJeanW0eailcAEo/w0kSKm0/OOK3Z6kXfg1x212aDXK2
         bwVURowxxSzS7uSzuF0IovLeO7PPMo+JtObNuThwfF9vCZGop1T4CCh8JIxf07s2fUKR
         3u+38f91gFqclLvMrY5kQCTGGsSEgb3ImRithdpTukoQgN8nsExY+O9Zs5IlErzPeiHa
         X5xtjx9BYGVMkrlqlAJwUaDog7KYS92vKd4FFnvvDghcJTQ+N3dIeuPuHMC3pAstQ4H2
         XfUqxA7l3b2BugOSZPrzEjevBmSVdMhYSQfbkCyPKqvTVAHNGeQbJqglV7cZEEHnF9sK
         1kqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w16si11178053ljw.178.2019.02.28.00.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:35:46 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzHAJ-0008R2-WC; Thu, 28 Feb 2019 11:35:40 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH v2 2/4] mm: remove zone_lru_lock() function access ->lru_lock directly
Date: Thu, 28 Feb 2019 11:33:27 +0300
Message-Id: <20190228083329.31892-2-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20190228083329.31892-1-aryabinin@virtuozzo.com>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We have common pattern to access lru_lock from a page pointer:
	zone_lru_lock(page_zone(page))

Which is silly, because it unfolds to this:
	&NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)]->zone_pgdat->lru_lock
while we can simply do
	&NODE_DATA(page_to_nid(page))->lru_lock

Remove zone_lru_lock() function, since it's only complicate things.
Use 'page_pgdat(page)->lru_lock' pattern instead.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---

Changes since v1:
 - Added ack.

 Documentation/cgroup-v1/memcg_test.txt |  4 ++--
 Documentation/cgroup-v1/memory.txt     |  4 ++--
 include/linux/mm_types.h               |  2 +-
 include/linux/mmzone.h                 |  4 ----
 mm/compaction.c                        | 15 ++++++++-------
 mm/filemap.c                           |  4 ++--
 mm/huge_memory.c                       |  6 +++---
 mm/memcontrol.c                        | 14 +++++++-------
 mm/mlock.c                             | 14 +++++++-------
 mm/page_idle.c                         |  8 ++++----
 mm/rmap.c                              |  2 +-
 mm/swap.c                              | 16 ++++++++--------
 mm/vmscan.c                            | 16 ++++++++--------
 13 files changed, 53 insertions(+), 56 deletions(-)

diff --git a/Documentation/cgroup-v1/memcg_test.txt b/Documentation/cgroup-v1/memcg_test.txt
index 5c7f310f32bb..621e29ffb358 100644
--- a/Documentation/cgroup-v1/memcg_test.txt
+++ b/Documentation/cgroup-v1/memcg_test.txt
@@ -107,9 +107,9 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 
 8. LRU
         Each memcg has its own private LRU. Now, its handling is under global
-	VM's control (means that it's handled under global zone_lru_lock).
+	VM's control (means that it's handled under global pgdat->lru_lock).
 	Almost all routines around memcg's LRU is called by global LRU's
-	list management functions under zone_lru_lock().
+	list management functions under pgdat->lru_lock.
 
 	A special function is mem_cgroup_isolate_pages(). This scans
 	memcg's private LRU and call __isolate_lru_page() to extract a page
diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index 8e2cb1dabeb0..a33cedf85427 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -267,11 +267,11 @@ When oom event notifier is registered, event will be delivered.
    Other lock order is following:
    PG_locked.
    mm->page_table_lock
-       zone_lru_lock
+       pgdat->lru_lock
 	  lock_page_cgroup.
   In many cases, just lock_page_cgroup() is called.
   per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
-  zone_lru_lock, it has no lock of its own.
+  pgdat->lru_lock, it has no lock of its own.
 
 2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fe0f672f53ce..9b9dd8350e26 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -79,7 +79,7 @@ struct page {
 		struct {	/* Page cache and anonymous pages */
 			/**
 			 * @lru: Pageout list, eg. active_list protected by
-			 * zone_lru_lock.  Sometimes used as a generic list
+			 * pgdat->lru_lock.  Sometimes used as a generic list
 			 * by the page owner.
 			 */
 			struct list_head lru;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2fd4247262e9..22423763c0bd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -788,10 +788,6 @@ typedef struct pglist_data {
 
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
-static inline spinlock_t *zone_lru_lock(struct zone *zone)
-{
-	return &zone->zone_pgdat->lru_lock;
-}
 
 static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
 {
diff --git a/mm/compaction.c b/mm/compaction.c
index 98f99f41dfdc..a3305f13a138 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -775,6 +775,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			unsigned long end_pfn, isolate_mode_t isolate_mode)
 {
 	struct zone *zone = cc->zone;
+	pg_data_t *pgdat = zone->zone_pgdat;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
@@ -839,8 +840,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * if contended.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(zone_lru_lock(zone), flags,
-								&locked, cc))
+		    && compact_unlock_should_abort(&pgdat->lru_lock,
+					    flags, &locked, cc))
 			break;
 
 		if (!pfn_valid_within(low_pfn))
@@ -910,7 +911,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (unlikely(__PageMovable(page)) &&
 					!PageIsolated(page)) {
 				if (locked) {
-					spin_unlock_irqrestore(zone_lru_lock(zone),
+					spin_unlock_irqrestore(&pgdat->lru_lock,
 									flags);
 					locked = false;
 				}
@@ -940,7 +941,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_lock_irqsave(zone_lru_lock(zone),
+			locked = compact_lock_irqsave(&pgdat->lru_lock,
 								&flags, cc);
 
 			/* Try get exclusive access under lock */
@@ -965,7 +966,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			}
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
@@ -1007,7 +1008,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (nr_isolated) {
 			if (locked) {
-				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 				locked = false;
 			}
 			putback_movable_pages(&cc->migratepages);
@@ -1034,7 +1035,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 isolate_abort:
 	if (locked)
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 
 	/*
 	 * Updated the cached scanner pfn once the pageblock has been scanned
diff --git a/mm/filemap.c b/mm/filemap.c
index 663f3b84990d..cace3eb8069f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -98,8 +98,8 @@
  *    ->swap_lock		(try_to_unmap_one)
  *    ->private_lock		(try_to_unmap_one)
  *    ->i_pages lock		(try_to_unmap_one)
- *    ->zone_lru_lock(zone)	(follow_page->mark_page_accessed)
- *    ->zone_lru_lock(zone)	(check_pte_range->isolate_lru_page)
+ *    ->pgdat->lru_lock		(follow_page->mark_page_accessed)
+ *    ->pgdat->lru_lock		(check_pte_range->isolate_lru_page)
  *    ->private_lock		(page_remove_rmap->set_page_dirty)
  *    ->i_pages lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d4847026d4b1..4ccac6b32d49 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2475,7 +2475,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		xa_unlock(&head->mapping->i_pages);
 	}
 
-	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+	spin_unlock_irqrestore(&page_pgdat(head)->lru_lock, flags);
 
 	remap_page(head);
 
@@ -2686,7 +2686,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		lru_add_drain();
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
+	spin_lock_irqsave(&pgdata->lru_lock, flags);
 
 	if (mapping) {
 		XA_STATE(xas, &mapping->i_pages, page_index(head));
@@ -2731,7 +2731,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		spin_unlock(&pgdata->split_queue_lock);
 fail:		if (mapping)
 			xa_unlock(&mapping->i_pages);
-		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+		spin_unlock_irqrestore(&pgdata->lru_lock, flags);
 		remap_page(head);
 		ret = -EBUSY;
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5fc2e1a7d4d2..17859721a263 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2377,13 +2377,13 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 
 static void lock_page_lru(struct page *page, int *isolated)
 {
-	struct zone *zone = page_zone(page);
+	pg_data_t *pgdat = page_pgdat(page);
 
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		*isolated = 1;
@@ -2393,17 +2393,17 @@ static void lock_page_lru(struct page *page, int *isolated)
 
 static void unlock_page_lru(struct page *page, int isolated)
 {
-	struct zone *zone = page_zone(page);
+	pg_data_t *pgdat = page_pgdat(page);
 
 	if (isolated) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
@@ -2689,7 +2689,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 
 /*
  * Because tail pages are not marked as "used", set it. We're under
- * zone_lru_lock and migration entries setup in all page mappings.
+ * pgdat->lru_lock and migration entries setup in all page mappings.
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
diff --git a/mm/mlock.c b/mm/mlock.c
index 41cc47e28ad6..080f3b36415b 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -182,7 +182,7 @@ static void __munlock_isolation_failed(struct page *page)
 unsigned int munlock_vma_page(struct page *page)
 {
 	int nr_pages;
-	struct zone *zone = page_zone(page);
+	pg_data_t *pgdat = page_pgdat(page);
 
 	/* For try_to_munlock() and to serialize with page migration */
 	BUG_ON(!PageLocked(page));
@@ -194,7 +194,7 @@ unsigned int munlock_vma_page(struct page *page)
 	 * might otherwise copy PageMlocked to part of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 
 	if (!TestClearPageMlocked(page)) {
 		/* Potentially, PTE-mapped THP: do not skip the rest PTEs */
@@ -203,17 +203,17 @@ unsigned int munlock_vma_page(struct page *page)
 	}
 
 	nr_pages = hpage_nr_pages(page);
-	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
+	__mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 
 	if (__munlock_isolate_lru_page(page, true)) {
-		spin_unlock_irq(zone_lru_lock(zone));
+		spin_unlock_irq(&pgdat->lru_lock);
 		__munlock_isolated_page(page);
 		goto out;
 	}
 	__munlock_isolation_failed(page);
 
 unlock_out:
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 
 out:
 	return nr_pages - 1;
@@ -298,7 +298,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	pagevec_init(&pvec_putback);
 
 	/* Phase 1: page isolation */
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&zone->zone_pgdat->lru_lock);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -325,7 +325,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 		pvec->pages[i] = NULL;
 	}
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&zone->zone_pgdat->lru_lock);
 
 	/* Now we can release pins of pages that we are not munlocking */
 	pagevec_release(&pvec_putback);
diff --git a/mm/page_idle.c b/mm/page_idle.c
index b9e4b42b33ab..0b39ec0c945c 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -31,7 +31,7 @@
 static struct page *page_idle_get_page(unsigned long pfn)
 {
 	struct page *page;
-	struct zone *zone;
+	pg_data_t *pgdat;
 
 	if (!pfn_valid(pfn))
 		return NULL;
@@ -41,13 +41,13 @@ static struct page *page_idle_get_page(unsigned long pfn)
 	    !get_page_unless_zero(page))
 		return NULL;
 
-	zone = page_zone(page);
-	spin_lock_irq(zone_lru_lock(zone));
+	pgdat = page_pgdat(page);
+	spin_lock_irq(&pgdat->lru_lock);
 	if (unlikely(!PageLRU(page))) {
 		put_page(page);
 		page = NULL;
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 	return page;
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc29537..b30c7c71d1d9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -27,7 +27,7 @@
  *         mapping->i_mmap_rwsem
  *           anon_vma->rwsem
  *             mm->page_table_lock or pte_lock
- *               zone_lru_lock (in mark_page_accessed, isolate_lru_page)
+ *               pgdat->lru_lock (in mark_page_accessed, isolate_lru_page)
  *               swap_lock (in swap_duplicate, swap_info_get)
  *                 mmlist_lock (in mmput, drain_mmlist and others)
  *                 mapping->private_lock (in __set_page_dirty_buffers)
diff --git a/mm/swap.c b/mm/swap.c
index 4d7d37eb3c40..301ed4e04320 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -58,16 +58,16 @@ static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
 static void __page_cache_release(struct page *page)
 {
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
 		struct lruvec *lruvec;
 		unsigned long flags;
 
-		spin_lock_irqsave(zone_lru_lock(zone), flags);
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		spin_lock_irqsave(&pgdat->lru_lock, flags);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 	}
 	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
@@ -322,12 +322,12 @@ static inline void activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	pg_data_t *pgdat = page_pgdat(page);
 
 	page = compound_head(page);
-	spin_lock_irq(zone_lru_lock(zone));
-	__activate_page(page, mem_cgroup_page_lruvec(page, zone->zone_pgdat), NULL);
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
+	__activate_page(page, mem_cgroup_page_lruvec(page, pgdat), NULL);
+	spin_unlock_irq(&pgdat->lru_lock);
 }
 #endif
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9852ed7b97f..2d081a32c6a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1614,8 +1614,8 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
 
 }
 
-/*
- * zone_lru_lock is heavily contended.  Some of the functions that
+/**
+ * pgdat->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
@@ -1750,11 +1750,11 @@ int isolate_lru_page(struct page *page)
 	WARN_RATELIMIT(PageTail(page), "trying to isolate tail page");
 
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(zone_lru_lock(zone));
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		spin_lock_irq(&pgdat->lru_lock);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			get_page(page);
@@ -1762,7 +1762,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(zone_lru_lock(zone));
+		spin_unlock_irq(&pgdat->lru_lock);
 	}
 	return ret;
 }
@@ -1990,9 +1990,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  * processes, from rmap.
  *
  * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone_lru_lock across the whole operation.  But if
+ * appropriate to hold pgdat->lru_lock across the whole operation.  But if
  * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone_lru_lock around each page.  It's impossible to balance
+ * should drop pgdat->lru_lock around each page.  It's impossible to balance
  * this, so instead we remove the pages from the LRU while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
-- 
2.19.2

