Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7D76B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 16:03:26 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id z192so627224qkb.3
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 13:03:26 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v25si4092616qkv.286.2018.01.31.13.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 13:03:25 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity checking
Date: Wed, 31 Jan 2018 16:02:59 -0500
Message-Id: <20180131210300.22963-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180131210300.22963-1-pasha.tatashin@oracle.com>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com

During boot we poison struct page memory in order to ensure that no one is
accessing this memory until the struct pages are initialized in
__init_single_page().

This patch adds more scrutiny to this checking, by making sure that flags
do not equal to poison pattern when the are accessed. The pattern is all
ones.

Since, node id is also stored in struct page, and may be accessed quiet
early we add the enforcement into page_to_nid() function as well.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 include/linux/mm.h         |  4 +++-
 include/linux/page-flags.h | 22 +++++++++++++++++-----
 mm/memblock.c              |  2 +-
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 42b7154291e4..e0281de2cb13 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -896,7 +896,9 @@ extern int page_to_nid(const struct page *page);
 #else
 static inline int page_to_nid(const struct page *page)
 {
-	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
+	struct page *p = (struct page *)page;
+
+	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
 #endif
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 3ec44e27aa9d..743644b73359 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -161,9 +161,18 @@ static __always_inline int PageCompound(struct page *page)
 	return test_bit(PG_head, &page->flags) || PageTail(page);
 }
 
+#define	PAGE_POISON_PATTERN	~0ul
+static inline int PagePoisoned(const struct page *page)
+{
+	return page->flags == PAGE_POISON_PATTERN;
+}
+
 /*
  * Page flags policies wrt compound pages
  *
+ * PF_POISONED_CHECK
+ *     check if this struct page poisoned/uninitialized
+ *
  * PF_ANY:
  *     the page flag is relevant for small, head and tail pages.
  *
@@ -181,17 +190,20 @@ static __always_inline int PageCompound(struct page *page)
  * PF_NO_COMPOUND:
  *     the page flag is not relevant for compound pages.
  */
-#define PF_ANY(page, enforce)	page
-#define PF_HEAD(page, enforce)	compound_head(page)
+#define PF_POISONED_CHECK(page) ({					\
+		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
+		page; })
+#define PF_ANY(page, enforce)	PF_POISONED_CHECK(page)
+#define PF_HEAD(page, enforce)	PF_POISONED_CHECK(compound_head(page))
 #define PF_ONLY_HEAD(page, enforce) ({					\
 		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
-		page;})
+		PF_POISONED_CHECK(page); })
 #define PF_NO_TAIL(page, enforce) ({					\
 		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
-		compound_head(page);})
+		PF_POISONED_CHECK(compound_head(page)); })
 #define PF_NO_COMPOUND(page, enforce) ({				\
 		VM_BUG_ON_PGFLAGS(enforce && PageCompound(page), page);	\
-		page;})
+		PF_POISONED_CHECK(page); })
 
 /*
  * Macros to create function definitions for page flags
diff --git a/mm/memblock.c b/mm/memblock.c
index 5a9ca2a1751b..d85c8754e0ce 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1373,7 +1373,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
 					   min_addr, max_addr, nid);
 #ifdef CONFIG_DEBUG_VM
 	if (ptr && size > 0)
-		memset(ptr, 0xff, size);
+		memset(ptr, PAGE_POISON_PATTERN, size);
 #endif
 	return ptr;
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
