Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FBAD6B0205
	for <linux-mm@kvack.org>; Wed, 12 May 2010 03:19:33 -0400 (EDT)
Message-ID: <4BEA56D3.6040705@cn.fujitsu.com>
Date: Wed, 12 May 2010 15:20:51 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH -mm] cpuset,mm: fix no node to alloc memory when changing
 cpuset's mems - fix2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

- cleanup unnecessary header file
- fix the race between set_mempolicy() and cpuset_change_task_nodemask()

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 kernel/cpuset.c |    3 +--
 kernel/exit.c   |    1 -
 kernel/fork.c   |    1 -
 3 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 30cb9a2..d243a22 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -963,7 +963,6 @@ repeat:
 	task_lock(tsk);
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
-	task_unlock(tsk);
 
 
 	/*
@@ -985,6 +984,7 @@ repeat:
 	 * for the read-side.
 	 */
 	while (ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
+		task_unlock(tsk);
 		if (!task_curr(tsk))
 			yield();
 		goto repeat;
@@ -999,7 +999,6 @@ repeat:
 	 */
 	smp_mb();
 
-	task_lock(tsk);
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP2);
 	tsk->mems_allowed = *newmems;
 	task_unlock(tsk);
diff --git a/kernel/exit.c b/kernel/exit.c
index 41bc5b2..0ecb17b 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -16,7 +16,6 @@
 #include <linux/key.h>
 #include <linux/security.h>
 #include <linux/cpu.h>
-#include <linux/cpuset.h>
 #include <linux/acct.h>
 #include <linux/tsacct_kern.h>
 #include <linux/file.h>
diff --git a/kernel/fork.c b/kernel/fork.c
index 6e87c95..f4f0951 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -31,7 +31,6 @@
 #include <linux/nsproxy.h>
 #include <linux/capability.h>
 #include <linux/cpu.h>
-#include <linux/cpuset.h>
 #include <linux/cgroup.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
