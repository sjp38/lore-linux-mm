Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 523FF6B003A
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:54:52 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id wo20so13641551obc.26
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:54:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wr2si21740111obb.28.2014.09.29.18.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:54:50 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 5/5] mm: poison page struct
Date: Mon, 29 Sep 2014 21:47:19 -0400
Message-Id: <1412041639-23617-6-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>

Add poisoning to page struct to catch corruption at either the beginning or
the end of the struct.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mm.h         |  9 +++++++++
 include/linux/mm_types.h   |  6 ++++++
 include/linux/mmdebug.h    |  6 ++++++
 include/linux/page-flags.h | 24 ++++++++++++++++--------
 4 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0c13412..c48c4e2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -524,6 +524,10 @@ static inline struct page *virt_to_head_page(const void *x)
  */
 static inline void init_page_count(struct page *page)
 {
+#ifdef CONFIG_DEBUG_VM_POISON
+	page->poison_start = MM_POISON_BEGIN;
+	page->poison_end = MM_POISON_END;
+#endif
 	atomic_set(&page->_count, 1);
 }
 
@@ -1482,12 +1486,17 @@ static inline void pgtable_init(void)
 
 static inline bool pgtable_page_ctor(struct page *page)
 {
+#ifdef CONFIG_DEBUG_VM_POISON
+	page->poison_start = MM_POISON_BEGIN;
+	page->poison_end = MM_POISON_END;
+#endif
 	inc_zone_page_state(page, NR_PAGETABLE);
 	return ptlock_init(page);
 }
 
 static inline void pgtable_page_dtor(struct page *page)
 {
+	VM_CHECK_POISON_PAGE(page);
 	pte_lock_deinit(page);
 	dec_zone_page_state(page, NR_PAGETABLE);
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4e2cf93..7cab56a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -42,6 +42,9 @@ struct address_space;
  * and lru list pointers also.
  */
 struct page {
+#ifdef CONFIG_DEBUG_VM_POISON
+	u32 poison_start;
+#endif
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
@@ -196,6 +199,9 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+#ifdef CONFIG_DEBUG_VM_POISON
+	u32 poison_end;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 75bc69d..461c452 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -50,6 +50,11 @@ void dump_mm(const struct mm_struct *mm);
 		VM_BUG_ON_VMA((vma)->poison_start != MM_POISON_BEGIN, (vma));\
 		VM_BUG_ON_VMA((vma)->poison_end != MM_POISON_END, (vma));\
 	} while (0)
+#define VM_CHECK_POISON_PAGE(page)					\
+	do {                                                            \
+		VM_BUG_ON_PAGE((page)->poison_start != MM_POISON_BEGIN, (page));\
+		VM_BUG_ON_PAGE((page)->poison_end != MM_POISON_END, (page));\
+	} while (0)
 #endif
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
@@ -61,6 +66,7 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
 #define VM_CHECK_POISON_MM(mm) do { } while(0)
 #define VM_CHECK_POISON_VMA(vma) do { } while(0)
+#define VM_CHECK_POISON_PAGE(page) do { } while(0)
 #endif
 
 #ifdef CONFIG_DEBUG_VIRTUAL
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e1f5fcd..688f72c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -135,35 +135,43 @@ enum pageflags {
  */
 #define TESTPAGEFLAG(uname, lname)					\
 static inline int Page##uname(const struct page *page)			\
-			{ return test_bit(PG_##lname, &page->flags); }
+			{ VM_CHECK_POISON_PAGE(page);			\
+			  return test_bit(PG_##lname, &page->flags); }
 
 #define SETPAGEFLAG(uname, lname)					\
 static inline void SetPage##uname(struct page *page)			\
-			{ set_bit(PG_##lname, &page->flags); }
+			{ VM_CHECK_POISON_PAGE(page);			\
+			  set_bit(PG_##lname, &page->flags); }
 
 #define CLEARPAGEFLAG(uname, lname)					\
 static inline void ClearPage##uname(struct page *page)			\
-			{ clear_bit(PG_##lname, &page->flags); }
+			{ VM_CHECK_POISON_PAGE(page);			\
+			  clear_bit(PG_##lname, &page->flags); }
 
 #define __SETPAGEFLAG(uname, lname)					\
 static inline void __SetPage##uname(struct page *page)			\
-			{ __set_bit(PG_##lname, &page->flags); }
+			{ VM_CHECK_POISON_PAGE(page);			\
+			  __set_bit(PG_##lname, &page->flags); }
 
 #define __CLEARPAGEFLAG(uname, lname)					\
 static inline void __ClearPage##uname(struct page *page)		\
-			{ __clear_bit(PG_##lname, &page->flags); }
+			{ VM_CHECK_POISON_PAGE(page);			\
+			  __clear_bit(PG_##lname, &page->flags); }
 
 #define TESTSETFLAG(uname, lname)					\
 static inline int TestSetPage##uname(struct page *page)			\
-		{ return test_and_set_bit(PG_##lname, &page->flags); }
+		{ VM_CHECK_POISON_PAGE(page);				\
+		  return test_and_set_bit(PG_##lname, &page->flags); }
 
 #define TESTCLEARFLAG(uname, lname)					\
 static inline int TestClearPage##uname(struct page *page)		\
-		{ return test_and_clear_bit(PG_##lname, &page->flags); }
+		{ VM_CHECK_POISON_PAGE(page);				\
+		  return test_and_clear_bit(PG_##lname, &page->flags); }
 
 #define __TESTCLEARFLAG(uname, lname)					\
 static inline int __TestClearPage##uname(struct page *page)		\
-		{ return __test_and_clear_bit(PG_##lname, &page->flags); }
+		{ VM_CHECK_POISON_PAGE(page);				\
+		  return __test_and_clear_bit(PG_##lname, &page->flags); }
 
 #define PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
 	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
