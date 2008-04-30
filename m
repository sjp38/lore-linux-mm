Message-Id: <20080430044320.082665180@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:56 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [05/11] vcompound: Debugging aid
Content-Disposition: inline; filename=vcp_debugging_aids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Virtualized Compound Pages are rare in practice and thus subtle bugs may
creep in if we do not test the kernel with Virtualized Compounds.
CONFIG_VIRTUALIZE_ALWAYS results in virtualizable compound allocation
requests always result in virtualized compounds.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 lib/Kconfig.debug |   12 ++++++++++++
 mm/vmalloc.c      |   15 +++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug	2008-04-29 21:27:20.452525154 -0700
+++ linux-2.6/lib/Kconfig.debug	2008-04-29 21:27:36.533025562 -0700
@@ -159,6 +159,18 @@ config DETECT_SOFTLOCKUP
 	   can be detected via the NMI-watchdog, on platforms that
 	   support it.)
 
+config VIRTUALIZE_ALWAYS
+	bool "Always allocate virtualized compounds pages"
+	default y
+	help
+	  Virtualized compound pages are only allocated if there is no linear
+	  memory available. They are a fallback and potential issues created by
+	  the use of virtual mappings instead of physically linear memory may
+	  not surface because of the infrequent need to create them. Enabling
+	  this option makes every allocation of a virtualizable compound page
+	  generate virtualized compound page. May have a significant
+	  performance impact. Only for testing.
+
 config SCHED_DEBUG
 	bool "Collect scheduler debugging info"
 	depends on DEBUG_KERNEL && PROC_FS
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2008-04-29 21:27:32.237026026 -0700
+++ linux-2.6/mm/vmalloc.c	2008-04-29 21:27:36.537025989 -0700
@@ -1191,6 +1191,11 @@ struct page *alloc_vcompound_node(int no
 	if (order)
 		alloc_flags |= __GFP_COMP;
 
+#ifdef CONFIG_VIRTUALIZE_ALWAYS
+	if (system_state == SYSTEM_RUNNING && order)
+		page = NULL;
+	else
+#endif
 	if (node == -1) {
 		page = alloc_pages(alloc_flags, order);
 	} else
@@ -1212,8 +1217,14 @@ void *__alloc_vcompound(gfp_t flags, int
 	struct vm_struct *vm;
 	void *addr;
 
-	addr = (void *)__get_free_pages(flags | __GFP_NORETRY | __GFP_NOWARN,
-								order);
+#ifdef CONFIG_VIRTUALIZE_ALWAYS
+	if (system_state == SYSTEM_RUNNING && order)
+		addr = NULL;
+	else
+#endif
+		addr = (void *)__get_free_pages(
+			flags | __GFP_NORETRY | __GFP_NOWARN, order);
+
 	if (addr || !order)
 		return addr;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
