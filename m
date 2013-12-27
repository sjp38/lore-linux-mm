Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A86C06B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 05:23:32 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so9184375pbc.10
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 02:23:32 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id m8si16446725pbq.59.2013.12.27.02.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 02:23:31 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 27 Dec 2013 15:53:23 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 1E3DF394002D
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:53:22 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBRANIV631326428
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:53:18 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBRANLFN003540
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:53:21 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] sched/auto_group: fix consume memory even if add 'noautogroup' in the cmdline
Date: Fri, 27 Dec 2013 18:22:31 +0800
Message-Id: <1388139751-19632-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

We have a server which have 200 CPUs and 8G memory, there is auto_group creation 
which will almost consume 12MB memory even if add 'noautogroup' in the kernel 
boot parameter. In addtion, SLUB per cpu partial caches freeing that is local to 
a processor which requires the taking of locks at the price of more indeterminism 
in the latency of the free. This patch fix it by check noautogroup earlier to avoid 
free after unnecessary memory consumption.

cat /sys/kernel/slab/kmalloc-512/alloc_calls  
18000 .alloc_fair_sched_group+0xec/0x1e0 age=2579/19587/286617 pid=1-8462 cpus=0-1,5,9,21,26,29,41,61,
69,73,76-77,89,92-93,97,101,109,121,125,133,141,145,149,153,161,185 nodes=1
cat /sys/kernel/slab/kmalloc-192/alloc_calls
18000 .alloc_fair_sched_group+0x110/0x1e0 age=2637/19654/286688 pid=1-8462 cpus=0-1,5,9,21,26,29,41,61,
69,73,76-77,89,92-93,97,101,109,121,125,133,141,145,149,153,161,185 nodes=1

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/auto_group.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/kernel/sched/auto_group.c b/kernel/sched/auto_group.c
index 4a07353..748ebc9 100644
--- a/kernel/sched/auto_group.c
+++ b/kernel/sched/auto_group.c
@@ -145,15 +145,11 @@ autogroup_move_group(struct task_struct *p, struct autogroup *ag)
 
 	p->signal->autogroup = autogroup_kref_get(ag);
 
-	if (!ACCESS_ONCE(sysctl_sched_autogroup_enabled))
-		goto out;
-
 	t = p;
 	do {
 		sched_move_task(t);
 	} while_each_thread(p, t);
 
-out:
 	unlock_task_sighand(p, &flags);
 	autogroup_kref_put(prev);
 }
@@ -161,7 +157,12 @@ out:
 /* Allocates GFP_KERNEL, cannot be called under any spinlock */
 void sched_autogroup_create_attach(struct task_struct *p)
 {
-	struct autogroup *ag = autogroup_create();
+	struct autogroup *ag;
+
+	if (!ACCESS_ONCE(sysctl_sched_autogroup_enabled))
+		return;
+
+	ag = autogroup_create();
 
 	autogroup_move_group(p, ag);
 	/* drop extra reference added by autogroup_create() */
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
