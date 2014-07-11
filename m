Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C1DF382A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:36:52 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so932334pdj.8
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:36:52 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id cf5si1579350pbc.10.2014.07.11.00.36.51
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:36:51 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 21/30] mm, irqchip: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:38 +0800
Message-Id: <1405064267-11678-22-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Alexander Shiyan <shc_work@mail.ru>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/irqchip/irq-clps711x.c |    2 +-
 drivers/irqchip/irq-gic.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/irqchip/irq-clps711x.c b/drivers/irqchip/irq-clps711x.c
index 33340dc97d1d..b0acf8b32a1a 100644
--- a/drivers/irqchip/irq-clps711x.c
+++ b/drivers/irqchip/irq-clps711x.c
@@ -186,7 +186,7 @@ static int __init _clps711x_intc_init(struct device_node *np,
 	writel_relaxed(0, clps711x_intc->intmr[1]);
 	writel_relaxed(0, clps711x_intc->intmr[2]);
 
-	err = irq_alloc_descs(-1, 0, ARRAY_SIZE(clps711x_irqs), numa_node_id());
+	err = irq_alloc_descs(-1, 0, ARRAY_SIZE(clps711x_irqs), numa_mem_id());
 	if (IS_ERR_VALUE(err))
 		goto out_iounmap;
 
diff --git a/drivers/irqchip/irq-gic.c b/drivers/irqchip/irq-gic.c
index 7e11c9d6ae8c..a7e6c043d823 100644
--- a/drivers/irqchip/irq-gic.c
+++ b/drivers/irqchip/irq-gic.c
@@ -1005,7 +1005,7 @@ void __init gic_init_bases(unsigned int gic_nr, int irq_start,
 	if (of_property_read_u32(node, "arm,routable-irqs",
 				 &nr_routable_irqs)) {
 		irq_base = irq_alloc_descs(irq_start, 16, gic_irqs,
-					   numa_node_id());
+					   numa_mem_id());
 		if (IS_ERR_VALUE(irq_base)) {
 			WARN(1, "Cannot allocate irq_descs @ IRQ%d, assuming pre-allocated\n",
 			     irq_start);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
