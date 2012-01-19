Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 669C66B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 01:05:35 -0500 (EST)
Received: by iadj38 with SMTP id j38so7312371iad.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 22:05:34 -0800 (PST)
Date: Wed, 18 Jan 2012 22:05:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for next
Message-ID: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit c1e2ee2dc436 "memcg: replace ss->id_lock with a rwlock" has
now been seen to cause the unfair behavior we should have expected
from converting a spinlock to an rwlock: softlockup in cgroup_mkdir(),
whose get_new_cssid() is waiting for the wlock, while there are 19
tasks using the rlock in css_get_next() to get on with their memcg
workload (in an artificial test, admittedly).  Yet lib/idr.c was
made suitable for RCU way back.

1. Revert that commit, restoring ss->id_lock to a spinlock.

2. Make one small adjustment to idr_get_next(): take the height from
the top layer (stable under RCU) instead of from the root (unprotected
by RCU), as idr_find() does.

3. Remove lock and unlock around css_get_next()'s call to idr_get_next():
memcg iterators (only users of css_get_next) already did rcu_read_lock(),
and comment demands that, but add a WARN_ON_ONCE to make sure of it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/cgroup.h |    2 +-
 kernel/cgroup.c        |   19 +++++++++----------
 lib/idr.c              |    4 ++--
 3 files changed, 12 insertions(+), 13 deletions(-)

--- 3.2.0+/include/linux/cgroup.h	2012-01-14 13:01:57.532007832 -0800
+++ linux/include/linux/cgroup.h	2012-01-18 21:21:45.695966602 -0800
@@ -535,7 +535,7 @@ struct cgroup_subsys {
 	struct list_head sibling;
 	/* used when use_id == true */
 	struct idr idr;
-	rwlock_t id_lock;
+	spinlock_t id_lock;
 
 	/* should be defined only by modular subsystems */
 	struct module *module;
--- 3.2.0+/kernel/cgroup.c	2012-01-14 13:01:57.824007839 -0800
+++ linux/kernel/cgroup.c	2012-01-18 21:29:05.199958492 -0800
@@ -4939,9 +4939,9 @@ void free_css_id(struct cgroup_subsys *s
 
 	rcu_assign_pointer(id->css, NULL);
 	rcu_assign_pointer(css->id, NULL);
-	write_lock(&ss->id_lock);
+	spin_lock(&ss->id_lock);
 	idr_remove(&ss->idr, id->id);
-	write_unlock(&ss->id_lock);
+	spin_unlock(&ss->id_lock);
 	kfree_rcu(id, rcu_head);
 }
 EXPORT_SYMBOL_GPL(free_css_id);
@@ -4967,10 +4967,10 @@ static struct css_id *get_new_cssid(stru
 		error = -ENOMEM;
 		goto err_out;
 	}
-	write_lock(&ss->id_lock);
+	spin_lock(&ss->id_lock);
 	/* Don't use 0. allocates an ID of 1-65535 */
 	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
-	write_unlock(&ss->id_lock);
+	spin_unlock(&ss->id_lock);
 
 	/* Returns error when there are no free spaces for new ID.*/
 	if (error) {
@@ -4985,9 +4985,9 @@ static struct css_id *get_new_cssid(stru
 	return newid;
 remove_idr:
 	error = -ENOSPC;
-	write_lock(&ss->id_lock);
+	spin_lock(&ss->id_lock);
 	idr_remove(&ss->idr, myid);
-	write_unlock(&ss->id_lock);
+	spin_unlock(&ss->id_lock);
 err_out:
 	kfree(newid);
 	return ERR_PTR(error);
@@ -4999,7 +4999,7 @@ static int __init_or_module cgroup_init_
 {
 	struct css_id *newid;
 
-	rwlock_init(&ss->id_lock);
+	spin_lock_init(&ss->id_lock);
 	idr_init(&ss->idr);
 
 	newid = get_new_cssid(ss, 0);
@@ -5087,6 +5087,8 @@ css_get_next(struct cgroup_subsys *ss, i
 		return NULL;
 
 	BUG_ON(!ss->use_id);
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
 	/* fill start point for scan */
 	tmpid = id;
 	while (1) {
@@ -5094,10 +5096,7 @@ css_get_next(struct cgroup_subsys *ss, i
 		 * scan next entry from bitmap(tree), tmpid is updated after
 		 * idr_get_next().
 		 */
-		read_lock(&ss->id_lock);
 		tmp = idr_get_next(&ss->idr, &tmpid);
-		read_unlock(&ss->id_lock);
-
 		if (!tmp)
 			break;
 		if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
--- 3.2.0+/lib/idr.c	2012-01-04 15:55:44.000000000 -0800
+++ linux/lib/idr.c	2012-01-18 21:25:36.947963342 -0800
@@ -605,11 +605,11 @@ void *idr_get_next(struct idr *idp, int
 	int n, max;
 
 	/* find first ent */
-	n = idp->layers * IDR_BITS;
-	max = 1 << n;
 	p = rcu_dereference_raw(idp->top);
 	if (!p)
 		return NULL;
+	n = (p->layer + 1) * IDR_BITS;
+	max = 1 << n;
 
 	while (id < max) {
 		while (n > 0 && p) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
