Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id AC2B782A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:38:04 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so945708pde.20
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:38:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bc4si1566498pbb.71.2014.07.11.00.37.30
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:38:03 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 23/30] mm, x86: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:40 +0800
Message-Id: <1405064267-11678-24-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Grant Likely <grant.likely@linaro.org>, Prarit Bhargava <prarit@redhat.com>, Liu Ping Fan <kernelfans@gmail.com>, Yoshihiro YUNOMAE <yoshihiro.yunomae.ez@hitachi.com>, Jiang Liu <jiang.liu@linux.intel.com>, Rob Herring <robh@kernel.org>, Michal Simek <monstr@monstr.eu>, Tony Lindgren <tony@atomide.com>, Steven Rostedt <srostedt@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mathias Krause <minipli@googlemail.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/x86/kernel/apic/io_apic.c |   10 +++++-----
 arch/x86/kernel/devicetree.c   |    2 +-
 arch/x86/kernel/irq_32.c       |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 81e08eff05ee..7cb3d58b11e8 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -204,7 +204,7 @@ int __init arch_early_irq_init(void)
 
 	cfg = irq_cfgx;
 	count = ARRAY_SIZE(irq_cfgx);
-	node = cpu_to_node(0);
+	node = cpu_to_mem(0);
 
 	for (i = 0; i < count; i++) {
 		irq_set_chip_data(i, &cfg[i]);
@@ -1348,7 +1348,7 @@ static bool __init io_apic_pin_not_connected(int idx, int ioapic_idx, int pin)
 
 static void __init __io_apic_setup_irqs(unsigned int ioapic_idx)
 {
-	int idx, node = cpu_to_node(0);
+	int idx, node = cpu_to_mem(0);
 	struct io_apic_irq_attr attr;
 	unsigned int pin, irq;
 
@@ -1394,7 +1394,7 @@ static void __init setup_IO_APIC_irqs(void)
  */
 void setup_IO_APIC_irq_extra(u32 gsi)
 {
-	int ioapic_idx = 0, pin, idx, irq, node = cpu_to_node(0);
+	int ioapic_idx = 0, pin, idx, irq, node = cpu_to_mem(0);
 	struct io_apic_irq_attr attr;
 
 	/*
@@ -2662,7 +2662,7 @@ int timer_through_8259 __initdata;
 static inline void __init check_timer(void)
 {
 	struct irq_cfg *cfg = irq_get_chip_data(0);
-	int node = cpu_to_node(0);
+	int node = cpu_to_mem(0);
 	int apic1, pin1, apic2, pin2;
 	unsigned long flags;
 	int no_pin1 = 0;
@@ -3387,7 +3387,7 @@ int io_apic_set_pci_routing(struct device *dev, int irq,
 		return -EINVAL;
 	}
 
-	node = dev ? dev_to_node(dev) : cpu_to_node(0);
+	node = dev ? dev_to_node(dev) : cpu_to_mem(0);
 
 	return io_apic_setup_irq_pin_once(irq, node, irq_attr);
 }
diff --git a/arch/x86/kernel/devicetree.c b/arch/x86/kernel/devicetree.c
index 7db54b5d5f86..289762f4ea06 100644
--- a/arch/x86/kernel/devicetree.c
+++ b/arch/x86/kernel/devicetree.c
@@ -295,7 +295,7 @@ static int ioapic_xlate(struct irq_domain *domain,
 	set_io_apic_irq_attr(&attr, idx, line, it->trigger, it->polarity);
 
 	rc = io_apic_setup_irq_pin_once(irq_find_mapping(domain, line),
-					cpu_to_node(0), &attr);
+					cpu_to_mem(0), &attr);
 	if (rc)
 		return rc;
 
diff --git a/arch/x86/kernel/irq_32.c b/arch/x86/kernel/irq_32.c
index 63ce838e5a54..425bb4b1110a 100644
--- a/arch/x86/kernel/irq_32.c
+++ b/arch/x86/kernel/irq_32.c
@@ -128,12 +128,12 @@ void irq_ctx_init(int cpu)
 	if (per_cpu(hardirq_stack, cpu))
 		return;
 
-	irqstk = page_address(alloc_pages_node(cpu_to_node(cpu),
+	irqstk = page_address(alloc_pages_node(cpu_to_mem(cpu),
 					       THREADINFO_GFP,
 					       THREAD_SIZE_ORDER));
 	per_cpu(hardirq_stack, cpu) = irqstk;
 
-	irqstk = page_address(alloc_pages_node(cpu_to_node(cpu),
+	irqstk = page_address(alloc_pages_node(cpu_to_mem(cpu),
 					       THREADINFO_GFP,
 					       THREAD_SIZE_ORDER));
 	per_cpu(softirq_stack, cpu) = irqstk;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
