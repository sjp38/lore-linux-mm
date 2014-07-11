Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE4082A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:36:13 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so940755pdj.36
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:36:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id cf5si1579350pbc.10.2014.07.11.00.36.11
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:36:11 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 12/30] mm, IB/qib: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:29 +0800
Message-Id: <1405064267-11678-13-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Mike Marciniszyn <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/infiniband/hw/qib/qib_file_ops.c |    4 ++--
 drivers/infiniband/hw/qib/qib_init.c     |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index b15e34eeef68..55540295e0e3 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -1312,8 +1312,8 @@ static int setup_ctxt(struct qib_pportdata *ppd, int ctxt,
 	assign_ctxt_affinity(fp, dd);
 
 	numa_id = qib_numa_aware ? ((fd->rec_cpu_num != -1) ?
-		cpu_to_node(fd->rec_cpu_num) :
-		numa_node_id()) : dd->assigned_node_id;
+		cpu_to_mem(fd->rec_cpu_num) : numa_mem_id()) :
+		dd->assigned_node_id;
 
 	rcd = qib_create_ctxtdata(ppd, ctxt, numa_id);
 
diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index 8d3c78ddc906..85ff56ad1075 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -133,7 +133,7 @@ int qib_create_ctxts(struct qib_devdata *dd)
 	int local_node_id = pcibus_to_node(dd->pcidev->bus);
 
 	if (local_node_id < 0)
-		local_node_id = numa_node_id();
+		local_node_id = numa_mem_id();
 	dd->assigned_node_id = local_node_id;
 
 	/*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
