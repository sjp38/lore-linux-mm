Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86B168E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:53:04 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id p4so2638245pgj.21
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:53:04 -0800 (PST)
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id m14si20439432pgd.326.2019.01.23.15.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 15:53:02 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH] mm: ksm: do not block on page lock when searching stable tree
Date: Thu, 24 Jan 2019 07:52:53 +0800
Message-Id: <1548287573-15084-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ktkhai@virtuozzo.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

ksmd need search stable tree to look for the suitable KSM page, but the
KSM page might be locked for a while due to i.e. KSM page rmap walk.
Basically it is not a big deal since commit 2c653d0ee2ae
("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
since max_page_sharing limits the number of shared KSM pages.

But it still sounds not worth waiting for the lock, the page can be skip,
then try to merge it in the next scan to avoid potential stall if its
content is still intact.

Introduce async mode to get_ksm_page() to not block on page lock, like
what try_to_merge_one_page() does.

Return -EBUSY if trylock fails, since NULL means not find suitable KSM
page, which is a valid case.

With the default max_page_sharing setting (256), there is almost no
observed change comparing lock vs trylock.

However, with ksm02 of LTP, the reduced ksmd full scan time can be
observed, which has set max_page_sharing to 786432.  With lock version,
ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
may take 8s - 11s to run two full scans.  And, the number of
pages_sharing and pages_to_scan keep same.  Basically, this change has
no harm.

Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
Hi folks,

This patch was with "mm: vmscan: skip KSM page in direct reclaim if priority
is low" in the initial submission.  Then Hugh and Andrea pointed out commit
2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page deduplication
limit") is good enough for limiting the number of shared KSM page to prevent
from softlock when walking ksm page rmap.  This commit does solve the problem.
So, the series was dropped by Andrew from -mm tree.

However, I thought the second patch (this one) still sounds useful.  So, I did
some test and resubmit it.  The first version was reviewed by Krill Tkhai, so
I keep his Reviewed-by tag since there is no change to the patch except the
commit log.

So, would you please reconsider this patch?

v2: Updated the commit log to reflect some test result and latest discussion

 mm/ksm.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 6c48ad1..f66405c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -668,7 +668,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 }
 
 /*
- * get_ksm_page: checks if the page indicated by the stable node
+ * __get_ksm_page: checks if the page indicated by the stable node
  * is still its ksm page, despite having held no reference to it.
  * In which case we can trust the content of the page, and it
  * returns the gotten page; but if the page has now been zapped,
@@ -686,7 +686,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
  * a page to put something that might look like our key in page->mapping.
  * is on its way to being freed; but it is an anomaly to bear in mind.
  */
-static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
+static struct page *__get_ksm_page(struct stable_node *stable_node,
+				   bool lock_it, bool async)
 {
 	struct page *page;
 	void *expected_mapping;
@@ -729,7 +730,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	}
 
 	if (lock_it) {
-		lock_page(page);
+		if (async) {
+			if (!trylock_page(page)) {
+				put_page(page);
+				return ERR_PTR(-EBUSY);
+			}
+		} else
+			lock_page(page);
+
 		if (READ_ONCE(page->mapping) != expected_mapping) {
 			unlock_page(page);
 			put_page(page);
@@ -752,6 +760,11 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	return NULL;
 }
 
+static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
+{
+	return __get_ksm_page(stable_node, lock_it, false);
+}
+
 /*
  * Removing rmap_item from stable or unstable tree.
  * This function will clean the information from the stable/unstable tree.
@@ -1673,7 +1686,11 @@ static struct page *stable_tree_search(struct page *page)
 			 * It would be more elegant to return stable_node
 			 * than kpage, but that involves more changes.
 			 */
-			tree_page = get_ksm_page(stable_node_dup, true);
+			tree_page = __get_ksm_page(stable_node_dup, true, true);
+
+			if (PTR_ERR(tree_page) == -EBUSY)
+				return ERR_PTR(-EBUSY);
+
 			if (unlikely(!tree_page))
 				/*
 				 * The tree may have been rebalanced,
@@ -2060,6 +2077,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 
 	/* We first start with searching the page inside the stable tree */
 	kpage = stable_tree_search(page);
+
+	if (PTR_ERR(kpage) == -EBUSY)
+		return;
+
 	if (kpage == page && rmap_item->head == stable_node) {
 		put_page(kpage);
 		return;
-- 
1.8.3.1
