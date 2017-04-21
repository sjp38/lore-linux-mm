Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3C5A6B03A4
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k1so22105635qtb.20
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k66si7173215qkl.154.2017.04.21.07.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:03 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 08/14] cgroup: Keep accurate count of tasks in each css_set
Date: Fri, 21 Apr 2017 10:04:06 -0400
Message-Id: <1492783452-12267-9-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

The reference count in the css_set data structure was used as a
proxy of the number of tasks attached to that css_set. However, that
count is actually not an accurate measure especially with thread mode
support. So a new variable task_count is added to the css_set to keep
track of the actual task count. This new variable is protected by
the css_set_lock. Functions that require the actual task count are
updated to use the new variable.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/cgroup-defs.h | 3 +++
 kernel/cgroup/cgroup-v1.c   | 6 +-----
 kernel/cgroup/cgroup.c      | 5 +++++
 kernel/cgroup/debug.c       | 6 +-----
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index bb4752a..7be1a90 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -158,6 +158,9 @@ struct css_set {
 	/* reference count */
 	atomic_t refcount;
 
+	/* internal task count, protected by css_set_lock */
+	int task_count;
+
 	/*
 	 * If not threaded, the following points to self.  If threaded, to
 	 * a cset which belongs to the top cgroup of the threaded subtree.
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index 6757a50..6d69796 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -334,10 +334,6 @@ static struct cgroup_pidlist *cgroup_pidlist_find_create(struct cgroup *cgrp,
 /**
  * cgroup_task_count - count the number of tasks in a cgroup.
  * @cgrp: the cgroup in question
- *
- * Return the number of tasks in the cgroup.  The returned number can be
- * higher than the actual number of tasks due to css_set references from
- * namespace roots and temporary usages.
  */
 static int cgroup_task_count(const struct cgroup *cgrp)
 {
@@ -346,7 +342,7 @@ static int cgroup_task_count(const struct cgroup *cgrp)
 
 	spin_lock_irq(&css_set_lock);
 	list_for_each_entry(link, &cgrp->cset_links, cset_link)
-		count += atomic_read(&link->cset->refcount);
+		count += link->cset->task_count;
 	spin_unlock_irq(&css_set_lock);
 	return count;
 }
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index d48eedd..3186b1f 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1671,6 +1671,7 @@ static void cgroup_enable_task_cg_lists(void)
 				css_set_update_populated(cset, true);
 			list_add_tail(&p->cg_list, &cset->tasks);
 			get_css_set(cset);
+			cset->task_count++;
 		}
 		spin_unlock(&p->sighand->siglock);
 	} while_each_thread(g, p);
@@ -2154,8 +2155,10 @@ static int cgroup_migrate_execute(struct cgroup_mgctx *mgctx)
 			struct css_set *to_cset = cset->mg_dst_cset;
 
 			get_css_set(to_cset);
+			to_cset->task_count++;
 			css_set_move_task(task, from_cset, to_cset, true);
 			put_css_set_locked(from_cset);
+			from_cset->task_count--;
 		}
 	}
 	spin_unlock_irq(&css_set_lock);
@@ -5150,6 +5153,7 @@ void cgroup_post_fork(struct task_struct *child)
 		cset = task_css_set(current);
 		if (list_empty(&child->cg_list)) {
 			get_css_set(cset);
+			cset->task_count++;
 			css_set_move_task(child, NULL, cset, false);
 		}
 		spin_unlock_irq(&css_set_lock);
@@ -5199,6 +5203,7 @@ void cgroup_exit(struct task_struct *tsk)
 	if (!list_empty(&tsk->cg_list)) {
 		spin_lock_irq(&css_set_lock);
 		css_set_move_task(tsk, cset, NULL, false);
+		cset->task_count--;
 		spin_unlock_irq(&css_set_lock);
 	} else {
 		get_css_set(cset);
diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
index 9146461..c8f7590 100644
--- a/kernel/cgroup/debug.c
+++ b/kernel/cgroup/debug.c
@@ -23,10 +23,6 @@ static void debug_css_free(struct cgroup_subsys_state *css)
 /*
  * debug_taskcount_read - return the number of tasks in a cgroup.
  * @cgrp: the cgroup in question
- *
- * Return the number of tasks in the cgroup.  The returned number can be
- * higher than the actual number of tasks due to css_set references from
- * namespace roots and temporary usages.
  */
 static u64 debug_taskcount_read(struct cgroup_subsys_state *css,
 				struct cftype *cft)
@@ -37,7 +33,7 @@ static u64 debug_taskcount_read(struct cgroup_subsys_state *css,
 
 	spin_lock_irq(&css_set_lock);
 	list_for_each_entry(link, &cgrp->cset_links, cset_link)
-		count += atomic_read(&link->cset->refcount);
+		count += link->cset->task_count;
 	spin_unlock_irq(&css_set_lock);
 	return count;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
