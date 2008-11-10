Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAA9rBQ4022423
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Nov 2008 18:53:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6223B45DE54
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:53:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4276045DE53
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:53:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 221EB1DB803F
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:53:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B6FB31DB8040
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:53:10 +0900 (JST)
Date: Mon, 10 Nov 2008 18:52:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: add feature for customizing behavior at rmdir
Message-Id: <20081110185235.5c38b82f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

A patch to free all pages at rmdir(). (not forget.)

This patch is tesded on mmotm-30/Oct+ account_move patch.
Maybe no hunk with the newer one (mmotm-06/Nov), which includes 
memcg-move-all-accounts-to-parent-at-rmdir.patch.

(06/Nov doesn't work because linux-next in it can't work. 
 10/Nov release of linux-next works well.)

I started rebase of mem+swap controller on this.
But I'd like to ask Paul whether this interface is acceptable or not.
one-attribute-per-one-file is better ?

Thanks,
-Kame
==
By memcg-move-all-accounts-to-parent-at-rmdir.patch, there is no leak
of memory usage. It moves all remaining pages to parent at rmdir().
But obviously, there is an another choice.

This patch adds "free all at rmdir" and its attribute to memcg.

This memory.attribute file allows following to set/clear attribute.
  #echo attribute option > memory.attribute

This patch implements an attribute

 # on_rmdir [keep | drop] > memory.attribute.

 When on_rmdir=keep, memory remaining in memcg will be moved up to parent
 at rmdir.  When on_rmdir=drop, memory remaining in memcg will be freed.

 Characteristic of Keep.
  - Doesn't cause unnecessary freeing of memory(page cache).
    (page-cache for temporal files or some unnecessary pages will be kept.)
 Characteristic of Drop.
  - maybe do necessary write-back.
  - All page caches and RSSs will be dropped.
    (page-cache for libc or some important pages will be dropped.)
  - If a patch which cannot be freed (mlocked etc..) is found, use move
    logic and move it to the parent.

This patch also adds break for signal in the loop of force_empty.
(it can be heavy when we do writeback.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Changelog v0->v1:
  - added congestion wait to try_to_free_page() failure path of force_empty.
    (If not, we'll see -EBUSY at rmdir at removing small cgroup.)

 Documentation/controllers/memory.txt |   35 +++++++-
 mm/memcontrol.c                      |  148 ++++++++++++++++++++++++++++++++++-
 2 files changed, 176 insertions(+), 7 deletions(-)

Index: mmotm-2.6.28-Oct30/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Oct30.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Oct30/mm/memcontrol.c
@@ -30,6 +30,7 @@
 #include <linux/swap.h>
 #include <linux/spinlock.h>
 #include <linux/fs.h>
+#include <linux/ctype.h>
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
@@ -132,6 +133,11 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+	/*
+	 * attributes.
+	 * on_rmdir ....0=free all 1=move all.
+	 */
+	char	on_rmdir;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -157,6 +163,22 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 	0, /* FORCE */
 };
 
+
+/*
+ *  attribute for memcg default value comes from its parent.
+ *  the root set all to false.
+ */
+enum {
+	MEMCG_ATTR_ON_RMDIR, /* drop_all if true, default is true. */
+	MEMCG_LAST_ATTR,
+};
+/* we may have to check status under racy situation. use global mutex. */
+DEFINE_MUTEX(memcg_attr_mutex);
+
+static char *memcg_attribute_names[MEMCG_LAST_ATTR] = {
+	"on_rmdir",
+};
+
 /*
  * Always modified under lru lock. Then, not necessary to preempt_disable()
  */
@@ -1072,11 +1094,17 @@ static int mem_cgroup_force_empty(struct
 
 	shrink = 0;
 move_account:
+	/* should free all ? */
+	if (!mem->on_rmdir)
+		goto try_to_free;
+
 	while (mem->res.usage > 0) {
 		ret = -EBUSY;
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
-
+		ret = -EINTR;
+		if (signal_pending(current))
+			goto out;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		ret = 0;
@@ -1111,14 +1139,24 @@ try_to_free:
 		ret = -EBUSY;
 		goto out;
 	}
+	/* we call try-to-free pages for make this cgroup empty */
+	lru_add_drain_all();
 	/* try to free all pages in this cgroup */
 	shrink = 1;
 	while (nr_retries && mem->res.usage > 0) {
 		int progress;
+
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			goto out;
+		}
 		progress = try_to_free_mem_cgroup_pages(mem,
 						  GFP_HIGHUSER_MOVABLE);
-		if (!progress)
+		if (!progress) {
 			nr_retries--;
+			/* writeback is necessary */
+			congestion_wait(WRITE, HZ/10);
+		}
 
 	}
 	/* try move_account...there may be some *locked* pages. */
@@ -1225,6 +1263,99 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+
+/*
+ * Expected Usage:
+ * #echo attribute [option] > memory.feature
+ */
+static int
+parse_attr_option(char *buffer, char **attr, char **option, char **end)
+{
+	char *c = buffer;
+
+	*attr = NULL;
+	*option = NULL;
+	/* skip white space */
+	for (; *c && isspace(*c);c++);
+	/* found NULL ? */
+	if (!*c)
+		return -EINVAL;
+	*attr = c;
+	/* skip attribute */
+	for (; *c && !isspace(*c);c++);
+	/* skip space */
+	for (; *c && isspace(*c);c++);
+	/* pass pointer to option */
+	*option = c;
+	for (; *c; c++);
+	*end = c;
+	return 0;
+
+}
+
+static int mem_cgroup_write_attr(struct cgroup *cont,
+				 struct cftype *cft,
+				 const char *buffer)
+{
+	int i, len;
+	char *attr, *option, *end;
+	int ret = -EINVAL;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
+	mutex_lock(&memcg_attr_mutex);
+	/* parse attribute option */
+	ret = parse_attr_option((char*)buffer, &attr, &option, &end);
+	if (ret)
+		goto out;
+
+	for (i = 0; i < MEMCG_LAST_ATTR; i++) {
+
+		len = strlen(memcg_attribute_names[i]);
+		if ((option - attr) < len)
+			continue;
+		if (!strncmp(memcg_attribute_names[i], attr, len))
+			break;
+	}
+
+	ret = -EINVAL;
+	if (i == MEMCG_LAST_ATTR)
+		goto out;
+	switch(i) {
+	case MEMCG_ATTR_ON_RMDIR:
+		if ((end - option) < 4)
+			break;
+		ret = 0;
+		if (strncmp(option, "keep", 4) == 0)
+			mem->on_rmdir = 1;
+		else if (strncmp(option, "drop", 4) == 0)
+			mem->on_rmdir = 0;
+		else
+			ret = -EINVAL;
+		break;
+	}
+out:
+	mutex_unlock(&memcg_attr_mutex);
+	return ret;
+}
+
+
+static int mem_cgroup_read_attr(struct cgroup *cont, struct cftype *cft,
+				struct seq_file *m)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	char *s;
+
+	s = memcg_attribute_names[MEMCG_ATTR_ON_RMDIR];
+
+	if (!mem->on_rmdir)
+		seq_printf(m, "%s drop\n",s);
+	else
+		seq_printf(m, "%s keep\n",s);
+
+	return 0;
+}
+
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1253,6 +1384,11 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "attribute",
+		.write_string = mem_cgroup_write_attr,
+		.read_seq_string = mem_cgroup_read_attr,
+	},
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1318,18 +1454,24 @@ static void mem_cgroup_free(struct mem_c
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 
+	parent = NULL;
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
+		/* do this in explicit way. */
+		mem->on_rmdir = 0;
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		parent = mem_cgroup_from_cont(cont->parent);
 	}
 
 	res_counter_init(&mem->res);
+	if (parent)
+		mem->on_rmdir = parent->on_rmdir;
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
Index: mmotm-2.6.28-Oct30/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-Oct30.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-Oct30/Documentation/controllers/memory.txt
@@ -237,11 +237,38 @@ reclaimed.
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
 tasks have migrated away from it.
-Such charges are moved to its parent as much as possible and freed if parent
-is full. Both of RSS and CACHES are moved to parent.
-If both of them are busy, rmdir() returns -EBUSY.
+Such charges are freed(at default) or moved to its parent. When moved,
+both of RSS and CACHES are moved to parent.
+If both of them are busy, rmdir() returns -EBUSY. See 5.1 Also.
+
+5. Attributes.
+
+memory controller has some of attributes for customizing behavior.
+You can specify attribute by
+#echo attribute option > memory.attribute
+
+To see current value, read the file.
+#cat memory.attribute
+
+5.1 on_rmdir
+set behavior of memcg at rmdir (Removing cgroup) default is "drop".
+
+5.1.1 drop
+       #echo on_rmdir drop > memory.attribute
+       This is default. All pages on the memcg will be freed.
+       If pages are locked or too busy, they will be moved up to the parent.
+       Useful when you want to drop (large) page caches used in this memcg.
+       But some of in-use page cache can be dropped by this.
+
+5.1.2 keep
+       #echo on_rmdir keep > memory.attribute
+       All pages on the memcg will be moved to its parent.
+       Useful when you don't want to drop page caches used in this memcg.
+       You can keep page caches from some library or DB accessed by this
+       memcg on memory.
 
-5. TODO
+
+6. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
