Date: Wed, 27 Apr 2005 11:09:52 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH/RFC 3/4] VM: toss_page_cache_node syscall
Message-ID: <20050427150952.GU8018@localhost>
References: <20050427145734.GL8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050427145734.GL8018@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux-MM <linux-mm@kvack.org>
Cc: Ray Bryant <raybry@sgi.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>


This just adds a simple syscall to call into the reclaim code.
The use for this would be to clear all unneeded pagecache and slabcache
off a node before running a big HPC job.

A "memory freer" app can be found at:
http://www.bork.org/~mort/sgi/localreclaim/reclaim_memory.c

Signed-off-by: Martin Hicks <mort@sgi.com>
---

 arch/ia64/kernel/entry.S |    2 -
 kernel/sys_ni.c          |    2 +
 mm/vmscan.c              |   52 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 1 deletion(-)

Index: linux-2.6.12-rc2.wk/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/mm/vmscan.c	2005-04-27 06:56:57.000000000 -0700
+++ linux-2.6.12-rc2.wk/mm/vmscan.c	2005-04-27 07:06:42.000000000 -0700
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
+#include <linux/compat.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1501,3 +1502,54 @@ unsigned int reclaim_clean_pages(struct 
 
 	return total_reclaimed;
 }
+
+
+/* Free some page cache on a specified node */
+asmlinkage long sys_toss_page_cache_node(unsigned int node,
+					 unsigned long bytes,
+					 unsigned int flags)
+{
+	unsigned long pages_to_reclaim;
+	unsigned long reclaimed = 0;
+	int i;
+	struct zone *z, **zones;
+
+	if (!node_online(node))
+		/* get a better error code here? */
+		return -EINVAL;
+
+	/* Check to make sure that we have reasonable flag values */
+	if (flags & RECLAIM_MASK)
+		return -EINVAL;
+
+	/* Set the Manual reclaim flag to override rate limiting */
+	flags |= RECLAIM_MANUAL;
+
+	pages_to_reclaim = (bytes + PAGE_SIZE - 1)/PAGE_SIZE;
+
+	/*
+	 * This is kind of bad because we're using zone internals.
+	 * The goal here is to start reclaiming from the "higest" zone,
+	 * ZONE_HIGHMEM -> ZONE_NORMAL -> ZONE_DMA
+	 */
+	zones = (NODE_DATA(node)->node_zonelists+ZONE_HIGHMEM)->zones;
+	for (i = 0; (z = zones[i]) && reclaimed < pages_to_reclaim; i++) {
+		if (!z->present_pages)
+			continue;
+		reclaimed += reclaim_clean_pages(z, pages_to_reclaim,
+						 flags);
+	}
+
+	return reclaimed * PAGE_SIZE;
+}
+
+#ifdef CONFIG_COMPAT
+
+asmlinkage long compat_sys_toss_page_cache_node(compat_uint_t node,
+						compat_ulong_t bytes,
+						compat_uint_t flags)
+{
+	return sys_toss_page_cache_node(node, bytes, flags);
+}
+
+#endif
Index: linux-2.6.12-rc2.wk/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.12-rc2.wk.orig/arch/ia64/kernel/entry.S	2005-04-27 06:56:48.000000000 -0700
+++ linux-2.6.12-rc2.wk/arch/ia64/kernel/entry.S	2005-04-27 07:06:42.000000000 -0700
@@ -1573,7 +1573,7 @@ sys_call_table:
 	data8 sys_keyctl
 	data8 sys_ioprio_set
 	data8 sys_ioprio_get			// 1275
-	data8 sys_ni_syscall
+	data8 sys_toss_page_cache_node
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
Index: linux-2.6.12-rc2.wk/kernel/sys_ni.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/kernel/sys_ni.c	2005-04-27 06:56:48.000000000 -0700
+++ linux-2.6.12-rc2.wk/kernel/sys_ni.c	2005-04-27 07:06:42.000000000 -0700
@@ -82,6 +82,8 @@ cond_syscall(sys_request_key);
 cond_syscall(sys_keyctl);
 cond_syscall(compat_sys_keyctl);
 cond_syscall(compat_sys_socketcall);
+cond_syscall(sys_toss_page_cache_node);
+cond_syscall(compat_sys_toss_page_cache_node);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
