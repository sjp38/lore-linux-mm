Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC4E6B01C9
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:12:11 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 02/96] eclone (2/11): Have alloc_pidmap() return actual error code
Date: Wed, 17 Mar 2010 12:07:50 -0400
Message-Id: <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

alloc_pidmap() can fail either because all pid numbers are in use or
because memory allocation failed.  With support for setting a specific
pid number, alloc_pidmap() would also fail if either the given pid
number is invalid or in use.

Rather than have callers assume -ENOMEM, have alloc_pidmap() return
the actual error.

Changelog[v1]:
	- [Oren Laadan] Rebase to kernel 2.6.33

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
Reviewed-by: Oren Laadan <orenl@cs.columbia.edu>
---
 kernel/fork.c |    5 +++--
 kernel/pid.c  |   10 ++++++----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index f88bd98..e9cf524 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1167,10 +1167,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		goto bad_fork_cleanup_io;
 
 	if (pid != &init_struct_pid) {
-		retval = -ENOMEM;
 		pid = alloc_pid(p->nsproxy->pid_ns);
-		if (!pid)
+		if (IS_ERR(pid)) {
+			retval = PTR_ERR(pid);
 			goto bad_fork_cleanup_io;
+		}
 
 		if (clone_flags & CLONE_NEWPID) {
 			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
diff --git a/kernel/pid.c b/kernel/pid.c
index 39292e6..252babf 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -160,7 +160,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	for (i = 0; i <= max_scan; ++i) {
 		if (unlikely(!map->page))
 			if (alloc_pidmap_page(map) < 0)
-				break;
+				return -ENOMEM;
 		if (likely(atomic_read(&map->nr_free))) {
 			do {
 				if (!test_and_set_bit(offset, map->page)) {
@@ -191,7 +191,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 		}
 		pid = mk_pid(pid_ns, map, offset);
 	}
-	return -1;
+	return -EBUSY;
 }
 
 int next_pidmap(struct pid_namespace *pid_ns, int last)
@@ -260,8 +260,10 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	struct upid *upid;
 
 	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
-	if (!pid)
+	if (!pid) {
+		pid = ERR_PTR(-ENOMEM);
 		goto out;
+	}
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
@@ -295,7 +297,7 @@ out_free:
 		free_pidmap(pid->numbers + i);
 
 	kmem_cache_free(ns->pid_cachep, pid);
-	pid = NULL;
+	pid = ERR_PTR(nr);
 	goto out;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
