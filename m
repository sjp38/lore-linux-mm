Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E84726B0544
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 14:17:05 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g21-v6so4017184pfg.18
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 11:17:05 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id y16-v6si1160241pgk.479.2018.11.07.11.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 11:17:04 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 2/2] mm: ksm: do not block on page lock when searching stable tree
Date: Thu,  8 Nov 2018 03:16:41 +0800
Message-Id: <1541618201-120667-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1541618201-120667-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1541618201-120667-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, vbabka@suse.cz, hannes@cmpxchg.org, hughd@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

ksmd need search stable tree to look for the suitable KSM page, but the
KSM page might be locked for long time due to i.e. KSM page rmap walk.

It sounds not worth waiting for the lock, the page can be skip, then try
to merge it in the next scan to avoid long stall if its content is
still intact.

Introduce async mode to get_ksm_page() to not block on page lock, like
what try_to_merge_one_page() does.

Return -EBUSY if trylock fails, since NULL means not find suitable KSM
page, which is a valid case.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/ksm.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b..576803d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -667,7 +667,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 }
 
 /*
- * get_ksm_page: checks if the page indicated by the stable node
+ * __get_ksm_page: checks if the page indicated by the stable node
  * is still its ksm page, despite having held no reference to it.
  * In which case we can trust the content of the page, and it
  * returns the gotten page; but if the page has now been zapped,
@@ -685,7 +685,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
  * a page to put something that might look like our key in page->mapping.
  * is on its way to being freed; but it is an anomaly to bear in mind.
  */
-static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
+static struct page *__get_ksm_page(struct stable_node *stable_node,
+				   bool lock_it, bool async)
 {
 	struct page *page;
 	void *expected_mapping;
@@ -728,7 +729,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
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
@@ -751,6 +759,11 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
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
@@ -1675,7 +1688,11 @@ static struct page *stable_tree_search(struct page *page)
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
@@ -2062,6 +2079,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 
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
