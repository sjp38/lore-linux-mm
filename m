Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 361476B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 16:26:26 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH] mm: Neaten warn_alloc_failed
Date: Thu, 25 Aug 2011 13:26:19 -0700
Message-Id: <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Add __attribute__((format (printf...) to the function
to validate format and arguments.  Use vsprintf extension
%pV to avoid any possible message interleaving. Coalesce
format string.  Convert printks/pr_warning to pr_warn.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/mm.h |    3 ++-
 mm/page_alloc.c    |   16 +++++++++++-----
 mm/vmalloc.c       |    4 ++--
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7438071..24b3b0f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1334,7 +1334,8 @@ extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
 
-extern void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
+extern __attribute__((format (printf, 3, 4)))
+void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..1b77872 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1753,7 +1753,6 @@ static DEFINE_RATELIMIT_STATE(nopage_rs,
 
 void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 {
-	va_list args;
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
@@ -1772,14 +1771,21 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		filter &= ~SHOW_MEM_FILTER_NODES;
 
 	if (fmt) {
-		printk(KERN_WARNING);
+		struct va_format vaf;
+		va_list args;
+
 		va_start(args, fmt);
-		vprintk(fmt, args);
+
+		vaf.fmt = fmt;
+		vaf.va = &args;
+
+		pr_warn("%pV", &vaf);
+
 		va_end(args);
 	}
 
-	pr_warning("%s: page allocation failure: order:%d, mode:0x%x\n",
-		   current->comm, order, gfp_mask);
+	pr_warn("%s: page allocation failure: order:%d, mode:0x%x\n",
+		current->comm, order, gfp_mask);
 
 	dump_stack();
 	if (!should_suppress_show_mem())
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ef0903..3122acc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1568,8 +1568,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	return area->addr;
 
 fail:
-	warn_alloc_failed(gfp_mask, order, "vmalloc: allocation failure, "
-			  "allocated %ld of %ld bytes\n",
+	warn_alloc_failed(gfp_mask, order,
+			  "vmalloc: allocation failure, allocated %ld of %ld bytes\n",
 			  (area->nr_pages*PAGE_SIZE), area->size);
 	vfree(area->addr);
 	return NULL;
-- 
1.7.6.405.gc1be0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
