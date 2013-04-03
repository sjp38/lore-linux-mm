Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C69706B00CC
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:13:30 -0400 (EDT)
Message-ID: <515BF2A4.1070703@huawei.com>
Date: Wed, 3 Apr 2013 17:13:08 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 5/7] cgroup: make sure parent won't be destroyed before
 its children
References: <515BF233.6070308@huawei.com>
In-Reply-To: <515BF233.6070308@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Suppose we rmdir a cgroup and there're still css refs, this cgroup won't
be freed. Then we rmdir the parent cgroup, and the parent is freed due
to css ref draining to 0. Now it would be a disaster if the child cgroup
tries to access its parent.

Make sure this won't happen.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 kernel/cgroup.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fa54b92..78204bc 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -888,6 +888,13 @@ static void cgroup_free_fn(struct work_struct *work)
 	mutex_unlock(&cgroup_mutex);
 
 	/*
+	 * We get a ref to the parent's dentry, and put the ref when
+	 * this cgroup is being freed, so it's guaranteed that the
+	 * parent won't be destroyed before its children.
+	 */
+	dput(cgrp->parent->dentry);
+
+	/*
 	 * Drop the active superblock reference that we took when we
 	 * created the cgroup
 	 */
@@ -4171,6 +4178,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	for_each_subsys(root, ss)
 		dget(dentry);
 
+	/* hold a ref to the parent's dentry */
+	dget(parent->dentry);
+
 	/* creation succeeded, notify subsystems */
 	for_each_subsys(root, ss) {
 		err = online_css(ss, cgrp);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
