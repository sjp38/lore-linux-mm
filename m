Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CECDC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7E9220872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7E9220872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6A0B6B026A; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 872456B0266; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C6D6B0266; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id 041316B026B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A9B8E8130
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-FDA: 75918642786.01.trick57_41f539d83380d
X-HE-Tag: trick57_41f539d83380d
X-Filterd-Recvd-Size: 11492
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4AF8AF59;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 07/10] mm,hwpoison: Rework soft offline for in-use pages
Date: Tue, 10 Sep 2019 12:30:13 +0200
Message-Id: <20190910103016.14290-8-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch changes the way we set and handle in-use poisoned pages.
Until now, poisoned pages were released to the buddy allocator, trusting
that the checks that take place prior to hand the page to userspace would
act as a safe net and would skip that page.

This has proved to be wrong, as we got some pfn walkers out there, like
compaction, that all they care is the page to be PageBuddy and be in a
freelist.
Although this might not be the only user, having poisoned pages
in the buddy allocator seems a bad idea as we should only have
free pages that are ready and meant to be used as such.

Before explainaing the taken approach, let us break down the kind
of pages we can soft offline.

- Anonymous THP (after the split, they end up being 4K pages)
- Hugetlb
- Order-0 pages (that can be either migrated or invalited)

The following will only refer to in-use pages, free pages will
be explained in patch#9.

* Normal pages (order-0 and anon-THP)

  - If they are clean and unmapped page cache pages, we detach
    the page from its mapping.
  - If they are mapped/dirty, we do the isolate-and-migrate dance.

  Either way, do not call put_page directly from those paths.
  Instead, we keep the page and send it to page_set_poison.

  page_set_poison sets the HWPoison flag and calls put_page.
  This call to put_page is mainly to be able to call __page_cache_release,
  since this function is not exported.

  Down the chain, we placed a check for HWPoison page in free_pages_prepare,
  that just skips any poisoned page, so those pages do not end up in any
  pcplist/freelist.

  [[Now, I think that we would be better off if we duplicated/exported
  __page_cache_release in/to the hwpoison code, so this last put_page
  could go]]

  After that, we set the refcount on the page to 1 and we increment
  the poisoned pages counter.

* Hugetlb pages

  - we isolate-and-migrate them

  After the migration has been succesful, we call page_set_poison
  that sets the HWPoison flag and actually calls
  dissolve_free_huge_page for hugetlb pages.

  When dissolving a non-gigantib hugetlb page and we know that
  the memory range contains poisoned pages, we free the pages
  as order-0 pages, so free_pages_prepare will skip them accordingly.
  poisoned page.
  Since the infrastructure is already there because that is the way
  we free gigantic hugetlb pages, it does not take any effort to adapt
  it for non-gigantic hugetlb pages.

Because of the way we handle now in-use pages, we can safely drop
the put-as-isolation-migratetype dance, that was guarding
for the poisoned pages to end up in pcplists.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/hugetlb.c        | 35 +++++++++++++++++++++++++------
 mm/memory-failure.c | 60 ++++++++++++++++++++++++++---------------------------
 mm/migrate.c        | 11 +++-------
 mm/page_alloc.c     |  3 +++
 4 files changed, 64 insertions(+), 45 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ef37c85423a5..139e1c05c9a1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1045,16 +1045,17 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static void destroy_compound_gigantic_page(struct page *page,
-					unsigned int order)
+static void destroy_compound_page(struct page *page, unsigned int order)
 {
 	int i;
 	int nr_pages = 1 << order;
 	struct page *p = page + 1;
+	bool gigantic = order > MAX_ORDER - 1;
 
 	atomic_set(compound_mapcount_ptr(page), 0);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
+		if (!gigantic)
+			p->mapping = NULL;
 		clear_compound_head(p);
 		set_page_refcounted(p);
 	}
@@ -1063,6 +1064,13 @@ static void destroy_compound_gigantic_page(struct page *page,
 	__ClearPageHead(page);
 }
 
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
+static void destroy_compound_gigantic_page(struct page *page,
+					unsigned int order)
+{
+	destroy_compound_page(page, order);
+}
+
 static void free_gigantic_page(struct page *page, unsigned int order)
 {
 	free_contig_range(page_to_pfn(page), 1 << order);
@@ -1175,6 +1183,8 @@ static inline void destroy_compound_gigantic_page(struct page *page,
 static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
+	bool poisoned = false;
+	unsigned int order = huge_page_order(h);
 
 	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
 		return;
@@ -1182,6 +1192,8 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
+		if (unlikely(PageHWPoison(page)))
+			poisoned = true;
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error |
 				1 << PG_referenced | 1 << PG_dirty |
 				1 << PG_active | 1 << PG_private |
@@ -1191,10 +1203,21 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	set_compound_page_dtor(page, NULL_COMPOUND_DTOR);
 	set_page_refcounted(page);
 	if (hstate_is_gigantic(h)) {
-		destroy_compound_gigantic_page(page, huge_page_order(h));
-		free_gigantic_page(page, huge_page_order(h));
+		destroy_compound_gigantic_page(page, order);
+		free_gigantic_page(page, order);
 	} else {
-		__free_pages(page, huge_page_order(h));
+		if (poisoned) {
+			unsigned long pfn = page_to_pfn(page);
+			/*
+			 * If we have poisoned pages in the range,
+			 * we free them up as order-0 pages, so
+			 * free_pages_prepare will skip them accordingly.
+			 */
+			destroy_compound_page(page, order);
+			free_contig_range(pfn, 1 << order);
+		} else {
+			__free_pages(page, order);
+		}
 	}
 }
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 820742035402..d44dacb8e2ea 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -78,6 +78,24 @@ EXPORT_SYMBOL_GPL(hwpoison_filter_dev_minor);
 EXPORT_SYMBOL_GPL(hwpoison_filter_flags_mask);
 EXPORT_SYMBOL_GPL(hwpoison_filter_flags_value);
 
+static bool page_set_poison(struct page *page)
+{
+	SetPageHWPoison(page);
+
+	if (PageHuge(page) && dissolve_free_huge_page(page))
+		goto error;
+	else if (!PageHuge(page) && page_count(page))
+		put_page(page);
+
+	set_page_refcounted(page);
+	num_poisoned_pages_inc();
+
+	return true;
+error:
+	ClearPageHWPoison(page);
+	return false;
+}
+
 static int hwpoison_filter_dev(struct page *p)
 {
 	struct address_space *mapping;
@@ -1704,28 +1722,16 @@ static int soft_offline_huge_page(struct page *page)
 
 	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 				MIGRATE_SYNC, MR_MEMORY_FAILURE);
-	if (ret) {
+	if (!ret) {
+		if (!page_set_poison(page))
+			ret = -EBUSY;
+	} else {
 		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%pGp)\n",
 			pfn, ret, page->flags, &page->flags);
 		if (!list_empty(&pagelist))
 			putback_movable_pages(&pagelist);
 		if (ret > 0)
 			ret = -EIO;
-	} else {
-		/*
-		 * We set PG_hwpoison only when the migration source hugepage
-		 * was successfully dissolved, because otherwise hwpoisoned
-		 * hugepage remains on free hugepage list, then userspace will
-		 * find it as SIGBUS by allocation failure. That's not expected
-		 * in soft-offlining.
-		 */
-		ret = dissolve_free_huge_page(page);
-		if (!ret) {
-			if (set_hwpoison_free_buddy_page(page))
-				num_poisoned_pages_inc();
-			else
-				ret = -EBUSY;
-		}
 	}
 	return ret;
 }
@@ -1760,10 +1766,8 @@ static int __soft_offline_page(struct page *page)
 	 * would need to fix isolation locking first.
 	 */
 	if (ret == 1) {
-		put_hwpoison_page(page);
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
-		SetPageHWPoison(page);
-		num_poisoned_pages_inc();
+		page_set_poison(page);
 		return 0;
 	}
 
@@ -1794,7 +1798,12 @@ static int __soft_offline_page(struct page *page)
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
-		if (ret) {
+		if (!ret) {
+			/*
+			 * Page was succesfully migrated.
+			 */
+			page_set_poison(page);
+		} else {
 			if (!list_empty(&pagelist))
 				putback_movable_pages(&pagelist);
 
@@ -1813,27 +1822,16 @@ static int __soft_offline_page(struct page *page)
 static int soft_offline_in_use_page(struct page *page)
 {
 	int ret;
-	int mt;
 	struct page *hpage = compound_head(page);
 
 	if (!PageHuge(page) && PageTransHuge(hpage))
 		if (try_to_split_thp_page(page, "soft offline") < 0)
 			return -EBUSY;
 
-	/*
-	 * Setting MIGRATE_ISOLATE here ensures that the page will be linked
-	 * to free list immediately (not via pcplist) when released after
-	 * successful page migration. Otherwise we can't guarantee that the
-	 * page is really free after put_page() returns, so
-	 * set_hwpoison_free_buddy_page() highly likely fails.
-	 */
-	mt = get_pageblock_migratetype(page);
-	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page);
 	else
 		ret = __soft_offline_page(page);
-	set_pageblock_migratetype(page, mt);
 	return ret;
 }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index bdd1e95a459e..c396a019b2a4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1223,16 +1223,11 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	 * we want to retry.
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		put_page(page);
-		if (reason == MR_MEMORY_FAILURE) {
+		if (reason != MR_MEMORY_FAILURE)
 			/*
-			 * Set PG_HWPoison on just freed page
-			 * intentionally. Although it's rather weird,
-			 * it's how HWPoison flag works at the moment.
+			 * We handle poisoned pages in hwpoison code
 			 */
-			if (set_hwpoison_free_buddy_page(page))
-				num_poisoned_pages_inc();
-		}
+			put_page(page);
 	} else {
 		if (rc != -EAGAIN) {
 			if (likely(!__PageMovable(page))) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c5d62f1c2851..fe38229d0a77 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1134,6 +1134,9 @@ static __always_inline bool free_pages_prepare(struct page *page,
 
 	trace_mm_page_free(page, order);
 
+	if (unlikely(PageHWPoison(page)))
+		return false;
+
 	/*
 	 * Check tail pages before head page information is cleared to
 	 * avoid checking PageCompound for order-0 pages.
-- 
2.12.3


