Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B28EC6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 21:31:36 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o7P1Z9Qe024255
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 18:35:18 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by kpbe16.cbf.corp.google.com with ESMTP id o7P1Z0Me025257
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 18:35:01 -0700
Received: by pwj3 with SMTP id 3so115101pwj.36
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 18:35:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100825100310.ba3fd27e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
	<20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=KW_gxbmB14j5opSKL+-JFDFKO1YP6a7yvT8U5@mail.gmail.com>
	<20100825100310.ba3fd27e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 18:35:00 -0700
Message-ID: <AANLkTikuJ9x1u+GC_ox448Fp9wdJ2_GJyu6kNwjOJ9Y=@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 6:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm. How this pseudo code looks like ? This passes "new id" via
> cgroup->subsys[array] at creation. (Using union will be better, maybe).
>

That's rather ugly. I was thinking of something more like this. (Not
even compiled yet, and the only subsystem updated is cpuset).

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ed3e92e..063d9f2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -458,8 +458,7 @@ void cgroup_release_and_wakeup_rmdir(struct
cgroup_subsys_state *css);
  */

 struct cgroup_subsys {
-	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
-						  struct cgroup *cgrp);
+	int (*create)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
@@ -513,6 +512,12 @@ struct cgroup_subsys {

 	/* should be defined only by modular subsystems */
 	struct module *module;
+
+	/* Total size of the subsystem's CSS object */
+	size_t css_size;
+
+	/* If non-NULL, the CSS to use for the root cgroup */
+	struct cgroup_subsys_state *root_css;
 };

 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 192f88c..c589a41 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3307,6 +3307,7 @@ static long cgroup_create(struct cgroup *parent,
struct dentry *dentry,
 			     mode_t mode)
 {
 	struct cgroup *cgrp;
+	struct cgroup_subsys_state *new_css[CGROUP_SUBSYS_COUNT] = {};
 	struct cgroupfs_root *root = parent->root;
 	int err = 0;
 	struct cgroup_subsys *ss;
@@ -3325,6 +3326,16 @@ static long cgroup_create(struct cgroup
*parent, struct dentry *dentry,

 	mutex_lock(&cgroup_mutex);

+	for_each_subsys(root, ss) {
+		int id = ss->subsys_id;
+		new_css[id] = kzalloc(ss->css_size, GFP_KERNEL);
+		if (!new_css) {
+			/* Failed to allocate memory */
+			err = -ENOMEM;
+			goto err_destroy;
+		}
+	}
+
 	init_cgroup_housekeeping(cgrp);

 	cgrp->parent = parent;
@@ -3335,19 +3346,19 @@ static long cgroup_create(struct cgroup
*parent, struct dentry *dentry,
 		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);

 	for_each_subsys(root, ss) {
-		struct cgroup_subsys_state *css = ss->create(ss, cgrp);
-
-		if (IS_ERR(css)) {
-			err = PTR_ERR(css);
-			goto err_destroy;
-		}
-		init_cgroup_css(css, ss, cgrp);
+		int id = ss->subsys_id;
+		init_cgroup_css(new_css[id], ss, cgrp);
 		if (ss->use_id) {
 			err = alloc_css_id(ss, parent, cgrp);
 			if (err)
 				goto err_destroy;
 		}
-		/* At error, ->destroy() callback has to free assigned ID. */
+		err = ss->create(ss, cgrp);
+		if (err) {
+			free_css_id(ss, css->id);
+			goto err_destroy;
+		}
+		new_css[id] = NULL;
 	}

 	cgroup_lock_hierarchy(root);
@@ -3380,7 +3391,10 @@ static long cgroup_create(struct cgroup
*parent, struct dentry *dentry,
  err_destroy:

 	for_each_subsys(root, ss) {
-		if (cgrp->subsys[ss->subsys_id])
+		int id = ss->subsys_id;
+		if (new_css[id])
+			kfree(new_css[id]);
+		else if (cgrp->subsys[id])
 			ss->destroy(ss, cgrp);
 	}

@@ -3607,11 +3621,16 @@ static void __init cgroup_init_subsys(struct
cgroup_subsys *ss)
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &rootnode.subsys_list);
 	ss->root = &rootnode;
-	css = ss->create(ss, dummytop);
+	if (ss->root_css)
+		css = ss->root_css;
+	else
+		css = kzalloc(ss->css_size, GFP_KERNEL);
 	/* We don't handle early failures gracefully */
-	BUG_ON(IS_ERR(css));
+	BUG_ON(!css);
 	init_cgroup_css(css, ss, dummytop);

+	BUG_ON(ss->create(ss, dummytop));
+
 	/* Update the init_css_set to contain a subsys
 	 * pointer to this state - since the subsystem is
 	 * newly registered, all tasks and hence the
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index b23c097..7720a79 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1871,24 +1871,12 @@ static void cpuset_post_clone(struct cgroup_subsys *ss,
  *	cont:	control group that the new cpuset will be part of
  */

-static struct cgroup_subsys_state *cpuset_create(
-	struct cgroup_subsys *ss,
-	struct cgroup *cont)
+static int cpuset_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct cpuset *cs;
-	struct cpuset *parent;
-
-	if (!cont->parent) {
-		return &top_cpuset.css;
-	}
-	parent = cgroup_cs(cont->parent);
-	cs = kmalloc(sizeof(*cs), GFP_KERNEL);
-	if (!cs)
-		return ERR_PTR(-ENOMEM);
-	if (!alloc_cpumask_var(&cs->cpus_allowed, GFP_KERNEL)) {
-		kfree(cs);
-		return ERR_PTR(-ENOMEM);
-	}
+	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *parent = cgroup_cs(cont->parent);
+	if (!alloc_cpumask_var(&cs->cpus_allowed, GFP_KERNEL))
+		return -ENOMEM;

 	cs->flags = 0;
 	if (is_spread_page(parent))
@@ -1903,7 +1891,7 @@ static struct cgroup_subsys_state *cpuset_create(

 	cs->parent = parent;
 	number_of_cpusets++;
-	return &cs->css ;
+	return 0;
 }

 /*
@@ -1934,6 +1922,8 @@ struct cgroup_subsys cpuset_subsys = {
 	.post_clone = cpuset_post_clone,
 	.subsys_id = cpuset_subsys_id,
 	.early_init = 1,
+	.css_size = sizeof(struct cpuset),
+	.root_css = &top_cpuset.css;
 };

 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
