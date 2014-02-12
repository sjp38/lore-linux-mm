Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3CD6B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:07:44 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so9861694pad.25
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 15:07:43 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xk2si24083515pab.216.2014.02.12.15.07.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 15:07:13 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so9792602pab.5
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 15:07:13 -0800 (PST)
Date: Wed, 12 Feb 2014 15:06:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/2] cgroup: bring back kill_cnt to order css destruction
In-Reply-To: <alpine.LSU.2.11.1402121417230.5029@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1402121504150.5029@eggly.anvils>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils> <20140207164321.GE6963@cmpxchg.org> <alpine.LSU.2.11.1402121417230.5029@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Sometimes the cleanup after memcg hierarchy testing gets stuck in
mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.

There may turn out to be several causes, but a major cause is this: the
workitem to offline parent can get run before workitem to offline child;
parent's mem_cgroup_reparent_charges() circles around waiting for the
child's pages to be reparented to its lrus, but it's holding cgroup_mutex
which prevents the child from reaching its mem_cgroup_reparent_charges().

Further testing showed that an ordered workqueue for cgroup_destroy_wq
is not always good enough: percpu_ref_kill_and_confirm's call_rcu_sched
stage on the way can mess up the order before reaching the workqueue.

Instead bring back v3.11's css kill_cnt, repurposing it to make sure
that offline_css() is not called for parent before it has been called
for all children.

Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup destruction")
Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Filipe Brandenburger <filbranden@google.com>
Cc: stable@vger.kernel.org # v3.10+ (but will need extra care)
---
This is an alternative to Filipe's 1/2: there's no need for both,
but each has its merits.  I prefer Filipe's, which is much easier to
understand: this one made more sense in v3.11, when it was just a matter
of extending the use of css_kill_cnt; but might be preferred if offlining
children before parent is thought to be a good idea generally.

 include/linux/cgroup.h |    3 +++
 kernel/cgroup.c        |   21 +++++++++++++++++++++
 2 files changed, 24 insertions(+)

--- 3.14-rc2/include/linux/cgroup.h	2014-02-02 18:49:07.033302094 -0800
+++ linux/include/linux/cgroup.h	2014-02-11 15:59:22.720393186 -0800
@@ -79,6 +79,9 @@ struct cgroup_subsys_state {
 
 	unsigned long flags;
 
+	/* ensure children are offlined before parent */
+	atomic_t kill_cnt;
+
 	/* percpu_ref killing and RCU release */
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
--- 3.14-rc2/kernel/cgroup.c	2014-02-02 18:49:07.737302111 -0800
+++ linux/kernel/cgroup.c	2014-02-11 15:57:56.000391125 -0800
@@ -175,6 +175,7 @@ static int need_forkexit_callback __read
 
 static struct cftype cgroup_base_files[];
 
+static void css_killed_ref_fn(struct percpu_ref *ref);
 static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
@@ -4043,6 +4044,7 @@ static void init_css(struct cgroup_subsy
 	css->cgroup = cgrp;
 	css->ss = ss;
 	css->flags = 0;
+	atomic_set(&css->kill_cnt, 1);
 
 	if (cgrp->parent)
 		css->parent = cgroup_css(cgrp->parent, ss);
@@ -4292,6 +4294,7 @@ static void css_killed_work_fn(struct wo
 {
 	struct cgroup_subsys_state *css =
 		container_of(work, struct cgroup_subsys_state, destroy_work);
+	struct cgroup_subsys_state *parent = css->parent;
 	struct cgroup *cgrp = css->cgroup;
 
 	mutex_lock(&cgroup_mutex);
@@ -4320,6 +4323,12 @@ static void css_killed_work_fn(struct wo
 	 * destruction happens only after all css's are released.
 	 */
 	css_put(css);
+
+	/*
+	 * Put the parent's kill_cnt reference from kill_css(), and
+	 * schedule its ->css_offline() if all children are now offline.
+	 */
+	css_killed_ref_fn(&parent->refcnt);
 }
 
 /* css kill confirmation processing requires process context, bounce */
@@ -4328,6 +4337,9 @@ static void css_killed_ref_fn(struct per
 	struct cgroup_subsys_state *css =
 		container_of(ref, struct cgroup_subsys_state, refcnt);
 
+	if (!atomic_dec_and_test(&css->kill_cnt))
+		return;
+
 	INIT_WORK(&css->destroy_work, css_killed_work_fn);
 	queue_work(cgroup_destroy_wq, &css->destroy_work);
 }
@@ -4362,6 +4374,15 @@ static void kill_css(struct cgroup_subsy
 	 * css is confirmed to be seen as killed on all CPUs.
 	 */
 	percpu_ref_kill_and_confirm(&css->refcnt, css_killed_ref_fn);
+
+	/*
+	 * Make sure that ->css_offline() will not be called for parent
+	 * before it has been called for all children: this ordering
+	 * requirement is important for memcg, where parent's offline
+	 * might wait for a child's, leading to deadlock.
+	 */
+	atomic_inc(&css->parent->kill_cnt);
+	css_killed_ref_fn(&css->refcnt);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
