Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E43546B0266
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:31:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r20-v6so531953pgv.20
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:31:33 -0700 (PDT)
Received: from mxct.zte.com.cn (out1.zte.com.cn. [202.103.147.172])
        by mx.google.com with ESMTPS id m12-v6si690970pgd.334.2018.07.26.00.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 00:31:32 -0700 (PDT)
From: Jiang Biao <jiang.biao2@zte.com.cn>
Subject: [PATCH v2] mm: fix page_freeze_refs and page_unfreeze_refs in comments.
Date: Thu, 26 Jul 2018 15:30:26 +0800
Message-Id: <1532590226-106038-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jiang.biao2@zte.com.cn, zhong.weidong@zte.com.cn

page_freeze_refs/page_unfreeze_refs have already been relplaced by
page_ref_freeze/page_ref_unfreeze , but they are not modified in
the comments.

Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
v1: fix comments in vmscan.
v2: fix other two places and fix typoes.

 mm/ksm.c            | 4 ++--
 mm/memory-failure.c | 2 +-
 mm/vmscan.c         | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index a6d43cf..4c39cb67 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -703,7 +703,7 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	 * We cannot do anything with the page while its refcount is 0.
 	 * Usually 0 means free, or tail of a higher-order page: in which
 	 * case this node is no longer referenced, and should be freed;
-	 * however, it might mean that the page is under page_freeze_refs().
+	 * however, it might mean that the page is under page_ref_freeze().
 	 * The __remove_mapping() case is easy, again the node is now stale;
 	 * but if page is swapcache in migrate_page_move_mapping(), it might
 	 * still be our page, in which case it's essential to keep the node.
@@ -714,7 +714,7 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 		 * work here too.  We have chosen the !PageSwapCache test to
 		 * optimize the common case, when the page is or is about to
 		 * be freed: PageSwapCache is cleared (under spin_lock_irq)
-		 * in the freeze_refs section of __remove_mapping(); but Anon
+		 * in the ref_freeze section of __remove_mapping(); but Anon
 		 * page->mapping reset to NULL later, in free_pages_prepare().
 		 */
 		if (!PageSwapCache(page))
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9d142b9..c83a174 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1167,7 +1167,7 @@ int memory_failure(unsigned long pfn, int flags)
 	 *    R/W the page; let's pray that the page has been
 	 *    used and will be freed some time later.
 	 * In fact it's dangerous to directly bump up page count from 0,
-	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
+	 * that may make page_ref_freeze()/page_ref_unfreeze() mismatch.
 	 */
 	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
 		if (is_free_buddy_page(p)) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f8..02d0c20 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -744,7 +744,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		refcount = 2;
 	if (!page_ref_freeze(page, refcount))
 		goto cannot_free;
-	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
+	/* note: atomic_cmpxchg in page_ref_freeze provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
 		page_ref_unfreeze(page, refcount);
 		goto cannot_free;
-- 
2.7.4
