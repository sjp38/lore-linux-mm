Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F3D06B0044
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 05:37:13 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id f25so2164082rvb.26
        for <linux-mm@kvack.org>; Tue, 23 Dec 2008 02:37:11 -0800 (PST)
Date: Tue, 23 Dec 2008 19:37:01 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] failslab for SLUB
Message-ID: <20081223103616.GA7217@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Currently fault-injection capability for SLAB allocator is only available
to SLAB. This patch makes it available to SLUB, too.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 lib/Kconfig.debug |    1 
 mm/slub.c         |   66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

Index: 2.6-rc/mm/slub.c
===================================================================
--- 2.6-rc.orig/mm/slub.c
+++ 2.6-rc/mm/slub.c
@@ -24,6 +24,7 @@
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
 #include <linux/math64.h>
+#include <linux/fault-inject.h>
 
 /*
  * Lock order:
@@ -1573,6 +1574,68 @@ debug:
 	goto unlock_out;
 }
 
+#ifdef CONFIG_FAILSLAB
+
+static struct {
+	struct fault_attr attr;
+	u32 ignore_gfp_wait;
+#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
+	struct dentry *ignore_gfp_wait_file;
+#endif
+} failslub = {
+	.attr = FAULT_ATTR_INITIALIZER,
+	.ignore_gfp_wait = 1,
+};
+
+static bool should_failslub(struct kmem_cache *s, gfp_t gfpflags)
+{
+	if (gfpflags & __GFP_NOFAIL)
+		return false;
+	if (failslub.ignore_gfp_wait && (gfpflags & __GFP_WAIT))
+		return false;
+
+	return should_fail(&failslub.attr, s->objsize);
+}
+
+#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
+
+static int __init failslub_debugfs(void)
+{
+	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
+	struct dentry *dir;
+	int err;
+
+	err = init_fault_attr_dentries(&failslub.attr, "failslab");
+	if (err)
+		return err;
+	dir = failslub.attr.dentries.dir;
+
+	failslub.ignore_gfp_wait_file =
+		debugfs_create_bool("ignore-gfp-wait", mode, dir,
+				      &failslub.ignore_gfp_wait);
+
+	if (!failslub.ignore_gfp_wait_file) {
+		err = -ENOMEM;
+		debugfs_remove(failslub.ignore_gfp_wait_file);
+		cleanup_fault_attr_dentries(&failslub.attr);
+	}
+
+	return err;
+}
+
+late_initcall(failslub_debugfs);
+
+#endif /* CONFIG_FAULT_INJECTION_DEBUG_FS */
+
+#else /* CONFIG_FAILSLAB */
+
+static inline bool should_failslub(struct kmem_cache *cachep, gfp_t flags)
+{
+	return false;
+}
+
+#endif /* CONFIG_FAILSLAB */
+
 /*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
@@ -1591,6 +1654,9 @@ static __always_inline void *slab_alloc(
 	unsigned long flags;
 	unsigned int objsize;
 
+	if (should_failslub(s, gfpflags))
+		return NULL;
+
 	local_irq_save(flags);
 	c = get_cpu_slab(s, smp_processor_id());
 	objsize = c->objsize;
Index: 2.6-rc/lib/Kconfig.debug
===================================================================
--- 2.6-rc.orig/lib/Kconfig.debug
+++ 2.6-rc/lib/Kconfig.debug
@@ -699,6 +699,7 @@ config FAULT_INJECTION
 config FAILSLAB
 	bool "Fault-injection capability for kmalloc"
 	depends on FAULT_INJECTION
+	depends on SLAB || SLUB
 	help
 	  Provide fault-injection capability for kmalloc.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
