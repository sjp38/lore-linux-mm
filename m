Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0896B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 04:17:18 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id cy9so212271829pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 01:17:18 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q2si71852744pfa.27.2016.01.05.01.17.17
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 01:17:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] memblock: fix section mismatch
Date: Tue,  5 Jan 2016 12:16:04 +0300
Message-Id: <1451985364-90757-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, "Signed-off-by : Zhang Yanfei" <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

allmodconfig produces following warning for me:

  WARNING: vmlinux.o(.text.unlikely+0x10314): Section mismatch in reference from the function movable_node_is_enabled() to the variable .meminit.data:movable_node_enabled
  The function movable_node_is_enabled() references
  the variable __meminitdata movable_node_enabled.
  This is often because movable_node_is_enabled lacks a __meminitdata
  annotation or the annotation of movable_node_enabled is wrong.

Let's mark the function with __meminit. It fixes the warning.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/memblock.h | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 173fb44e22f1..3106ac1c895e 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -61,6 +61,14 @@ extern int memblock_debug;
 extern bool movable_node_enabled;
 #endif /* CONFIG_MOVABLE_NODE */
 
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+#define __init_memblock __meminit
+#define __initdata_memblock __meminitdata
+#else
+#define __init_memblock
+#define __initdata_memblock
+#endif
+
 #define memblock_dbg(fmt, ...) \
 	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
 
@@ -166,7 +174,7 @@ static inline bool memblock_is_hotpluggable(struct memblock_region *m)
 	return m->flags & MEMBLOCK_HOTPLUG;
 }
 
-static inline bool movable_node_is_enabled(void)
+static inline bool __init_memblock movable_node_is_enabled(void)
 {
 	return movable_node_enabled;
 }
@@ -405,14 +413,6 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
 	for (idx = 0; idx < memblock_type->cnt;				\
 	     idx++,rgn = &memblock_type->regions[idx])
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-#define __init_memblock __meminit
-#define __initdata_memblock __meminitdata
-#else
-#define __init_memblock
-#define __initdata_memblock
-#endif
-
 #ifdef CONFIG_MEMTEST
 extern void early_memtest(phys_addr_t start, phys_addr_t end);
 #else
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
