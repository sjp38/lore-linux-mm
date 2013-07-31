Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D450D6B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 21:52:51 -0400 (EDT)
Message-ID: <51F86DA3.6050406@huawei.com>
Date: Wed, 31 Jul 2013 09:51:31 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 3/8] cgroup: implement cgroup_from_id()
References: <51F86D69.2030907@huawei.com>
In-Reply-To: <51F86D69.2030907@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

This will be used as a replacement for css_lookup().

There's a difference with cgroup id and css id. cgroup id starts with 0,
while css id starts with 1.

v4:
- also check if cggroup_mutex is held.
- make it an inline function.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/cgroup.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8c107e9..4ef8452 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -720,6 +720,24 @@ static inline struct cgroup* task_cgroup(struct task_struct *task,
 	return task_subsys_state(task, subsys_id)->cgroup;
 }
 
+/**
+ * cgroup_from_id - lookup cgroup by id
+ * @ss: cgroup subsys to be looked into
+ * @id: the cgroup id
+ *
+ * Returns the cgroup if there's valid one with @id, otherwise returns NULL.
+ * Should be called under rcu_read_lock().
+ */
+static inline struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
+{
+#ifdef CONFIG_PROVE_RCU
+	rcu_lockdep_assert(rcu_read_lock_held() ||
+			   lockdep_is_held(&cgroup_mutex),
+			   "cgroup_from_id() needs proper protection");
+#endif
+	return idr_find(&ss->root->cgroup_idr, id);
+}
+
 struct cgroup *cgroup_next_sibling(struct cgroup *pos);
 
 /**
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
