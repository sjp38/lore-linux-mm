Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 714F9C4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A6762145D
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q5fNwQ6a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A6762145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA8A46B0277; Mon, 10 Jun 2019 18:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B595E6B0278; Mon, 10 Jun 2019 18:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A22326B0279; Mon, 10 Jun 2019 18:17:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF936B0277
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:17:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o184so8150894pfg.1
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:17:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YGTMCWCkvPAIqxrMUQnFWBNeBjNUX65nDUARd571e3A=;
        b=jdrqgPMTW57YKAPixlqDRyeFUVg8NVpGVDtbtATZhK9iGcOZGfhSDuGbgYJpNDsadu
         P9MCwqZIBo9RFqWFR/UCGsVx/loaNszD1iahkTuZyiJ7BnBJEiYvLAl5qRT52cev1cy8
         5lIdj3zEPjD0krBj6+ksowJ2f9onUexhfQjsSS0c2RcyBccd9h1HemGh5k/fljPXU7h/
         diSFsNpcwdxC+sOqdpAoVDjdMA1m5HINEdKHGIVisA8jtCvyKo0KRUBp/b9jlvWUnH0E
         SjRE8Xp1nJjozTDREGHx4VUxKTTinHTJUCpt/YcVkXp6rOYx1rHjZBSHhIwfYu0UHFD5
         SOMA==
X-Gm-Message-State: APjAAAXNFdsSijSQLcPLy+b00epEG4/pDizvNo5AYODc+hQYAufsNaun
	wC2hmYR6GzliIyOYVvXrQej+m+aP0Sk4Efx4nia3CCJYuaLCk69KusKnukm9ZuOBXet6oOAKBQt
	hphM7Oy3lgB6eXhK1U70a2GDRfJylu1Ky9SFjEFqyZjFxytPpbsmEJ+ni9TJ702Q=
X-Received: by 2002:a17:902:9897:: with SMTP id s23mr5739073plp.47.1560205021787;
        Mon, 10 Jun 2019 15:17:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkGmM3W+QrjP/bbuDUhOswxI860Jb5IkuKs1yOYjhFeGaWw8sc0zV+d0ehkkX/ptY+VqHU
X-Received: by 2002:a17:902:9897:: with SMTP id s23mr5738992plp.47.1560205020779;
        Mon, 10 Jun 2019 15:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205020; cv=none;
        d=google.com; s=arc-20160816;
        b=r/MDOablrb2xhhtz481OUqrK1yDPJYE7gteoZt9n96gYcnxZSVpCwlkJyFYNeaV51M
         +2X/ghLXbyNizDA//YZ15JjGvRkaZMYvAevAWaaoYTFXBQNXDScTdDeITOL7ANIMagxW
         IwOomK3JiKqfvuSUCh0RAAd12Il0jdCmL5FJZQFXvc7Zy2aTwBQgTpzvs1d8+/Hns7oV
         k9w1ZCY6t0FSJjJxVs1P/Zq646pw+lynrgdMjZouei8FPxz43b90uFhA+U6by8J46cVU
         zBA5DtsarheKy4MvLzzWpT9xD/dYCYc2k6LkCqJjYsdjh3bmMREY8nfstX65ba/fjbf6
         PRPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YGTMCWCkvPAIqxrMUQnFWBNeBjNUX65nDUARd571e3A=;
        b=1CK/moY1aWliOO3Y5tryvGnjKxYl10Av5gnyXNhFuL6P/oU1WKka3op/BkSaF2g7LZ
         HHm6+swZyyoCOl4lCq1PyTQRZjH3fNzswTfFOPyKgp+38AavOy30dcIlzRIKHSOurHEt
         1Kh77SjfxpUGr0pJ+U5IgIgZkyw6KfY+TTZ153mNDoIx9i7f7kOufCyEOelZ5JQI3gAO
         LKd/hUZb8yZFzI52V/etaU0S1H544gwcQpbFZ0pwcYuqn+zURlhxPrS1tZsH5/7JprQy
         DYyiXpThDX+i0OJoW5Kr4Kwe5kno2WGPsRPTLq9ZB/lNuqllPjSNKFJDgazzWWRlvR1a
         nfAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Q5fNwQ6a;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a10si665410pjh.1.2019.06.10.15.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:17:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Q5fNwQ6a;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YGTMCWCkvPAIqxrMUQnFWBNeBjNUX65nDUARd571e3A=; b=Q5fNwQ6apOmQhrORfwQIEwDGiQ
	fZWhTqOdPwS0pHPDyxuWE8Q+/41Jv6To1QZiIFiNQxb65Q5GfczwZ7IxJvNPU/HRvGUqgJJuwwwlp
	ss8qj+eqxXY5SBJ/B1ZKGPA1Haj3OdUsvQthFlVOJvATuTyXC4+mvbQ2pkFhqH8MtcY1IVkZsIGnM
	+GOyIbhoCcpMq7a0jqcC0BwR+Yla8ZZOIhdRA2IXOpjjOLBPqDuNsTrozSCULLVbMI9/dFrXuNMwc
	yc2QVGjhnMrx7rI8KLAV2V+J6acucXevx3rX/L5rE66iIzfuy0mRgxvNNgFHydYDXy+IMnXDhNC2J
	EUpPtVSw==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSb1-0003av-U9; Mon, 10 Jun 2019 22:16:56 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 12/17] riscv: provide native clint access for M-mode
Date: Tue, 11 Jun 2019 00:16:16 +0200
Message-Id: <20190610221621.10938-13-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610221621.10938-1-hch@lst.de>
References: <20190610221621.10938-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RISC-V has the concept of a cpu level interrupt controller.  Part of it
is expose as bits in the status registers, and 2 new CSRs per privilege
level in the instruction set, but the machanisms to trigger IPIs and
timer events, as well as reading the actual timer value are not
specified in the RISC-V spec but usually delegated to a block of MMIO
registers.  This patch adds support for those MMIO registers in the
timer and IPI code.  For now only the SiFive layout also supported by
a few other implementations is supported, but the code should be
easily extensible to others in the future.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/include/asm/clint.h    | 17 +++++++++++
 arch/riscv/include/asm/timex.h    | 22 ++++++++++++++
 arch/riscv/kernel/Makefile        |  1 +
 arch/riscv/kernel/clint.c         | 50 +++++++++++++++++++++++++++++++
 arch/riscv/kernel/setup.c         |  2 ++
 arch/riscv/kernel/smp.c           | 24 +++++++++++++++
 arch/riscv/kernel/smpboot.c       |  3 ++
 drivers/clocksource/timer-riscv.c | 11 ++++++-
 8 files changed, 129 insertions(+), 1 deletion(-)
 create mode 100644 arch/riscv/include/asm/clint.h
 create mode 100644 arch/riscv/kernel/clint.c

diff --git a/arch/riscv/include/asm/clint.h b/arch/riscv/include/asm/clint.h
new file mode 100644
index 000000000000..77559d07db33
--- /dev/null
+++ b/arch/riscv/include/asm/clint.h
@@ -0,0 +1,17 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef _ASM_CLINT_H
+#define _ASM_CLINT_H 1
+
+#ifdef CONFIG_M_MODE
+extern u32 __iomem *clint_ipi_base;
+extern u64 __iomem *clint_time_val;
+extern u64 __iomem *clint_time_cmp;
+
+void clint_init_one(void);
+void clint_init_boot_cpu(void);
+#else
+#define clint_init_one()	do { } while (0)
+#define clint_init_boot_cpu()	do { } while (0)
+#endif /* CONFIG_M_MODE */
+
+#endif /* _ASM_CLINT_H */
diff --git a/arch/riscv/include/asm/timex.h b/arch/riscv/include/asm/timex.h
index 6a703ec9d796..2a95adf8bba0 100644
--- a/arch/riscv/include/asm/timex.h
+++ b/arch/riscv/include/asm/timex.h
@@ -10,6 +10,27 @@
 
 typedef unsigned long cycles_t;
 
+#ifdef CONFIG_M_MODE
+
+#include <linux/io-64-nonatomic-lo-hi.h>
+#include <asm/clint.h>
+
+static inline uint64_t get_cycles64(void)
+{
+	return readq_relaxed(clint_time_val);
+}
+
+#ifdef CONFIG_64BIT
+#define get_cycles	get_cycles64
+#else
+static inline cycles_t get_cycles(void)
+{
+	return readl_relaxed(clint_time_val);
+}
+#define get_cycles	get_cycles
+#endif /* CONFIG_64BIT */
+
+#else /* CONFIG_M_MODE */
 static inline cycles_t get_cycles_inline(void)
 {
 	cycles_t n;
@@ -40,6 +61,7 @@ static inline uint64_t get_cycles64(void)
 	return ((u64)hi << 32) | lo;
 }
 #endif
+#endif /* CONFIG_M_MODE */
 
 #define ARCH_HAS_READ_CURRENT_TIMER
 
diff --git a/arch/riscv/kernel/Makefile b/arch/riscv/kernel/Makefile
index 2420d37d96de..f933c04f89db 100644
--- a/arch/riscv/kernel/Makefile
+++ b/arch/riscv/kernel/Makefile
@@ -29,6 +29,7 @@ obj-y	+= vdso.o
 obj-y	+= cacheinfo.o
 obj-y	+= vdso/
 
+obj-$(CONFIG_M_MODE)		+= clint.o
 obj-$(CONFIG_FPU)		+= fpu.o
 obj-$(CONFIG_SMP)		+= smpboot.o
 obj-$(CONFIG_SMP)		+= smp.o
diff --git a/arch/riscv/kernel/clint.c b/arch/riscv/kernel/clint.c
new file mode 100644
index 000000000000..a1089ccab9e3
--- /dev/null
+++ b/arch/riscv/kernel/clint.c
@@ -0,0 +1,50 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2019 Christoph Hellwig.
+ */
+
+#include <linux/io.h>
+#include <linux/of_address.h>
+#include <linux/types.h>
+#include <asm/csr.h>
+#include <asm/irq.h>
+#include <asm/timex.h>
+
+/*
+ * This is the layout used by the SiFive clint, which is also shared by the qemu
+ * virt platform, and the Kendryte KD210 at least.
+ */
+#define CLINT_IPI_OFF		0
+#define CLINT_TIME_VAL_OFF	0xbff8
+#define CLINT_TIME_CMP_OFF	0x4000;
+
+u32 __iomem *clint_ipi_base;
+u64 __iomem *clint_time_val;
+u64 __iomem *clint_time_cmp;
+
+void clint_init_one(void)
+{
+	writel(0, clint_ipi_base + csr_read(mhartid));
+}
+
+void clint_init_boot_cpu(void)
+{
+	struct device_node *np;
+	void __iomem *base;
+
+	np = of_find_compatible_node(NULL, NULL, "riscv,clint0");
+	if (!np) {
+		panic("clint not found");
+		return;
+	}
+
+	base = of_iomap(np, 0);
+	if (!base)
+		panic("could not map CLINT");
+
+	clint_ipi_base = base + CLINT_IPI_OFF;
+	clint_time_val = base + CLINT_TIME_VAL_OFF;
+	clint_time_cmp = base + CLINT_TIME_CMP_OFF;
+
+	clint_init_one();
+}
diff --git a/arch/riscv/kernel/setup.c b/arch/riscv/kernel/setup.c
index b92e6831d1ec..2892d82f474c 100644
--- a/arch/riscv/kernel/setup.c
+++ b/arch/riscv/kernel/setup.c
@@ -17,6 +17,7 @@
 #include <linux/sched/task.h>
 #include <linux/swiotlb.h>
 
+#include <asm/clint.h>
 #include <asm/setup.h>
 #include <asm/sections.h>
 #include <asm/pgtable.h>
@@ -67,6 +68,7 @@ void __init setup_arch(char **cmdline_p)
 	setup_bootmem();
 	paging_init();
 	unflatten_device_tree();
+	clint_init_boot_cpu();
 
 #ifdef CONFIG_SWIOTLB
 	swiotlb_init(1);
diff --git a/arch/riscv/kernel/smp.c b/arch/riscv/kernel/smp.c
index 91164204496c..e498a5e1615c 100644
--- a/arch/riscv/kernel/smp.c
+++ b/arch/riscv/kernel/smp.c
@@ -24,7 +24,9 @@
 #include <linux/sched.h>
 #include <linux/seq_file.h>
 #include <linux/delay.h>
+#include <linux/io.h>
 
+#include <asm/clint.h>
 #include <asm/sbi.h>
 #include <asm/tlbflush.h>
 #include <asm/cacheflush.h>
@@ -89,6 +91,27 @@ static void ipi_stop(void)
 		wait_for_interrupt();
 }
 
+#ifdef CONFIG_M_MODE
+static inline void send_ipi_single(int cpu, enum ipi_message_type op)
+{
+	set_bit(op, &ipi_data[cpu].bits);
+	writel(1, clint_ipi_base + cpuid_to_hartid_map(cpu));
+}
+
+static inline void send_ipi_mask(const struct cpumask *mask,
+		enum ipi_message_type op)
+{
+	int cpu;
+
+	for_each_cpu(cpu, mask)
+		send_ipi_single(cpu, op);
+}
+
+static inline void clear_ipi(void)
+{
+	writel(0, clint_ipi_base + cpuid_to_hartid_map(smp_processor_id()));
+}
+#else /* CONFIG_M_MODE */
 static void send_ipi_mask(const struct cpumask *mask, enum ipi_message_type op)
 {
 	int cpuid, hartid;
@@ -114,6 +137,7 @@ static inline void clear_ipi(void)
 {
 	csr_clear(CSR_SIP, SIE_SSIE);
 }
+#endif /* CONFIG_M_MODE */
 
 void riscv_software_interrupt(void)
 {
diff --git a/arch/riscv/kernel/smpboot.c b/arch/riscv/kernel/smpboot.c
index 7462a44304fe..5737c8e9c97d 100644
--- a/arch/riscv/kernel/smpboot.c
+++ b/arch/riscv/kernel/smpboot.c
@@ -23,6 +23,7 @@
 #include <linux/of.h>
 #include <linux/sched/task_stack.h>
 #include <linux/sched/mm.h>
+#include <asm/clint.h>
 #include <asm/irq.h>
 #include <asm/mmu_context.h>
 #include <asm/tlbflush.h>
@@ -132,6 +133,8 @@ asmlinkage void __init smp_callin(void)
 {
 	struct mm_struct *mm = &init_mm;
 
+	clint_init_one();
+
 	/* All kernel threads share the same mm context.  */
 	mmgrab(mm);
 	current->active_mm = mm;
diff --git a/drivers/clocksource/timer-riscv.c b/drivers/clocksource/timer-riscv.c
index 2e2d363faabf..281915c3e6f2 100644
--- a/drivers/clocksource/timer-riscv.c
+++ b/drivers/clocksource/timer-riscv.c
@@ -24,7 +24,15 @@
  * operations on the current hart.  There is guaranteed to be exactly one timer
  * per hart on all RISC-V systems.
  */
-
+#ifdef CONFIG_M_MODE
+static int riscv_clock_next_event(unsigned long delta,
+		struct clock_event_device *ce)
+{
+	csr_set(CSR_XIE, XIE_XTIE);
+	writeq(get_cycles64() + delta, clint_time_cmp + csr_read(mhartid));
+	return 0;
+}
+#else
 static int riscv_clock_next_event(unsigned long delta,
 		struct clock_event_device *ce)
 {
@@ -32,6 +40,7 @@ static int riscv_clock_next_event(unsigned long delta,
 	sbi_set_timer(get_cycles64() + delta);
 	return 0;
 }
+#endif /* #ifdef CONFIG_M_MODE */
 
 static DEFINE_PER_CPU(struct clock_event_device, riscv_clock_event) = {
 	.name			= "riscv_timer_clockevent",
-- 
2.20.1

