Message-Id: <20071004040003.797970826@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:44 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [09/18] Vcompound: GFP_VFALLBACK debugging aid
Content-Disposition: inline; filename=vcompound_debugging_aid
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Virtual fallbacks are rare and thus subtle bugs may creep in if we do not
test the fallbacks. CONFIG_VFALLBACK_ALWAYS makes all GFP_VFALLBACK
allocations fall back to virtual mapping.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 lib/Kconfig.debug |   11 +++++++++++
 mm/page_alloc.c   |    6 ++++++
 2 files changed, 17 insertions(+)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-10-03 18:04:33.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-10-03 18:07:16.000000000 -0700
@@ -1257,6 +1257,12 @@ zonelist_scan:
 			}
 		}
 
+#ifdef CONFIG_VFALLBACK_ALWAYS
+		if ((gfp_mask & __GFP_VFALLBACK) &&
+				system_state == SYSTEM_RUNNING)
+			return alloc_vcompound(gfp_mask, order,
+					zonelist, alloc_flags);
+#endif
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page)
 			break;
Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug	2007-10-03 18:04:29.000000000 -0700
+++ linux-2.6/lib/Kconfig.debug	2007-10-03 18:07:16.000000000 -0700
@@ -105,6 +105,17 @@ config DETECT_SOFTLOCKUP
 	   can be detected via the NMI-watchdog, on platforms that
 	   support it.)
 
+config VFALLBACK_ALWAYS
+	bool "Always fall back to Virtual Compound pages"
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

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
