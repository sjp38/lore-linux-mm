Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 725EDC48BE3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 200CC2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pE4dI02l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 200CC2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6798C6B026A; Mon, 24 Jun 2019 01:43:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62BDA8E0002; Mon, 24 Jun 2019 01:43:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42F2D8E0001; Mon, 24 Jun 2019 01:43:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3206B026A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:56 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s195so8644991pgs.13
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=f/LMSlxfhI7zBN2HPhyn2vXf7Q0YVjnn4dkhV1o/cCs=;
        b=Zofyg/8i2F+YS7MXXJS6oE9hFzABhkbj0gt+YvmlvBTUMf3qKrYm5HR8cBVylqda5C
         Zk1rEHhR3ucKmm+9LSt/TLjFfkkkDvjo1nNInEDAEfzU/Ba+CO5zD3pCpei8AeXq5Kl1
         eT7i5ELB+/+NMqKN+7qGxFzMHIerJpXSiCLQz90akkXo329Z6wmWjHpPHFgklbz6rCn5
         JFsQK3cqPJrStHJr5npmg+9eiqRNX5BwTeKdRngGtv3OTLFrlmJohtB44qbiErJnjZDf
         mBinrcvtZ/tfAF8YQLZGYGJMl6hBfVpF9wffJFE6Q7VTwu3fxle3dFCHNPFrCaVoQ5b8
         h2Tw==
X-Gm-Message-State: APjAAAVGN8rfUv8bgnYKnnCA0l7KuPLqWTGavj6NiwITZMBi19EBvuB+
	PyLNReZBKI8UvLtFEhisKl5dQA4574V1F7m5k3yWo5oOOol44ExK2Y5z05umcez4OCODH4O29yA
	5aVstoaCO0xePvc2OG7zvCOD+qV6EhH25emoQxDplTaD+ebWRvmEWxG3rD0Y882g=
X-Received: by 2002:a17:90a:ba93:: with SMTP id t19mr22381012pjr.139.1561355035675;
        Sun, 23 Jun 2019 22:43:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcoZaM2ponF/yyjOpkkZx6gm/5qorYrIhZHuplJP9+DCuWBPsKaKeoO/yliR4FHLA/q/+6
X-Received: by 2002:a17:90a:ba93:: with SMTP id t19mr22380959pjr.139.1561355034695;
        Sun, 23 Jun 2019 22:43:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355034; cv=none;
        d=google.com; s=arc-20160816;
        b=INj3v7UtsR1APZCI5zPhaEKTyICYEDCCFLzjiKELSQmVcH2ItlAFuPZIeBzX1YOj5d
         Q5e05QMNfBfFGSruSFPMmjomvpzOIsXcR/kM6quHue6xcQ6/oO0bU7vy9L6e63YBf5A5
         IYzK09U3rFB4AC2hbuIikqiSronzZ7MuYhokwnFf8+iNbTfICWe4IDmL18xcrSjtx330
         sx/wkWu66eCod8GfBoHyHNVojnF+3B5pjYYiGdjsG440YEtPy+J1qC1q9D7WwI8/yGCK
         eN6Szl6lq3o8gPiVB0V8qYo8Y07VIW6v9xX4S5O54gL8I+gcsnkDuJlwNYNkV4sxC1co
         0wOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=f/LMSlxfhI7zBN2HPhyn2vXf7Q0YVjnn4dkhV1o/cCs=;
        b=gN6nGoT1yaLlQJ5qLvrl5BNUGQkloHLKbuvDRSn0tZlWZU2uO+yjCYQyVOGTBoQBL9
         MCXZwkSZ/SHgFI5IZwzCSJ3PntzVHgV93lLCxwLnAgAjTQRrZN/0dF4I4ciyFoNW9bAu
         Ev+Pbb05SzrtufAUEf7THjUYyh0vvh+MeqQjE4/XS2Ffs/dWCdPUsGjOCKZDDy/y86a/
         BHscc7T74mmZZLFB7jSxrgRB+YXNAnsohe/eWXurrBHWTpz2U94UfGCgdOT0zqvqtX1B
         Kzn9EjLnMgQbDA/Y7ERLF05ZH5Otip9kkLJzB75YEJMS/AXjh4xHqCADL7jE2BcmYfwX
         Nggg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pE4dI02l;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33si9368165pli.144.2019.06.23.22.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pE4dI02l;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=f/LMSlxfhI7zBN2HPhyn2vXf7Q0YVjnn4dkhV1o/cCs=; b=pE4dI02lDFfkAV82lMiqZforjy
	SG8akkDP/ZbgaSrs+ci1Ww+ClWN3TIs/e2BGmih9m1XnFy7suJnKZb7wRpi2ZLabuo7kIxpKfX173
	TbXzu+w+qPkAIwKYjE6uwsy++/t3xcQbwOIWoVI9LMjU+hM3TIbsmlWMl2FIQInTv4tc3NxFPb2KG
	Z0/2oVjWC8zT/BhhTsD57BD0nMkDQKjDr6maNaiBp1ev3xHz2Y+/4nO8OL1XSf6G8mTiEm88Gjplr
	VfPkrdYotaO/y0aV4AjWWDBr65EuvWHwT+5P8pSs8zTVVQWUtrm7HCf9hutHyKpw/HLo63mGonrFG
	P5RplXeQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlg-0006c3-P1; Mon, 24 Jun 2019 05:43:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/17] riscv: provide native clint access for M-mode
Date: Mon, 24 Jun 2019 07:43:05 +0200
Message-Id: <20190624054311.30256-12-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
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
 arch/riscv/include/asm/clint.h    | 40 +++++++++++++++++++++++++++
 arch/riscv/include/asm/timex.h    | 17 ++++++++++++
 arch/riscv/kernel/Makefile        |  1 +
 arch/riscv/kernel/clint.c         | 45 +++++++++++++++++++++++++++++++
 arch/riscv/kernel/setup.c         |  2 ++
 arch/riscv/kernel/smp.c           | 24 +++++++++++++++++
 arch/riscv/kernel/smpboot.c       |  3 +++
 drivers/clocksource/timer-riscv.c | 16 ++++++++---
 8 files changed, 144 insertions(+), 4 deletions(-)
 create mode 100644 arch/riscv/include/asm/clint.h
 create mode 100644 arch/riscv/kernel/clint.c

diff --git a/arch/riscv/include/asm/clint.h b/arch/riscv/include/asm/clint.h
new file mode 100644
index 000000000000..46d182d9a4db
--- /dev/null
+++ b/arch/riscv/include/asm/clint.h
@@ -0,0 +1,40 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef _ASM_CLINT_H
+#define _ASM_CLINT_H 1
+
+#include <linux/smp.h>
+
+#ifdef CONFIG_M_MODE
+extern u32 __iomem *clint_ipi_base;
+extern u64 __iomem *clint_time_val;
+extern u64 __iomem *clint_time_cmp;
+
+void clint_init_boot_cpu(void);
+
+static inline void clint_send_ipi(unsigned long hartid)
+{
+	writel(1, clint_ipi_base + hartid);
+}
+
+static inline void clint_clear_ipi(unsigned long hartid)
+{
+	writel(0, clint_ipi_base + hartid);
+}
+
+static inline u64 clint_read_timer(void)
+{
+	return readq_relaxed(clint_time_val);
+}
+
+static inline void clint_set_timer(unsigned long delta)
+{
+	writeq_relaxed(clint_read_timer() + delta,
+		clint_time_cmp + cpuid_to_hartid_map(smp_processor_id()));
+}
+
+#else
+#define clint_init_boot_cpu()	do { } while (0)
+#define clint_clear_ipi(hartid)	do { } while (0)
+#endif /* CONFIG_M_MODE */
+
+#endif /* _ASM_CLINT_H */
diff --git a/arch/riscv/include/asm/timex.h b/arch/riscv/include/asm/timex.h
index 6a703ec9d796..bf907997f107 100644
--- a/arch/riscv/include/asm/timex.h
+++ b/arch/riscv/include/asm/timex.h
@@ -10,6 +10,22 @@
 
 typedef unsigned long cycles_t;
 
+#ifdef CONFIG_M_MODE
+
+#include <linux/io-64-nonatomic-lo-hi.h>
+#include <asm/clint.h>
+
+static inline cycles_t get_cycles(void)
+{
+#ifdef CONFIG_64BIT
+	return readq_relaxed(clint_time_val);
+#else
+	return readl_relaxed(clint_time_val);
+#endif
+}
+#define get_cycles	get_cycles
+
+#else /* CONFIG_M_MODE */
 static inline cycles_t get_cycles_inline(void)
 {
 	cycles_t n;
@@ -40,6 +56,7 @@ static inline uint64_t get_cycles64(void)
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
index 000000000000..15b9e7fa5416
--- /dev/null
+++ b/arch/riscv/kernel/clint.c
@@ -0,0 +1,45 @@
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
+	clint_clear_ipi(boot_cpu_hartid);
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
index 8cd730239613..ee8599a7ca48 100644
--- a/arch/riscv/kernel/smp.c
+++ b/arch/riscv/kernel/smp.c
@@ -13,7 +13,9 @@
 #include <linux/sched.h>
 #include <linux/seq_file.h>
 #include <linux/delay.h>
+#include <linux/io.h>
 
+#include <asm/clint.h>
 #include <asm/sbi.h>
 #include <asm/tlbflush.h>
 #include <asm/cacheflush.h>
@@ -78,6 +80,27 @@ static void ipi_stop(void)
 		wait_for_interrupt();
 }
 
+#ifdef CONFIG_M_MODE
+static inline void send_ipi_single(int cpu, enum ipi_message_type op)
+{
+	set_bit(op, &ipi_data[cpu].bits);
+	clint_send_ipi(cpuid_to_hartid_map(cpu));
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
+	clint_clear_ipi(cpuid_to_hartid_map(smp_processor_id()));
+}
+#else /* CONFIG_M_MODE */
 static void send_ipi_mask(const struct cpumask *mask, enum ipi_message_type op)
 {
 	int cpuid, hartid;
@@ -103,6 +126,7 @@ static inline void clear_ipi(void)
 {
 	csr_clear(CSR_SIP, SIE_SSIE);
 }
+#endif /* CONFIG_M_MODE */
 
 void riscv_software_interrupt(void)
 {
diff --git a/arch/riscv/kernel/smpboot.c b/arch/riscv/kernel/smpboot.c
index 7462a44304fe..1b7678d86ec8 100644
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
 
+	clint_clear_ipi(cpuid_to_hartid_map(smp_processor_id()));
+
 	/* All kernel threads share the same mm context.  */
 	mmgrab(mm);
 	current->active_mm = mm;
diff --git a/drivers/clocksource/timer-riscv.c b/drivers/clocksource/timer-riscv.c
index 2e2d363faabf..008af21611d9 100644
--- a/drivers/clocksource/timer-riscv.c
+++ b/drivers/clocksource/timer-riscv.c
@@ -24,12 +24,16 @@
  * operations on the current hart.  There is guaranteed to be exactly one timer
  * per hart on all RISC-V systems.
  */
-
 static int riscv_clock_next_event(unsigned long delta,
 		struct clock_event_device *ce)
 {
 	csr_set(CSR_XIE, XIE_XTIE);
+
+#ifdef CONFIG_M_MODE
+	clint_set_timer(delta);
+#else
 	sbi_set_timer(get_cycles64() + delta);
+#endif
 	return 0;
 }
 
@@ -45,14 +49,18 @@ static DEFINE_PER_CPU(struct clock_event_device, riscv_clock_event) = {
  * within one tick of each other, so while this could technically go
  * backwards when hopping between CPUs, practically it won't happen.
  */
-static unsigned long long riscv_clocksource_rdtime(struct clocksource *cs)
+static u64 riscv_sched_clock(void)
 {
+#ifdef CONFIG_M_MODE
+	return clint_read_timer();
+#else
 	return get_cycles64();
+#endif
 }
 
-static u64 riscv_sched_clock(void)
+static unsigned long long riscv_clocksource_rdtime(struct clocksource *cs)
 {
-	return get_cycles64();
+	return riscv_sched_clock();
 }
 
 static DEFINE_PER_CPU(struct clocksource, riscv_clocksource) = {
-- 
2.20.1

