Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4C11C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 857C62238C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cmL1+InM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 857C62238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 243548E0003; Tue, 23 Jul 2019 02:26:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CD408E0001; Tue, 23 Jul 2019 02:26:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070298E0003; Tue, 23 Jul 2019 02:26:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C12A18E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:26:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so25442679pfo.22
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:26:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xr8cwtVAFqpMs6Az1B0omCnRc5Dl1COt3ClHqKPUTb0=;
        b=moh9rHA9nHVX7dCj+Kc0PHWSl4yx4c964Pq8ZlxQtMEZTyBBS4Wxdl/etQFDRlfuqQ
         IHgi1LAOLb2+Eqb2uIwbjImURAG5OR0w2mGi5vFlLjh8rUZzNRkrh4/yBjybXsggcSdA
         reUEJkct3zTawxcVzjUFCnr49libbVmW7XT57r2T08wlWcINkiDb+6oDApsIVAQ7xvlM
         NbMJehpf9LTgC4hU8ylXIDe84FQqIopR2lM9Jp29yZd52v0LoDjzt1TnfrFIdLAUKw9P
         fQEVwzZp0GQ3uNWR3hUsbX3yJ94hog51cCcAiSC6YAmnsnW8SPyx1ed5Az/0O1Uvip4a
         j2ew==
X-Gm-Message-State: APjAAAUnV4CuzqtigEiVd/lGkr/VGrMNVprHz6stNFMRAbGpxbSeG6zq
	2iYBp9fYwyAvhKQgh7LJjrINJK+MoCmJDZWl8zW3fV6rKBr2vp4LH64/dDcZ18Pd+H8aOVSLeW5
	tqHw3C7rJHBHoQQ3FSBUSVsi9guJhE2XZv9g8x4pW3T6FJUlmWNtPREl5cGbGSMY=
X-Received: by 2002:a17:90a:8a84:: with SMTP id x4mr79465966pjn.105.1563863166422;
        Mon, 22 Jul 2019 23:26:06 -0700 (PDT)
X-Received: by 2002:a17:90a:8a84:: with SMTP id x4mr79465899pjn.105.1563863165294;
        Mon, 22 Jul 2019 23:26:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863165; cv=none;
        d=google.com; s=arc-20160816;
        b=SUwvikr5xt16xqO1je4qhkgcPLEXsAKt4ryPCVholSZJsv8MMnQAlBq/wtrAqzUeuP
         oRt0XMpnoX7v0bz/7iIwF0Hp5kYMeJ1EWtK6C23jQ+z7DodzqPTG4vn9A3bQEmghcKDG
         nCvb9QYER065n7LqlFTxnzbumncRPM9uxKppwwAZaSIlEyy6/Jx/MPW0druZ+u5IehaK
         WJmu3vFsSTGZNne7rrKGdySbOh7wePI1uvHtYyxeyoeSQGRam4HUBppzVBzTYN67QDyg
         NNbzIRrFLtomVMcVP3sQS0KtkdNUqp7hU061p+tDXxkf5VBQ+tBZAhUDgnFP56tgqhD/
         WYOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=xr8cwtVAFqpMs6Az1B0omCnRc5Dl1COt3ClHqKPUTb0=;
        b=xR7ht3rpp42JP0L7g9TYuFI+vNjRo+Zqt3wV8ETGZgzfCseFehAPmIrhAIs0nfe8Wf
         dj6kTs3cc4derJKeiy8oik09aacwjsTXncTXjLvqW1KhfKAd6vdeBCi6Y65cHwedbgNR
         4WHuwHyuvPcaV5+Ri98Np+g+bHByuodC0CR67VcOErxD4eyYgtBmgBDDHrw0Lw5rYgTR
         lOXkB483ccOwS9iUlIwwBTo2FqmdsLuM9nyFLXk2PHO6JBve/rI/2QsKB4jifnzqEjTV
         3m38W0MsgrbRzj8+NVcGsFNiZjJYAU2B17uFc444E+/FIVp+72QSkZ+DOTmeIS9rmfRq
         /Q/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cmL1+InM;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor52015187pjc.24.2019.07.22.23.26.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 23:26:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cmL1+InM;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xr8cwtVAFqpMs6Az1B0omCnRc5Dl1COt3ClHqKPUTb0=;
        b=cmL1+InM3mkcUz2zDDDyJRITha2V/7Rd8iwv+E1hV4xWxw3bm/WF6h5BVMClUgEvVn
         66oS1lHbyJ+8UIfuPXPAVjxqqUIpzZl2DuPnRuJXWr7GgBT5srsqpRCit5/5ame8HVfG
         DF90SM1618EeOQJZ26t4Pic/dJQt8dW0+hEHbVK7gAmZxyWKrktsuvNLItNKdsEk2uno
         pr+uwP0MZYECsS6HPNco8k2jZBDGffHXAoytjxANUnkkf+jIj9lm8EZq/salckMn93f2
         L4cug0wZEPWUN/ER/t5ZJsZqUAxAnQoMZ2RHkDienL6bNL01khE3mG0XmELWBBKvvQ7q
         2TYw==
X-Google-Smtp-Source: APXvYqyYQVyWb5NekZSfzb2hyCygQblEI1kBz45ohHpfqzxwwSNZgRSbErPKUB/YTrfc5L/+EwHqXw==
X-Received: by 2002:a17:90a:3344:: with SMTP id m62mr81071242pjb.135.1563863164805;
        Mon, 22 Jul 2019 23:26:04 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s66sm44630376pfs.8.2019.07.22.23.25.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 23:26:03 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 3/5] mm: account nr_isolated_xxx in [isolate|putback]_lru_page
Date: Tue, 23 Jul 2019 15:25:37 +0900
Message-Id: <20190723062539.198697-4-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
In-Reply-To: <20190723062539.198697-1-minchan@kernel.org>
References: <20190723062539.198697-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The isolate counting is pecpu counter so it would be not huge gain
to work them by batch. Rather than complicating to make them batch,
let's make it more stright-foward via adding the counting logic
into [isolate|putback]_lru_page API.

* v1
 * fix accounting bug - Hillf

Link: http://lkml.kernel.org/r/20190531165927.GA20067@cmpxchg.org
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/compaction.c     |  2 --
 mm/gup.c            |  7 +------
 mm/khugepaged.c     |  3 ---
 mm/memory-failure.c |  3 ---
 mm/memory_hotplug.c |  4 ----
 mm/mempolicy.c      |  6 +-----
 mm/migrate.c        | 37 ++++++++-----------------------------
 mm/vmscan.c         | 22 ++++++++++++++++------
 8 files changed, 26 insertions(+), 58 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 952dc2fb24e50..3e6b5acdaaffc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -984,8 +984,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-		inc_node_page_state(page,
-				NR_ISOLATED_ANON + page_is_file_cache(page));
 
 isolate_success:
 		list_add(&page->lru, &cc->migratepages);
diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bacc..11d0634ce6137 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1475,13 +1475,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 					drain_allow = false;
 				}
 
-				if (!isolate_lru_page(head)) {
+				if (!isolate_lru_page(head))
 					list_add_tail(&head->lru, &cma_page_list);
-					mod_node_page_state(page_pgdat(head),
-							    NR_ISOLATED_ANON +
-							    page_is_file_cache(head),
-							    hpage_nr_pages(head));
-				}
 			}
 		}
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index eaaa21b232156..a8b517d6df4ab 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -503,7 +503,6 @@ void __khugepaged_exit(struct mm_struct *mm)
 
 static void release_pte_page(struct page *page)
 {
-	dec_node_page_state(page, NR_ISOLATED_ANON + page_is_file_cache(page));
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -602,8 +601,6 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			result = SCAN_DEL_PAGE_LRU;
 			goto out;
 		}
-		inc_node_page_state(page,
-				NR_ISOLATED_ANON + page_is_file_cache(page));
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 7ef849da8278c..9900bb95d7740 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1791,9 +1791,6 @@ static int __soft_offline_page(struct page *page, int flags)
 		 * so use !__PageMovable instead for LRU page's mapping
 		 * cannot have PAGE_MAPPING_MOVABLE.
 		 */
-		if (!__PageMovable(page))
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2a9bbddb0e554..e92103a13545b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1383,10 +1383,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
 		if (!ret) { /* Success */
 			list_add_tail(&page->lru, &source);
-			if (!__PageMovable(page))
-				inc_node_page_state(page, NR_ISOLATED_ANON +
-						    page_is_file_cache(page));
-
 		} else {
 			pr_warn("failed to isolate pfn %lx\n", pfn);
 			dump_page(page, "isolation failed");
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4acc2d14bc779..a5685eee6d1db 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -994,12 +994,8 @@ static int migrate_page_add(struct page *page, struct list_head *pagelist,
 	 * Avoid migrating a page that is shared with others.
 	 */
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(head) == 1) {
-		if (!isolate_lru_page(head)) {
+		if (!isolate_lru_page(head))
 			list_add_tail(&head->lru, pagelist);
-			mod_node_page_state(page_pgdat(head),
-				NR_ISOLATED_ANON + page_is_file_cache(head),
-				hpage_nr_pages(head));
-		}
 	}
 
 	return 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index 515718392b249..2ccab4add6471 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -190,8 +190,6 @@ void putback_movable_pages(struct list_head *l)
 			unlock_page(page);
 			put_page(page);
 		} else {
-			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
-					page_is_file_cache(page), -hpage_nr_pages(page));
 			putback_lru_page(page);
 		}
 	}
@@ -1177,10 +1175,17 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (page_count(page) == 1) {
+		bool is_lru = !__PageMovable(page);
+
 		/* page was freed from under us. So we are done. */
 		ClearPageActive(page);
 		ClearPageUnevictable(page);
-		if (unlikely(__PageMovable(page))) {
+		if (likely(is_lru))
+			mod_node_page_state(page_pgdat(page),
+						NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-hpage_nr_pages(page));
+		else {
 			lock_page(page);
 			if (!PageMovable(page))
 				__ClearPageIsolated(page);
@@ -1206,15 +1211,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * restored.
 		 */
 		list_del(&page->lru);
-
-		/*
-		 * Compaction can migrate also non-LRU pages which are
-		 * not accounted to NR_ISOLATED_*. They can be recognized
-		 * as __PageMovable
-		 */
-		if (likely(!__PageMovable(page)))
-			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
-					page_is_file_cache(page), -hpage_nr_pages(page));
 	}
 
 	/*
@@ -1568,9 +1564,6 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 
 		err = 0;
 		list_add_tail(&head->lru, pagelist);
-		mod_node_page_state(page_pgdat(head),
-			NR_ISOLATED_ANON + page_is_file_cache(head),
-			hpage_nr_pages(head));
 	}
 out_putpage:
 	/*
@@ -1886,8 +1879,6 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
-	int page_lru;
-
 	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
 
 	/* Avoid migrating to a node that is nearly full */
@@ -1909,10 +1900,6 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 		return 0;
 	}
 
-	page_lru = page_is_file_cache(page);
-	mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON + page_lru,
-				hpage_nr_pages(page));
-
 	/*
 	 * Isolating the page has taken another reference, so the
 	 * caller's reference can be safely dropped without the page
@@ -1967,8 +1954,6 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
 			putback_lru_page(page);
 		}
 		isolated = 0;
@@ -1998,7 +1983,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
-	int page_lru = page_is_file_cache(page);
 	unsigned long start = address & HPAGE_PMD_MASK;
 
 	new_page = alloc_pages_node(node,
@@ -2044,8 +2028,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_node_page_state(page_pgdat(page),
-			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
 
 		goto out_unlock;
 	}
@@ -2095,9 +2077,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_node_page_state(page_pgdat(page),
-			NR_ISOLATED_ANON + page_lru,
-			-HPAGE_PMD_NR);
 	return isolated;
 
 out_fail:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f68449ce0c44c..c693585c3facd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1021,6 +1021,9 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 void putback_lru_page(struct page *page)
 {
 	lru_cache_add(page);
+	mod_node_page_state(page_pgdat(page),
+				NR_ISOLATED_ANON + page_is_file_cache(page),
+				-hpage_nr_pages(page));
 	put_page(page);		/* drop ref from isolate */
 }
 
@@ -1486,6 +1489,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		nr_reclaimed += nr_pages;
 
+		mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-nr_pages);
 		/*
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
@@ -1561,7 +1567,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
 			TTU_IGNORE_ACCESS, &dummy_stat, true);
 	list_splice(&clean_pages, page_list);
-	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
 
@@ -1637,6 +1642,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 		 */
 		ClearPageLRU(page);
 		ret = 0;
+		__mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 	}
 
 	return ret;
@@ -1768,6 +1776,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
 				    total_scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
+
 	return nr_taken;
 }
 
@@ -1816,6 +1825,9 @@ int isolate_lru_page(struct page *page)
 			ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
+			mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 		}
 		spin_unlock_irq(&pgdat->lru_lock);
 	}
@@ -1907,6 +1919,9 @@ static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
 
+		__mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-hpage_nr_pages(page));
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1984,7 +1999,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
@@ -2010,8 +2024,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	move_pages_to_lru(lruvec, &page_list);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
@@ -2070,7 +2082,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_vm_events(PGREFILL, nr_scanned);
@@ -2139,7 +2150,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_active);
-- 
2.22.0.657.g960e92d24f-goog

