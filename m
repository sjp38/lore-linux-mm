Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 919006B0070
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:46 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so8115783vnb.13
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:46 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v135si1179846yke.117.2015.04.14.13.56.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 13:56:42 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 03/11] mm: debug: dump VMA into a string rather than directly on screen
Date: Tue, 14 Apr 2015 16:56:25 -0400
Message-Id: <1429044993-1677-4-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

This lets us use regular string formatting code to dump VMAs, use it
in VM_BUG_ON_VMA instead of just printing it to screen as well.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |    8 ++++++--
 lib/vsprintf.c          |    7 +++++--
 mm/debug.c              |   26 ++++++++++++++------------
 3 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 877ef22..506e405 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -10,10 +10,10 @@ struct mm_struct;
 extern void dump_page(struct page *page, const char *reason);
 extern void dump_page_badflags(struct page *page, const char *reason,
 			       unsigned long badflags);
-void dump_vma(const struct vm_area_struct *vma);
 void dump_mm(const struct mm_struct *mm);
 
 #ifdef CONFIG_DEBUG_VM
+char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #define VM_BUG_ON_PAGE(cond, page)					\
 	do {								\
@@ -25,7 +25,7 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_BUG_ON_VMA(cond, vma)					\
 	do {								\
 		if (unlikely(cond)) {					\
-			dump_vma(vma);					\
+			pr_emerg("%pZv", vma);				\
 			BUG();						\
 		}							\
 	} while (0)
@@ -40,6 +40,10 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
 #else
+static char *format_vma(const struct vm_area_struct *vma, char *buf, char *end)
+{
+	return buf;
+}
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 809d19d..b4800c1 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1376,10 +1376,12 @@ char *comm_name(char *buf, char *end, struct task_struct *tsk,
 }
 
 static noinline_for_stack
-char *mm_pointer(char *buf, char *end, struct task_struct *tsk,
+char *mm_pointer(char *buf, char *end, const void *ptr,
 		struct printf_spec spec, const char *fmt)
 {
 	switch (fmt[1]) {
+	case 'v':
+		return format_vma(ptr, buf, end);
 	}
 
 	return buf;
@@ -1473,7 +1475,8 @@ int kptr_restrict __read_mostly;
  *        (legacy clock framework) of the clock
  * - 'Cr' For a clock, it prints the current rate of the clock
  * - 'T' task_struct->comm
- * - 'Z' Outputs a readable version of a type of memory management struct.
+ * - 'Z[v]' Outputs a readable version of a type of memory management struct:
+ *		v struct vm_area_struct
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
diff --git a/mm/debug.c b/mm/debug.c
index c9f7dd7..82e2e1c 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -186,20 +186,22 @@ static const struct trace_print_flags vmaflags_names[] = {
 	{VM_MERGEABLE,			"mergeable"	},
 };
 
-void dump_vma(const struct vm_area_struct *vma)
+char *format_vma(const struct vm_area_struct *vma, char *buf, char *end)
 {
-	pr_emerg("vma %p start %p end %p\n"
-		"next %p prev %p mm %p\n"
-		"prot %lx anon_vma %p vm_ops %p\n"
-		"pgoff %lx file %p private_data %p\n",
-		vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
-		vma->vm_prev, vma->vm_mm,
-		(unsigned long)pgprot_val(vma->vm_page_prot),
-		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
-		vma->vm_file, vma->vm_private_data);
-	dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));
+	buf += snprintf(buf, buf > end ? 0 : end - buf,
+		"vma %p start %p end %p\n"
+                "next %p prev %p mm %p\n"
+                "prot %lx anon_vma %p vm_ops %p\n"
+                "pgoff %lx file %p private_data %p\n",
+                vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
+                vma->vm_prev, vma->vm_mm,
+                (unsigned long)pgprot_val(vma->vm_page_prot),
+                vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
+                vma->vm_file, vma->vm_private_data);
+
+        return format_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names),
+				buf, end);
 }
-EXPORT_SYMBOL(dump_vma);
 
 void dump_mm(const struct mm_struct *mm)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
