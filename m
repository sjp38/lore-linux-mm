Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 787D66B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 18:16:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e64so9896637wmi.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:16:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y76sor1396244lfk.80.2017.09.25.15.16.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 15:16:56 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [RFC PATCH] ksm: add offset arg to memcmp_pages() to speedup comparing
Date: Tue, 26 Sep 2017 01:16:47 +0300
Message-Id: <20170925221647.4284-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

Currently while search/inserting in RB tree,
memcmp used for comparing out of tree pages with in tree pages.

But on each step of search memcmp used to compare pages from
zero offset, i.e. each time we just ignore forward byte progress.

That make some overhead for search in deep RB tree,
so store last start offset where no diff in page content.

offset aligned to 1024, that a some type of magic value
For that value i get ~ same performance in bad case (where offset useless)
for memcmp_pages() with offset and without.

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 mm/ksm.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 15dd7415f7b3..63f8b4f0824c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -991,14 +991,27 @@ static u32 calc_checksum(struct page *page)
 	return checksum;
 }

-static int memcmp_pages(struct page *page1, struct page *page2)
+static int memcmp_pages(struct page *page1, struct page *page2, u32 *offset)
 {
+	const u32 iter = 1024;
 	char *addr1, *addr2;
-	int ret;
+	u32 i = 0;
+	int ret = 0;
+
+	BUILD_BUG_ON(!IS_ALIGNED(PAGE_SIZE, iter));

 	addr1 = kmap_atomic(page1);
 	addr2 = kmap_atomic(page2);
-	ret = memcmp(addr1, addr2, PAGE_SIZE);
+	if (offset == NULL) {
+		ret = memcmp(addr1, addr2, PAGE_SIZE);
+	} else {
+		if (*offset < PAGE_SIZE)
+			i = *offset;
+		for (; i < PAGE_SIZE && ret == 0; i += iter) {
+			ret = memcmp(&addr1[i], &addr2[i], iter);
+		}
+		*offset = i;
+	}
 	kunmap_atomic(addr2);
 	kunmap_atomic(addr1);
 	return ret;
@@ -1006,7 +1019,7 @@ static int memcmp_pages(struct page *page1, struct page *page2)

 static inline int pages_identical(struct page *page1, struct page *page2)
 {
-	return !memcmp_pages(page1, page2);
+	return !memcmp_pages(page1, page2, NULL);
 }

 static int write_protect_page(struct vm_area_struct *vma, struct page *page,
@@ -1514,6 +1527,7 @@ static __always_inline struct page *chain(struct stable_node **s_n_d,
 static struct page *stable_tree_search(struct page *page)
 {
 	int nid;
+	u32 diff_offset;
 	struct rb_root *root;
 	struct rb_node **new;
 	struct rb_node *parent;
@@ -1532,6 +1546,7 @@ static struct page *stable_tree_search(struct page *page)
 again:
 	new = &root->rb_node;
 	parent = NULL;
+	diff_offset = 0;

 	while (*new) {
 		struct page *tree_page;
@@ -1590,7 +1605,7 @@ static struct page *stable_tree_search(struct page *page)
 			goto again;
 		}

-		ret = memcmp_pages(page, tree_page);
+		ret = memcmp_pages(page, tree_page, &diff_offset);
 		put_page(tree_page);

 		parent = *new;
@@ -1760,6 +1775,7 @@ static struct page *stable_tree_search(struct page *page)
 static struct stable_node *stable_tree_insert(struct page *kpage)
 {
 	int nid;
+	u32 diff_offset;
 	unsigned long kpfn;
 	struct rb_root *root;
 	struct rb_node **new;
@@ -1773,6 +1789,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 again:
 	parent = NULL;
 	new = &root->rb_node;
+	diff_offset = 0;

 	while (*new) {
 		struct page *tree_page;
@@ -1819,7 +1836,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 			goto again;
 		}

-		ret = memcmp_pages(kpage, tree_page);
+		ret = memcmp_pages(kpage, tree_page, &diff_offset);
 		put_page(tree_page);

 		parent = *new;
@@ -1884,6 +1901,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 	struct rb_root *root;
 	struct rb_node *parent = NULL;
 	int nid;
+	u32 diff_offset = 0;

 	nid = get_kpfn_nid(page_to_pfn(page));
 	root = root_unstable_tree + nid;
@@ -1908,7 +1926,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 			return NULL;
 		}

-		ret = memcmp_pages(page, tree_page);
+		ret = memcmp_pages(page, tree_page, &diff_offset);

 		parent = *new;
 		if (ret < 0) {
--
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
