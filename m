Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D37C56B006C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:36 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:36 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 52D456E804B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:30 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EWud65404928
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EW7W029962
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:32 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 13/25] mm: memlayout+dnuma: add debugfs interface
Date: Thu, 11 Apr 2013 18:13:45 -0700
Message-Id: <1365729237-29711-14-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Add a debugfs interface to dnuma/memlayout. It keeps track of a
variable backlog of memory layouts, provides some statistics on dnuma
moved pages & cache performance, and allows the setting of a new global
memlayout.

TODO: split out statistics, backlog, & write interfaces from eachother.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/dnuma.h     |   2 +-
 include/linux/memlayout.h |   7 +
 mm/Kconfig                |  30 ++++
 mm/Makefile               |   1 +
 mm/dnuma.c                |   4 +-
 mm/memlayout-debugfs.c    | 339 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/memlayout-debugfs.h    |  39 ++++++
 mm/memlayout.c            |  20 ++-
 8 files changed, 436 insertions(+), 6 deletions(-)
 create mode 100644 mm/memlayout-debugfs.c
 create mode 100644 mm/memlayout-debugfs.h

diff --git a/include/linux/dnuma.h b/include/linux/dnuma.h
index 029a984..7a33131 100644
--- a/include/linux/dnuma.h
+++ b/include/linux/dnuma.h
@@ -64,7 +64,7 @@ static inline int dnuma_page_needs_move(struct page *page)
 	return new_nid;
 }
 
-void dnuma_post_free_to_new_zone(struct page *page, int order);
+void dnuma_post_free_to_new_zone(int order);
 void dnuma_prior_free_to_new_zone(struct page *page, int order,
 				  struct zone *dest_zone,
 				  int dest_nid);
diff --git a/include/linux/memlayout.h b/include/linux/memlayout.h
index 6c26c52..14dbf35 100644
--- a/include/linux/memlayout.h
+++ b/include/linux/memlayout.h
@@ -56,6 +56,7 @@ struct memlayout {
 };
 
 extern __rcu struct memlayout *pfn_to_node_map;
+extern struct mutex memlayout_lock; /* update-side lock */
 
 /* FIXME: overflow potential in completion check */
 #define ml_for_each_pfn_in_range(rme, pfn)	\
@@ -90,7 +91,13 @@ static inline struct rangemap_entry *rme_first(struct memlayout *ml)
 	     rme = rme_next(rme))
 
 struct memlayout *memlayout_create(enum memlayout_type);
+
+/*
+ * In most cases, these should only be used by the memlayout debugfs code (or
+ * internally within memlayout)
+ */
 void memlayout_destroy(struct memlayout *ml);
+void memlayout_destroy_mem(struct memlayout *ml);
 
 int memlayout_new_range(struct memlayout *ml,
 		unsigned long pfn_start, unsigned long pfn_end, int nid);
diff --git a/mm/Kconfig b/mm/Kconfig
index 86f0984..3820b3c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,6 +193,36 @@ config DYNAMIC_NUMA
 	 Choose Y if you have are running linux under a hypervisor that uses
 	 this feature, otherwise choose N if unsure.
 
+config DNUMA_DEBUGFS
+	bool "Export DNUMA & memlayout internals via debugfs"
+	depends on DYNAMIC_NUMA
+	help
+	 Export some dynamic numa info via debugfs in <debugfs>/memlayout.
+
+	 Enables the tracking and export of statistics and the exporting of the
+	 current memory layout.
+
+	 If you are not debugging Dynamic NUMA or memlayout, choose N.
+
+config DNUMA_BACKLOG
+	int "Number of old memlayouts to keep (0 = None, -1 = unlimited)"
+	depends on DNUMA_DEBUGFS
+	help
+	 Allows access to old memory layouts & statistics in debugfs.
+
+	 Each memlayout will consume some memory, and when set to -1
+	 (unlimited), this can result in unbounded kernel memory use.
+
+config DNUMA_DEBUGFS_WRITE
+	bool "Change NUMA layout via debugfs"
+	depends on DNUMA_DEBUGFS
+	help
+	 Enable the use of <debugfs>/memlayout/{start,end,node,commit}
+
+	 Write a PFN to 'start' & 'end', then a node id to 'node'.
+	 Repeat this until you are satisfied with your memory layout, then
+	 write '1' to 'commit'.
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
diff --git a/mm/Makefile b/mm/Makefile
index 82fe7c9b..b07926c 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -59,3 +59,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_DYNAMIC_NUMA) += dnuma.o memlayout.o
+obj-$(CONFIG_DNUMA_DEBUGFS) += memlayout-debugfs.o
diff --git a/mm/dnuma.c b/mm/dnuma.c
index 2ee0903..eb00b7b 100644
--- a/mm/dnuma.c
+++ b/mm/dnuma.c
@@ -11,6 +11,7 @@
 #include <linux/types.h>
 
 #include "internal.h"
+#include "memlayout-debugfs.h"
 
 /* - must be called under lock_memory_hotplug() */
 /* TODO: avoid iterating over all PFNs. */
@@ -117,8 +118,9 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 }
 #endif
 
-void dnuma_post_free_to_new_zone(struct page *page, int order)
+void dnuma_post_free_to_new_zone(int order)
 {
+	ml_stat_count_moved_pages(order);
 }
 
 static void dnuma_prior_return_to_new_zone(struct page *page, int order,
diff --git a/mm/memlayout-debugfs.c b/mm/memlayout-debugfs.c
new file mode 100644
index 0000000..a4fc2cb
--- /dev/null
+++ b/mm/memlayout-debugfs.c
@@ -0,0 +1,339 @@
+#include <linux/debugfs.h>
+
+#include <linux/slab.h> /* kmalloc */
+#include <linux/module.h> /* THIS_MODULE, needed for DEFINE_SIMPLE_ATTR */
+
+#include "memlayout-debugfs.h"
+
+#if CONFIG_DNUMA_BACKLOG > 0
+/* Fixed size backlog */
+#include <linux/kfifo.h>
+#include <linux/log2.h> /* roundup_pow_of_two */
+DEFINE_KFIFO(ml_backlog, struct memlayout *,
+		roundup_pow_of_two(CONFIG_DNUMA_BACKLOG));
+void ml_backlog_feed(struct memlayout *ml)
+{
+	if (kfifo_is_full(&ml_backlog)) {
+		struct memlayout *old_ml;
+		BUG_ON(!kfifo_get(&ml_backlog, &old_ml));
+		memlayout_destroy(old_ml);
+	}
+
+	kfifo_put(&ml_backlog, (const struct memlayout **)&ml);
+}
+#elif CONFIG_DNUMA_BACKLOG < 0
+/* Unlimited backlog */
+void ml_backlog_feed(struct memlayout *ml)
+{
+	/* we never use the rme_tree, so we destroy the non-debugfs portions to
+	 * save memory */
+	memlayout_destroy_mem(ml);
+}
+#else /* CONFIG_DNUMA_BACKLOG == 0 */
+/* No backlog */
+void ml_backlog_feed(struct memlayout *ml)
+{
+	memlayout_destroy(ml);
+}
+#endif
+
+static atomic64_t dnuma_moved_page_ct;
+void ml_stat_count_moved_pages(int order)
+{
+	atomic64_add(1 << order, &dnuma_moved_page_ct);
+}
+
+static atomic_t ml_seq = ATOMIC_INIT(0);
+static struct dentry *root_dentry, *current_dentry;
+#define ML_LAYOUT_NAME_SZ \
+	((size_t)(DIV_ROUND_UP(sizeof(unsigned) * 8, 3) \
+				+ 1 + strlen("layout.")))
+#define ML_REGION_NAME_SZ ((size_t)(2 * BITS_PER_LONG / 4 + 2))
+
+static void ml_layout_name(struct memlayout *ml, char *name)
+{
+	sprintf(name, "layout.%u", ml->seq);
+}
+
+static int dfs_range_get(void *data, u64 *val)
+{
+	*val = (uintptr_t)data;
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(range_fops, dfs_range_get, NULL, "%lld\n");
+
+static void _ml_dbgfs_create_range(struct dentry *base,
+		struct rangemap_entry *rme, char *name)
+{
+	struct dentry *rd;
+	sprintf(name, "%05lx-%05lx", rme->pfn_start, rme->pfn_end);
+	rd = debugfs_create_file(name, 0400, base,
+				(void *)(uintptr_t)rme->nid, &range_fops);
+	if (!rd)
+		pr_devel("debugfs: failed to create "RME_FMT"\n",
+				RME_EXP(rme));
+	else
+		pr_devel("debugfs: created "RME_FMT"\n", RME_EXP(rme));
+}
+
+/* Must be called with memlayout_lock held */
+static void _ml_dbgfs_set_current(struct memlayout *ml, char *name)
+{
+	ml_layout_name(ml, name);
+	debugfs_remove(current_dentry);
+	current_dentry = debugfs_create_symlink("current", root_dentry, name);
+}
+
+static void ml_dbgfs_create_layout_assume_root(struct memlayout *ml)
+{
+	char name[ML_LAYOUT_NAME_SZ];
+	ml_layout_name(ml, name);
+	WARN_ON(!root_dentry);
+	ml->d = debugfs_create_dir(name, root_dentry);
+	WARN_ON(!ml->d);
+}
+
+# if defined(CONFIG_DNUMA_DEBUGFS_WRITE)
+
+#define DEFINE_DEBUGFS_GET(___type)					\
+	static int debugfs_## ___type ## _get(void *data, u64 *val)	\
+	{								\
+		*val = *(___type *)data;				\
+		return 0;						\
+	}
+
+DEFINE_DEBUGFS_GET(u32);
+DEFINE_DEBUGFS_GET(u8);
+
+#define DEFINE_WATCHED_ATTR(___type, ___var)			\
+	static int ___var ## _watch_set(void *data, u64 val)	\
+	{							\
+		___type old_val = *(___type *)data;		\
+		int ret = ___var ## _watch(old_val, val);	\
+		if (!ret)					\
+			*(___type *)data = val;			\
+		return ret;					\
+	}							\
+	DEFINE_SIMPLE_ATTRIBUTE(___var ## _fops,		\
+			debugfs_ ## ___type ## _get,		\
+			___var ## _watch_set, "%llu\n");
+
+#define DEFINE_ACTION_ATTR(___name)
+
+static u64 dnuma_user_start;
+static u64 dnuma_user_end;
+static u32 dnuma_user_node; /* XXX: I don't care about this var, remove? */
+static u8  dnuma_user_commit, dnuma_user_clear; /* same here */
+static struct memlayout *user_ml;
+static DEFINE_MUTEX(dnuma_user_lock);
+static int dnuma_user_node_watch(u32 old_val, u32 new_val)
+{
+	int ret = 0;
+	mutex_lock(&dnuma_user_lock);
+	if (!user_ml)
+		user_ml = memlayout_create(ML_USER_DEBUG);
+
+	if (WARN_ON(!user_ml)) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	if (new_val >= nr_node_ids) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (dnuma_user_start > dnuma_user_end) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = memlayout_new_range(user_ml, dnuma_user_start, dnuma_user_end,
+				  new_val);
+
+	if (!ret) {
+		dnuma_user_start = 0;
+		dnuma_user_end = 0;
+	}
+out:
+	mutex_unlock(&dnuma_user_lock);
+	return ret;
+}
+
+static int dnuma_user_commit_watch(u8 old_val, u8 new_val)
+{
+	mutex_lock(&dnuma_user_lock);
+	if (user_ml)
+		memlayout_commit(user_ml);
+	user_ml = NULL;
+	mutex_unlock(&dnuma_user_lock);
+	return 0;
+}
+
+static int dnuma_user_clear_watch(u8 old_val, u8 new_val)
+{
+	mutex_lock(&dnuma_user_lock);
+	if (user_ml)
+		memlayout_destroy(user_ml);
+	user_ml = NULL;
+	mutex_unlock(&dnuma_user_lock);
+	return 0;
+}
+
+DEFINE_WATCHED_ATTR(u32, dnuma_user_node);
+DEFINE_WATCHED_ATTR(u8, dnuma_user_commit);
+DEFINE_WATCHED_ATTR(u8, dnuma_user_clear);
+# endif /* defined(CONFIG_DNUMA_DEBUGFS_WRITE) */
+
+/* create the entire current memlayout.
+ * only used for the layout which exsists prior to fs initialization
+ */
+static void ml_dbgfs_create_initial_layout(void)
+{
+	struct rangemap_entry *rme;
+	char name[max(ML_REGION_NAME_SZ, ML_LAYOUT_NAME_SZ)];
+	struct memlayout *old_ml, *new_ml;
+
+	new_ml = kmalloc(sizeof(*new_ml), GFP_KERNEL);
+	if (WARN(!new_ml, "memlayout allocation failed\n"))
+		return;
+
+	mutex_lock(&memlayout_lock);
+
+	old_ml = rcu_dereference_protected(pfn_to_node_map,
+			mutex_is_locked(&memlayout_lock));
+	if (WARN_ON(!old_ml))
+		goto e_out;
+	*new_ml = *old_ml;
+
+	if (WARN_ON(new_ml->d))
+		goto e_out;
+
+	/* this assumption holds as ml_dbgfs_create_initial_layout() (this
+	 * function) is only called by ml_dbgfs_create_root() */
+	ml_dbgfs_create_layout_assume_root(new_ml);
+	if (!new_ml->d)
+		goto e_out;
+
+	ml_for_each_range(new_ml, rme) {
+		_ml_dbgfs_create_range(new_ml->d, rme, name);
+	}
+
+	_ml_dbgfs_set_current(new_ml, name);
+	rcu_assign_pointer(pfn_to_node_map, new_ml);
+	mutex_unlock(&memlayout_lock);
+
+	synchronize_rcu();
+	kfree(old_ml);
+	return;
+e_out:
+	mutex_unlock(&memlayout_lock);
+	kfree(new_ml);
+}
+
+static atomic64_t ml_cache_hits;
+static atomic64_t ml_cache_misses;
+
+void ml_stat_cache_miss(void)
+{
+	atomic64_inc(&ml_cache_misses);
+}
+
+void ml_stat_cache_hit(void)
+{
+	atomic64_inc(&ml_cache_hits);
+}
+
+/* returns 0 if root_dentry has been created */
+static int ml_dbgfs_create_root(void)
+{
+	if (root_dentry)
+		return 0;
+
+	if (!debugfs_initialized()) {
+		pr_devel("debugfs not registered or disabled.\n");
+		return -EINVAL;
+	}
+
+	root_dentry = debugfs_create_dir("memlayout", NULL);
+	if (!root_dentry) {
+		pr_devel("root dir creation failed\n");
+		return -EINVAL;
+	}
+
+	/* TODO: place in a different dir? (to keep memlayout & dnuma seperate)
+	 */
+	/* FIXME: use debugfs_create_atomic64() [does not yet exsist]. */
+	debugfs_create_u64("moved-pages", 0400, root_dentry,
+			   (uint64_t *)&dnuma_moved_page_ct.counter);
+	debugfs_create_u64("pfn-lookup-cache-misses", 0400, root_dentry,
+			   (uint64_t *)&ml_cache_misses.counter);
+	debugfs_create_u64("pfn-lookup-cache-hits", 0400, root_dentry,
+			   (uint64_t *)&ml_cache_hits.counter);
+
+# if defined(CONFIG_DNUMA_DEBUGFS_WRITE)
+	/* Set node last: on write, it adds the range. */
+	debugfs_create_x64("start", 0600, root_dentry, &dnuma_user_start);
+	debugfs_create_x64("end",   0600, root_dentry, &dnuma_user_end);
+	debugfs_create_file("node",  0200, root_dentry,
+			&dnuma_user_node, &dnuma_user_node_fops);
+	debugfs_create_file("commit",  0200, root_dentry,
+			&dnuma_user_commit, &dnuma_user_commit_fops);
+	debugfs_create_file("clear",  0200, root_dentry,
+			&dnuma_user_clear, &dnuma_user_clear_fops);
+# endif
+
+	/* uses root_dentry */
+	ml_dbgfs_create_initial_layout();
+
+	return 0;
+}
+
+static void ml_dbgfs_create_layout(struct memlayout *ml)
+{
+	if (ml_dbgfs_create_root()) {
+		ml->d = NULL;
+		return;
+	}
+	ml_dbgfs_create_layout_assume_root(ml);
+}
+
+static int ml_dbgfs_init_root(void)
+{
+	ml_dbgfs_create_root();
+	return 0;
+}
+
+void ml_dbgfs_init(struct memlayout *ml)
+{
+	ml->seq = atomic_inc_return(&ml_seq) - 1;
+	ml_dbgfs_create_layout(ml);
+}
+
+void ml_dbgfs_create_range(struct memlayout *ml, struct rangemap_entry *rme)
+{
+	char name[ML_REGION_NAME_SZ];
+	if (ml->d)
+		_ml_dbgfs_create_range(ml->d, rme, name);
+}
+
+void ml_dbgfs_set_current(struct memlayout *ml)
+{
+	char name[ML_LAYOUT_NAME_SZ];
+	_ml_dbgfs_set_current(ml, name);
+}
+
+void ml_destroy_dbgfs(struct memlayout *ml)
+{
+	if (ml && ml->d)
+		debugfs_remove_recursive(ml->d);
+}
+
+static void __exit ml_dbgfs_exit(void)
+{
+	debugfs_remove_recursive(root_dentry);
+	root_dentry = NULL;
+}
+
+module_init(ml_dbgfs_init_root);
+module_exit(ml_dbgfs_exit);
diff --git a/mm/memlayout-debugfs.h b/mm/memlayout-debugfs.h
new file mode 100644
index 0000000..12dc1eb
--- /dev/null
+++ b/mm/memlayout-debugfs.h
@@ -0,0 +1,39 @@
+#ifndef LINUX_MM_MEMLAYOUT_DEBUGFS_H_
+#define LINUX_MM_MEMLAYOUT_DEBUGFS_H_
+
+#include <linux/memlayout.h>
+
+#ifdef CONFIG_DNUMA_DEBUGFS
+void ml_stat_count_moved_pages(int order);
+void ml_stat_cache_hit(void);
+void ml_stat_cache_miss(void);
+void ml_dbgfs_init(struct memlayout *ml);
+void ml_dbgfs_create_range(struct memlayout *ml, struct rangemap_entry *rme);
+void ml_destroy_dbgfs(struct memlayout *ml);
+void ml_dbgfs_set_current(struct memlayout *ml);
+void ml_backlog_feed(struct memlayout *ml);
+#else /* !defined(CONFIG_DNUMA_DEBUGFS) */
+static inline void ml_stat_count_moved_pages(int order)
+{}
+static inline void ml_stat_cache_hit(void)
+{}
+static inline void ml_stat_cache_miss(void)
+{}
+
+static inline void ml_dbgfs_init(struct memlayout *ml)
+{}
+static inline void ml_dbgfs_create_range(struct memlayout *ml,
+		struct rangemap_entry *rme)
+{}
+static inline void ml_destroy_dbgfs(struct memlayout *ml)
+{}
+static inline void ml_dbgfs_set_current(struct memlayout *ml)
+{}
+
+static inline void ml_backlog_feed(struct memlayout *ml)
+{
+	memlayout_destroy(ml);
+}
+#endif
+
+#endif
diff --git a/mm/memlayout.c b/mm/memlayout.c
index 7d2905b..45e7df6 100644
--- a/mm/memlayout.c
+++ b/mm/memlayout.c
@@ -14,6 +14,8 @@
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 
+#include "memlayout-debugfs.h"
+
 /* protected by memlayout_lock */
 __rcu struct memlayout *pfn_to_node_map;
 DEFINE_MUTEX(memlayout_lock);
@@ -26,7 +28,7 @@ static void free_rme_tree(struct rb_root *root)
 	}
 }
 
-static void ml_destroy_mem(struct memlayout *ml)
+void memlayout_destroy_mem(struct memlayout *ml)
 {
 	if (!ml)
 		return;
@@ -88,6 +90,8 @@ int memlayout_new_range(struct memlayout *ml, unsigned long pfn_start,
 
 	rb_link_node(&rme->node, parent, new);
 	rb_insert_color(&rme->node, &ml->root);
+
+	ml_dbgfs_create_range(ml, rme);
 	return 0;
 }
 
@@ -104,9 +108,12 @@ int memlayout_pfn_to_nid(unsigned long pfn)
 	rme = ACCESS_ONCE(ml->cache);
 	if (rme && rme_bounds_pfn(rme, pfn)) {
 		rcu_read_unlock();
+		ml_stat_cache_hit();
 		return rme->nid;
 	}
 
+	ml_stat_cache_miss();
+
 	node = ml->root.rb_node;
 	while (node) {
 		struct rangemap_entry *rme = rb_entry(node, typeof(*rme), node);
@@ -135,7 +142,8 @@ out:
 
 void memlayout_destroy(struct memlayout *ml)
 {
-	ml_destroy_mem(ml);
+	ml_destroy_dbgfs(ml);
+	memlayout_destroy_mem(ml);
 }
 
 struct memlayout *memlayout_create(enum memlayout_type type)
@@ -153,6 +161,7 @@ struct memlayout *memlayout_create(enum memlayout_type type)
 	ml->type = type;
 	ml->cache = NULL;
 
+	ml_dbgfs_init(ml);
 	return ml;
 }
 
@@ -163,12 +172,12 @@ void memlayout_commit(struct memlayout *ml)
 	if (ml->type == ML_INITIAL) {
 		if (WARN(dnuma_has_memlayout(),
 				"memlayout marked first is not first, ignoring.\n")) {
-			memlayout_destroy(ml);
 			ml_backlog_feed(ml);
 			return;
 		}
 
 		mutex_lock(&memlayout_lock);
+		ml_dbgfs_set_current(ml);
 		rcu_assign_pointer(pfn_to_node_map, ml);
 		mutex_unlock(&memlayout_lock);
 		return;
@@ -179,13 +188,16 @@ void memlayout_commit(struct memlayout *ml)
 	unlock_memory_hotplug();
 
 	mutex_lock(&memlayout_lock);
+
+	ml_dbgfs_set_current(ml);
+
 	old_ml = rcu_dereference_protected(pfn_to_node_map,
 			mutex_is_locked(&memlayout_lock));
 
 	rcu_assign_pointer(pfn_to_node_map, ml);
 
 	synchronize_rcu();
-	memlayout_destroy(old_ml);
+	ml_backlog_feed(old_ml);
 
 	/* Must be called only after the new value for pfn_to_node_map has
 	 * propogated to all tasks, otherwise some pages may lookup the old
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
