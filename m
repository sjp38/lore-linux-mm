Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 08016900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 14:20:58 -0400 (EDT)
From: Andrew Bresticker <abrestic@google.com>
Subject: [PATCH] memcg: replace ss->id_lock with a rwlock
Date: Wed, 10 Aug 2011 11:20:33 -0700
Message-Id: <1313000433-11537-1-git-send-email-abrestic@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Andrew Bresticker <abrestic@google.com>

While back-porting Johannes Weiner's patch "mm: memcg-aware global reclaim"
for an internal effort, we noticed a significant performance regression
during page-reclaim heavy workloads due to high contention of the ss->id_lock.
This lock protects idr map, and serializes calls to idr_get_next() in
css_get_next() (which is used during the memcg hierarchy walk).  Since
idr_get_next() is just doing a look up, we need only serialize it with
respect to idr_remove()/idr_get_new().  By making the ss->id_lock a
rwlock, contention is greatly reduced and performance improves.

Tested: cat a 256m file from a ramdisk in a 128m container 50 times
on each core (one file + container per core) in parallel on a NUMA
machine.  Result is the time for the test to complete in 1 of the
containers.  Both kernels included Johannes' memcg-aware global
reclaim patches.
Before rwlock patch: 1710.778s
After rwlock patch: 152.227s

Signed-off-by: Andrew Bresticker <abrestic@google.com>
---
 include/linux/cgroup.h |    2 +-
 kernel/cgroup.c        |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index da7e4bc..1b7f9d5 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -516,7 +516,7 @@ struct cgroup_subsys {
 	struct list_head sibling;
 	/* used when use_id == true */
 	struct idr idr;
-	spinlock_t id_lock;
+	rwlock_t id_lock;
 
 	/* should be defined only by modular subsystems */
 	struct module *module;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1d2b6ce..bc3caf0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4880,9 +4880,9 @@ void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
 
 	rcu_assign_pointer(id->css, NULL);
 	rcu_assign_pointer(css->id, NULL);
-	spin_lock(&ss->id_lock);
+	write_lock(&ss->id_lock);
 	idr_remove(&ss->idr, id->id);
-	spin_unlock(&ss->id_lock);
+	write_unlock(&ss->id_lock);
 	kfree_rcu(id, rcu_head);
 }
 EXPORT_SYMBOL_GPL(free_css_id);
@@ -4908,10 +4908,10 @@ static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
 		error = -ENOMEM;
 		goto err_out;
 	}
-	spin_lock(&ss->id_lock);
+	write_lock(&ss->id_lock);
 	/* Don't use 0. allocates an ID of 1-65535 */
 	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
-	spin_unlock(&ss->id_lock);
+	write_unlock(&ss->id_lock);
 
 	/* Returns error when there are no free spaces for new ID.*/
 	if (error) {
@@ -4926,9 +4926,9 @@ static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
 	return newid;
 remove_idr:
 	error = -ENOSPC;
-	spin_lock(&ss->id_lock);
+	write_lock(&ss->id_lock);
 	idr_remove(&ss->idr, myid);
-	spin_unlock(&ss->id_lock);
+	write_unlock(&ss->id_lock);
 err_out:
 	kfree(newid);
 	return ERR_PTR(error);
@@ -4940,7 +4940,7 @@ static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
 {
 	struct css_id *newid;
 
-	spin_lock_init(&ss->id_lock);
+	rwlock_init(&ss->id_lock);
 	idr_init(&ss->idr);
 
 	newid = get_new_cssid(ss, 0);
@@ -5035,9 +5035,9 @@ css_get_next(struct cgroup_subsys *ss, int id,
 		 * scan next entry from bitmap(tree), tmpid is updated after
 		 * idr_get_next().
 		 */
-		spin_lock(&ss->id_lock);
+		read_lock(&ss->id_lock);
 		tmp = idr_get_next(&ss->idr, &tmpid);
-		spin_unlock(&ss->id_lock);
+		read_unlock(&ss->id_lock);
 
 		if (!tmp)
 			break;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
