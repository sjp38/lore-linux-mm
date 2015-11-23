Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9118A6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 16:25:13 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so208963292pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 13:25:13 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hq4si22614888pbb.89.2015.11.23.13.25.12
        for <linux-mm@kvack.org>;
        Mon, 23 Nov 2015 13:25:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] page-flags: drop __TestClearPage*() helpers
Date: Mon, 23 Nov 2015 23:24:38 +0200
Message-Id: <1448313878-36033-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody uses them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 10 +---------
 scripts/tags.sh            |  2 --
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 190f1915a097..7bc7fd9c4c5c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -211,10 +211,6 @@ static inline int TestSetPage##uname(struct page *page)			\
 static inline int TestClearPage##uname(struct page *page)		\
 	{ return test_and_clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define __TESTCLEARFLAG(uname, lname, policy)				\
-static inline int __TestClearPage##uname(struct page *page)		\
-	{ return __test_and_clear_bit(PG_##lname, &policy(page, 1)->flags); }
-
 #define PAGEFLAG(uname, lname, policy)					\
 	TESTPAGEFLAG(uname, lname, policy)				\
 	SETPAGEFLAG(uname, lname, policy)				\
@@ -247,9 +243,6 @@ static inline int TestSetPage##uname(struct page *page) { return 0; }
 #define TESTCLEARFLAG_FALSE(uname)					\
 static inline int TestClearPage##uname(struct page *page) { return 0; }
 
-#define __TESTCLEARFLAG_FALSE(uname)					\
-static inline int __TestClearPage##uname(struct page *page) { return 0; }
-
 #define PAGEFLAG_FALSE(uname) TESTPAGEFLAG_FALSE(uname)			\
 	SETPAGEFLAG_NOOP(uname) CLEARPAGEFLAG_NOOP(uname)
 
@@ -331,10 +324,9 @@ PAGEFLAG(Unevictable, unevictable, PF_HEAD)
 PAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
 	__CLEARPAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
 	TESTSCFLAG(Mlocked, mlocked, PF_NO_TAIL)
-	__TESTCLEARFLAG(Mlocked, mlocked, PF_NO_TAIL)
 #else
 PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
-	TESTSCFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
+	TESTSCFLAG_FALSE(Mlocked)
 #endif
 
 #ifdef CONFIG_ARCH_USES_PG_UNCACHED
diff --git a/scripts/tags.sh b/scripts/tags.sh
index 8e5aee6d9da2..b4f119544a83 100755
--- a/scripts/tags.sh
+++ b/scripts/tags.sh
@@ -193,7 +193,6 @@ exuberant()
 	--regex-c++='/CLEARPAGEFLAG_NOOP\(([^,)]*).*/ClearPage\1/'	\
 	--regex-c++='/__CLEARPAGEFLAG_NOOP\(([^,)]*).*/__ClearPage\1/'	\
 	--regex-c++='/TESTCLEARFLAG_FALSE\(([^,)]*).*/TestClearPage\1/' \
-	--regex-c++='/__TESTCLEARFLAG_FALSE\(([^,)]*).*/__TestClearPage\1/' \
 	--regex-c++='/_PE\(([^,)]*).*/PEVENT_ERRNO__\1/'		\
 	--regex-c++='/TASK_PFA_TEST\([^,]*,\s*([^)]*)\)/task_\1/'	\
 	--regex-c++='/TASK_PFA_SET\([^,]*,\s*([^)]*)\)/task_set_\1/'	\
@@ -258,7 +257,6 @@ emacs()
 	--regex='/CLEARPAGEFLAG_NOOP(\([^,)]*\).*/ClearPage\1/'	\
 	--regex='/__CLEARPAGEFLAG_NOOP(\([^,)]*\).*/__ClearPage\1/' \
 	--regex='/TESTCLEARFLAG_FALSE(\([^,)]*\).*/TestClearPage\1/' \
-	--regex='/__TESTCLEARFLAG_FALSE(\([^,)]*\).*/__TestClearPage\1/' \
 	--regex='/TASK_PFA_TEST\([^,]*,\s*([^)]*)\)/task_\1/'		\
 	--regex='/TASK_PFA_SET\([^,]*,\s*([^)]*)\)/task_set_\1/'	\
 	--regex='/TASK_PFA_CLEAR\([^,]*,\s*([^)]*)\)/task_clear_\1/'	\
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
