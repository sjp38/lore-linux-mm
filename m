Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 18F026B0123
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 01:58:56 -0500 (EST)
Message-ID: <4B99E62C.1020500@cn.fujitsu.com>
Date: Fri, 12 Mar 2010 14:58:52 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH -mmotm 1/2] cpuset: fix the problem that cpuset_mem_spread_node()
 returns an offline node - fix
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Remove unnecessary smp_wmb().

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
Against the following patch in mmotm-2010-03-11-13-13:
cpuset-fix-the-problem-that-cpuset_mem_spread_node-returns-an-offline-node.patch
---
 kernel/cpuset.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index b15c01c..f36e577 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -933,23 +933,9 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 
 	tsk->mems_allowed = *to;
 
-	/*
-	 * After current->mems_allowed is set to a new value, current will
-	 * allocate new pages for the migrating memory region. So we must
-	 * ensure that update of current->mems_allowed have been completed
-	 * by this moment.
-	 */
-	smp_wmb();
 	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
 
 	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
-
-	/*
-	 * After doing migrate pages, current will allocate new pages for
-	 * itself not the other tasks. So we must ensure that update of
-	 * current->mems_allowed have been completed by this moment.
-	 */
-	smp_wmb();
 }
 
 /*
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
