Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EA9DF6B0078
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 05:59:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R9x6Xt032326
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Sep 2010 18:59:07 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3606345DE61
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B12745DED2
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:58:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E02471DB80D7
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:58:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 651CFE38002
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:57:24 +0900 (JST)
Date: Mon, 27 Sep 2010 18:52:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/4] memcg: make css ID visible at cgroup creation time
Message-Id: <20100927185213.be22d7b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, css'id is allocated after ->create() is called. But to make use of ID
in ->create(), it should be available before ->create().

In another thinking, considering the ID is tightly coupled with "css",
it should be allocated when "css" is allocated.
This patch moves alloc_css_id() to css allocation routine. Now, only 2 subsys,
memory and blkio are using ID. (To support complicated hierarchy walk.)

ID will be used in mem cgroup's ->create(), later.

This patch adds css ID documentation which is not provided.

Note:
If someone changes rules of css allocation, ID allocation should be changed.

Changelog: 2010/09/01
 - modified cgroups.txt

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/cgroups.txt |   48 ++++++++++++++++++++++++++++++++++++
 block/blk-cgroup.c                |    9 ++++++
 include/linux/cgroup.h            |   16 ++++++------
 kernel/cgroup.c                   |   50 +++++++++++---------------------------
 mm/memcontrol.c                   |    5 +++
 5 files changed, 86 insertions(+), 42 deletions(-)

Index: mmotm-0922/kernel/cgroup.c
===================================================================
--- mmotm-0922.orig/kernel/cgroup.c
+++ mmotm-0922/kernel/cgroup.c
@@ -288,9 +288,6 @@ struct cg_cgroup_link {
 static struct css_set init_css_set;
 static struct cg_cgroup_link init_css_set_link;
 
-static int cgroup_init_idr(struct cgroup_subsys *ss,
-			   struct cgroup_subsys_state *css);
-
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
  * due to cgroup_iter_start() */
@@ -769,9 +766,6 @@ static struct backing_dev_info cgroup_ba
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
 
-static int alloc_css_id(struct cgroup_subsys *ss,
-			struct cgroup *parent, struct cgroup *child);
-
 static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 {
 	struct inode *inode = new_inode(sb);
@@ -3254,7 +3248,8 @@ static void init_cgroup_css(struct cgrou
 	css->cgroup = cgrp;
 	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
-	css->id = NULL;
+	if (!ss->use_id)
+		css->id = NULL;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
@@ -3339,12 +3334,6 @@ static long cgroup_create(struct cgroup 
 			goto err_destroy;
 		}
 		init_cgroup_css(css, ss, cgrp);
-		if (ss->use_id) {
-			err = alloc_css_id(ss, parent, cgrp);
-			if (err)
-				goto err_destroy;
-		}
-		/* At error, ->destroy() callback has to free assigned ID. */
 	}
 
 	cgroup_lock_hierarchy(root);
@@ -3706,17 +3695,6 @@ int __init_or_module cgroup_load_subsys(
 
 	/* our new subsystem will be attached to the dummy hierarchy. */
 	init_cgroup_css(css, ss, dummytop);
-	/* init_idr must be after init_cgroup_css because it sets css->id. */
-	if (ss->use_id) {
-		int ret = cgroup_init_idr(ss, css);
-		if (ret) {
-			dummytop->subsys[ss->subsys_id] = NULL;
-			ss->destroy(ss, dummytop);
-			subsys[i] = NULL;
-			mutex_unlock(&cgroup_mutex);
-			return ret;
-		}
-	}
 
 	/*
 	 * Now we need to entangle the css into the existing css_sets. unlike
@@ -3885,8 +3863,6 @@ int __init cgroup_init(void)
 		struct cgroup_subsys *ss = subsys[i];
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
-		if (ss->use_id)
-			cgroup_init_idr(ss, init_css_set.subsys[ss->subsys_id]);
 	}
 
 	/* Add init_css_set to the hash table */
@@ -4600,8 +4576,8 @@ err_out:
 
 }
 
-static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
-					    struct cgroup_subsys_state *rootcss)
+static int cgroup_init_idr(struct cgroup_subsys *ss,
+			    struct cgroup_subsys_state *rootcss)
 {
 	struct css_id *newid;
 
@@ -4613,21 +4589,25 @@ static int __init_or_module cgroup_init_
 		return PTR_ERR(newid);
 
 	newid->stack[0] = newid->id;
-	newid->css = rootcss;
-	rootcss->id = newid;
+	rcu_assign_pointer(newid->css, rootcss);
+	rcu_assign_pointer(rootcss->id, newid);
 	return 0;
 }
 
-static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
-			struct cgroup *child)
+int alloc_css_id(struct cgroup_subsys *ss,
+	struct cgroup *cgrp, struct cgroup_subsys_state *css)
 {
 	int subsys_id, i, depth = 0;
-	struct cgroup_subsys_state *parent_css, *child_css;
+	struct cgroup_subsys_state *parent_css;
+	struct cgroup *parent;
 	struct css_id *child_id, *parent_id;
 
+	if (cgrp == dummytop)
+		return cgroup_init_idr(ss, css);
+
+	parent = cgrp->parent;
 	subsys_id = ss->subsys_id;
 	parent_css = parent->subsys[subsys_id];
-	child_css = child->subsys[subsys_id];
 	parent_id = parent_css->id;
 	depth = parent_id->depth + 1;
 
@@ -4642,7 +4622,7 @@ static int alloc_css_id(struct cgroup_su
 	 * child_id->css pointer will be set after this cgroup is available
 	 * see cgroup_populate_dir()
 	 */
-	rcu_assign_pointer(child_css->id, child_id);
+	rcu_assign_pointer(css->id, child_id);
 
 	return 0;
 }
Index: mmotm-0922/include/linux/cgroup.h
===================================================================
--- mmotm-0922.orig/include/linux/cgroup.h
+++ mmotm-0922/include/linux/cgroup.h
@@ -588,9 +588,11 @@ static inline int cgroup_attach_task_cur
 /*
  * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
  * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
- * CSS ID is assigned at cgroup allocation (create) automatically
- * and removed when subsys calls free_css_id() function. This is because
- * the lifetime of cgroup_subsys_state is subsys's matter.
+ * CSS ID must be assigned by subsys itself at cgroup creation and deleted
+ * when subsys calls free_css_id() function. This is because the life time of
+ * of cgroup_subsys_state is subsys's matter.
+ *
+ * ID->css look up is available after cgroup's directory is populated.
  *
  * Looking up and scanning function should be called under rcu_read_lock().
  * Taking cgroup_mutex()/hierarchy_mutex() is not necessary for following calls.
@@ -598,10 +600,10 @@ static inline int cgroup_attach_task_cur
  * destroyed". The caller should check css and cgroup's status.
  */
 
-/*
- * Typically Called at ->destroy(), or somewhere the subsys frees
- * cgroup_subsys_state.
- */
+/* Should be called in ->create() by subsys itself */
+int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *newgr,
+		struct cgroup_subsys_state *css);
+/* Typically Called at ->destroy(), or somewhere the subsys frees css */
 void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
 
 /* Find a cgroup_subsys_state which has given ID */
Index: mmotm-0922/mm/memcontrol.c
===================================================================
--- mmotm-0922.orig/mm/memcontrol.c
+++ mmotm-0922/mm/memcontrol.c
@@ -4347,6 +4347,11 @@ mem_cgroup_create(struct cgroup_subsys *
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
+	error = alloc_css_id(ss, cont, &mem->css);
+	if (error)
+		goto free_out;
+	/* Here, css_id(&mem->css) works. but css_lookup(id)->mem doesn't */
+
 	/* root ? */
 	if (cont->parent == NULL) {
 		int cpu;
Index: mmotm-0922/block/blk-cgroup.c
===================================================================
--- mmotm-0922.orig/block/blk-cgroup.c
+++ mmotm-0922/block/blk-cgroup.c
@@ -1434,9 +1434,13 @@ blkiocg_create(struct cgroup_subsys *sub
 {
 	struct blkio_cgroup *blkcg;
 	struct cgroup *parent = cgroup->parent;
+	int ret;
 
 	if (!parent) {
 		blkcg = &blkio_root_cgroup;
+		ret = alloc_css_id(subsys, cgroup, &blkcg->css);
+		if (ret)
+			return ERR_PTR(ret);
 		goto done;
 	}
 
@@ -1447,6 +1451,11 @@ blkiocg_create(struct cgroup_subsys *sub
 	blkcg = kzalloc(sizeof(*blkcg), GFP_KERNEL);
 	if (!blkcg)
 		return ERR_PTR(-ENOMEM);
+	ret = alloc_css_id(subsys, cgroup, &blkcg->css);
+	if (ret) {
+		kfree(blkcg);
+		return ERR_PTR(ret);
+	}
 
 	blkcg->weight = BLKIO_WEIGHT_DEFAULT;
 done:
Index: mmotm-0922/Documentation/cgroups/cgroups.txt
===================================================================
--- mmotm-0922.orig/Documentation/cgroups/cgroups.txt
+++ mmotm-0922/Documentation/cgroups/cgroups.txt
@@ -621,6 +621,54 @@ and root cgroup. Currently this will onl
 the default hierarchy (which never has sub-cgroups) and a hierarchy
 that is being created/destroyed (and hence has no sub-cgroups).
 
+3.4 cgroup subsys state IDs.
+------------
+When subsystem sets use_id == true, an ID per [cgroup, subsys] is added
+and it will be tied to cgroup_subsys_state object.
+
+When use_id==true can use following interfaces. But please note that
+allocation/free an ID is subsystem's job because cgroup_subsys_state
+object's lifetime is subsystem's matter.
+
+unsigned short css_id(struct cgroup_subsys_state *css)
+
+Returns ID of cgroup_subsys_state
+
+unsigend short css_depth(struct cgroup_subsys_state *css)
+
+Returns the level which "css" is exisiting under hierarchy tree.
+The root cgroup's depth 0, its children are 1, children's children are
+2....
+
+int alloc_css_id(struct struct cgroup_subsys *ss, struct cgroup *newgr,
+                struct cgroup_subsys_state *css);
+
+Attach an new ID to given css under subsystem ([ss, cgroup])
+should be called in ->create() callback.
+
+void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
+
+Free ID attached to "css" under subsystem. Should be called before
+"css" is freed.
+
+struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
+
+Look up cgroup_subsys_state via ID. Should be called under rcu_read_lock().
+
+struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss, int id,
+                struct cgroup_subsys_state *root, int *foundid);
+
+Returns ID which is under "root" i.e. under sub-directory of "root"
+cgroup's directory at considering cgroup hierarchy. The order of IDs
+returned by this function is not sorted. Please be careful.
+
+bool css_is_ancestor(struct cgroup_subsys_state *cg,
+                     const struct cgroup_subsys_state *root);
+
+Returns true if "root" and "cs" is under the same hierarchy and
+"root" can be found when you see all ->parent from "cs" until
+the root cgroup.
+
 4. Questions
 ============
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
