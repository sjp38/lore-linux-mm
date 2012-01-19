Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 521F16B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:50:24 -0500 (EST)
Received: by iadj38 with SMTP id j38so498019iad.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:50:23 -0800 (PST)
Date: Thu, 19 Jan 2012 12:50:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/3] cgroup: revert ss_id_lock to spinlock
In-Reply-To: <alpine.LSU.2.00.1201191235330.29542@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1201191249000.29542@eggly.anvils>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils> <1326958401.1113.22.camel@edumazet-laptop> <CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com> <1326979818.2249.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.LSU.2.00.1201191235330.29542@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit c1e2ee2dc436 "memcg: replace ss->id_lock with a rwlock" has
now been seen to cause the unfair behavior we should have expected
from converting a spinlock to an rwlock: softlockup in cgroup_mkdir(),
whose get_new_cssid() is waiting for the wlock, while there are 19
tasks using the rlock in css_get_next() to get on with their memcg
workload (in an artificial test, admittedly).  Yet lib/idr.c was
made suitable for RCU way back: revert that commit, restoring
ss->id_lock to a spinlock.

Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Li Zefan <lizf@cn.fujitsu.com>
---
 include/linux/cgroup.h |    2 +-
 kernel/cgroup.c        |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

--- 3.2.0+.orig/include/linux/cgroup.h	2012-01-14 13:01:57.000000000 -0800
+++ 3.2.0+/include/linux/cgroup.h	2012-01-19 12:14:47.420233522 -0800
@@ -535,7 +535,7 @@ struct cgroup_subsys {
 	struct list_head sibling;
 	/* used when use_id == true */
 	struct idr idr;
-	rwlock_t id_lock;
+	spinlock_t id_lock;
 
 	/* should be defined only by modular subsystems */
 	struct module *module;
--- 3.2.0+.orig/kernel/cgroup.c	2012-01-14 13:01:57.000000000 -0800
+++ 3.2.0+/kernel/cgroup.c	2012-01-19 12:16:04.132235263 -0800
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
@@ -5094,9 +5094,9 @@ css_get_next(struct cgroup_subsys *ss, i
 		 * scan next entry from bitmap(tree), tmpid is updated after
 		 * idr_get_next().
 		 */
-		read_lock(&ss->id_lock);
+		spin_lock(&ss->id_lock);
 		tmp = idr_get_next(&ss->idr, &tmpid);
-		read_unlock(&ss->id_lock);
+		spin_unlock(&ss->id_lock);
 
 		if (!tmp)
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
