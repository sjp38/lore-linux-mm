Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 183DB6B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:02:42 -0400 (EDT)
Message-ID: <51EFA5C7.40504@huawei.com>
Date: Wed, 24 Jul 2013 18:00:39 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2 3/8] cgroup: implement cgroup_from_id()
References: <51EFA554.6080801@huawei.com>
In-Reply-To: <51EFA554.6080801@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

This will be used as a replacement for css_lookup().

There's a difference with cgroup id and css id. cgroup id starts with 0,
while css id starts with 1.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 include/linux/cgroup.h |  2 ++
 kernel/cgroup.c        | 16 ++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8c107e9..e8eb361 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -553,6 +553,8 @@ int task_cgroup_path_from_hierarchy(struct task_struct *task, int hierarchy_id,
 
 int cgroup_task_count(const struct cgroup *cgrp);
 
+struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id);
+
 /*
  * Control Group taskset, used to pass around set of tasks to cgroup_subsys
  * methods.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ee3c02e..9b27775 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5536,6 +5536,22 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 	return css ? css : ERR_PTR(-ENOENT);
 }
 
+/**
+ * cgroup_from_id - lookup cgroup by id
+ * @ss: cgroup subsys to be looked into
+ * @id: the cgroup id
+ *
+ * Returns the cgroup is there's valid one with @id, otherwise returns Null.
+ * Should be called under rcu_readlock().
+ */
+struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
+{
+	rcu_lockdep_assert(rcu_read_lock_held(),
+			   "cgroup_from_id() needs rcu_read_lock()"
+			   " protection");
+	return idr_find(&ss->root->cgroup_idr, id);
+}
+
 #ifdef CONFIG_CGROUP_DEBUG
 static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cgrp)
 {
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
