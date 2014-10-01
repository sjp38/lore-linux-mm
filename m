Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0DC6B0071
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 07:32:36 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id p10so118811pdj.1
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 04:32:36 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s4si593347pdj.117.2014.10.01.04.32.35
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 04:32:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] mm: generalize VM_BUG_ON() macros
Date: Wed,  1 Oct 2014 14:31:59 +0300
Message-Id: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch makes VM_BUG_ON() to accept one to three arguments after the
condition. Any of these arguments can be page, vma or mm. VM_BUG_ON()
will dump info about the argument using appropriate dump_* function.

It's intended to replace separate VM_BUG_ON_PAGE(), VM_BUG_ON_VMA(),
VM_BUG_ON_MM() and allows additional use-cases like:

  VM_BUG_ON(cond, vma, page);
  VM_BUG_ON(cond, vma, src_page, dst_page);
  VM_BUG_ON(cond, mm, src_vma, dst_vma);
  ...

It's possible to extend list of supported data-structures or number of
arguments VM_BUG_ON() can accept.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mmdebug.h | 49 ++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 877ef226f90f..12f304a36b01 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -14,33 +14,60 @@ void dump_vma(const struct vm_area_struct *vma);
 void dump_mm(const struct mm_struct *mm);
 
 #ifdef CONFIG_DEBUG_VM
-#define VM_BUG_ON(cond) BUG_ON(cond)
-#define VM_BUG_ON_PAGE(cond, page)					\
+#define GET_MACRO(_1, _2, _3, _4, NAME, ...) NAME
+
+#define _VM_DUMP(arg, cond) do {					\
+	if (__builtin_types_compatible_p(typeof(*arg), struct page))	\
+		dump_page((struct page *) arg,				\
+				"VM_BUG_ON(" __stringify(cond)")");	\
+	else if (__builtin_types_compatible_p(typeof(*arg),		\
+				struct vm_area_struct))			\
+		dump_vma((struct vm_area_struct *) arg);		\
+	else if (__builtin_types_compatible_p(typeof(*arg),		\
+				struct mm_struct))			\
+		dump_mm((struct mm_struct *) arg);			\
+	else								\
+		BUILD_BUG();						\
+} while(0)
+
+#define _VM_BUG_ON_ARG1(cond, arg1)					\
 	do {								\
 		if (unlikely(cond)) {					\
-			dump_page(page, "VM_BUG_ON_PAGE(" __stringify(cond)")");\
+			_VM_DUMP(arg1, cond);				\
 			BUG();						\
 		}							\
-	} while (0)
-#define VM_BUG_ON_VMA(cond, vma)					\
+	} while(0)
+#define _VM_BUG_ON_ARG2(cond, arg1, arg2)				\
 	do {								\
 		if (unlikely(cond)) {					\
-			dump_vma(vma);					\
+			_VM_DUMP(arg1, cond);				\
+			_VM_DUMP(arg2, cond);				\
 			BUG();						\
 		}							\
-	} while (0)
-#define VM_BUG_ON_MM(cond, mm)						\
+	} while(0)
+#define _VM_BUG_ON_ARG3(cond, arg1, arg2, arg3)				\
 	do {								\
 		if (unlikely(cond)) {					\
-			dump_mm(mm);					\
+			_VM_DUMP(arg1, cond);				\
+			_VM_DUMP(arg2, cond);				\
+			_VM_DUMP(arg3, cond);				\
 			BUG();						\
 		}							\
-	} while (0)
+	} while(0)
+
+#define VM_BUG_ON(...) GET_MACRO(__VA_ARGS__,				\
+		_VM_BUG_ON_ARG3,					\
+		_VM_BUG_ON_ARG2,					\
+		_VM_BUG_ON_ARG1,					\
+		BUG_ON)(__VA_ARGS__)
+#define VM_BUG_ON_PAGE VM_BUG_ON
+#define VM_BUG_ON_VMA VM_BUG_ON
+#define VM_BUG_ON_MM VM_BUG_ON
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
 #else
-#define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
+#define VM_BUG_ON(cond, ...) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
 #define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
