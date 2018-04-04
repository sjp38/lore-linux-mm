Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0348F6B028B
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:39 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p21so15439442qke.20
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u43si6849094qtb.359.2018.04.04.12.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:35 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 79/79] mm/ksm: set page->mapping to page_ronly struct instead of stable_node.
Date: Wed,  4 Apr 2018 15:18:31 -0400
Message-Id: <20180404191831.5378-42-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Set page->mapping to the page_ronly struct instead of stable_node
struct. There is no functional change as page_ronly is just a field
of stable_node.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 6085068fb8b3..52b0ae291d23 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -39,6 +39,7 @@
 #include <linux/freezer.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/page_ronly.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -126,6 +127,7 @@ struct ksm_scan {
 
 /**
  * struct stable_node - node of the stable rbtree
+ * @ronly: Page read only struct wrapper (see include/linux/page_ronly.h).
  * @node: rb node of this ksm page in the stable tree
  * @head: (overlaying parent) &migrate_nodes indicates temporarily on that list
  * @hlist_dup: linked into the stable_node->hlist with a stable_node chain
@@ -137,6 +139,7 @@ struct ksm_scan {
  * @nid: NUMA node id of stable tree in which linked (may not match kpfn)
  */
 struct stable_node {
+	struct page_ronly ronly;
 	union {
 		struct rb_node node;	/* when node of stable tree */
 		struct {		/* when listed for migration */
@@ -318,13 +321,15 @@ static void __init ksm_slab_free(void)
 
 static inline struct stable_node *page_stable_node(struct page *page)
 {
-	return PageReadOnly(page) ? page_rmapping(page) : NULL;
+	struct page_ronly *ronly = page_ronly(page);
+
+	return ronly ? container_of(ronly, struct stable_node, ronly) : NULL;
 }
 
 static inline void set_page_stable_node(struct page *page,
 					struct stable_node *stable_node)
 {
-	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_RONLY);
+	page_ronly_set(page, stable_node ? &stable_node->ronly : NULL);
 }
 
 static __always_inline bool is_stable_node_chain(struct stable_node *chain)
-- 
2.14.3
