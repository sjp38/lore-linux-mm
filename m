Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8389C6B025F
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:49:42 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r64so16607172oie.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:49:42 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0101.outbound.protection.outlook.com. [157.55.234.101])
        by mx.google.com with ESMTPS id r65si1257767oia.96.2016.05.24.01.49.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:49:41 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 2/8] mm: clean up non-standard page->_mapcount users
Date: Tue, 24 May 2016 11:49:24 +0300
Message-ID: <502f49000e0b63e6c62e338fac6b420bf34fb526.1464079537.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1464079537.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

 - Add a proper comment to page->_mapcount.
 - Introduce a macro for generating helper functions.
 - Place all special page->_mapcount values next to each other so that
   readers can see all possible values and so we don't get duplicates.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/mm_types.h   |  5 ++++
 include/linux/page-flags.h | 73 ++++++++++++++++++++--------------------------
 scripts/tags.sh            |  3 ++
 3 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc5977a9cab..16bdef7943e3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -85,6 +85,11 @@ struct page {
 				/*
 				 * Count of ptes mapped in mms, to show when
 				 * page is mapped & limit reverse map searches.
+				 *
+				 * Extra information about page type may be
+				 * stored here for pages that are never mapped,
+				 * in which case the value MUST BE <= -2.
+				 * See page-flags.h for more details.
 				 */
 				atomic_t _mapcount;
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e5a32445f930..9940ade6a25e 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -593,54 +593,45 @@ TESTPAGEFLAG_FALSE(DoubleMap)
 #endif
 
 /*
- * PageBuddy() indicate that the page is free and in the buddy system
- * (see mm/page_alloc.c).
- *
- * PAGE_BUDDY_MAPCOUNT_VALUE must be <= -2 but better not too close to
- * -2 so that an underflow of the page_mapcount() won't be mistaken
- * for a genuine PAGE_BUDDY_MAPCOUNT_VALUE. -128 can be created very
- * efficiently by most CPU architectures.
+ * For pages that are never mapped to userspace, page->mapcount may be
+ * used for storing extra information about page type. Any value used
+ * for this purpose must be <= -2, but it's better start not too close
+ * to -2 so that an underflow of the page_mapcount() won't be mistaken
+ * for a special page.
  */
-#define PAGE_BUDDY_MAPCOUNT_VALUE (-128)
-
-static inline int PageBuddy(struct page *page)
-{
-	return atomic_read(&page->_mapcount) == PAGE_BUDDY_MAPCOUNT_VALUE;
+#define PAGE_MAPCOUNT_OPS(uname, lname)					\
+static __always_inline int Page##uname(struct page *page)		\
+{									\
+	return atomic_read(&page->_mapcount) ==				\
+				PAGE_##lname##_MAPCOUNT_VALUE;		\
+}									\
+static __always_inline void __SetPage##uname(struct page *page)		\
+{									\
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);	\
+	atomic_set(&page->_mapcount, PAGE_##lname##_MAPCOUNT_VALUE);	\
+}									\
+static __always_inline void __ClearPage##uname(struct page *page)	\
+{									\
+	VM_BUG_ON_PAGE(!Page##uname(page), page);			\
+	atomic_set(&page->_mapcount, -1);				\
 }
 
-static inline void __SetPageBuddy(struct page *page)
-{
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
-	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
-}
+/*
+ * PageBuddy() indicate that the page is free and in the buddy system
+ * (see mm/page_alloc.c).
+ */
+#define PAGE_BUDDY_MAPCOUNT_VALUE		(-128)
+PAGE_MAPCOUNT_OPS(Buddy, BUDDY)
 
-static inline void __ClearPageBuddy(struct page *page)
-{
-	VM_BUG_ON_PAGE(!PageBuddy(page), page);
-	atomic_set(&page->_mapcount, -1);
-}
+/*
+ * PageBalloon() is set on pages that are on the balloon page list
+ * (see mm/balloon_compaction.c).
+ */
+#define PAGE_BALLOON_MAPCOUNT_VALUE		(-256)
+PAGE_MAPCOUNT_OPS(Balloon, BALLOON)
 
 extern bool is_free_buddy_page(struct page *page);
 
-#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
-
-static inline int PageBalloon(struct page *page)
-{
-	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
-}
-
-static inline void __SetPageBalloon(struct page *page)
-{
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
-	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
-}
-
-static inline void __ClearPageBalloon(struct page *page)
-{
-	VM_BUG_ON_PAGE(!PageBalloon(page), page);
-	atomic_set(&page->_mapcount, -1);
-}
-
 /*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
diff --git a/scripts/tags.sh b/scripts/tags.sh
index f72f48f638ae..ed7eef24ef89 100755
--- a/scripts/tags.sh
+++ b/scripts/tags.sh
@@ -185,6 +185,9 @@ regex_c=(
 	'/\<CLEARPAGEFLAG_NOOP(\([[:alnum:]_]*\).*/ClearPage\1/'
 	'/\<__CLEARPAGEFLAG_NOOP(\([[:alnum:]_]*\).*/__ClearPage\1/'
 	'/\<TESTCLEARFLAG_FALSE(\([[:alnum:]_]*\).*/TestClearPage\1/'
+	'/^PAGE_MAPCOUNT_OPS(\([[:alnum:]_]*\).*/Page\1/'
+	'/^PAGE_MAPCOUNT_OPS(\([[:alnum:]_]*\).*/__SetPage\1/'
+	'/^PAGE_MAPCOUNT_OPS(\([[:alnum:]_]*\).*/__ClearPage\1/'
 	'/^TASK_PFA_TEST([^,]*, *\([[:alnum:]_]*\))/task_\1/'
 	'/^TASK_PFA_SET([^,]*, *\([[:alnum:]_]*\))/task_set_\1/'
 	'/^TASK_PFA_CLEAR([^,]*, *\([[:alnum:]_]*\))/task_clear_\1/'
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
