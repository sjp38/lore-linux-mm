Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 95A466B00A3
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:06:44 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id ar1so2738440iec.35
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:06:44 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id x8si15490718icj.45.2014.09.09.12.06.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 12:06:44 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 9 Sep 2014 13:06:43 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D891A3E40030
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 13:06:41 -0600 (MDT)
Received: from d03av01.ahe.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s89J4ldB50725116
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 21:04:47 +0200
Received: from d03av01.ahe.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.ahe.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s89J6d1U006710
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 13:06:41 -0600
Date: Tue, 9 Sep 2014 12:06:30 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 3/3] Partial revert of 81c98869faa5 ("kthread: ensure
 locality of task_struct allocations")
Message-ID: <20140909190630.GF22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
 <20140909190326.GD22906@linux.vnet.ibm.com>
 <20140909190514.GE22906@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140909190514.GE22906@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

After discussions with Tejun, we don't want to spread the use of
cpu_to_mem() (and thus knowledge of allocators/NUMA topology details)
into callers, but would rather ensure the callees correctly handle
memoryless nodes. With the previous patches ("topology: add support for
node_to_mem_node() to determine the fallback node" and "slub: fallback
to node_to_mem_node() node if allocating on memoryless node") adding and
using node_to_mem_node(), we can safely undo part of the change to the
kthread logic from 81c98869faa5.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/kernel/kthread.c b/kernel/kthread.c
index ef483220e855..10e489c448fe 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -369,7 +369,7 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
 {
 	struct task_struct *p;
 
-	p = kthread_create_on_node(threadfn, data, cpu_to_mem(cpu), namefmt,
+	p = kthread_create_on_node(threadfn, data, cpu_to_node(cpu), namefmt,
 				   cpu);
 	if (IS_ERR(p))
 		return p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
