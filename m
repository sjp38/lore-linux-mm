Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 03DC36B01F0
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 04:11:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P8BfvQ005666
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 17:11:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D39F145DE62
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:11:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F0E545DE5D
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:11:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F7EEE18001
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:11:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9CA21DB803C
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:11:39 +0900 (JST)
Date: Wed, 25 Aug 2010 17:06:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/5] cgroup: do ID allocation under css allocator.
Message-Id: <20100825170640.5f365629.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, css'id is allocated after ->create() is called. But to make use of ID
in ->create(), it should be available before ->create().

In another thinking, considering the ID is tightly coupled with "css",
it should be allocated when "css" is allocated.
This patch moves alloc_css_id() to css allocation routine. Now, only 2 subsys,
memory and blkio are useing ID. (To support complicated hierarchy walk.)

ID will be used in mem cgroup's ->create(), later.

Note:
If someone changes rules of css allocation, ID allocation should be moved too.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 block/blk-cgroup.c     |    9 ++++++++
 include/linux/cgroup.h |   16 ++++++++-------
 kernel/cgroup.c        |   50 ++++++++++++++-----------------------------------
 mm/memcontrol.c        |    5 ++++
 4 files changed, 38 insertions(+), 42 deletions(-)

Index: mmotm-0811/kernel/cgroup.c
===================================================================
--- mmotm-0811.orig/kernel/cgroup.c
+++ mmotm-0811/kernel/cgroup.c
@@ -289,9 +289,6 @@ struct cg_cgroup_link {
 static struct css_set init_css_set;
 static struct cg_cgroup_link init_css_set_link;
 
-static int cgroup_init_idr(struct cgroup_subsys *ss,
-			   struct cgroup_subsys_state *css);
-
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
  * due to cgroup_iter_start() */
@@ -770,9 +767,6 @@ static struct backing_dev_info cgroup_ba
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
 
-static int alloc_css_id(struct cgroup_subsys *ss,
-			struct cgroup *parent, struct cgroup *child);
-
 static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 {
 	struct inode *inode = new_inode(sb);
@@ -3257,7 +3251,8 @@ static void init_cgroup_css(struct cgrou
 	css->cgroup = cgrp;
 	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
-	css->id = NULL;
+	if (!ss->use_id)
+		css->id = NULL;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
@@ -3342,12 +3337,6 @@ static long cgroup_create(struct cgroup 
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
@@ -3709,17 +3698,6 @@ int __init_or_module cgroup_load_subsys(
 
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
@@ -3888,8 +3866,6 @@ int __init cgroup_init(void)
 		struct cgroup_subsys *ss = subsys[i];
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
-		if (ss->use_id)
-			cgroup_init_idr(ss, init_css_set.subsys[ss->subsys_id]);
 	}
 
 	/* Add init_css_set to the hash table */
@@ -4603,8 +4579,8 @@ err_out:
 
 }
 
-static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
-					    struct cgroup_subsys_state *rootcss)
+static int cgroup_init_idr(struct cgroup_subsys *ss,
+			    struct cgroup_subsys_state *rootcss)
 {
 	struct css_id *newid;
 
@@ -4616,21 +4592,25 @@ static int __init_or_module cgroup_init_
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
 
@@ -4645,7 +4625,7 @@ static int alloc_css_id(struct cgroup_su
 	 * child_id->css pointer will be set after this cgroup is available
 	 * see cgroup_populate_dir()
 	 */
-	rcu_assign_pointer(child_css->id, child_id);
+	rcu_assign_pointer(css->id, child_id);
 
 	return 0;
 }
Index: mmotm-0811/include/linux/cgroup.h
===================================================================
--- mmotm-0811.orig/include/linux/cgroup.h
+++ mmotm-0811/include/linux/cgroup.h
@@ -583,9 +583,11 @@ int cgroup_attach_task_current_cg(struct
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
@@ -593,10 +595,10 @@ int cgroup_attach_task_current_cg(struct
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
Index: mmotm-0811/mm/memcontrol.c
===================================================================
--- mmotm-0811.orig/mm/memcontrol.c
+++ mmotm-0811/mm/memcontrol.c
@@ -4141,6 +4141,11 @@ mem_cgroup_create(struct cgroup_subsys *
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
Index: mmotm-0811/block/blk-cgroup.c
===================================================================
--- mmotm-0811.orig/block/blk-cgroup.c
+++ mmotm-0811/block/blk-cgroup.c
@@ -958,9 +958,13 @@ blkiocg_create(struct cgroup_subsys *sub
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
 
@@ -971,6 +975,11 @@ blkiocg_create(struct cgroup_subsys *sub
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
