Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD140C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:21:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6504B21873
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:21:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6504B21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BB9A6B0007; Fri, 22 Mar 2019 09:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F36FE6B0008; Fri, 22 Mar 2019 09:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DADCD6B000A; Fri, 22 Mar 2019 09:21:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53ACA6B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:21:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i59so940395edi.15
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:21:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hhHAufUIypftYMknO5/rktwjo4O494ALWthxV4C0u1A=;
        b=ONZDnGVozQhWWeMnCMnaz1R/pTRMHZzumP/QV90JiU40TpV1tEnyOjmCESN2tVcxgK
         KdPLceU5uQaVzqcMMiM5l1hm+X3mvo/79BqSrEBwqP4HE1YJ1QTS9FzCRXc1nkfbEga4
         YBGRqGmxvoWJhUGf0kpGcP5HHlTjeQqQQo0avmMgbe4DBRK3jKXr3DNBUags0HS6RHJX
         FeKlwobTdFH6aBA30N8VAON8ixxortGDRenYjjjeDLvQWDr1inMXMWGW3X/qnSNm0tIu
         tdh6rY3wdWQd0V0HjDMOCmtIu0+frLgmYVV0anN97w8zr8oIsvTYGxKNepKAQjzHnCm/
         BAFQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) smtp.mailfrom=sakari.ailus@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW48qkubYPBTB86UbvBijQwwS6pigQsG7SOxh5ylaU9dCnjmt4y
	FRDEDmPXxj8Sdn11M7aY4aI/w7qOuWAOg6eSTm+l5FFBFxLRs4tnMS7HGkUgjSfjllKyFKoZFSL
	39F8CTeznm/xj8sBFASe5uTtuzRfUs+KB4WhWtromI3LZy3GbGUDvAO03hpW+HGI=
X-Received: by 2002:a50:8835:: with SMTP id b50mr6486127edb.262.1553260875718;
        Fri, 22 Mar 2019 06:21:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsqWWh2ahr1jrdHbqIixsjEaLSL2cTSGcCVtlWMlzJdxxoV4Yoef3g7ppUQb/4gQdkOxCH
X-Received: by 2002:a50:8835:: with SMTP id b50mr6485880edb.262.1553260870977;
        Fri, 22 Mar 2019 06:21:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553260870; cv=none;
        d=google.com; s=arc-20160816;
        b=vN2449phJXyARF94qmpozq98jtBzVG/d5H+YzIay7hiAN2XsGpKrmJLPD0BiBx88Lz
         G5gqgyBUfSDha8JB5MBXNMVQAeYOgehNLT5y2wsLiaa13lvaU+KYpubSXu0W1idwiGn2
         1r1xL6bL7T4tXBX2ddDJcPXPfxte5vKy8zgyIafFTOeqbAJFWx3JtOIif4olcc23kURz
         be1SNaQlCnIVHWq5qy3fRstUpoVvBaAeqxOGjXPPguyUzlrE/DCa6F37I1gNPNgStv7J
         m2ao5FA91cGgkl2bHhlYIY+Q2guSX5lR7xwAxulaidOnvuUy2Kjaa8At0OSxqOxIrr6B
         X/vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hhHAufUIypftYMknO5/rktwjo4O494ALWthxV4C0u1A=;
        b=m4Ais7bKxg00wjQvUqrmv4Xrzs6co8VeXtoh3rogvwqxSquBdCLq5Go387SDKo9xLB
         h/Yn6X02WuRxd6vFPCDWPSrjWbnG0nplrAhFjE2lwzcMlGJ4QcLqv3U7M4UdWS/FZ7yL
         0tLgH6NFOZ6DkAicx+afBQYecUgPGI4cu9vizmUwtHyAS6MUJIYy0us30330nwLCTmAs
         rY3CLf/XSAS2qPxSE7lvIjjuIoWoVv7aXTo+xfR2Rdp4cbvwWZLsxjJPzXZLqmf6mrCm
         bsup4KhOXCyPAhsVt6VO/W9yT8Q4GtsalnZEY4fyrDbu31jPRnDcmMfavZXKRw6o8c38
         f9rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from hillosipuli.retiisi.org.uk (retiisi.org.uk. [95.216.213.190])
        by mx.google.com with ESMTPS id 11si182881ejz.190.2019.03.22.06.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 06:21:10 -0700 (PDT)
Received-SPF: neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) client-ip=95.216.213.190;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from lanttu.localdomain (unknown [IPv6:2a01:4f9:c010:4572::e1:1001])
	by hillosipuli.retiisi.org.uk (Postfix) with ESMTP id F05C4634C7D;
	Fri, 22 Mar 2019 15:19:02 +0200 (EET)
From: Sakari Ailus <sakari.ailus@linux.intel.com>
To: Petr Mladek <pmladek@suse.com>,
	linux-kernel@vger.kernel.org
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org,
	sparclinux@vger.kernel.org,
	linux-um@lists.infradead.org,
	xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org,
	linux-pm@vger.kernel.org,
	drbd-dev@lists.linbit.com,
	linux-block@vger.kernel.org,
	linux-mmc@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH 1/2] treewide: Switch printk users from %pf and %pF to %ps and %pS, respectively
Date: Fri, 22 Mar 2019 15:21:07 +0200
Message-Id: <20190322132108.25501-2-sakari.ailus@linux.intel.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

%pF and %pf are functionally equivalent to %pS and %ps conversion
specifiers. The former are deprecated, therefore switch the current users
to use the preferred variant.

The changes have been produced by the following command:

	git grep -l '%p[fF]' | grep -v '^\(tools\|Documentation\)/' | \
	while read i; do perl -i -pe 's/%pf/%ps/g; s/%pF/%pS/g;' $i; done

And verifying the result.

Signed-off-by: Sakari Ailus <sakari.ailus@linux.intel.com>
---
 arch/alpha/kernel/pci_iommu.c           | 20 ++++++++++----------
 arch/arm/mach-imx/pm-imx6.c             |  2 +-
 arch/arm/mm/alignment.c                 |  2 +-
 arch/arm/nwfpe/fpmodule.c               |  2 +-
 arch/microblaze/mm/pgtable.c            |  2 +-
 arch/sparc/kernel/ds.c                  |  2 +-
 arch/um/kernel/sysrq.c                  |  2 +-
 arch/x86/include/asm/trace/exceptions.h |  2 +-
 arch/x86/kernel/irq_64.c                |  2 +-
 arch/x86/mm/extable.c                   |  4 ++--
 arch/x86/xen/multicalls.c               |  2 +-
 drivers/acpi/device_pm.c                |  2 +-
 drivers/base/power/main.c               |  6 +++---
 drivers/base/syscore.c                  | 12 ++++++------
 drivers/block/drbd/drbd_receiver.c      |  2 +-
 drivers/block/floppy.c                  | 10 +++++-----
 drivers/cpufreq/cpufreq.c               |  2 +-
 drivers/mmc/core/quirks.h               |  2 +-
 drivers/nvdimm/bus.c                    |  2 +-
 drivers/nvdimm/dimm_devs.c              |  2 +-
 drivers/pci/pci-driver.c                | 14 +++++++-------
 drivers/pci/quirks.c                    |  4 ++--
 drivers/pnp/quirks.c                    |  2 +-
 drivers/scsi/esp_scsi.c                 |  2 +-
 fs/btrfs/tests/free-space-tree-tests.c  |  4 ++--
 fs/f2fs/f2fs.h                          |  2 +-
 fs/pstore/inode.c                       |  2 +-
 include/trace/events/btrfs.h            |  2 +-
 include/trace/events/cpuhp.h            |  4 ++--
 include/trace/events/preemptirq.h       |  2 +-
 include/trace/events/rcu.h              |  4 ++--
 include/trace/events/sunrpc.h           |  2 +-
 include/trace/events/timer.h            |  8 ++++----
 include/trace/events/vmscan.h           |  4 ++--
 include/trace/events/workqueue.h        |  4 ++--
 include/trace/events/xen.h              |  2 +-
 init/main.c                             |  6 +++---
 kernel/async.c                          |  4 ++--
 kernel/events/uprobes.c                 |  2 +-
 kernel/fail_function.c                  |  2 +-
 kernel/irq/debugfs.c                    |  2 +-
 kernel/irq/handle.c                     |  2 +-
 kernel/irq/manage.c                     |  2 +-
 kernel/irq/spurious.c                   |  4 ++--
 kernel/rcu/tree.c                       |  2 +-
 kernel/stop_machine.c                   |  2 +-
 kernel/time/sched_clock.c               |  2 +-
 kernel/time/timer.c                     |  2 +-
 kernel/workqueue.c                      | 12 ++++++------
 lib/error-inject.c                      |  2 +-
 lib/percpu-refcount.c                   |  4 ++--
 mm/memblock.c                           | 12 ++++++------
 mm/memory.c                             |  2 +-
 mm/vmscan.c                             |  2 +-
 net/ceph/osd_client.c                   |  2 +-
 net/core/net-procfs.c                   |  2 +-
 net/core/netpoll.c                      |  4 ++--
 57 files changed, 109 insertions(+), 109 deletions(-)

diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 3034d6d936d2..242108439f42 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -249,7 +249,7 @@ static int pci_dac_dma_supported(struct pci_dev *dev, u64 mask)
 		ok = 0;
 
 	/* If both conditions above are met, we are fine. */
-	DBGA("pci_dac_dma_supported %s from %pf\n",
+	DBGA("pci_dac_dma_supported %s from %ps\n",
 	     ok ? "yes" : "no", __builtin_return_address(0));
 
 	return ok;
@@ -281,7 +281,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	    && paddr + size <= __direct_map_size) {
 		ret = paddr + __direct_map_base;
 
-		DBGA2("pci_map_single: [%p,%zx] -> direct %llx from %pf\n",
+		DBGA2("pci_map_single: [%p,%zx] -> direct %llx from %ps\n",
 		      cpu_addr, size, ret, __builtin_return_address(0));
 
 		return ret;
@@ -292,7 +292,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	if (dac_allowed) {
 		ret = paddr + alpha_mv.pci_dac_offset;
 
-		DBGA2("pci_map_single: [%p,%zx] -> DAC %llx from %pf\n",
+		DBGA2("pci_map_single: [%p,%zx] -> DAC %llx from %ps\n",
 		      cpu_addr, size, ret, __builtin_return_address(0));
 
 		return ret;
@@ -329,7 +329,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	ret = arena->dma_base + dma_ofs * PAGE_SIZE;
 	ret += (unsigned long)cpu_addr & ~PAGE_MASK;
 
-	DBGA2("pci_map_single: [%p,%zx] np %ld -> sg %llx from %pf\n",
+	DBGA2("pci_map_single: [%p,%zx] np %ld -> sg %llx from %ps\n",
 	      cpu_addr, size, npages, ret, __builtin_return_address(0));
 
 	return ret;
@@ -396,14 +396,14 @@ static void alpha_pci_unmap_page(struct device *dev, dma_addr_t dma_addr,
 	    && dma_addr < __direct_map_base + __direct_map_size) {
 		/* Nothing to do.  */
 
-		DBGA2("pci_unmap_single: direct [%llx,%zx] from %pf\n",
+		DBGA2("pci_unmap_single: direct [%llx,%zx] from %ps\n",
 		      dma_addr, size, __builtin_return_address(0));
 
 		return;
 	}
 
 	if (dma_addr > 0xffffffff) {
-		DBGA2("pci64_unmap_single: DAC [%llx,%zx] from %pf\n",
+		DBGA2("pci64_unmap_single: DAC [%llx,%zx] from %ps\n",
 		      dma_addr, size, __builtin_return_address(0));
 		return;
 	}
@@ -435,7 +435,7 @@ static void alpha_pci_unmap_page(struct device *dev, dma_addr_t dma_addr,
 
 	spin_unlock_irqrestore(&arena->lock, flags);
 
-	DBGA2("pci_unmap_single: sg [%llx,%zx] np %ld from %pf\n",
+	DBGA2("pci_unmap_single: sg [%llx,%zx] np %ld from %ps\n",
 	      dma_addr, size, npages, __builtin_return_address(0));
 }
 
@@ -458,7 +458,7 @@ static void *alpha_pci_alloc_coherent(struct device *dev, size_t size,
 	cpu_addr = (void *)__get_free_pages(gfp | __GFP_ZERO, order);
 	if (! cpu_addr) {
 		printk(KERN_INFO "pci_alloc_consistent: "
-		       "get_free_pages failed from %pf\n",
+		       "get_free_pages failed from %ps\n",
 			__builtin_return_address(0));
 		/* ??? Really atomic allocation?  Otherwise we could play
 		   with vmalloc and sg if we can't find contiguous memory.  */
@@ -477,7 +477,7 @@ static void *alpha_pci_alloc_coherent(struct device *dev, size_t size,
 		goto try_again;
 	}
 
-	DBGA2("pci_alloc_consistent: %zx -> [%p,%llx] from %pf\n",
+	DBGA2("pci_alloc_consistent: %zx -> [%p,%llx] from %ps\n",
 	      size, cpu_addr, *dma_addrp, __builtin_return_address(0));
 
 	return cpu_addr;
@@ -497,7 +497,7 @@ static void alpha_pci_free_coherent(struct device *dev, size_t size,
 	pci_unmap_single(pdev, dma_addr, size, PCI_DMA_BIDIRECTIONAL);
 	free_pages((unsigned long)cpu_addr, get_order(size));
 
-	DBGA2("pci_free_consistent: [%llx,%zx] from %pf\n",
+	DBGA2("pci_free_consistent: [%llx,%zx] from %ps\n",
 	      dma_addr, size, __builtin_return_address(0));
 }
 
diff --git a/arch/arm/mach-imx/pm-imx6.c b/arch/arm/mach-imx/pm-imx6.c
index 87f45b926c78..e67e0b2d4ce0 100644
--- a/arch/arm/mach-imx/pm-imx6.c
+++ b/arch/arm/mach-imx/pm-imx6.c
@@ -631,7 +631,7 @@ static void imx6_pm_stby_poweroff(void)
 static int imx6_pm_stby_poweroff_probe(void)
 {
 	if (pm_power_off) {
-		pr_warn("%s: pm_power_off already claimed  %p %pf!\n",
+		pr_warn("%s: pm_power_off already claimed  %p %ps!\n",
 			__func__, pm_power_off, pm_power_off);
 		return -EBUSY;
 	}
diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index b54f8f8def36..e376883ab35b 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -133,7 +133,7 @@ static const char *usermode_action[] = {
 static int alignment_proc_show(struct seq_file *m, void *v)
 {
 	seq_printf(m, "User:\t\t%lu\n", ai_user);
-	seq_printf(m, "System:\t\t%lu (%pF)\n", ai_sys, ai_sys_last_pc);
+	seq_printf(m, "System:\t\t%lu (%pS)\n", ai_sys, ai_sys_last_pc);
 	seq_printf(m, "Skipped:\t%lu\n", ai_skipped);
 	seq_printf(m, "Half:\t\t%lu\n", ai_half);
 	seq_printf(m, "Word:\t\t%lu\n", ai_word);
diff --git a/arch/arm/nwfpe/fpmodule.c b/arch/arm/nwfpe/fpmodule.c
index 1365e8650843..ee34c76e6624 100644
--- a/arch/arm/nwfpe/fpmodule.c
+++ b/arch/arm/nwfpe/fpmodule.c
@@ -147,7 +147,7 @@ void float_raise(signed char flags)
 #ifdef CONFIG_DEBUG_USER
 	if (flags & debug)
  		printk(KERN_DEBUG
-		       "NWFPE: %s[%d] takes exception %08x at %pf from %08lx\n",
+		       "NWFPE: %s[%d] takes exception %08x at %ps from %08lx\n",
 		       current->comm, current->pid, flags,
 		       __builtin_return_address(0), GET_USERREG()->ARM_pc);
 #endif
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index c2ce1e42b888..8fe54fda31dc 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -75,7 +75,7 @@ static void __iomem *__ioremap(phys_addr_t addr, unsigned long size,
 		p >= memory_start && p < virt_to_phys(high_memory) &&
 		!(p >= __virt_to_phys((phys_addr_t)__bss_stop) &&
 		p < __virt_to_phys((phys_addr_t)__bss_stop))) {
-		pr_warn("__ioremap(): phys addr "PTE_FMT" is RAM lr %pf\n",
+		pr_warn("__ioremap(): phys addr "PTE_FMT" is RAM lr %ps\n",
 			(unsigned long)p, __builtin_return_address(0));
 		return NULL;
 	}
diff --git a/arch/sparc/kernel/ds.c b/arch/sparc/kernel/ds.c
index f87265afb175..cad08ccce625 100644
--- a/arch/sparc/kernel/ds.c
+++ b/arch/sparc/kernel/ds.c
@@ -876,7 +876,7 @@ void ldom_power_off(void)
 
 static void ds_conn_reset(struct ds_info *dp)
 {
-	printk(KERN_ERR "ds-%llu: ds_conn_reset() from %pf\n",
+	printk(KERN_ERR "ds-%llu: ds_conn_reset() from %ps\n",
 	       dp->id, __builtin_return_address(0));
 }
 
diff --git a/arch/um/kernel/sysrq.c b/arch/um/kernel/sysrq.c
index 6b995e870d55..05585eef11d9 100644
--- a/arch/um/kernel/sysrq.c
+++ b/arch/um/kernel/sysrq.c
@@ -20,7 +20,7 @@
 
 static void _print_addr(void *data, unsigned long address, int reliable)
 {
-	pr_info(" [<%08lx>] %s%pF\n", address, reliable ? "" : "? ",
+	pr_info(" [<%08lx>] %s%pS\n", address, reliable ? "" : "? ",
 		(void *)address);
 }
 
diff --git a/arch/x86/include/asm/trace/exceptions.h b/arch/x86/include/asm/trace/exceptions.h
index e0e6d7f21399..6b1e87194809 100644
--- a/arch/x86/include/asm/trace/exceptions.h
+++ b/arch/x86/include/asm/trace/exceptions.h
@@ -30,7 +30,7 @@ DECLARE_EVENT_CLASS(x86_exceptions,
 		__entry->error_code = error_code;
 	),
 
-	TP_printk("address=%pf ip=%pf error_code=0x%lx",
+	TP_printk("address=%ps ip=%ps error_code=0x%lx",
 		  (void *)__entry->address, (void *)__entry->ip,
 		  __entry->error_code) );
 
diff --git a/arch/x86/kernel/irq_64.c b/arch/x86/kernel/irq_64.c
index 0469cd078db1..4dff56658427 100644
--- a/arch/x86/kernel/irq_64.c
+++ b/arch/x86/kernel/irq_64.c
@@ -58,7 +58,7 @@ static inline void stack_overflow_check(struct pt_regs *regs)
 	if (regs->sp >= estack_top && regs->sp <= estack_bottom)
 		return;
 
-	WARN_ONCE(1, "do_IRQ(): %s has overflown the kernel stack (cur:%Lx,sp:%lx,irq stk top-bottom:%Lx-%Lx,exception stk top-bottom:%Lx-%Lx,ip:%pF)\n",
+	WARN_ONCE(1, "do_IRQ(): %s has overflown the kernel stack (cur:%Lx,sp:%lx,irq stk top-bottom:%Lx-%Lx,exception stk top-bottom:%Lx-%Lx,ip:%pS)\n",
 		current->comm, curbase, regs->sp,
 		irq_stack_top, irq_stack_bottom,
 		estack_top, estack_bottom, (void *)regs->ip);
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 3c4568f8fb28..b0a2de8d2f9e 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -145,7 +145,7 @@ __visible bool ex_handler_rdmsr_unsafe(const struct exception_table_entry *fixup
 				       unsigned long error_code,
 				       unsigned long fault_addr)
 {
-	if (pr_warn_once("unchecked MSR access error: RDMSR from 0x%x at rIP: 0x%lx (%pF)\n",
+	if (pr_warn_once("unchecked MSR access error: RDMSR from 0x%x at rIP: 0x%lx (%pS)\n",
 			 (unsigned int)regs->cx, regs->ip, (void *)regs->ip))
 		show_stack_regs(regs);
 
@@ -162,7 +162,7 @@ __visible bool ex_handler_wrmsr_unsafe(const struct exception_table_entry *fixup
 				       unsigned long error_code,
 				       unsigned long fault_addr)
 {
-	if (pr_warn_once("unchecked MSR access error: WRMSR to 0x%x (tried to write 0x%08x%08x) at rIP: 0x%lx (%pF)\n",
+	if (pr_warn_once("unchecked MSR access error: WRMSR to 0x%x (tried to write 0x%08x%08x) at rIP: 0x%lx (%pS)\n",
 			 (unsigned int)regs->cx, (unsigned int)regs->dx,
 			 (unsigned int)regs->ax,  regs->ip, (void *)regs->ip))
 		show_stack_regs(regs);
diff --git a/arch/x86/xen/multicalls.c b/arch/x86/xen/multicalls.c
index 0766a08bdf45..07054572297f 100644
--- a/arch/x86/xen/multicalls.c
+++ b/arch/x86/xen/multicalls.c
@@ -105,7 +105,7 @@ void xen_mc_flush(void)
 		for (i = 0; i < b->mcidx; i++) {
 			if (b->entries[i].result < 0) {
 #if MC_DEBUG
-				pr_err("  call %2d: op=%lu arg=[%lx] result=%ld\t%pF\n",
+				pr_err("  call %2d: op=%lu arg=[%lx] result=%ld\t%pS\n",
 				       i + 1,
 				       b->debug[i].op,
 				       b->debug[i].args[0],
diff --git a/drivers/acpi/device_pm.c b/drivers/acpi/device_pm.c
index 824ae985ad93..1aa0d014dc34 100644
--- a/drivers/acpi/device_pm.c
+++ b/drivers/acpi/device_pm.c
@@ -414,7 +414,7 @@ static void acpi_pm_notify_handler(acpi_handle handle, u32 val, void *not_used)
 	if (adev->wakeup.flags.notifier_present) {
 		pm_wakeup_ws_event(adev->wakeup.ws, 0, acpi_s2idle_wakeup());
 		if (adev->wakeup.context.func) {
-			acpi_handle_debug(handle, "Running %pF for %s\n",
+			acpi_handle_debug(handle, "Running %pS for %s\n",
 					  adev->wakeup.context.func,
 					  dev_name(adev->wakeup.context.dev));
 			adev->wakeup.context.func(&adev->wakeup.context);
diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
index f80d298de3fa..a619be025056 100644
--- a/drivers/base/power/main.c
+++ b/drivers/base/power/main.c
@@ -207,7 +207,7 @@ static ktime_t initcall_debug_start(struct device *dev, void *cb)
 	if (!pm_print_times_enabled)
 		return 0;
 
-	dev_info(dev, "calling %pF @ %i, parent: %s\n", cb,
+	dev_info(dev, "calling %pS @ %i, parent: %s\n", cb,
 		 task_pid_nr(current),
 		 dev->parent ? dev_name(dev->parent) : "none");
 	return ktime_get();
@@ -225,7 +225,7 @@ static void initcall_debug_report(struct device *dev, ktime_t calltime,
 	rettime = ktime_get();
 	nsecs = (s64) ktime_to_ns(ktime_sub(rettime, calltime));
 
-	dev_info(dev, "%pF returned %d after %Ld usecs\n", cb, error,
+	dev_info(dev, "%pS returned %d after %Ld usecs\n", cb, error,
 		 (unsigned long long)nsecs >> 10);
 }
 
@@ -2063,7 +2063,7 @@ EXPORT_SYMBOL_GPL(dpm_suspend_start);
 void __suspend_report_result(const char *function, void *fn, int ret)
 {
 	if (ret)
-		pr_err("%s(): %pF returns %d\n", function, fn, ret);
+		pr_err("%s(): %pS returns %d\n", function, fn, ret);
 }
 EXPORT_SYMBOL_GPL(__suspend_report_result);
 
diff --git a/drivers/base/syscore.c b/drivers/base/syscore.c
index 6e076f359dcc..0d346a307140 100644
--- a/drivers/base/syscore.c
+++ b/drivers/base/syscore.c
@@ -62,19 +62,19 @@ int syscore_suspend(void)
 	list_for_each_entry_reverse(ops, &syscore_ops_list, node)
 		if (ops->suspend) {
 			if (initcall_debug)
-				pr_info("PM: Calling %pF\n", ops->suspend);
+				pr_info("PM: Calling %pS\n", ops->suspend);
 			ret = ops->suspend();
 			if (ret)
 				goto err_out;
 			WARN_ONCE(!irqs_disabled(),
-				"Interrupts enabled after %pF\n", ops->suspend);
+				"Interrupts enabled after %pS\n", ops->suspend);
 		}
 
 	trace_suspend_resume(TPS("syscore_suspend"), 0, false);
 	return 0;
 
  err_out:
-	pr_err("PM: System core suspend callback %pF failed.\n", ops->suspend);
+	pr_err("PM: System core suspend callback %pS failed.\n", ops->suspend);
 
 	list_for_each_entry_continue(ops, &syscore_ops_list, node)
 		if (ops->resume)
@@ -100,10 +100,10 @@ void syscore_resume(void)
 	list_for_each_entry(ops, &syscore_ops_list, node)
 		if (ops->resume) {
 			if (initcall_debug)
-				pr_info("PM: Calling %pF\n", ops->resume);
+				pr_info("PM: Calling %pS\n", ops->resume);
 			ops->resume();
 			WARN_ONCE(!irqs_disabled(),
-				"Interrupts enabled after %pF\n", ops->resume);
+				"Interrupts enabled after %pS\n", ops->resume);
 		}
 	trace_suspend_resume(TPS("syscore_resume"), 0, false);
 }
@@ -122,7 +122,7 @@ void syscore_shutdown(void)
 	list_for_each_entry_reverse(ops, &syscore_ops_list, node)
 		if (ops->shutdown) {
 			if (initcall_debug)
-				pr_info("PM: Calling %pF\n", ops->shutdown);
+				pr_info("PM: Calling %pS\n", ops->shutdown);
 			ops->shutdown();
 		}
 
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index c7ad88d91a09..3e5fd97a3b4d 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -6116,7 +6116,7 @@ int drbd_ack_receiver(struct drbd_thread *thi)
 
 			err = cmd->fn(connection, &pi);
 			if (err) {
-				drbd_err(connection, "%pf failed\n", cmd->fn);
+				drbd_err(connection, "%ps failed\n", cmd->fn);
 				goto reconnect;
 			}
 
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index 95f608d1a098..49f89db0766f 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -1693,7 +1693,7 @@ irqreturn_t floppy_interrupt(int irq, void *dev_id)
 		/* we don't even know which FDC is the culprit */
 		pr_info("DOR0=%x\n", fdc_state[0].dor);
 		pr_info("floppy interrupt on bizarre fdc %d\n", fdc);
-		pr_info("handler=%pf\n", handler);
+		pr_info("handler=%ps\n", handler);
 		is_alive(__func__, "bizarre fdc");
 		return IRQ_NONE;
 	}
@@ -1752,7 +1752,7 @@ static void reset_interrupt(void)
 	debugt(__func__, "");
 	result();		/* get the status ready for set_fdc */
 	if (FDCS->reset) {
-		pr_info("reset set in interrupt, calling %pf\n", cont->error);
+		pr_info("reset set in interrupt, calling %ps\n", cont->error);
 		cont->error();	/* a reset just after a reset. BAD! */
 	}
 	cont->redo();
@@ -1793,7 +1793,7 @@ static void show_floppy(void)
 	pr_info("\n");
 	pr_info("floppy driver state\n");
 	pr_info("-------------------\n");
-	pr_info("now=%lu last interrupt=%lu diff=%lu last called handler=%pf\n",
+	pr_info("now=%lu last interrupt=%lu diff=%lu last called handler=%ps\n",
 		jiffies, interruptjiffies, jiffies - interruptjiffies,
 		lasthandler);
 
@@ -1812,9 +1812,9 @@ static void show_floppy(void)
 	pr_info("status=%x\n", fd_inb(FD_STATUS));
 	pr_info("fdc_busy=%lu\n", fdc_busy);
 	if (do_floppy)
-		pr_info("do_floppy=%pf\n", do_floppy);
+		pr_info("do_floppy=%ps\n", do_floppy);
 	if (work_pending(&floppy_work))
-		pr_info("floppy_work.func=%pf\n", floppy_work.func);
+		pr_info("floppy_work.func=%ps\n", floppy_work.func);
 	if (delayed_work_pending(&fd_timer))
 		pr_info("delayed work.function=%p expires=%ld\n",
 		       fd_timer.work.func,
diff --git a/drivers/cpufreq/cpufreq.c b/drivers/cpufreq/cpufreq.c
index e10922709d13..bf78a3d9e0e9 100644
--- a/drivers/cpufreq/cpufreq.c
+++ b/drivers/cpufreq/cpufreq.c
@@ -426,7 +426,7 @@ static void cpufreq_list_transition_notifiers(void)
 	mutex_lock(&cpufreq_transition_notifier_list.mutex);
 
 	for (nb = cpufreq_transition_notifier_list.head; nb; nb = nb->next)
-		pr_info("%pF\n", nb->notifier_call);
+		pr_info("%pS\n", nb->notifier_call);
 
 	mutex_unlock(&cpufreq_transition_notifier_list.mutex);
 }
diff --git a/drivers/mmc/core/quirks.h b/drivers/mmc/core/quirks.h
index dd2f73af8f2c..2d2d9ea8be4f 100644
--- a/drivers/mmc/core/quirks.h
+++ b/drivers/mmc/core/quirks.h
@@ -159,7 +159,7 @@ static inline void mmc_fixup_device(struct mmc_card *card,
 		    (f->ext_csd_rev == EXT_CSD_REV_ANY ||
 		     f->ext_csd_rev == card->ext_csd.rev) &&
 		    rev >= f->rev_start && rev <= f->rev_end) {
-			dev_dbg(&card->dev, "calling %pf\n", f->vendor_fixup);
+			dev_dbg(&card->dev, "calling %ps\n", f->vendor_fixup);
 			f->vendor_fixup(card, f->data);
 		}
 	}
diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 7bbff0af29b2..7ff684159f29 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -581,7 +581,7 @@ int __nd_driver_register(struct nd_device_driver *nd_drv, struct module *owner,
 	struct device_driver *drv = &nd_drv->drv;
 
 	if (!nd_drv->type) {
-		pr_debug("driver type bitmask not set (%pf)\n",
+		pr_debug("driver type bitmask not set (%ps)\n",
 				__builtin_return_address(0));
 		return -EINVAL;
 	}
diff --git a/drivers/nvdimm/dimm_devs.c b/drivers/nvdimm/dimm_devs.c
index 91b9abbf689c..ecbab2d66e38 100644
--- a/drivers/nvdimm/dimm_devs.c
+++ b/drivers/nvdimm/dimm_devs.c
@@ -58,7 +58,7 @@ static int validate_dimm(struct nvdimm_drvdata *ndd)
 
 	rc = nvdimm_check_config_data(ndd->dev);
 	if (rc)
-		dev_dbg(ndd->dev, "%pf: %s error: %d\n",
+		dev_dbg(ndd->dev, "%ps: %s error: %d\n",
 				__builtin_return_address(0), __func__, rc);
 	return rc;
 }
diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
index 71853befd435..cae630fe6387 100644
--- a/drivers/pci/pci-driver.c
+++ b/drivers/pci/pci-driver.c
@@ -578,7 +578,7 @@ static int pci_legacy_suspend(struct device *dev, pm_message_t state)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: Device state not saved by %pF\n",
+				"PCI PM: Device state not saved by %pS\n",
 				drv->suspend);
 		}
 	}
@@ -605,7 +605,7 @@ static int pci_legacy_suspend_late(struct device *dev, pm_message_t state)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: Device state not saved by %pF\n",
+				"PCI PM: Device state not saved by %pS\n",
 				drv->suspend_late);
 			goto Fixup;
 		}
@@ -773,7 +773,7 @@ static int pci_pm_suspend(struct device *dev)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: State of device not saved by %pF\n",
+				"PCI PM: State of device not saved by %pS\n",
 				pm->suspend);
 		}
 	}
@@ -821,7 +821,7 @@ static int pci_pm_suspend_noirq(struct device *dev)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: State of device not saved by %pF\n",
+				"PCI PM: State of device not saved by %pS\n",
 				pm->suspend_noirq);
 			goto Fixup;
 		}
@@ -1260,11 +1260,11 @@ static int pci_pm_runtime_suspend(struct device *dev)
 		 * log level.
 		 */
 		if (error == -EBUSY || error == -EAGAIN) {
-			dev_dbg(dev, "can't suspend now (%pf returned %d)\n",
+			dev_dbg(dev, "can't suspend now (%ps returned %d)\n",
 				pm->runtime_suspend, error);
 			return error;
 		} else if (error) {
-			dev_err(dev, "can't suspend (%pf returned %d)\n",
+			dev_err(dev, "can't suspend (%ps returned %d)\n",
 				pm->runtime_suspend, error);
 			return error;
 		}
@@ -1276,7 +1276,7 @@ static int pci_pm_runtime_suspend(struct device *dev)
 	    && !pci_dev->state_saved && pci_dev->current_state != PCI_D0
 	    && pci_dev->current_state != PCI_UNKNOWN) {
 		WARN_ONCE(pci_dev->current_state != prev,
-			"PCI PM: State of device not saved by %pF\n",
+			"PCI PM: State of device not saved by %pS\n",
 			pm->runtime_suspend);
 		return 0;
 	}
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index a59ad09ce911..b56c2a75d42f 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -36,7 +36,7 @@ static ktime_t fixup_debug_start(struct pci_dev *dev,
 				 void (*fn)(struct pci_dev *dev))
 {
 	if (initcall_debug)
-		pci_info(dev, "calling  %pF @ %i\n", fn, task_pid_nr(current));
+		pci_info(dev, "calling  %pS @ %i\n", fn, task_pid_nr(current));
 
 	return ktime_get();
 }
@@ -51,7 +51,7 @@ static void fixup_debug_report(struct pci_dev *dev, ktime_t calltime,
 	delta = ktime_sub(rettime, calltime);
 	duration = (unsigned long long) ktime_to_ns(delta) >> 10;
 	if (initcall_debug || duration > 10000)
-		pci_info(dev, "%pF took %lld usecs\n", fn, duration);
+		pci_info(dev, "%pS took %lld usecs\n", fn, duration);
 }
 
 static void pci_do_fixups(struct pci_dev *dev, struct pci_fixup *f,
diff --git a/drivers/pnp/quirks.c b/drivers/pnp/quirks.c
index 803666ae3635..de99f371d362 100644
--- a/drivers/pnp/quirks.c
+++ b/drivers/pnp/quirks.c
@@ -458,7 +458,7 @@ void pnp_fixup_device(struct pnp_dev *dev)
 	for (f = pnp_fixups; *f->id; f++) {
 		if (!compare_pnp_id(dev->id, f->id))
 			continue;
-		pnp_dbg(&dev->dev, "%s: calling %pF\n", f->id,
+		pnp_dbg(&dev->dev, "%s: calling %pS\n", f->id,
 			f->quirk_function);
 		f->quirk_function(dev);
 	}
diff --git a/drivers/scsi/esp_scsi.c b/drivers/scsi/esp_scsi.c
index 465df475f753..76fd02ccbf49 100644
--- a/drivers/scsi/esp_scsi.c
+++ b/drivers/scsi/esp_scsi.c
@@ -1031,7 +1031,7 @@ static int esp_check_spur_intr(struct esp *esp)
 
 static void esp_schedule_reset(struct esp *esp)
 {
-	esp_log_reset("esp_schedule_reset() from %pf\n",
+	esp_log_reset("esp_schedule_reset() from %ps\n",
 		      __builtin_return_address(0));
 	esp->flags |= ESP_FLAG_RESETTING;
 	esp_event(esp, ESP_EVENT_RESET);
diff --git a/fs/btrfs/tests/free-space-tree-tests.c b/fs/btrfs/tests/free-space-tree-tests.c
index 89346da890cf..f7a969b986eb 100644
--- a/fs/btrfs/tests/free-space-tree-tests.c
+++ b/fs/btrfs/tests/free-space-tree-tests.c
@@ -539,7 +539,7 @@ static int run_test_both_formats(test_func_t test_func, u32 sectorsize,
 	ret = run_test(test_func, 0, sectorsize, nodesize, alignment);
 	if (ret) {
 		test_err(
-	"%pf failed with extents, sectorsize=%u, nodesize=%u, alignment=%u",
+	"%ps failed with extents, sectorsize=%u, nodesize=%u, alignment=%u",
 			 test_func, sectorsize, nodesize, alignment);
 		test_ret = ret;
 	}
@@ -547,7 +547,7 @@ static int run_test_both_formats(test_func_t test_func, u32 sectorsize,
 	ret = run_test(test_func, 1, sectorsize, nodesize, alignment);
 	if (ret) {
 		test_err(
-	"%pf failed with bitmaps, sectorsize=%u, nodesize=%u, alignment=%u",
+	"%ps failed with bitmaps, sectorsize=%u, nodesize=%u, alignment=%u",
 			 test_func, sectorsize, nodesize, alignment);
 		test_ret = ret;
 	}
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 87f75ebd2fd6..0787b836d4c6 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1338,7 +1338,7 @@ struct f2fs_private_dio {
 
 #ifdef CONFIG_F2FS_FAULT_INJECTION
 #define f2fs_show_injection_info(type)					\
-	printk_ratelimited("%sF2FS-fs : inject %s in %s of %pF\n",	\
+	printk_ratelimited("%sF2FS-fs : inject %s in %s of %pS\n",	\
 		KERN_INFO, f2fs_fault_name[type],			\
 		__func__, __builtin_return_address(0))
 static inline bool time_to_inject(struct f2fs_sb_info *sbi, int type)
diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
index c60ee46f3e39..29e94e0b6d73 100644
--- a/fs/pstore/inode.c
+++ b/fs/pstore/inode.c
@@ -115,7 +115,7 @@ static int pstore_ftrace_seq_show(struct seq_file *s, void *v)
 
 	rec = (struct pstore_ftrace_record *)(ps->record->buf + data->off);
 
-	seq_printf(s, "CPU:%d ts:%llu %08lx  %08lx  %pf <- %pF\n",
+	seq_printf(s, "CPU:%d ts:%llu %08lx  %08lx  %ps <- %pS\n",
 		   pstore_ftrace_decode_cpu(rec),
 		   pstore_ftrace_read_timestamp(rec),
 		   rec->ip, rec->parent_ip, (void *)rec->ip,
diff --git a/include/trace/events/btrfs.h b/include/trace/events/btrfs.h
index ab1cc33adbac..b9b7465be5eb 100644
--- a/include/trace/events/btrfs.h
+++ b/include/trace/events/btrfs.h
@@ -1345,7 +1345,7 @@ DECLARE_EVENT_CLASS(btrfs__work,
 		__entry->normal_work	= &work->normal_work;
 	),
 
-	TP_printk_btrfs("work=%p (normal_work=%p) wq=%p func=%pf ordered_func=%p "
+	TP_printk_btrfs("work=%p (normal_work=%p) wq=%p func=%ps ordered_func=%p "
 		  "ordered_free=%p",
 		  __entry->work, __entry->normal_work, __entry->wq,
 		   __entry->func, __entry->ordered_func, __entry->ordered_free)
diff --git a/include/trace/events/cpuhp.h b/include/trace/events/cpuhp.h
index fe1d6e8cd99d..ad16f77310c6 100644
--- a/include/trace/events/cpuhp.h
+++ b/include/trace/events/cpuhp.h
@@ -30,7 +30,7 @@ TRACE_EVENT(cpuhp_enter,
 		__entry->fun	= fun;
 	),
 
-	TP_printk("cpu: %04u target: %3d step: %3d (%pf)",
+	TP_printk("cpu: %04u target: %3d step: %3d (%ps)",
 		  __entry->cpu, __entry->target, __entry->idx, __entry->fun)
 );
 
@@ -58,7 +58,7 @@ TRACE_EVENT(cpuhp_multi_enter,
 		__entry->fun	= fun;
 	),
 
-	TP_printk("cpu: %04u target: %3d step: %3d (%pf)",
+	TP_printk("cpu: %04u target: %3d step: %3d (%ps)",
 		  __entry->cpu, __entry->target, __entry->idx, __entry->fun)
 );
 
diff --git a/include/trace/events/preemptirq.h b/include/trace/events/preemptirq.h
index 9a0d4ceeb166..95fba0471e5b 100644
--- a/include/trace/events/preemptirq.h
+++ b/include/trace/events/preemptirq.h
@@ -27,7 +27,7 @@ DECLARE_EVENT_CLASS(preemptirq_template,
 		__entry->parent_offs = (u32)(parent_ip - (unsigned long)_stext);
 	),
 
-	TP_printk("caller=%pF parent=%pF",
+	TP_printk("caller=%pS parent=%pS",
 		  (void *)((unsigned long)(_stext) + __entry->caller_offs),
 		  (void *)((unsigned long)(_stext) + __entry->parent_offs))
 );
diff --git a/include/trace/events/rcu.h b/include/trace/events/rcu.h
index f0c4d10e614b..80339fd14c1c 100644
--- a/include/trace/events/rcu.h
+++ b/include/trace/events/rcu.h
@@ -491,7 +491,7 @@ TRACE_EVENT(rcu_callback,
 		__entry->qlen = qlen;
 	),
 
-	TP_printk("%s rhp=%p func=%pf %ld/%ld",
+	TP_printk("%s rhp=%p func=%ps %ld/%ld",
 		  __entry->rcuname, __entry->rhp, __entry->func,
 		  __entry->qlen_lazy, __entry->qlen)
 );
@@ -587,7 +587,7 @@ TRACE_EVENT(rcu_invoke_callback,
 		__entry->func = rhp->func;
 	),
 
-	TP_printk("%s rhp=%p func=%pf",
+	TP_printk("%s rhp=%p func=%ps",
 		  __entry->rcuname, __entry->rhp, __entry->func)
 );
 
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 7e899e635d33..f0a6f0c5549c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -146,7 +146,7 @@ DECLARE_EVENT_CLASS(rpc_task_running,
 		__entry->flags = task->tk_flags;
 		),
 
-	TP_printk("task:%u@%d flags=%s runstate=%s status=%d action=%pf",
+	TP_printk("task:%u@%d flags=%s runstate=%s status=%d action=%ps",
 		__entry->task_id, __entry->client_id,
 		rpc_show_task_flags(__entry->flags),
 		rpc_show_runstate(__entry->runstate),
diff --git a/include/trace/events/timer.h b/include/trace/events/timer.h
index a57e4ee989d6..6785065de31d 100644
--- a/include/trace/events/timer.h
+++ b/include/trace/events/timer.h
@@ -73,7 +73,7 @@ TRACE_EVENT(timer_start,
 		__entry->flags		= flags;
 	),
 
-	TP_printk("timer=%p function=%pf expires=%lu [timeout=%ld] cpu=%u idx=%u flags=%s",
+	TP_printk("timer=%p function=%ps expires=%lu [timeout=%ld] cpu=%u idx=%u flags=%s",
 		  __entry->timer, __entry->function, __entry->expires,
 		  (long)__entry->expires - __entry->now,
 		  __entry->flags & TIMER_CPUMASK,
@@ -105,7 +105,7 @@ TRACE_EVENT(timer_expire_entry,
 		__entry->function	= timer->function;
 	),
 
-	TP_printk("timer=%p function=%pf now=%lu", __entry->timer, __entry->function,__entry->now)
+	TP_printk("timer=%p function=%ps now=%lu", __entry->timer, __entry->function,__entry->now)
 );
 
 /**
@@ -210,7 +210,7 @@ TRACE_EVENT(hrtimer_start,
 		__entry->mode		= mode;
 	),
 
-	TP_printk("hrtimer=%p function=%pf expires=%llu softexpires=%llu "
+	TP_printk("hrtimer=%p function=%ps expires=%llu softexpires=%llu "
 		  "mode=%s", __entry->hrtimer, __entry->function,
 		  (unsigned long long) __entry->expires,
 		  (unsigned long long) __entry->softexpires,
@@ -243,7 +243,7 @@ TRACE_EVENT(hrtimer_expire_entry,
 		__entry->function	= hrtimer->function;
 	),
 
-	TP_printk("hrtimer=%p function=%pf now=%llu", __entry->hrtimer, __entry->function,
+	TP_printk("hrtimer=%p function=%ps now=%llu", __entry->hrtimer, __entry->function,
 		  (unsigned long long) __entry->now)
 );
 
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb91342231..252327dbfa51 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -226,7 +226,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->priority = priority;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
+	TP_printk("%pS %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
@@ -265,7 +265,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pS %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
diff --git a/include/trace/events/workqueue.h b/include/trace/events/workqueue.h
index 9a761bc6a251..e172549283be 100644
--- a/include/trace/events/workqueue.h
+++ b/include/trace/events/workqueue.h
@@ -60,7 +60,7 @@ TRACE_EVENT(workqueue_queue_work,
 		__entry->cpu		= pwq->pool->cpu;
 	),
 
-	TP_printk("work struct=%p function=%pf workqueue=%p req_cpu=%u cpu=%u",
+	TP_printk("work struct=%p function=%ps workqueue=%p req_cpu=%u cpu=%u",
 		  __entry->work, __entry->function, __entry->workqueue,
 		  __entry->req_cpu, __entry->cpu)
 );
@@ -102,7 +102,7 @@ TRACE_EVENT(workqueue_execute_start,
 		__entry->function	= work->func;
 	),
 
-	TP_printk("work struct %p: function %pf", __entry->work, __entry->function)
+	TP_printk("work struct %p: function %ps", __entry->work, __entry->function)
 );
 
 /**
diff --git a/include/trace/events/xen.h b/include/trace/events/xen.h
index fdcf88bcf0ea..9a0e8af21310 100644
--- a/include/trace/events/xen.h
+++ b/include/trace/events/xen.h
@@ -73,7 +73,7 @@ TRACE_EVENT(xen_mc_callback,
 		    __entry->fn = fn;
 		    __entry->data = data;
 		    ),
-	    TP_printk("callback %pf, data %p",
+	    TP_printk("callback %ps, data %p",
 		      __entry->fn, __entry->data)
 	);
 
diff --git a/init/main.c b/init/main.c
index 598e278b46f7..204e87ec3419 100644
--- a/init/main.c
+++ b/init/main.c
@@ -840,7 +840,7 @@ trace_initcall_start_cb(void *data, initcall_t fn)
 {
 	ktime_t *calltime = (ktime_t *)data;
 
-	printk(KERN_DEBUG "calling  %pF @ %i\n", fn, task_pid_nr(current));
+	printk(KERN_DEBUG "calling  %pS @ %i\n", fn, task_pid_nr(current));
 	*calltime = ktime_get();
 }
 
@@ -854,7 +854,7 @@ trace_initcall_finish_cb(void *data, initcall_t fn, int ret)
 	rettime = ktime_get();
 	delta = ktime_sub(rettime, *calltime);
 	duration = (unsigned long long) ktime_to_ns(delta) >> 10;
-	printk(KERN_DEBUG "initcall %pF returned %d after %lld usecs\n",
+	printk(KERN_DEBUG "initcall %pS returned %d after %lld usecs\n",
 		 fn, ret, duration);
 }
 
@@ -911,7 +911,7 @@ int __init_or_module do_one_initcall(initcall_t fn)
 		strlcat(msgbuf, "disabled interrupts ", sizeof(msgbuf));
 		local_irq_enable();
 	}
-	WARN(msgbuf[0], "initcall %pF returned with %s\n", fn, msgbuf);
+	WARN(msgbuf[0], "initcall %pS returned with %s\n", fn, msgbuf);
 
 	add_latent_entropy();
 	return ret;
diff --git a/kernel/async.c b/kernel/async.c
index f6bd0d9885e1..12c332e4e13e 100644
--- a/kernel/async.c
+++ b/kernel/async.c
@@ -119,7 +119,7 @@ static void async_run_entry_fn(struct work_struct *work)
 
 	/* 1) run (and print duration) */
 	if (initcall_debug && system_state < SYSTEM_RUNNING) {
-		pr_debug("calling  %lli_%pF @ %i\n",
+		pr_debug("calling  %lli_%pS @ %i\n",
 			(long long)entry->cookie,
 			entry->func, task_pid_nr(current));
 		calltime = ktime_get();
@@ -128,7 +128,7 @@ static void async_run_entry_fn(struct work_struct *work)
 	if (initcall_debug && system_state < SYSTEM_RUNNING) {
 		rettime = ktime_get();
 		delta = ktime_sub(rettime, calltime);
-		pr_debug("initcall %lli_%pF returned 0 after %lld usecs\n",
+		pr_debug("initcall %lli_%pS returned 0 after %lld usecs\n",
 			(long long)entry->cookie,
 			entry->func,
 			(long long)ktime_to_ns(delta) >> 10);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c5cde87329c7..4a1ef880253c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -2028,7 +2028,7 @@ static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
 		if (uc->handler) {
 			rc = uc->handler(uc, regs);
 			WARN(rc & ~UPROBE_HANDLER_MASK,
-				"bad rc=0x%x from %pf()\n", rc, uc->handler);
+				"bad rc=0x%x from %ps()\n", rc, uc->handler);
 		}
 
 		if (uc->ret_handler)
diff --git a/kernel/fail_function.c b/kernel/fail_function.c
index 17f75b545f66..feb80712b913 100644
--- a/kernel/fail_function.c
+++ b/kernel/fail_function.c
@@ -210,7 +210,7 @@ static int fei_seq_show(struct seq_file *m, void *v)
 {
 	struct fei_attr *attr = list_entry(v, struct fei_attr, list);
 
-	seq_printf(m, "%pf\n", attr->kp.addr);
+	seq_printf(m, "%ps\n", attr->kp.addr);
 	return 0;
 }
 
diff --git a/kernel/irq/debugfs.c b/kernel/irq/debugfs.c
index 516c00a5e867..c1eccd4f6520 100644
--- a/kernel/irq/debugfs.c
+++ b/kernel/irq/debugfs.c
@@ -152,7 +152,7 @@ static int irq_debug_show(struct seq_file *m, void *p)
 
 	raw_spin_lock_irq(&desc->lock);
 	data = irq_desc_get_irq_data(desc);
-	seq_printf(m, "handler:  %pf\n", desc->handle_irq);
+	seq_printf(m, "handler:  %ps\n", desc->handle_irq);
 	seq_printf(m, "device:   %s\n", desc->dev_name);
 	seq_printf(m, "status:   0x%08x\n", desc->status_use_accessors);
 	irq_debug_show_bits(m, 0, desc->status_use_accessors, irqdesc_states,
diff --git a/kernel/irq/handle.c b/kernel/irq/handle.c
index 6df5ddfdb0f8..a4ace611f47f 100644
--- a/kernel/irq/handle.c
+++ b/kernel/irq/handle.c
@@ -149,7 +149,7 @@ irqreturn_t __handle_irq_event_percpu(struct irq_desc *desc, unsigned int *flags
 		res = action->handler(irq, action->dev_id);
 		trace_irq_handler_exit(irq, action, res);
 
-		if (WARN_ONCE(!irqs_disabled(),"irq %u handler %pF enabled interrupts\n",
+		if (WARN_ONCE(!irqs_disabled(),"irq %u handler %pS enabled interrupts\n",
 			      irq, action->handler))
 			local_irq_disable();
 
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 9ec34a2a6638..ec43ab2fdfda 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -778,7 +778,7 @@ int __irq_set_trigger(struct irq_desc *desc, unsigned long flags)
 		ret = 0;
 		break;
 	default:
-		pr_err("Setting trigger mode %lu for irq %u failed (%pF)\n",
+		pr_err("Setting trigger mode %lu for irq %u failed (%pS)\n",
 		       flags, irq_desc_get_irq(desc), chip->irq_set_type);
 	}
 	if (unmask)
diff --git a/kernel/irq/spurious.c b/kernel/irq/spurious.c
index 6d2fa6914b30..2ed97a7c9b2a 100644
--- a/kernel/irq/spurious.c
+++ b/kernel/irq/spurious.c
@@ -212,9 +212,9 @@ static void __report_bad_irq(struct irq_desc *desc, irqreturn_t action_ret)
 	 */
 	raw_spin_lock_irqsave(&desc->lock, flags);
 	for_each_action_of_desc(desc, action) {
-		printk(KERN_ERR "[<%p>] %pf", action->handler, action->handler);
+		printk(KERN_ERR "[<%p>] %ps", action->handler, action->handler);
 		if (action->thread_fn)
-			printk(KERN_CONT " threaded [<%p>] %pf",
+			printk(KERN_CONT " threaded [<%p>] %ps",
 					action->thread_fn, action->thread_fn);
 		printk(KERN_CONT "\n");
 	}
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index acd6ccf56faf..8eee921b384d 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -2870,7 +2870,7 @@ __call_rcu(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
 		 * Use rcu:rcu_callback trace event to find the previous
 		 * time callback was passed to __call_rcu().
 		 */
-		WARN_ONCE(1, "__call_rcu(): Double-freed CB %p->%pF()!!!\n",
+		WARN_ONCE(1, "__call_rcu(): Double-freed CB %p->%pS()!!!\n",
 			  head, head->func);
 		WRITE_ONCE(head->func, rcu_leak_callback);
 		return;
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index 067cb83f37ea..7231fb5953fc 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -513,7 +513,7 @@ static void cpu_stopper_thread(unsigned int cpu)
 		}
 		preempt_count_dec();
 		WARN_ONCE(preempt_count(),
-			  "cpu_stop: %pf(%p) leaked preempt count\n", fn, arg);
+			  "cpu_stop: %ps(%p) leaked preempt count\n", fn, arg);
 		goto repeat;
 	}
 }
diff --git a/kernel/time/sched_clock.c b/kernel/time/sched_clock.c
index 094b82ca95e5..1002cf61700a 100644
--- a/kernel/time/sched_clock.c
+++ b/kernel/time/sched_clock.c
@@ -231,7 +231,7 @@ sched_clock_register(u64 (*read)(void), int bits, unsigned long rate)
 	if (irqtime > 0 || (irqtime == -1 && rate >= 1000000))
 		enable_sched_clock_irqtime();
 
-	pr_debug("Registered %pF as sched_clock source\n", read);
+	pr_debug("Registered %pS as sched_clock source\n", read);
 }
 
 void __init generic_sched_clock_init(void)
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2fce056f8a49..6502c3ed317e 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1328,7 +1328,7 @@ static void call_timer_fn(struct timer_list *timer, void (*fn)(struct timer_list
 	lock_map_release(&lockdep_map);
 
 	if (count != preempt_count()) {
-		WARN_ONCE(1, "timer: %pF preempt leak: %08x -> %08x\n",
+		WARN_ONCE(1, "timer: %pS preempt leak: %08x -> %08x\n",
 			  fn, count, preempt_count());
 		/*
 		 * Restore the preempt count. That gives us a decent
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 4026d1871407..446e44f5d551 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2277,7 +2277,7 @@ __acquires(&pool->lock)
 
 	if (unlikely(in_atomic() || lockdep_depth(current) > 0)) {
 		pr_err("BUG: workqueue leaked lock or atomic: %s/0x%08x/%d\n"
-		       "     last function: %pf\n",
+		       "     last function: %ps\n",
 		       current->comm, preempt_count(), task_pid_nr(current),
 		       worker->current_func);
 		debug_show_held_locks(current);
@@ -2596,11 +2596,11 @@ static void check_flush_dependency(struct workqueue_struct *target_wq,
 	worker = current_wq_worker();
 
 	WARN_ONCE(current->flags & PF_MEMALLOC,
-		  "workqueue: PF_MEMALLOC task %d(%s) is flushing !WQ_MEM_RECLAIM %s:%pf",
+		  "workqueue: PF_MEMALLOC task %d(%s) is flushing !WQ_MEM_RECLAIM %s:%ps",
 		  current->pid, current->comm, target_wq->name, target_func);
 	WARN_ONCE(worker && ((worker->current_pwq->wq->flags &
 			      (WQ_MEM_RECLAIM | __WQ_LEGACY)) == WQ_MEM_RECLAIM),
-		  "workqueue: WQ_MEM_RECLAIM %s:%pf is flushing !WQ_MEM_RECLAIM %s:%pf",
+		  "workqueue: WQ_MEM_RECLAIM %s:%ps is flushing !WQ_MEM_RECLAIM %s:%ps",
 		  worker->current_pwq->wq->name, worker->current_func,
 		  target_wq->name, target_func);
 }
@@ -4586,7 +4586,7 @@ void print_worker_info(const char *log_lvl, struct task_struct *task)
 	probe_kernel_read(desc, worker->desc, sizeof(desc) - 1);
 
 	if (fn || name[0] || desc[0]) {
-		printk("%sWorkqueue: %s %pf", log_lvl, name, fn);
+		printk("%sWorkqueue: %s %ps", log_lvl, name, fn);
 		if (strcmp(name, desc))
 			pr_cont(" (%s)", desc);
 		pr_cont("\n");
@@ -4611,7 +4611,7 @@ static void pr_cont_work(bool comma, struct work_struct *work)
 		pr_cont("%s BAR(%d)", comma ? "," : "",
 			task_pid_nr(barr->task));
 	} else {
-		pr_cont("%s %pf", comma ? "," : "", work->func);
+		pr_cont("%s %ps", comma ? "," : "", work->func);
 	}
 }
 
@@ -4643,7 +4643,7 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (worker->current_pwq != pwq)
 				continue;
 
-			pr_cont("%s %d%s:%pf", comma ? "," : "",
+			pr_cont("%s %d%s:%ps", comma ? "," : "",
 				task_pid_nr(worker->task),
 				worker == pwq->wq->rescuer ? "(RESCUER)" : "",
 				worker->current_func);
diff --git a/lib/error-inject.c b/lib/error-inject.c
index c0d4600f4896..aa63751c916f 100644
--- a/lib/error-inject.c
+++ b/lib/error-inject.c
@@ -189,7 +189,7 @@ static int ei_seq_show(struct seq_file *m, void *v)
 {
 	struct ei_entry *ent = list_entry(v, struct ei_entry, list);
 
-	seq_printf(m, "%pf\t%s\n", (void *)ent->start_addr,
+	seq_printf(m, "%ps\t%s\n", (void *)ent->start_addr,
 		   error_type_string(ent->etype));
 	return 0;
 }
diff --git a/lib/percpu-refcount.c b/lib/percpu-refcount.c
index 9877682e49c7..da54318d3b55 100644
--- a/lib/percpu-refcount.c
+++ b/lib/percpu-refcount.c
@@ -151,7 +151,7 @@ static void percpu_ref_switch_to_atomic_rcu(struct rcu_head *rcu)
 	atomic_long_add((long)count - PERCPU_COUNT_BIAS, &ref->count);
 
 	WARN_ONCE(atomic_long_read(&ref->count) <= 0,
-		  "percpu ref (%pf) <= 0 (%ld) after switching to atomic",
+		  "percpu ref (%ps) <= 0 (%ld) after switching to atomic",
 		  ref->release, atomic_long_read(&ref->count));
 
 	/* @ref is viewed as dead on all CPUs, send out switch confirmation */
@@ -333,7 +333,7 @@ void percpu_ref_kill_and_confirm(struct percpu_ref *ref,
 	spin_lock_irqsave(&percpu_ref_switch_lock, flags);
 
 	WARN_ONCE(ref->percpu_count_ptr & __PERCPU_REF_DEAD,
-		  "%s called more than once on %pf!", __func__, ref->release);
+		  "%s called more than once on %ps!", __func__, ref->release);
 
 	ref->percpu_count_ptr |= __PERCPU_REF_DEAD;
 	__percpu_ref_switch_mode(ref, confirm_kill);
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf914b1..a48f520c2d01 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -702,7 +702,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_add: [%pa-%pa] %pF\n",
+	memblock_dbg("memblock_add: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
@@ -821,7 +821,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("   memblock_free: [%pa-%pa] %pF\n",
+	memblock_dbg("   memblock_free: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	kmemleak_free_part_phys(base, size);
@@ -832,7 +832,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_reserve: [%pa-%pa] %pF\n",
+	memblock_dbg("memblock_reserve: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
@@ -1447,7 +1447,7 @@ void * __init memblock_alloc_try_nid_raw(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pS\n",
 		     __func__, (u64)size, (u64)align, nid, &min_addr,
 		     &max_addr, (void *)_RET_IP_);
 
@@ -1483,7 +1483,7 @@ void * __init memblock_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pS\n",
 		     __func__, (u64)size, (u64)align, nid, &min_addr,
 		     &max_addr, (void *)_RET_IP_);
 	ptr = memblock_alloc_internal(size, align,
@@ -1508,7 +1508,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 	phys_addr_t cursor, end;
 
 	end = base + size - 1;
-	memblock_dbg("%s: [%pa-%pa] %pF\n",
+	memblock_dbg("%s: [%pa-%pa] %pS\n",
 		     __func__, &base, &end, (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
 	cursor = PFN_UP(base);
diff --git a/mm/memory.c b/mm/memory.c
index 47fe250307c7..3541a15067f2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -519,7 +519,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 		dump_page(page, "bad pte");
 	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
 		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
-	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
+	pr_alert("file:%pD fault:%ps mmap:%ps readpage:%ps\n",
 		 vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->fault : NULL,
 		 vma->vm_file ? vma->vm_file->f_op->mmap : NULL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a5ad0b35ab8e..90648187f622 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -493,7 +493,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 
 	total_scan += delta;
 	if (total_scan < 0) {
-		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
+		pr_err("shrink_slab: %pS negative objects to delete nr=%ld\n",
 		       shrinker->scan_objects, total_scan);
 		total_scan = freeable;
 		next_deferred = nr;
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index fa9530dd876e..6f739de28918 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -2398,7 +2398,7 @@ static void finish_request(struct ceph_osd_request *req)
 
 static void __complete_request(struct ceph_osd_request *req)
 {
-	dout("%s req %p tid %llu cb %pf result %d\n", __func__, req,
+	dout("%s req %p tid %llu cb %ps result %d\n", __func__, req,
 	     req->r_tid, req->r_callback, req->r_result);
 
 	if (req->r_callback)
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 63881f72ef71..36347933ec3a 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -258,7 +258,7 @@ static int ptype_seq_show(struct seq_file *seq, void *v)
 		else
 			seq_printf(seq, "%04x", ntohs(pt->type));
 
-		seq_printf(seq, " %-8s %pf\n",
+		seq_printf(seq, " %-8s %ps\n",
 			   pt->dev ? pt->dev->name : "", pt->func);
 	}
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 361aabffb8c0..bf5446192d6a 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -149,7 +149,7 @@ static void poll_one_napi(struct napi_struct *napi)
 	 * indicate that we are clearing the Tx path only.
 	 */
 	work = napi->poll(napi, 0);
-	WARN_ONCE(work, "%pF exceeded budget in poll\n", napi->poll);
+	WARN_ONCE(work, "%pS exceeded budget in poll\n", napi->poll);
 	trace_napi_poll(napi, work, 0);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
@@ -346,7 +346,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		}
 
 		WARN_ONCE(!irqs_disabled(),
-			"netpoll_send_skb_on_dev(): %s enabled interrupts in poll (%pF)\n",
+			"netpoll_send_skb_on_dev(): %s enabled interrupts in poll (%pS)\n",
 			dev->name, dev->netdev_ops->ndo_start_xmit);
 
 	}
-- 
2.11.0

