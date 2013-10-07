Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 577586B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:31:56 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so7487854pdj.6
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:31:56 -0700 (PDT)
Message-Id: <000001419430909f-da6a6e6c-103b-4c2e-9fa3-39e70a9b35a9-000000@email.amazonses.com>
Date: Mon, 7 Oct 2013 18:31:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [raw v1 1/4] Use raw_cpu ops for determining current NUMA node
References: <20131007183226.334180014@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linuxfoundation.org, linux-mm@kvack.org, Alex Shi <alex.shi@intel.com>, Steven Rostedt <srostedt@redhat.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

With the preempt check logic we will get false positives from
these locations. Before the use of __this_cpu ops there were
no checks for preemption present either and smp_raw_processor_id()
was used. See http://www.spinics.net/lists/linux-numa/msg00641.html

Use raw_cpu_read() to avoid preemption messages.

Note that this issue has been discussed in prior years.
If the process changes nodes after retrieving the current numa node then
that is acceptable since most uses of numa_node etc are for optimization
and not for correctness.

CC: linux-mm@kvack.org
Cc: Alex Shi <alex.shi@intel.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/topology.h
===================================================================
--- linux.orig/include/linux/topology.h	2013-09-24 11:29:51.000000000 -0500
+++ linux/include/linux/topology.h	2013-09-24 11:30:18.893831971 -0500
@@ -182,7 +182,7 @@ DECLARE_PER_CPU(int, numa_node);
 /* Returns the number of the current Node. */
 static inline int numa_node_id(void)
 {
-	return __this_cpu_read(numa_node);
+	return raw_cpu_read(numa_node);
 }
 #endif
 
@@ -239,7 +239,7 @@ static inline void set_numa_mem(int node
 /* Returns the number of the nearest Node with memory */
 static inline int numa_mem_id(void)
 {
-	return __this_cpu_read(_numa_mem_);
+	return raw_cpu_read(_numa_mem_);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
