Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id E055D6B0071
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:48 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so8222531vnb.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k4si1195144yha.20.2015.04.14.13.56.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 13:56:42 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 04/11] mm: debug: dump struct MM into a string rather than directly on screen
Date: Tue, 14 Apr 2015 16:56:26 -0400
Message-Id: <1429044993-1677-5-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

This lets us use regular string formatting code to dump MMs, use it
in VM_BUG_ON_MM instead of just printing it to screen as well.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |    8 ++++++--
 lib/vsprintf.c          |    5 ++++-
 mm/debug.c              |   11 +++++++----
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 506e405..202ebdf 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -10,10 +10,10 @@ struct mm_struct;
 extern void dump_page(struct page *page, const char *reason);
 extern void dump_page_badflags(struct page *page, const char *reason,
 			       unsigned long badflags);
-void dump_mm(const struct mm_struct *mm);
 
 #ifdef CONFIG_DEBUG_VM
 char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
+char *format_mm(const struct mm_struct *mm, char *buf, char *end);
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #define VM_BUG_ON_PAGE(cond, page)					\
 	do {								\
@@ -32,7 +32,7 @@ char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
 #define VM_BUG_ON_MM(cond, mm)						\
 	do {								\
 		if (unlikely(cond)) {					\
-			dump_mm(mm);					\
+			pr_emerg("%pZm", mm);				\
 			BUG();						\
 		}							\
 	} while (0)
@@ -44,6 +44,10 @@ static char *format_vma(const struct vm_area_struct *vma, char *buf, char *end)
 {
 	return buf;
 }
+static char *format_mm(const struct mm_struct *mm, char *buf, char *end)
+{
+	return buf;
+}
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index b4800c1..1ca3114 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1382,6 +1382,8 @@ char *mm_pointer(char *buf, char *end, const void *ptr,
 	switch (fmt[1]) {
 	case 'v':
 		return format_vma(ptr, buf, end);
+	case 'm':
+		return format_mm(ptr, buf, end);
 	}
 
 	return buf;
@@ -1475,8 +1477,9 @@ int kptr_restrict __read_mostly;
  *        (legacy clock framework) of the clock
  * - 'Cr' For a clock, it prints the current rate of the clock
  * - 'T' task_struct->comm
- * - 'Z[v]' Outputs a readable version of a type of memory management struct:
+ * - 'Z[mv]' Outputs a readable version of a type of memory management struct:
  *		v struct vm_area_struct
+ *		m struct mm_struct
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
diff --git a/mm/debug.c b/mm/debug.c
index 82e2e1c..dff65ff 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -203,9 +203,10 @@ char *format_vma(const struct vm_area_struct *vma, char *buf, char *end)
 				buf, end);
 }
 
-void dump_mm(const struct mm_struct *mm)
+char *format_mm(const struct mm_struct *mm, char *buf, char *end)
 {
-	pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"
+	buf += snprintf(buf, buf > end ? 0 : end - buf,
+		"mm %p mmap %p seqnum %d task_size %lu\n"
 #ifdef CONFIG_MMU
 		"get_unmapped_area %p\n"
 #endif
@@ -270,8 +271,10 @@ void dump_mm(const struct mm_struct *mm)
 		""		/* This is here to not have a comma! */
 		);
 
-		dump_flags(mm->def_flags, vmaflags_names,
-				ARRAY_SIZE(vmaflags_names));
+	buf = format_flags(mm->def_flags, vmaflags_names,
+				ARRAY_SIZE(vmaflags_names), buf, end);
+
+	return buf;
 }
 
 #endif		/* CONFIG_DEBUG_VM */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
