Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9A83C6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:42:13 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/4] sl[au]b: move print_slabinfo_header to slab_common.c
Date: Thu, 27 Sep 2012 18:37:38 +0400
Message-Id: <1348756660-16929-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1348756660-16929-1-git-send-email-glommer@parallels.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

The header format is highly similar between slab and slub. The main
difference lays in the fact that slab may optionally have statistics
added here in case of CONFIG_SLAB_DEBUG, while the slub will stick them
somewhere else.

By making sure that information conditionally lives inside a
globally-visible CONFIG_DEBUG_SLAB switch, we can move the header
printing to a common location.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c        | 24 ------------------------
 mm/slab.h        |  2 --
 mm/slab_common.c | 23 +++++++++++++++++++++++
 mm/slub.c        | 10 ----------
 4 files changed, 23 insertions(+), 36 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9502dfc..a3de3e5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4283,30 +4283,6 @@ out:
 }
 
 #ifdef CONFIG_SLABINFO
-
-void print_slabinfo_header(struct seq_file *m)
-{
-	/*
-	 * Output format version, so at least we can change it
-	 * without _too_ many complaints.
-	 */
-#if STATS
-	seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
-#else
-	seq_puts(m, "slabinfo - version: 2.1\n");
-#endif
-	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> "
-		 "<objperslab> <pagesperslab>");
-	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
-	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
-#if STATS
-	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> "
-		 "<error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
-	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
-#endif
-	seq_putc(m, '\n');
-}
-
 int slabinfo_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
diff --git a/mm/slab.h b/mm/slab.h
index ac0053f6..45b75c8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -47,8 +47,6 @@ static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t siz
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 
-void print_slabinfo_header(struct seq_file *m);
-
 int slabinfo_show(struct seq_file *m, void *p);
 
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2e0061a..1bde24a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -193,6 +193,29 @@ int slab_is_available(void)
 }
 
 #ifdef CONFIG_SLABINFO
+void print_slabinfo_header(struct seq_file *m)
+{
+	/*
+	 * Output format version, so at least we can change it
+	 * without _too_ many complaints.
+	 */
+#ifdef CONFIG_DEBUG_SLAB
+	seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
+#else
+	seq_puts(m, "slabinfo - version: 2.1\n");
+#endif
+	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> "
+		 "<objperslab> <pagesperslab>");
+	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
+	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
+#ifdef CONFIG_DEBUG_SLAB
+	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> "
+		 "<error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
+	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
+#endif
+	seq_putc(m, '\n');
+}
+
 static void *s_start(struct seq_file *m, loff_t *pos)
 {
 	loff_t n = *pos;
diff --git a/mm/slub.c b/mm/slub.c
index 6383622..4c2c092 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5392,16 +5392,6 @@ __initcall(slab_sysfs_init);
  * The /proc/slabinfo ABI
  */
 #ifdef CONFIG_SLABINFO
-void print_slabinfo_header(struct seq_file *m)
-{
-	seq_puts(m, "slabinfo - version: 2.1\n");
-	seq_puts(m, "# name            <active_objs> <num_objs> <object_size> "
-		 "<objperslab> <pagesperslab>");
-	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
-	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
-	seq_putc(m, '\n');
-}
-
 int slabinfo_show(struct seq_file *m, void *p)
 {
 	unsigned long nr_partials = 0;
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
