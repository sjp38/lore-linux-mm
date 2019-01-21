Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD38A8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:45 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w18so19938187qts.8
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:04:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 11si3278665qkf.108.2019.01.21.00.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:04:44 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L83qgf072899
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:44 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q580ddewa-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:43 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 08:04:41 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 02/21] powerpc: use memblock functions returning virtual address
Date: Mon, 21 Jan 2019 10:03:49 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-3-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Christophe Leroy <christophe.leroy@c-s.fr>, Mike Rapoport <rppt@linux.ibm.com>

From: Christophe Leroy <christophe.leroy@c-s.fr>

Since only the virtual address of allocated blocks is used,
lets use functions returning directly virtual address.

Those functions have the advantage of also zeroing the block.

[ MR:
 - updated error message in alloc_stack() to be more verbose
 - convereted several additional call sites ]

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/powerpc/kernel/dt_cpu_ftrs.c |  3 +--
 arch/powerpc/kernel/irq.c         |  5 -----
 arch/powerpc/kernel/paca.c        |  6 +++++-
 arch/powerpc/kernel/prom.c        |  5 ++++-
 arch/powerpc/kernel/setup_32.c    | 26 ++++++++++++++++----------
 5 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/kernel/dt_cpu_ftrs.c b/arch/powerpc/kernel/dt_cpu_ftrs.c
index 8be3721..2554824 100644
--- a/arch/powerpc/kernel/dt_cpu_ftrs.c
+++ b/arch/powerpc/kernel/dt_cpu_ftrs.c
@@ -813,7 +813,6 @@ static int __init process_cpufeatures_node(unsigned long node,
 	int len;
 
 	f = &dt_cpu_features[i];
-	memset(f, 0, sizeof(struct dt_cpu_feature));
 
 	f->node = node;
 
@@ -1008,7 +1007,7 @@ static int __init dt_cpu_ftrs_scan_callback(unsigned long node, const char
 	/* Count and allocate space for cpu features */
 	of_scan_flat_dt_subnodes(node, count_cpufeatures_subnodes,
 						&nr_dt_cpu_features);
-	dt_cpu_features = __va(memblock_phys_alloc(sizeof(struct dt_cpu_feature) * nr_dt_cpu_features, PAGE_SIZE));
+	dt_cpu_features = memblock_alloc(sizeof(struct dt_cpu_feature) * nr_dt_cpu_features, PAGE_SIZE);
 
 	cpufeatures_setup_start(isa);
 
diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index 916ddc4..4a44bc3 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -725,18 +725,15 @@ void exc_lvl_ctx_init(void)
 #endif
 #endif
 
-		memset((void *)critirq_ctx[cpu_nr], 0, THREAD_SIZE);
 		tp = critirq_ctx[cpu_nr];
 		tp->cpu = cpu_nr;
 		tp->preempt_count = 0;
 
 #ifdef CONFIG_BOOKE
-		memset((void *)dbgirq_ctx[cpu_nr], 0, THREAD_SIZE);
 		tp = dbgirq_ctx[cpu_nr];
 		tp->cpu = cpu_nr;
 		tp->preempt_count = 0;
 
-		memset((void *)mcheckirq_ctx[cpu_nr], 0, THREAD_SIZE);
 		tp = mcheckirq_ctx[cpu_nr];
 		tp->cpu = cpu_nr;
 		tp->preempt_count = HARDIRQ_OFFSET;
@@ -754,12 +751,10 @@ void irq_ctx_init(void)
 	int i;
 
 	for_each_possible_cpu(i) {
-		memset((void *)softirq_ctx[i], 0, THREAD_SIZE);
 		tp = softirq_ctx[i];
 		tp->cpu = i;
 		klp_init_thread_info(tp);
 
-		memset((void *)hardirq_ctx[i], 0, THREAD_SIZE);
 		tp = hardirq_ctx[i];
 		tp->cpu = i;
 		klp_init_thread_info(tp);
diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 8c890c6..e7382ab 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -196,7 +196,11 @@ void __init allocate_paca_ptrs(void)
 	paca_nr_cpu_ids = nr_cpu_ids;
 
 	paca_ptrs_size = sizeof(struct paca_struct *) * nr_cpu_ids;
-	paca_ptrs = __va(memblock_phys_alloc(paca_ptrs_size, SMP_CACHE_BYTES));
+	paca_ptrs = memblock_alloc_raw(paca_ptrs_size, SMP_CACHE_BYTES);
+	if (!paca_ptrs)
+		panic("Failed to allocate %d bytes for paca pointers\n",
+		      paca_ptrs_size);
+
 	memset(paca_ptrs, 0x88, paca_ptrs_size);
 }
 
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index e97aaf2..c0ed4fa 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -127,7 +127,10 @@ static void __init move_device_tree(void)
 	if ((memory_limit && (start + size) > PHYSICAL_START + memory_limit) ||
 	    !memblock_is_memory(start + size - 1) ||
 	    overlaps_crashkernel(start, size) || overlaps_initrd(start, size)) {
-		p = __va(memblock_phys_alloc(size, PAGE_SIZE));
+		p = memblock_alloc_raw(size, PAGE_SIZE);
+		if (!p)
+			panic("Failed to allocate %lu bytes to move device tree\n",
+			      size);
 		memcpy(p, initial_boot_params, size);
 		initial_boot_params = p;
 		DBG("Moved device tree to 0x%px\n", p);
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 947f904..1f0b762 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -196,6 +196,17 @@ static int __init ppc_init(void)
 }
 arch_initcall(ppc_init);
 
+static void *__init alloc_stack(void)
+{
+	void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
+
+	if (!ptr)
+		panic("cannot allocate %d bytes for stack at %pS\n",
+		      THREAD_SIZE, (void *)_RET_IP_);
+
+	return ptr;
+}
+
 void __init irqstack_early_init(void)
 {
 	unsigned int i;
@@ -203,10 +214,8 @@ void __init irqstack_early_init(void)
 	/* interrupt stacks must be in lowmem, we get that for free on ppc32
 	 * as the memblock is limited to lowmem by default */
 	for_each_possible_cpu(i) {
-		softirq_ctx[i] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
-		hardirq_ctx[i] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
+		softirq_ctx[i] = alloc_stack();
+		hardirq_ctx[i] = alloc_stack();
 	}
 }
 
@@ -224,13 +233,10 @@ void __init exc_lvl_early_init(void)
 		hw_cpu = 0;
 #endif
 
-		critirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
+		critirq_ctx[hw_cpu] = alloc_stack();
 #ifdef CONFIG_BOOKE
-		dbgirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
-		mcheckirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
+		dbgirq_ctx[hw_cpu] = alloc_stack();
+		mcheckirq_ctx[hw_cpu] = alloc_stack();
 #endif
 	}
 }
-- 
2.7.4
