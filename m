Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 389E26B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 09:56:51 -0400 (EDT)
Received: by iyl8 with SMTP id 8so5226669iyl.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 06:56:47 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH V2] Add debugging boundary check to pfn_to_page
Date: Mon, 13 Jun 2011 09:56:39 -0400
Message-Id: <1307973399-7784-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de
Cc: akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, randy.dunlap@oracle.com, josh@joshtriplett.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mgorman@suse.de, linux-mm@kvack.org, dave@linux.vnet.ibm.com, Eric B Munson <emunson@mgebm.net>

Bugzilla 36192 showed a problem where pages were being accessed outside of
a node boundary.  It would be helpful in diagnosing this kind of problem to
have pfn_to_page complain when a page is accessed outside of the node boundary.
This patch adds a new debug config option which adds a WARN_ON in pfn_to_page
that will complain when pages are accessed outside of the node boundary.

Signed-of-by: Eric B Munson <emunson@mgebm.net>
---
Changes from V1:
 minimize code duplication with a macro that will do the checking when
configured

 include/asm-generic/memory_model.h |   25 ++++++++++++++++++++-----
 lib/Kconfig.debug                  |    9 +++++++++
 2 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
index fb2d63f..7aa83ce 100644
--- a/include/asm-generic/memory_model.h
+++ b/include/asm-generic/memory_model.h
@@ -22,6 +22,16 @@
 
 #endif /* CONFIG_DISCONTIGMEM */
 
+#ifdef CONFIG_MEMORY_MODEL
+/*
+ * The flags for a page will only be zero if this page is being accessed
+ * outside of node boundaries.
+ */
+#define check_page(__page) WARN_ON(__page->flags == 0)
+#else
+#define check_page(__page) do{}while(0)
+#endif /* CONFIG_MEMORY_MODEL */
+
 /*
  * supports 3 memory models.
  */
@@ -35,7 +45,9 @@
 #define __pfn_to_page(pfn)			\
 ({	unsigned long __pfn = (pfn);		\
 	unsigned long __nid = arch_pfn_to_nid(__pfn);  \
-	NODE_DATA(__nid)->node_mem_map + arch_local_page_offset(__pfn, __nid);\
+	struct page * __pg = NODE_DATA(__nid)->node_mem_map + arch_local_page_offset(__pfn, __nid);\
+	check_page(__pg);			\
+	__pg;					\
 })
 
 #define __page_to_pfn(pg)						\
@@ -52,6 +64,7 @@
 #define __page_to_pfn(page)	(unsigned long)((page) - vmemmap)
 
 #elif defined(CONFIG_SPARSEMEM)
+
 /*
  * Note: section's mem_map is encorded to reflect its start_pfn.
  * section[i].section_mem_map == mem_map's address - start_pfn;
@@ -62,10 +75,12 @@
 	(unsigned long)(__pg - __section_mem_map_addr(__nr_to_section(__sec)));	\
 })
 
-#define __pfn_to_page(pfn)				\
-({	unsigned long __pfn = (pfn);			\
-	struct mem_section *__sec = __pfn_to_section(__pfn);	\
-	__section_mem_map_addr(__sec) + __pfn;		\
+#define __pfn_to_page(pfn)						\
+({	unsigned long __pfn = (pfn);					\
+	struct mem_section *__sec = __pfn_to_section(__pfn);		\
+	struct page *__pg = __section_mem_map_addr(__sec) + __pfn;	\
+	check_page(__pg);						\
+	__pg;								\
 })
 #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index dd373c8..7870907 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -777,6 +777,15 @@ config DEBUG_MEMORY_INIT
 
 	  If unsure, say Y
 
+config DEBUG_MEMORY_MODEL
+	bool "Debug memory model" if SPARSEMEM || DISCONTIGMEM
+	help
+	  Enable this to check that page accesses are done within node
+	  boundaries.  The check will warn each time a page is requested
+	  outside node boundaries.
+
+	  If unsure, say N
+
 config DEBUG_LIST
 	bool "Debug linked list manipulation"
 	depends on DEBUG_KERNEL
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
