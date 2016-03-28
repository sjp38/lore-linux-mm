Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8DC6B0264
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 02:30:16 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so130021175pfb.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:30:16 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id c90si11065318pfd.233.2016.03.27.23.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 23:30:15 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id td3so90771563pab.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:30:15 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 2/2] mm: rename _count, field of the struct page, to _refcount
Date: Mon, 28 Mar 2016 15:30:01 +0900
Message-Id: <1459146601-11448-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Many developer already know that field for reference count of
the struct page is _count and atomic type. They would try to handle it
directly and this could break the purpose of page reference count
tracepoint. To prevent direct _count modification, this patch rename it
to _refcount and add warning message on the code. After that, developer
who need to handle reference count will find that field should not be
accessed directly.

v2: change more _count usages to _refcount

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/tile/mm/init.c      |  2 +-
 include/linux/mm_types.h |  8 ++++++--
 include/linux/page_ref.h | 26 +++++++++++++-------------
 kernel/kexec_core.c      |  2 +-
 4 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index a0582b7..adce254 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -679,7 +679,7 @@ static void __init init_free_pfn_range(unsigned long start, unsigned long end)
 			 * Hacky direct set to avoid unnecessary
 			 * lock take/release for EVERY page here.
 			 */
-			p->_count.counter = 0;
+			p->_refcount.counter = 0;
 			p->_mapcount.counter = -1;
 		}
 		init_page_count(page);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 944b2b3..9e8eb5a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -97,7 +97,11 @@ struct page {
 					};
 					int units;	/* SLOB */
 				};
-				atomic_t _count;		/* Usage count, see below. */
+				/*
+				 * Usage count, *USE WRAPPER FUNCTION*
+				 * when manual accounting. See page_ref.h
+				 */
+				atomic_t _refcount;
 			};
 			unsigned int active;	/* SLAB */
 		};
@@ -248,7 +252,7 @@ struct page_frag_cache {
 	__u32 offset;
 #endif
 	/* we maintain a pagecount bias, so that we dont dirty cache line
-	 * containing page->_count every time we allocate a fragment.
+	 * containing page->_refcount every time we allocate a fragment.
 	 */
 	unsigned int		pagecnt_bias;
 	bool pfmemalloc;
diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index e596d5d9..8b5e0a9 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -63,17 +63,17 @@ static inline void __page_ref_unfreeze(struct page *page, int v)
 
 static inline int page_ref_count(struct page *page)
 {
-	return atomic_read(&page->_count);
+	return atomic_read(&page->_refcount);
 }
 
 static inline int page_count(struct page *page)
 {
-	return atomic_read(&compound_head(page)->_count);
+	return atomic_read(&compound_head(page)->_refcount);
 }
 
 static inline void set_page_count(struct page *page, int v)
 {
-	atomic_set(&page->_count, v);
+	atomic_set(&page->_refcount, v);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_set))
 		__page_ref_set(page, v);
 }
@@ -89,35 +89,35 @@ static inline void init_page_count(struct page *page)
 
 static inline void page_ref_add(struct page *page, int nr)
 {
-	atomic_add(nr, &page->_count);
+	atomic_add(nr, &page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, nr);
 }
 
 static inline void page_ref_sub(struct page *page, int nr)
 {
-	atomic_sub(nr, &page->_count);
+	atomic_sub(nr, &page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, -nr);
 }
 
 static inline void page_ref_inc(struct page *page)
 {
-	atomic_inc(&page->_count);
+	atomic_inc(&page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, 1);
 }
 
 static inline void page_ref_dec(struct page *page)
 {
-	atomic_dec(&page->_count);
+	atomic_dec(&page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, -1);
 }
 
 static inline int page_ref_sub_and_test(struct page *page, int nr)
 {
-	int ret = atomic_sub_and_test(nr, &page->_count);
+	int ret = atomic_sub_and_test(nr, &page->_refcount);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
 		__page_ref_mod_and_test(page, -nr, ret);
@@ -126,7 +126,7 @@ static inline int page_ref_sub_and_test(struct page *page, int nr)
 
 static inline int page_ref_dec_and_test(struct page *page)
 {
-	int ret = atomic_dec_and_test(&page->_count);
+	int ret = atomic_dec_and_test(&page->_refcount);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
 		__page_ref_mod_and_test(page, -1, ret);
@@ -135,7 +135,7 @@ static inline int page_ref_dec_and_test(struct page *page)
 
 static inline int page_ref_dec_return(struct page *page)
 {
-	int ret = atomic_dec_return(&page->_count);
+	int ret = atomic_dec_return(&page->_refcount);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
 		__page_ref_mod_and_return(page, -1, ret);
@@ -144,7 +144,7 @@ static inline int page_ref_dec_return(struct page *page)
 
 static inline int page_ref_add_unless(struct page *page, int nr, int u)
 {
-	int ret = atomic_add_unless(&page->_count, nr, u);
+	int ret = atomic_add_unless(&page->_refcount, nr, u);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
 		__page_ref_mod_unless(page, nr, ret);
@@ -153,7 +153,7 @@ static inline int page_ref_add_unless(struct page *page, int nr, int u)
 
 static inline int page_ref_freeze(struct page *page, int count)
 {
-	int ret = likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+	int ret = likely(atomic_cmpxchg(&page->_refcount, count, 0) == count);
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_freeze))
 		__page_ref_freeze(page, count, ret);
@@ -165,7 +165,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	VM_BUG_ON_PAGE(page_count(page) != 0, page);
 	VM_BUG_ON(count == 0);
 
-	atomic_set(&page->_count, count);
+	atomic_set(&page->_refcount, count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
 		__page_ref_unfreeze(page, count);
 }
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index f826e11..e0e95b0 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1410,7 +1410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_STRUCT_SIZE(list_head);
 	VMCOREINFO_SIZE(nodemask_t);
 	VMCOREINFO_OFFSET(page, flags);
-	VMCOREINFO_OFFSET(page, _count);
+	VMCOREINFO_OFFSET(page, _refcount);
 	VMCOREINFO_OFFSET(page, mapping);
 	VMCOREINFO_OFFSET(page, lru);
 	VMCOREINFO_OFFSET(page, _mapcount);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
