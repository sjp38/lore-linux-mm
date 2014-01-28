Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id BA52E6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:38:19 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 79so3376172ykr.9
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 10:38:19 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id j67si12402291yha.137.2014.01.28.10.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 10:38:18 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 28 Jan 2014 11:38:17 -0700
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 853716E804C
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:38:09 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0SIcDXI7930204
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:38:13 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0SIcCS5011498
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:38:13 -0500
Date: Tue, 28 Jan 2014 10:38:08 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH] kthread: ensure locality of task_struct allocations
Message-ID: <20140128183808.GB9315@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Anton Blanchard <anton@samba.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

In the presence of memoryless nodes, numa_node_id()/cpu_to_node() will
return the current CPU's NUMA node, but that may not be where we expect
to allocate from memory from. Instead, we should use
numa_mem_id()/cpu_to_mem(). On one ppc64 system with a memoryless Node
0, this ends up saving nearly 500M of slab due to less fragmentation.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/kernel/kthread.c b/kernel/kthread.c
index b5ae3ee..8573e4e 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -217,7 +217,7 @@ int tsk_fork_get_node(struct task_struct *tsk)
 	if (tsk == kthreadd_task)
 		return tsk->pref_node_fork;
 #endif
-	return numa_node_id();
+	return numa_mem_id();
 }
 
 static void create_kthread(struct kthread_create_info *create)
@@ -369,7 +369,7 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
 {
 	struct task_struct *p;
 
-	p = kthread_create_on_node(threadfn, data, cpu_to_node(cpu), namefmt,
+	p = kthread_create_on_node(threadfn, data, cpu_to_mem(cpu), namefmt,
 				   cpu);
 	if (IS_ERR(p))
 		return p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
