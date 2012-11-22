Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5E8946B0075
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 05:30:16 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/2] cgroup: helper do determine group name
Date: Thu, 22 Nov 2012 14:29:49 +0400
Message-Id: <1353580190-14721-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1353580190-14721-1-git-send-email-glommer@parallels.com>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>

With more than one user, it is useful to have a helper function in the
cgroup core to derive a group's name.

We'll just return a pointer, and it is not expected to get incredibly
complicated. But it is useful to have it so we can abstract away the
vfs relation from its users.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Tejun Heo <tj@kernel.org>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
---
Tejun:

I know the rcu is no longer necessary. I am using mhocko's tree,
that doesn't seem to have your last stream of patches yet. If you
approve the interface, we'll need a follow up on this to remove the
rcu dereference of the dentry.

 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        |  9 +++++++++
 mm/memcontrol.c        | 11 ++++-------
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index a178a91..57c4ab1 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -401,6 +401,7 @@ int cgroup_rm_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts);
 int cgroup_is_removed(const struct cgroup *cgrp);
 
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
+extern const char *cgroup_name(const struct cgroup *cgrp);
 
 int cgroup_task_count(const struct cgroup *cgrp);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3d68aad..d0d291e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1757,6 +1757,15 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 EXPORT_SYMBOL_GPL(cgroup_path);
 
+const char *cgroup_name(const struct cgroup *cgrp)
+{
+	struct dentry *dentry;
+	rcu_read_lock();
+	dentry = rcu_dereference_check(cgrp->dentry, cgroup_lock_is_held());
+	rcu_read_unlock();
+	return dentry->d_name.name;
+}
+
 /*
  * Control Group taskset
  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e3d805f..05b87aa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3141,16 +3141,13 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
 {
 	char *name;
-	struct dentry *dentry;
+	const char *cgname;
 
-	rcu_read_lock();
-	dentry = rcu_dereference(memcg->css.cgroup->dentry);
-	rcu_read_unlock();
-
-	BUG_ON(dentry == NULL);
+	cgname = cgroup_name(memcg->css.cgroup);
+	BUG_ON(cgname == NULL);
 
 	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
-			 memcg_cache_id(memcg), dentry->d_name.name);
+			 memcg_cache_id(memcg), cgname);
 
 	return name;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
