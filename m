Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id CBBD46B0092
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 02:35:48 -0400 (EDT)
Message-ID: <51626516.3000603@huawei.com>
Date: Mon, 8 Apr 2013 14:35:02 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 09/12] cgroup: make sure parent won't be destroyed before
 its children
References: <5162648B.9070802@huawei.com>
In-Reply-To: <5162648B.9070802@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Suppose we rmdir a cgroup and there're still css refs, this cgroup won't
be freed. Then we rmdir the parent cgroup, and the parent is freed
immediately due to css ref draining to 0. Now it would be a disaster if
the still-alive child cgroup tries to access its parent.

Make sure this won't happen.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/cgroup.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 06aeb42..7ee3bdf 100644
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
@@ -4170,6 +4177,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
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
