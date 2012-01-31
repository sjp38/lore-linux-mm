Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 822A46B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 00:44:57 -0500 (EST)
Message-ID: <4F278078.5030703@cn.fujitsu.com>
Date: Tue, 31 Jan 2012 13:47:36 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] cgroup: remove cgroup_subsys argument from callbacks
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, container cgroup <containers@lists.linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, netdev <netdev@vger.kernel.org>

The argument is not used at all, and it's not necessary, because
a specific callback handler of course knows which subsys it
belongs to.

Now only ->pupulate() takes this argument, because the handlers of
this callback always call cgroup_add_file()/cgroup_add_files().

So we reduce a few lines of code, though the shrinking of object size
is minimal.

 16 files changed, 113 insertions(+), 162 deletions(-)

   text    data     bss     dec     hex filename
5486240  656987 7039960 13183187         c928d3 vmlinux.o.orig
5486170  656987 7039960 13183117         c9288d vmlinux.o

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 Documentation/cgroups/cgroups.txt |   26 ++++++++-----------
 block/blk-cgroup.c                |   22 ++++++----------
 include/linux/cgroup.h            |   29 +++++++++-------------
 include/net/sock.h                |    7 ++---
 include/net/tcp_memcontrol.h      |    2 +-
 kernel/cgroup.c                   |   43 ++++++++++++++++-----------------
 kernel/cgroup_freezer.c           |   11 +++-----
 kernel/cpuset.c                   |   16 ++++--------
 kernel/events/core.c              |   13 ++++------
 kernel/sched/core.c               |   20 ++++++---------
 mm/memcontrol.c                   |   48 ++++++++++++++----------------------
 net/core/netprio_cgroup.c         |   10 +++----
 net/core/sock.c                   |    6 ++--
 net/ipv4/tcp_memcontrol.c         |    2 +-
 net/sched/cls_cgroup.c            |   10 +++----
 security/device_cgroup.c          |   10 +++----
 16 files changed, 113 insertions(+), 162 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index a7c96ae..8e74980 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -558,8 +558,7 @@ Each subsystem may export the following methods. The only mandatory
 methods are create/destroy. Any others that are null are presumed to
 be successful no-ops.
 
-struct cgroup_subsys_state *create(struct cgroup_subsys *ss,
-				   struct cgroup *cgrp)
+struct cgroup_subsys_state *create(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
 Called to create a subsystem state object for a cgroup. The
@@ -574,7 +573,7 @@ identified by the passed cgroup object having a NULL parent (since
 it's the root of the hierarchy) and may be an appropriate place for
 initialization code.
 
-void destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+void destroy(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
 The cgroup system is about to destroy the passed cgroup; the subsystem
@@ -585,7 +584,7 @@ cgroup->parent is still valid. (Note - can also be called for a
 newly-created cgroup if an error occurs after this subsystem's
 create() method has been called for the new cgroup).
 
-int pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+int pre_destroy(struct cgroup *cgrp);
 
 Called before checking the reference count on each subsystem. This may
 be useful for subsystems which have some extra references even if
@@ -593,8 +592,7 @@ there are not tasks in the cgroup. If pre_destroy() returns error code,
 rmdir() will fail with it. From this behavior, pre_destroy() can be
 called multiple times against a cgroup.
 
-int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	       struct cgroup_taskset *tset)
+int can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called prior to moving one or more tasks into a cgroup; if the
@@ -615,8 +613,7 @@ fork. If this method returns 0 (success) then this should remain valid
 while the caller holds cgroup_mutex and it is ensured that either
 attach() or cancel_attach() will be called in future.
 
-void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		   struct cgroup_taskset *tset)
+void cancel_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called when a task attach operation has failed after can_attach() has succeeded.
@@ -625,23 +622,22 @@ function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
 succeeded. The parameters are identical to can_attach().
 
-void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	    struct cgroup_taskset *tset)
+void attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
 The parameters are identical to can_attach().
 
-void fork(struct cgroup_subsy *ss, struct task_struct *task)
+void fork(struct task_struct *task)
 
 Called when a task is forked into a cgroup.
 
-void exit(struct cgroup_subsys *ss, struct task_struct *task)
+void exit(struct task_struct *task)
 
 Called during task exit.
 
-int populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+int populate(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
 Called after creation of a cgroup to allow a subsystem to populate
@@ -651,7 +647,7 @@ include/linux/cgroup.h for details).  Note that although this
 method can return an error code, the error code is currently not
 always handled well.
 
-void post_clone(struct cgroup_subsys *ss, struct cgroup *cgrp)
+void post_clone(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
 Called during cgroup_create() to do any parameter
@@ -659,7 +655,7 @@ initialization which might be required before a task could attach.  For
 example in cpusets, no task may attach before 'cpus' and 'mems' are set
 up.
 
-void bind(struct cgroup_subsys *ss, struct cgroup *root)
+void bind(struct cgroup *root)
 (cgroup_mutex and ss->hierarchy_mutex held by caller)
 
 Called when a cgroup subsystem is rebound to a different hierarchy
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index fa8f263..1359d63 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -28,13 +28,10 @@ static LIST_HEAD(blkio_list);
 struct blkio_cgroup blkio_root_cgroup = { .weight = 2*BLKIO_WEIGHT_DEFAULT };
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
-static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys *,
-						  struct cgroup *);
-static int blkiocg_can_attach(struct cgroup_subsys *, struct cgroup *,
-			      struct cgroup_taskset *);
-static void blkiocg_attach(struct cgroup_subsys *, struct cgroup *,
-			   struct cgroup_taskset *);
-static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
+static struct cgroup_subsys_state *blkiocg_create(struct cgroup *);
+static int blkiocg_can_attach(struct cgroup *, struct cgroup_taskset *);
+static void blkiocg_attach(struct cgroup *, struct cgroup_taskset *);
+static void blkiocg_destroy(struct cgroup *);
 static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
 
 /* for encoding cft->private value on file */
@@ -1548,7 +1545,7 @@ static int blkiocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
 				ARRAY_SIZE(blkio_files));
 }
 
-static void blkiocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+static void blkiocg_destroy(struct cgroup *cgroup)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
 	unsigned long flags;
@@ -1598,8 +1595,7 @@ static void blkiocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
 		kfree(blkcg);
 }
 
-static struct cgroup_subsys_state *
-blkiocg_create(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+static struct cgroup_subsys_state *blkiocg_create(struct cgroup *cgroup)
 {
 	struct blkio_cgroup *blkcg;
 	struct cgroup *parent = cgroup->parent;
@@ -1628,8 +1624,7 @@ done:
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkiocg_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			      struct cgroup_taskset *tset)
+static int blkiocg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 	struct io_context *ioc;
@@ -1648,8 +1643,7 @@ static int blkiocg_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	return ret;
 }
 
-static void blkiocg_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			   struct cgroup_taskset *tset)
+static void blkiocg_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 	struct io_context *ioc;
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 7da3e74..501adb1 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -452,23 +452,18 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
  */
 
 struct cgroup_subsys {
-	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
-						  struct cgroup *cgrp);
-	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
-	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
-	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			  struct cgroup_taskset *tset);
-	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			      struct cgroup_taskset *tset);
-	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		       struct cgroup_taskset *tset);
-	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
-	void (*exit)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			struct cgroup *old_cgrp, struct task_struct *task);
-	int (*populate)(struct cgroup_subsys *ss,
-			struct cgroup *cgrp);
-	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
-	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
+	struct cgroup_subsys_state *(*create)(struct cgroup *cgrp);
+	int (*pre_destroy)(struct cgroup *cgrp);
+	void (*destroy)(struct cgroup *cgrp);
+	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
+	void (*cancel_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
+	void (*attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
+	void (*fork)(struct task_struct *task);
+	void (*exit)(struct cgroup *cgrp, struct cgroup *old_cgrp,
+		     struct task_struct *task);
+	int (*populate)(struct cgroup_subsys *ss, struct cgroup *cgrp);
+	void (*post_clone)(struct cgroup *cgrp);
+	void (*bind)(struct cgroup *root);
 
 	int subsys_id;
 	int active;
diff --git a/include/net/sock.h b/include/net/sock.h
index bb972d2..705d1ad 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -68,7 +68,7 @@ struct cgroup;
 struct cgroup_subsys;
 #ifdef CONFIG_NET
 int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss);
-void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss);
+void mem_cgroup_sockets_destroy(struct cgroup *cgrp);
 #else
 static inline
 int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
@@ -76,7 +76,7 @@ int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	return 0;
 }
 static inline
-void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss)
+void mem_cgroup_sockets_destroy(struct cgroup *cgrp)
 {
 }
 #endif
@@ -869,8 +869,7 @@ struct proto {
 	 */
 	int			(*init_cgroup)(struct cgroup *cgrp,
 					       struct cgroup_subsys *ss);
-	void			(*destroy_cgroup)(struct cgroup *cgrp,
-						  struct cgroup_subsys *ss);
+	void			(*destroy_cgroup)(struct cgroup *cgrp);
 	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
 #endif
 };
diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 3512082..48410ff 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -13,7 +13,7 @@ struct tcp_memcontrol {
 
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
-void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
+void tcp_destroy_cgroup(struct cgroup *cgrp);
 unsigned long long tcp_max_memory(const struct mem_cgroup *memcg);
 void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx);
 #endif /* _TCP_MEMCG_H */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 43a224f..865d89a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -818,7 +818,7 @@ static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 
 	for_each_subsys(cgrp->root, ss)
 		if (ss->pre_destroy) {
-			ret = ss->pre_destroy(ss, cgrp);
+			ret = ss->pre_destroy(cgrp);
 			if (ret)
 				break;
 		}
@@ -846,7 +846,7 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 		 * Release the subsystem state objects.
 		 */
 		for_each_subsys(cgrp->root, ss)
-			ss->destroy(ss, cgrp);
+			ss->destroy(cgrp);
 
 		cgrp->root->number_of_cgroups--;
 		mutex_unlock(&cgroup_mutex);
@@ -1015,7 +1015,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
-				ss->bind(ss, cgrp);
+				ss->bind(cgrp);
 			mutex_unlock(&ss->hierarchy_mutex);
 			/* refcount was already taken, and we're keeping it */
 		} else if (bit & removed_bits) {
@@ -1025,7 +1025,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 			mutex_lock(&ss->hierarchy_mutex);
 			if (ss->bind)
-				ss->bind(ss, dummytop);
+				ss->bind(dummytop);
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
 			subsys[i]->root = &rootnode;
@@ -1908,7 +1908,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, &tset);
+			retval = ss->can_attach(cgrp, &tset);
 			if (retval) {
 				/*
 				 * Remember on which subsystem the can_attach()
@@ -1932,7 +1932,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 
 	for_each_subsys(root, ss) {
 		if (ss->attach)
-			ss->attach(ss, cgrp, &tset);
+			ss->attach(cgrp, &tset);
 	}
 
 	synchronize_rcu();
@@ -1954,7 +1954,7 @@ out:
 				 */
 				break;
 			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, &tset);
+				ss->cancel_attach(cgrp, &tset);
 		}
 	}
 	return retval;
@@ -2067,7 +2067,7 @@ static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, &tset);
+			retval = ss->can_attach(cgrp, &tset);
 			if (retval) {
 				failed_ss = ss;
 				goto out_cancel_attach;
@@ -2104,7 +2104,7 @@ static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->attach)
-			ss->attach(ss, cgrp, &tset);
+			ss->attach(cgrp, &tset);
 	}
 
 	/*
@@ -2128,7 +2128,7 @@ out_cancel_attach:
 			if (ss == failed_ss)
 				break;
 			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, &tset);
+				ss->cancel_attach(cgrp, &tset);
 		}
 	}
 out_free_group_list:
@@ -3756,7 +3756,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
 
 	for_each_subsys(root, ss) {
-		struct cgroup_subsys_state *css = ss->create(ss, cgrp);
+		struct cgroup_subsys_state *css = ss->create(cgrp);
 
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
@@ -3770,7 +3770,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		}
 		/* At error, ->destroy() callback has to free assigned ID. */
 		if (clone_children(parent) && ss->post_clone)
-			ss->post_clone(ss, cgrp);
+			ss->post_clone(cgrp);
 	}
 
 	cgroup_lock_hierarchy(root);
@@ -3804,7 +3804,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	for_each_subsys(root, ss) {
 		if (cgrp->subsys[ss->subsys_id])
-			ss->destroy(ss, cgrp);
+			ss->destroy(cgrp);
 	}
 
 	mutex_unlock(&cgroup_mutex);
@@ -4028,7 +4028,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &rootnode.subsys_list);
 	ss->root = &rootnode;
-	css = ss->create(ss, dummytop);
+	css = ss->create(dummytop);
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
 	init_cgroup_css(css, ss, dummytop);
@@ -4117,7 +4117,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 * no ss->create seems to need anything important in the ss struct, so
 	 * this can happen first (i.e. before the rootnode attachment).
 	 */
-	css = ss->create(ss, dummytop);
+	css = ss->create(dummytop);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the subsys[] slot. */
 		subsys[i] = NULL;
@@ -4135,7 +4135,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		int ret = cgroup_init_idr(ss, css);
 		if (ret) {
 			dummytop->subsys[ss->subsys_id] = NULL;
-			ss->destroy(ss, dummytop);
+			ss->destroy(dummytop);
 			subsys[i] = NULL;
 			mutex_unlock(&cgroup_mutex);
 			return ret;
@@ -4233,7 +4233,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * pointer to find their state. note that this also takes care of
 	 * freeing the css_id.
 	 */
-	ss->destroy(ss, dummytop);
+	ss->destroy(dummytop);
 	dummytop->subsys[ss->subsys_id] = NULL;
 
 	mutex_unlock(&cgroup_mutex);
@@ -4509,7 +4509,7 @@ void cgroup_fork_callbacks(struct task_struct *child)
 		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 			if (ss->fork)
-				ss->fork(ss, child);
+				ss->fork(child);
 		}
 	}
 }
@@ -4611,7 +4611,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 				struct cgroup *old_cgrp =
 					rcu_dereference_raw(cg->subsys[i])->cgroup;
 				struct cgroup *cgrp = task_cgroup(tsk, i);
-				ss->exit(ss, cgrp, old_cgrp, tsk);
+				ss->exit(cgrp, old_cgrp, tsk);
 			}
 		}
 	}
@@ -5066,8 +5066,7 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
-static struct cgroup_subsys_state *debug_create(struct cgroup_subsys *ss,
-						   struct cgroup *cont)
+static struct cgroup_subsys_state *debug_create(struct cgroup *cont)
 {
 	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
 
@@ -5077,7 +5076,7 @@ static struct cgroup_subsys_state *debug_create(struct cgroup_subsys *ss,
 	return css;
 }
 
-static void debug_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+static void debug_destroy(struct cgroup *cont)
 {
 	kfree(cont->subsys[debug_subsys_id]);
 }
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index fc0646b..f86e939 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -128,8 +128,7 @@ struct cgroup_subsys freezer_subsys;
  *    task->alloc_lock (inside __thaw_task(), prevents race with refrigerator())
  *     sighand->siglock
  */
-static struct cgroup_subsys_state *freezer_create(struct cgroup_subsys *ss,
-						  struct cgroup *cgroup)
+static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
 {
 	struct freezer *freezer;
 
@@ -142,8 +141,7 @@ static struct cgroup_subsys_state *freezer_create(struct cgroup_subsys *ss,
 	return &freezer->css;
 }
 
-static void freezer_destroy(struct cgroup_subsys *ss,
-			    struct cgroup *cgroup)
+static void freezer_destroy(struct cgroup *cgroup)
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
 
@@ -164,8 +162,7 @@ static bool is_task_frozen_enough(struct task_struct *task)
  * a write to that file racing against an attach, and hence the
  * can_attach() result will remain valid until the attach completes.
  */
-static int freezer_can_attach(struct cgroup_subsys *ss,
-			      struct cgroup *new_cgroup,
+static int freezer_can_attach(struct cgroup *new_cgroup,
 			      struct cgroup_taskset *tset)
 {
 	struct freezer *freezer;
@@ -185,7 +182,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	return 0;
 }
 
-static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
+static void freezer_fork(struct task_struct *task)
 {
 	struct freezer *freezer;
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index a09ac2b..5d57583 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1399,8 +1399,7 @@ static nodemask_t cpuset_attach_nodemask_from;
 static nodemask_t cpuset_attach_nodemask_to;
 
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
-static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			     struct cgroup_taskset *tset)
+static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct task_struct *task;
@@ -1436,8 +1435,7 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	return 0;
 }
 
-static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			  struct cgroup_taskset *tset)
+static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct mm_struct *mm;
 	struct task_struct *task;
@@ -1833,8 +1831,7 @@ static int cpuset_populate(struct cgroup_subsys *ss, struct cgroup *cont)
  * (and likewise for mems) to the new cgroup. Called with cgroup_mutex
  * held.
  */
-static void cpuset_post_clone(struct cgroup_subsys *ss,
-			      struct cgroup *cgroup)
+static void cpuset_post_clone(struct cgroup *cgroup)
 {
 	struct cgroup *parent, *child;
 	struct cpuset *cs, *parent_cs;
@@ -1857,13 +1854,10 @@ static void cpuset_post_clone(struct cgroup_subsys *ss,
 
 /*
  *	cpuset_create - create a cpuset
- *	ss:	cpuset cgroup subsystem
  *	cont:	control group that the new cpuset will be part of
  */
 
-static struct cgroup_subsys_state *cpuset_create(
-	struct cgroup_subsys *ss,
-	struct cgroup *cont)
+static struct cgroup_subsys_state *cpuset_create(struct cgroup *cont)
 {
 	struct cpuset *cs;
 	struct cpuset *parent;
@@ -1902,7 +1896,7 @@ static struct cgroup_subsys_state *cpuset_create(
  * will call async_rebuild_sched_domains().
  */
 
-static void cpuset_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+static void cpuset_destroy(struct cgroup *cont)
 {
 	struct cpuset *cs = cgroup_cs(cont);
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index a8f4ac0..a5d1ee9 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6906,8 +6906,7 @@ unlock:
 device_initcall(perf_event_sysfs_init);
 
 #ifdef CONFIG_CGROUP_PERF
-static struct cgroup_subsys_state *perf_cgroup_create(
-	struct cgroup_subsys *ss, struct cgroup *cont)
+static struct cgroup_subsys_state *perf_cgroup_create(struct cgroup *cont)
 {
 	struct perf_cgroup *jc;
 
@@ -6924,8 +6923,7 @@ static struct cgroup_subsys_state *perf_cgroup_create(
 	return &jc->css;
 }
 
-static void perf_cgroup_destroy(struct cgroup_subsys *ss,
-				struct cgroup *cont)
+static void perf_cgroup_destroy(struct cgroup *cont)
 {
 	struct perf_cgroup *jc;
 	jc = container_of(cgroup_subsys_state(cont, perf_subsys_id),
@@ -6941,8 +6939,7 @@ static int __perf_cgroup_move(void *info)
 	return 0;
 }
 
-static void perf_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			       struct cgroup_taskset *tset)
+static void perf_cgroup_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 
@@ -6950,8 +6947,8 @@ static void perf_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		task_function_call(task, __perf_cgroup_move, task);
 }
 
-static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		struct cgroup *old_cgrp, struct task_struct *task)
+static void perf_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
+			     struct task_struct *task)
 {
 	/*
 	 * cgroup_exit() is called in the copy_process() failure path.
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index df00cb0..ff12f72 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7530,8 +7530,7 @@ static inline struct task_group *cgroup_tg(struct cgroup *cgrp)
 			    struct task_group, css);
 }
 
-static struct cgroup_subsys_state *
-cpu_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static struct cgroup_subsys_state *cpu_cgroup_create(struct cgroup *cgrp)
 {
 	struct task_group *tg, *parent;
 
@@ -7548,15 +7547,14 @@ cpu_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return &tg->css;
 }
 
-static void
-cpu_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static void cpu_cgroup_destroy(struct cgroup *cgrp)
 {
 	struct task_group *tg = cgroup_tg(cgrp);
 
 	sched_destroy_group(tg);
 }
 
-static int cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+static int cpu_cgroup_can_attach(struct cgroup *cgrp,
 				 struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
@@ -7574,7 +7572,7 @@ static int cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	return 0;
 }
 
-static void cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+static void cpu_cgroup_attach(struct cgroup *cgrp,
 			      struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
@@ -7584,8 +7582,8 @@ static void cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 }
 
 static void
-cpu_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		struct cgroup *old_cgrp, struct task_struct *task)
+cpu_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
+		struct task_struct *task)
 {
 	/*
 	 * cgroup_exit() is called in the copy_process() failure path.
@@ -7935,8 +7933,7 @@ struct cgroup_subsys cpu_cgroup_subsys = {
  */
 
 /* create a new cpu accounting group */
-static struct cgroup_subsys_state *cpuacct_create(
-	struct cgroup_subsys *ss, struct cgroup *cgrp)
+static struct cgroup_subsys_state *cpuacct_create(struct cgroup *cgrp)
 {
 	struct cpuacct *ca;
 
@@ -7966,8 +7963,7 @@ out:
 }
 
 /* destroy an existing cpu accounting group */
-static void
-cpuacct_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static void cpuacct_destroy(struct cgroup *cgrp)
 {
 	struct cpuacct *ca = cgroup_ca(cgrp);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3dbff4d..ae2f0a8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4580,10 +4580,9 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
 	return mem_cgroup_sockets_init(cont, ss);
 };
 
-static void kmem_cgroup_destroy(struct cgroup_subsys *ss,
-				struct cgroup *cont)
+static void kmem_cgroup_destroy(struct cgroup *cont)
 {
-	mem_cgroup_sockets_destroy(cont, ss);
+	mem_cgroup_sockets_destroy(cont);
 }
 #else
 static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
@@ -4591,8 +4590,7 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
 	return 0;
 }
 
-static void kmem_cgroup_destroy(struct cgroup_subsys *ss,
-				struct cgroup *cont)
+static void kmem_cgroup_destroy(struct cgroup *cont)
 {
 }
 #endif
@@ -4884,7 +4882,7 @@ err_cleanup:
 }
 
 static struct cgroup_subsys_state * __ref
-mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
+mem_cgroup_create(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg, *parent;
 	long error = -ENOMEM;
@@ -4946,20 +4944,18 @@ free_out:
 	return ERR_PTR(error);
 }
 
-static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
-					struct cgroup *cont)
+static int mem_cgroup_pre_destroy(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
 	return mem_cgroup_force_empty(memcg, false);
 }
 
-static void mem_cgroup_destroy(struct cgroup_subsys *ss,
-				struct cgroup *cont)
+static void mem_cgroup_destroy(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	kmem_cgroup_destroy(ss, cont);
+	kmem_cgroup_destroy(cont);
 
 	mem_cgroup_put(memcg);
 }
@@ -5296,9 +5292,8 @@ static void mem_cgroup_clear_mc(void)
 	mem_cgroup_end_move(from);
 }
 
-static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
-				struct cgroup *cgroup,
-				struct cgroup_taskset *tset)
+static int mem_cgroup_can_attach(struct cgroup *cgroup,
+				 struct cgroup_taskset *tset)
 {
 	struct task_struct *p = cgroup_taskset_first(tset);
 	int ret = 0;
@@ -5336,9 +5331,8 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 	return ret;
 }
 
-static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
-				struct cgroup *cgroup,
-				struct cgroup_taskset *tset)
+static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
+				     struct cgroup_taskset *tset)
 {
 	mem_cgroup_clear_mc();
 }
@@ -5453,9 +5447,8 @@ retry:
 	up_read(&mm->mmap_sem);
 }
 
-static void mem_cgroup_move_task(struct cgroup_subsys *ss,
-				struct cgroup *cont,
-				struct cgroup_taskset *tset)
+static void mem_cgroup_move_task(struct cgroup *cont,
+				 struct cgroup_taskset *tset)
 {
 	struct task_struct *p = cgroup_taskset_first(tset);
 	struct mm_struct *mm = get_task_mm(p);
@@ -5470,20 +5463,17 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 		mem_cgroup_clear_mc();
 }
 #else	/* !CONFIG_MMU */
-static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
-				struct cgroup *cgroup,
-				struct cgroup_taskset *tset)
+static int mem_cgroup_can_attach(struct cgroup *cgroup,
+				 struct cgroup_taskset *tset)
 {
 	return 0;
 }
-static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
-				struct cgroup *cgroup,
-				struct cgroup_taskset *tset)
+static void mem_cgroup_cancel_attach(struct cgroup *cgroup,
+				     struct cgroup_taskset *tset)
 {
 }
-static void mem_cgroup_move_task(struct cgroup_subsys *ss,
-				struct cgroup *cont,
-				struct cgroup_taskset *tset)
+static void mem_cgroup_move_task(struct cgroup *cont,
+				 struct cgroup_taskset *tset)
 {
 }
 #endif
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 3a9fd48..22036ab 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -23,9 +23,8 @@
 #include <net/sock.h>
 #include <net/netprio_cgroup.h>
 
-static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
-					       struct cgroup *cgrp);
-static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp);
+static void cgrp_destroy(struct cgroup *cgrp);
 static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
 
 struct cgroup_subsys net_prio_subsys = {
@@ -120,8 +119,7 @@ static void update_netdev_tables(void)
 	rtnl_unlock();
 }
 
-static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
-						 struct cgroup *cgrp)
+static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
 	int ret;
@@ -145,7 +143,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 	return &cs->css;
 }
 
-static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static void cgrp_destroy(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
 	struct net_device *dev;
diff --git a/net/core/sock.c b/net/core/sock.c
index 5c5af998..688037c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -160,19 +160,19 @@ int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
 out:
 	list_for_each_entry_continue_reverse(proto, &proto_list, node)
 		if (proto->destroy_cgroup)
-			proto->destroy_cgroup(cgrp, ss);
+			proto->destroy_cgroup(cgrp);
 	mutex_unlock(&proto_list_mutex);
 	return ret;
 }
 
-void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss)
+void mem_cgroup_sockets_destroy(struct cgroup *cgrp)
 {
 	struct proto *proto;
 
 	mutex_lock(&proto_list_mutex);
 	list_for_each_entry_reverse(proto, &proto_list, node)
 		if (proto->destroy_cgroup)
-			proto->destroy_cgroup(cgrp, ss);
+			proto->destroy_cgroup(cgrp);
 	mutex_unlock(&proto_list_mutex);
 }
 #endif
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 4997878..e714c68 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -94,7 +94,7 @@ create_files:
 }
 EXPORT_SYMBOL(tcp_init_cgroup);
 
-void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+void tcp_destroy_cgroup(struct cgroup *cgrp)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct cg_proto *cg_proto;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index f84fdc3..1afaa28 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -22,9 +22,8 @@
 #include <net/sock.h>
 #include <net/cls_cgroup.h>
 
-static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
-					       struct cgroup *cgrp);
-static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp);
+static void cgrp_destroy(struct cgroup *cgrp);
 static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
 
 struct cgroup_subsys net_cls_subsys = {
@@ -51,8 +50,7 @@ static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
 			    struct cgroup_cls_state, css);
 }
 
-static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
-						 struct cgroup *cgrp)
+static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 {
 	struct cgroup_cls_state *cs;
 
@@ -66,7 +64,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 	return &cs->css;
 }
 
-static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+static void cgrp_destroy(struct cgroup *cgrp)
 {
 	kfree(cgrp_cls_state(cgrp));
 }
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 8b5b5d8..c43a332 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -61,8 +61,8 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 
 struct cgroup_subsys devices_subsys;
 
-static int devcgroup_can_attach(struct cgroup_subsys *ss,
-			struct cgroup *new_cgrp, struct cgroup_taskset *set)
+static int devcgroup_can_attach(struct cgroup *new_cgrp,
+				struct cgroup_taskset *set)
 {
 	struct task_struct *task = cgroup_taskset_first(set);
 
@@ -156,8 +156,7 @@ remove:
 /*
  * called from kernel/cgroup.c with cgroup_lock() held.
  */
-static struct cgroup_subsys_state *devcgroup_create(struct cgroup_subsys *ss,
-						struct cgroup *cgroup)
+static struct cgroup_subsys_state *devcgroup_create(struct cgroup *cgroup)
 {
 	struct dev_cgroup *dev_cgroup, *parent_dev_cgroup;
 	struct cgroup *parent_cgroup;
@@ -195,8 +194,7 @@ static struct cgroup_subsys_state *devcgroup_create(struct cgroup_subsys *ss,
 	return &dev_cgroup->css;
 }
 
-static void devcgroup_destroy(struct cgroup_subsys *ss,
-			struct cgroup *cgroup)
+static void devcgroup_destroy(struct cgroup *cgroup)
 {
 	struct dev_cgroup *dev_cgroup;
 	struct dev_whitelist_item *wh, *tmp;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
