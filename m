Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id CD7C46B0032
	for <linux-mm@kvack.org>; Sat, 10 Jan 2015 16:43:21 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id r5so13853396qcx.2
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 13:43:21 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id ep4si17231848qcb.44.2015.01.10.13.43.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 Jan 2015 13:43:20 -0800 (PST)
Received: by mail-qg0-f47.google.com with SMTP id q108so13502941qgd.6
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 13:43:20 -0800 (PST)
Date: Sat, 10 Jan 2015 16:43:16 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150110214316.GF25319@htj.dyndns.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150110085525.GD2110@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

Currently, if a hierarchy doesn't have any live children when it's
unmounted, the hierarchy starts dying by killing its refcnt.  The
expectation is that even if there are lingering dead children which
are lingering due to remaining references, they'll be put in a finite
amount of time.  When the children are finally released, the hierarchy
is destroyed and all controllers bound to it also are released.

However, for memcg, the premise that the lingering refs will be put in
a finite amount time is not true.  In the absense of memory pressure,
dead memcg's may hang around indefinitely pinned by its pages.  This
unfortunately may lead to indefinite hang on the next mount attempt
involving memcg as the mount logic waits for it to get released.

While we can change hierarchy destruction logic such that a hierarchy
is only destroyed when it's not mounted anywhere and all its children,
live or dead, are gone, this makes whether the hierarchy gets
destroyed or not to be determined by factors opaque to userland.
Userland may or may not get a new hierarchy on the next mount attempt.
Worse, if it explicitly wants to create a new hierarchy with different
options or controller compositions involving memcg, it will fail in an
essentially arbitrary manner.

We want to guarantee that a hierarchy is destroyed once the
conditions, unmounted and no visible children, are met.  To aid it,
this patch introduces a new callback cgroup_subsys->unbind() which is
invoked right before the hierarchy a subsystem is bound to starts
dying.  memcg can implement this callback and initiate draining of
remaining refs so that the hierarchy can eventually be released in a
finite amount of time.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>
---
Hello,

> May be, we should kill the ref counter to the memory controller root in
> cgroup_kill_sb only if there is no children at all, neither online nor
> offline.

Ah, thanks for the analysis, but I really wanna avoid making hierarchy
destruction conditions opaque to userland.  This is userland visible
behavior.  It shouldn't be determined by kernel internals invisible
outside.  This patch adds ss->unbind() which memcg can hook into to
kick off draining of residual refs.  If this would work, I'll add this
patch to cgroup/for-3.19-fixes, possibly with stable cc'd.

Thanks.

 Documentation/cgroups/cgroups.txt |   12 +++++++++++-
 include/linux/cgroup.h            |    1 +
 kernel/cgroup.c                   |   14 ++++++++++++--
 3 files changed, 24 insertions(+), 3 deletions(-)

--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -637,7 +637,7 @@ void exit(struct task_struct *task)
 
 Called during task exit.
 
-void bind(struct cgroup *root)
+void bind(struct cgroup_subsys_state *root_css)
 (cgroup_mutex held by caller)
 
 Called when a cgroup subsystem is rebound to a different hierarchy
@@ -645,6 +645,16 @@ and root cgroup. Currently this will onl
 the default hierarchy (which never has sub-cgroups) and a hierarchy
 that is being created/destroyed (and hence has no sub-cgroups).
 
+void unbind(struct cgroup_subsys_state *root_css)
+(cgroup_mutex held by caller)
+
+Called when a cgroup subsys is unbound from its current hierarchy. The
+subsystem must guarantee that all offline cgroups are going to be
+released in a finite amount of time after this function is called.
+Such draining can be asynchronous. The following binding of the
+subsystem to a hierarchy will be delayed till the draining is
+complete.
+
 4. Extended attribute usage
 ===========================
 
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -654,6 +654,7 @@ struct cgroup_subsys {
 		     struct cgroup_subsys_state *old_css,
 		     struct task_struct *task);
 	void (*bind)(struct cgroup_subsys_state *root_css);
+	void (*unbind)(struct cgroup_subsys_state *root_css);
 
 	int disabled;
 	int early_init;
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1910,10 +1910,20 @@ static void cgroup_kill_sb(struct super_
 	 * And don't kill the default root.
 	 */
 	if (css_has_online_children(&root->cgrp.self) ||
-	    root == &cgrp_dfl_root)
+	    root == &cgrp_dfl_root) {
 		cgroup_put(&root->cgrp);
-	else
+	} else {
+		struct cgroup_subsys *ss;
+		int i;
+
+		mutex_lock(&cgroup_mutex);
+		for_each_subsys(ss, i)
+			if ((root->subsys_mask & (1UL << i)) && ss->unbind)
+				ss->unbind(cgroup_css(&root->cgrp, ss));
+		mutex_unlock(&cgroup_mutex);
+
 		percpu_ref_kill(&root->cgrp.self.refcnt);
+	}
 
 	kernfs_kill_sb(sb);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
