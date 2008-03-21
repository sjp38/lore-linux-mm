Message-Id: <20080321061725.277866037@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:08 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [05/14] vcompound: Debugging aid
Content-Disposition: inline; filename=0008-vcompound-Debugging-aid.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Virtual fallbacks are rare and thus subtle bugs may creep in if we do not
test the fallbacks. CONFIG_VFALLBACK_ALWAYS makes all vcompound allocations
fall back to vmalloc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 lib/Kconfig.debug |   11 +++++++++++
 mm/vmalloc.c      |   18 +++++++++++++++---
 2 files changed, 26 insertions(+), 3 deletions(-)

Index: linux-2.6.25-rc5-mm1/lib/Kconfig.debug
===================================================================
--- linux-2.6.25-rc5-mm1.orig/lib/Kconfig.debug	2008-03-20 23:05:12.910212550 -0700
+++ linux-2.6.25-rc5-mm1/lib/Kconfig.debug	2008-03-20 23:06:21.599135107 -0700
@@ -158,6 +158,17 @@ config DETECT_SOFTLOCKUP
 	   can be detected via the NMI-watchdog, on platforms that
 	   support it.)
 
+config VFALLBACK_ALWAYS
+	bool "Always fall back to virtually mapped compound pages"
+	default y
+	help
+	  Virtual compound pages are only allocated if there is no linear
+	  memory available. They are a fallback and errors created by the
+	  use of virtual mappings instead of linear ones may not surface
+	  because of their infrequent use. This option makes every
+	  allocation that allows a fallback to a virtual mapping use
+	  the virtual mapping. May have a significant performance impact.
+
 config SCHED_DEBUG
 	bool "Collect scheduler debugging info"
 	depends on DEBUG_KERNEL && PROC_FS
Index: linux-2.6.25-rc5-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/vmalloc.c	2008-03-20 23:06:14.875045176 -0700
+++ linux-2.6.25-rc5-mm1/mm/vmalloc.c	2008-03-20 23:06:21.599135107 -0700
@@ -1159,7 +1159,13 @@ struct page *alloc_vcompound(gfp_t flags
 	struct vm_struct *vm;
 	struct page *page;
 
-	page = alloc_pages(flags | __GFP_NORETRY | __GFP_NOWARN, order);
+#ifdef CONFIG_VFALLBACK_ALWAYS
+	if (system_state == SYSTEM_RUNNING && order)
+		page = NULL;
+	else
+#endif
+		page = alloc_pages(flags | __GFP_NORETRY | __GFP_NOWARN,
+								order);
 	if (page || !order)
 		return page;
 
@@ -1175,8 +1181,14 @@ void *__alloc_vcompound(gfp_t flags, int
 	struct vm_struct *vm;
 	void *addr;
 
-	addr = (void *)__get_free_pages(flags | __GFP_NORETRY | __GFP_NOWARN,
-								order);
+#ifdef CONFIG_VFALLBACK_ALWAYS
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
