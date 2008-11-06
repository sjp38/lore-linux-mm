Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA6AgdBD029138
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 19:42:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 014F145DD79
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 19:42:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFF6445DD76
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 19:42:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 840801DB8042
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 19:42:38 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2415E1DB803E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 19:42:38 +0900 (JST)
Date: Thu, 6 Nov 2008 19:41:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 7/6] memcg: add atribute (for change bahavior of rmdir)
Message-Id: <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49129493.9070103@linux.vnet.ibm.com>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<49129493.9070103@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Nov 2008 12:24:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Weekly (RFC) update for memcg.
> > 
> > This set includes
> > 
> > 1. change force_empty to do move account rather than forget all
> 
> I would like this to be selectable, please. We don't want to break behaviour and
> not everyone would like to pay the cost of movement.

How about a patch like this ? I'd like to move this as [2/7], if possible.
It obviously needs painful rework. If I found it difficult, schedule this as [7/7].

BTW, cost of movement itself is not far from cost for force_empty.

If you can't find why "forget" is bad, please consider one more day.

==
This patch adds attribute to memory resource controller.

This memory.attribute file allows following to set/clear attribute.
  #echo attribute option > memory.attribute

This patch implements an attribute

 # on_rmdir [keep | drop] > memory.attribute.

 When on_rmdir=keep, memory remaining in memcg will be moved up to parent
 at rmdir. This is fast.
 When on_rmdir=drop, memory remaining in memcg will be freed.

 Characteristic of Keep.
  - fast.
  - Doesn't cause unnecessary freeing of memory(page cache).
    (IOW. page-cache for temporal files or some unnecessary pages will be kept.)
 Characteristic of Drop.
  - slow
  - No influence to its parent. all page caches will be dropped.
    (IOW. page-cache for libc or some important pages will be dropped.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/controllers/memory.txt |   22 +++++
 mm/memcontrol.c                      |  134 ++++++++++++++++++++++++++++++++++-
 2 files changed, 154 insertions(+), 2 deletions(-)

Index: mmotm-2.6.28-rc2-Oct30/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/mm/memcontrol.c
+++ mmotm-2.6.28-rc2-Oct30/mm/memcontrol.c
@@ -35,6 +35,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/ctype.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -146,6 +147,10 @@ struct mem_cgroup {
 	 */
 	int	prev_priority;	/* for recording reclaim priority */
 	/*
+	 * attribute
+	 */
+	char		drop_on_rmdir;
+	/*
 	 * used for counting reference from swap_cgroup.
 	 */
 	int		obsolete;
@@ -182,6 +187,22 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
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
+
 static void mem_cgroup_forget_swapref(struct mem_cgroup *mem);
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -1294,6 +1315,10 @@ static int mem_cgroup_force_empty(struct
 	css_get(&mem->css);
 
 	shrink = 0;
+	/* If this is true, free all orphan pages on LRU as much as possible */
+	if (mem->drop_on_rmdir)
+		goto try_to_free;
+
 move_account:
 	while (mem->res.usage > 0) {
 		ret = -EBUSY;
@@ -1311,6 +1336,9 @@ move_account:
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
 			goto try_to_free;
+		ret = -EINTR;
+		if (signal_pending(current))
+			goto out;
 		cond_resched();
 	}
 	ret = 0;
@@ -1332,6 +1360,10 @@ try_to_free:
 						  GFP_HIGHUSER_MOVABLE, false);
 		if (!progress)
 			nr_retries--;
+		ret = -EINTR;
+		if (signal_pending(current))
+			goto out;
+		cond_resched();
 
 	}
 	lru_add_drain();
@@ -1475,6 +1507,95 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+
+/*
+ * Assumes
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
+				     struct cftype *cft,
+				     const char *buffer)
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
+	for (i = 0; i < MEMCG_LAST_ATTR; i++) {
+
+		len = strlen(memcg_attribute_names[i]);
+		if ((option - attr) < len)
+			continue;
+		if (!strncmp(memcg_attribute_names[i], attr, len))
+			break;
+	}
+	ret = -EINVAL;
+	if (i == MEMCG_LAST_ATTR)
+		goto out;
+	switch(i) {
+	case MEMCG_ATTR_ON_RMDIR:
+		if ((end - option) < 4)
+			break;
+		ret = 0;
+		if (strncmp(option, "keep", 4) == 0)
+			mem->drop_on_rmdir = 0;
+		else if (strncmp(option, "drop", 4) == 0)
+			mem->drop_on_rmdir = 1;
+		else
+			ret = -EINVAL;
+		break;
+	}
+out:
+	mutex_unlock(&memcg_attr_mutex);
+	return ret;
+}
+
+static int mem_cgroup_read_attr(struct cgroup *cont, struct cftype *cft,
+				 struct seq_file *m)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	char *s;
+
+	s = memcg_attribute_names[MEMCG_ATTR_ON_RMDIR];
+
+	if (mem->drop_on_rmdir)
+		seq_printf(m, "%s drop\n",s);
+	else
+		seq_printf(m, "%s keep\n",s);
+
+	return 0;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1503,6 +1624,11 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "attribute",
+		.write_string = mem_cgroup_write_attr,
+		.read_seq_string = mem_cgroup_read_attr,
+	},
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 	{
 		.name = "memsw.usage_in_bytes",
@@ -1640,20 +1766,26 @@ static void __init enable_swap_cgroup(vo
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		enable_swap_cgroup();
+		parent = NULL;
+		mem->drop_on_rmdir = 1; /* default is drop */
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		parent = mem_cgroup_from_cont(cont->parent);
 	}
 
 	res_counter_init(&mem->res);
 	res_counter_init(&mem->memsw);
+	/* inherit */
+	if (parent)
+		mem->drop_on_rmdir = parent->drop_on_rmdir;
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
Index: mmotm-2.6.28-rc2-Oct30/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-rc2-Oct30.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-rc2-Oct30/Documentation/controllers/memory.txt
@@ -270,8 +270,28 @@ Charges recorded in swap information is 
 Recorded information is effectively discarded and a cgroup which uses swap
 (swapcache) will be charged as a new owner of it.
 
+5. Attributes
+memory.attribute file is provided to set per-memcg attribute.
+You can specify attribute by
+ #echo attribute option > memory.attribute
+
+5.1 on_rmdir
+set behavior of memcg at rmdir (destroy cgroup) default is "drop".
+
+  5.1.1 drop
+	#echo on_rmdir drop > memory.attribute
+	This is default. All pages on this memcg will be freed.
+	If pages are locked or too busy, they will be moved up to the parent.
+	Useful when you want to drop (large) page caches used in this memcg.
+
+  5.1.2 keep
+	#echo on_rmdir keep > memory.attribute
+	All pages on this memcg will be moved to parent.
+	Useful when you don't want to drop page caches used in this memcg.
+	You can keep page caches from some library or DB accessed by this
+	memcg on memory.
 
-5. TODO
+6. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
