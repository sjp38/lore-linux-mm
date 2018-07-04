Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAE2E6B0272
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:18:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v7-v6so2620586wrn.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:18:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t197-v6si2709978wmt.220.2018.07.04.06.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:18:30 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64D9n9a042864
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 09:18:29 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k0vm5e6u7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 09:18:28 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 14:18:27 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] nios2: use generic early_init_dt_add_memory_arch
Date: Wed,  4 Jul 2018 16:18:14 +0300
In-Reply-To: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530710295-10774-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <lftan@altera.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Michal Hocko <mhocko@kernel.org>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

All we have to do is to enable memblock, the generic FDT code will take
care of the rest.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/nios2/Kconfig        |  1 +
 arch/nios2/kernel/prom.c  | 10 ----------
 arch/nios2/kernel/setup.c |  2 ++
 3 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index 3d4ec88..5db8fa1 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -19,6 +19,7 @@ config NIOS2
 	select SPARSE_IRQ
 	select USB_ARCH_HAS_HCD if USB_SUPPORT
 	select CPU_NO_EFFICIENT_FFS
+	select HAVE_MEMBLOCK
 
 config GENERIC_CSUM
 	def_bool y
diff --git a/arch/nios2/kernel/prom.c b/arch/nios2/kernel/prom.c
index 8d7446a..ba96a49 100644
--- a/arch/nios2/kernel/prom.c
+++ b/arch/nios2/kernel/prom.c
@@ -32,16 +32,6 @@
 
 #include <asm/sections.h>
 
-void __init early_init_dt_add_memory_arch(u64 base, u64 size)
-{
-	u64 kernel_start = (u64)virt_to_phys(_text);
-
-	if (!memory_size &&
-	    (kernel_start >= base) && (kernel_start < (base + size)))
-		memory_size = size;
-
-}
-
 int __init early_init_dt_reserve_memory_arch(phys_addr_t base, phys_addr_t size,
 					     bool nomap)
 {
diff --git a/arch/nios2/kernel/setup.c b/arch/nios2/kernel/setup.c
index 926a02b..0946840 100644
--- a/arch/nios2/kernel/setup.c
+++ b/arch/nios2/kernel/setup.c
@@ -17,6 +17,7 @@
 #include <linux/sched/task.h>
 #include <linux/console.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/initrd.h>
 #include <linux/of_fdt.h>
 #include <linux/screen_info.h>
@@ -147,6 +148,7 @@ void __init setup_arch(char **cmdline_p)
 
 	console_verbose();
 
+	memory_size = memblock_phys_mem_size();
 	memory_start = PAGE_ALIGN((unsigned long)__pa(_end));
 	memory_end = (unsigned long) CONFIG_NIOS2_MEM_BASE + memory_size;
 
-- 
2.7.4
