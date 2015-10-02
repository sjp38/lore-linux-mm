Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF8C482F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 01:40:20 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so97251720pac.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 22:40:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cj4si14219634pbc.126.2015.10.01.22.40.20
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 22:40:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] page-flags: hide PF_* validation check under separate config option
Date: Fri,  2 Oct 2015 08:40:16 +0300
Message-Id: <1443764416-129688-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

VM_BUG_ONs in PF_NO_TAIL() and PF_NO_COMPOUND() add 4+ KiB to
mm/build-in.o for DEBUG_VM kernel.

Let's hide them under new config option -- CONFIG_DEBUG_VM_PGFLAGS.
With the option enabled VM_BUG_ON_PGFLAGS() is equal to VM_BUG_ON_PAGE.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mmdebug.h    | 6 ++++++
 include/linux/page-flags.h | 8 +++-----
 lib/Kconfig.debug          | 8 ++++++++
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 877ef226f90f..c447d8055e50 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -55,4 +55,10 @@ void dump_mm(const struct mm_struct *mm);
 #define VIRTUAL_BUG_ON(cond) do { } while (0)
 #endif
 
+#ifdef CONFIG_DEBUG_VM_PGFLAGS
+#define VM_BUG_ON_PGFLAGS(cond, page) VM_BUG_ON_PAGE(cond, page)
+#else
+#define VM_BUG_ON_PGFLAGS(cond, page) BUILD_BUG_ON_INVALID(cond)
+#endif
+
 #endif
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 19e4129f00e5..8d6e4e9a98af 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -153,12 +153,10 @@ enum pageflags {
 #define PF_ANY(page, enforce)	page
 #define PF_HEAD(page, enforce)	compound_head(page)
 #define PF_NO_TAIL(page, enforce) ({					\
-		if (enforce)						\
-			VM_BUG_ON_PAGE(PageTail(page), page);		\
+		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
 		compound_head(page);})
-#define PF_NO_COMPOUND(page, enforce) ({					\
-		if (enforce)						\
-			VM_BUG_ON_PAGE(PageCompound(page), page);	\
+#define PF_NO_COMPOUND(page, enforce) ({				\
+		VM_BUG_ON_PGFLAGS(enforce && PageCompound(page), page);	\
 		page;})
 
 /*
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e2894b23efb6..0d12bfa429de 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -570,6 +570,14 @@ config DEBUG_VM_RB
 
 	  If unsure, say N.
 
+config DEBUG_VM_PGFLAGS
+	bool "Debug page-flags operations"
+	depends on DEBUG_VM
+	help
+	  Enables extra validation on page flags operations.
+
+	  If unsure, say N.
+
 config DEBUG_VIRTUAL
 	bool "Debug VM translations"
 	depends on DEBUG_KERNEL && X86
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
