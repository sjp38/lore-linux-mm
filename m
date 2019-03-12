Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82C37C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 275F1213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="r8QdH1Yn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 275F1213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666D78E0010; Tue, 12 Mar 2019 18:16:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54D468E0008; Tue, 12 Mar 2019 18:16:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F0218E000F; Tue, 12 Mar 2019 18:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D747F8E000E
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:20 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 92so1604127wrb.6
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=7elSQE3ASFtmFBbQ1baRFPz6iwmnjLE3NV7GCI8qFKM=;
        b=UXvlW18Nq1fgUNDnh2gYEcbXMKSyqP+tvpaBPAgB06JdyvU3yCo7EgMmZXAn2x2sC+
         a2tcdz/kWD+/kSZC0kVxDzQH+y/zALLfLJuGqxLwrlZHOpLb6eQcN/venftaeQebn5tN
         p3gce4YxDHMoM1YVDII41Iml7bCb+QEDogxAORqoD9QTfMgudhd43Ja6KiRVqGyCWmkK
         PnNSt2978CDmThUB4G/p61FE9oupE5vFxe9Erk7qzULmkO2QpkNGRazHMLrxAVvzZf8L
         1Fwja0329KszuajriAVAhoDWdAJGGzrPmQARqDah2SNL6hjj75JNQgKr2gb/kf6NBjH7
         9nxg==
X-Gm-Message-State: APjAAAUFsx/j+AKWWELgk4YBnqYXW20AXuilNC8Z+KytoOuiGQqNmHi6
	n7MB3beIKzY16ifetpN8cz+vsl+1bsIYHz8W2pUj+ZzqYnS0qbCjueNNQoNT/WxTTrdUSimOHbG
	E0nJ1Ddy+4PtQIyx9IEcKNOiETx9wfYJJ3zOm47EX7wiw0dlyUkX208p77o0ZP02GFg==
X-Received: by 2002:a5d:620f:: with SMTP id y15mr23987226wru.101.1552428980116;
        Tue, 12 Mar 2019 15:16:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtDLJnD6lNetxXqJyIDGTU30FvoVfnACvg6QFSXe+NnqoPzfgHMLELJwahPJHOVwcAUDMW
X-Received: by 2002:a5d:620f:: with SMTP id y15mr23987170wru.101.1552428978118;
        Tue, 12 Mar 2019 15:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428978; cv=none;
        d=google.com; s=arc-20160816;
        b=IvH6gLXC6EPlcGzeb5iNKEAxPiSPXEsnEstITPlwT/r7nff02Drur6PZS2FMTMy45V
         uVETxmoYZB0ZZG5lG0zuwsAHLYL+Nx7xqBPvhxdZtzd6SEhirwk0AAQRRpjogzoYZuHD
         ksg1FlOSKpRmDPiz6kzRducIlbTVu3NVZXRoqrylLh7vhkS3NtgIRNp5dAT4Hlv/rpb+
         sbEYaEZOc5JeodXOip6G+KXrea4wIRheYZu1TZzNLCILW0WG9mLTNUVIeUaL/VoLaq7m
         QubDraulb4u5Ylwb/1i5NsT6SPhMzEcrmqOT6Mqt94ITecR7yUHWrcWzmiK+2nvAxz6s
         /s7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=7elSQE3ASFtmFBbQ1baRFPz6iwmnjLE3NV7GCI8qFKM=;
        b=AlcZpE9oOuHkUSvxzoHZQoWevtOVYOwOwZ+GcqOQqxgIvycX0MaBAIUKzST7TMd4M2
         bUdpNRCSy56Dhk0N5+K+IJ3USNY6TVYKEleUKaMIT3yub02DnzI6jUVaE1qP4UUqPxKf
         geCaXPJZMpacFOHsCW6PEhabT7YSUHBjdR9ZTyCnrSXvOwgOci2LpmTOlXYbVovBmjkJ
         WsbQ8yGr1bRf4a3CdKQ2lulSjCJvN0J+nPQ2J4mUzWVwxw6EniX2EWJU9YyXT99gCe2w
         CGb549juZQHGAj1nKKCDc42blP/ZYopd1ts13mzBQFd/2s+hLK6IYumQlZA4dw2ANydK
         OUhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=r8QdH1Yn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id t14si452wmj.42.2019.03.12.15.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=r8QdH1Yn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7P3Zyvz9vRb0;
	Tue, 12 Mar 2019 23:16:17 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=r8QdH1Yn; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id p7dWFWhAvf_h; Tue, 12 Mar 2019 23:16:17 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7P2Pd7zB09ZG;
	Tue, 12 Mar 2019 23:16:17 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428977; bh=7elSQE3ASFtmFBbQ1baRFPz6iwmnjLE3NV7GCI8qFKM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=r8QdH1YnRJRmEclIjneD3mLM+a+NgAxLSa+QIcxrhhjWhEhJYaWv4G5pagiNMWnUs
	 2x2tAysmQZRb6Z8GBr78ARZ91iMYDQ3kO8Jwbx0rnFJrF4C2iPWtEhHw9IM7G8Ldt3
	 sarWOsQ0WQmag1AIo6mlS1Y6o743NgdT0rJZ7Hak=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 83D6F8B8B1;
	Tue, 12 Mar 2019 23:16:17 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id D_VLXvzfkmS2; Tue, 12 Mar 2019 23:16:17 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 291848B8A7;
	Tue, 12 Mar 2019 23:16:17 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id E64366FA15; Tue, 12 Mar 2019 22:16:16 +0000 (UTC)
Message-Id: <7600ccac6eca9289244b7d1172a9525ef67b4822.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 11/18] powerpc/32: Add KASAN support
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds KASAN support for PPC32. The following patch
will add an early activation of hash table for book3s. Until
then, a warning will be raised if trying to use KASAN on an
hash 6xx.

To support KASAN, this patch initialises that MMU mapings for
accessing to the KASAN shadow area defined in a previous patch.

An early mapping is set as soon as the kernel code has been
relocated at its definitive place.

Then the definitive mapping is set once paging is initialised.

For modules, the shadow area is allocated at module_alloc().

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig                  |   1 +
 arch/powerpc/include/asm/kasan.h      |   9 ++
 arch/powerpc/kernel/head_32.S         |   3 +
 arch/powerpc/kernel/head_40x.S        |   3 +
 arch/powerpc/kernel/head_44x.S        |   3 +
 arch/powerpc/kernel/head_8xx.S        |   3 +
 arch/powerpc/kernel/head_fsl_booke.S  |   3 +
 arch/powerpc/kernel/setup-common.c    |   3 +
 arch/powerpc/mm/Makefile              |   1 +
 arch/powerpc/mm/init_32.c             |   3 +
 arch/powerpc/mm/kasan/Makefile        |   5 ++
 arch/powerpc/mm/kasan/kasan_init_32.c | 156 ++++++++++++++++++++++++++++++++++
 12 files changed, 193 insertions(+)
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index facaa6ba0d2a..d9364368329b 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -173,6 +173,7 @@ config PPC
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN			if PPC32
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 05274dea3109..296e51c2f066 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -27,5 +27,14 @@
 
 #define KASAN_SHADOW_SIZE	(KASAN_SHADOW_END - KASAN_SHADOW_START)
 
+#ifdef CONFIG_KASAN
+void kasan_early_init(void);
+void kasan_mmu_init(void);
+void kasan_init(void);
+#else
+static inline void kasan_init(void) { }
+static inline void kasan_mmu_init(void) { }
+#endif
+
 #endif /* __ASSEMBLY */
 #endif
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 48051c8977c5..3ee42c0ada69 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -958,6 +958,9 @@ start_here:
  * Do early platform-specific initialization,
  * and set up the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
index a9c934f2319b..efa219d2136e 100644
--- a/arch/powerpc/kernel/head_40x.S
+++ b/arch/powerpc/kernel/head_40x.S
@@ -848,6 +848,9 @@ start_here:
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_44x.S b/arch/powerpc/kernel/head_44x.S
index 37117ab11584..34a5df827b38 100644
--- a/arch/powerpc/kernel/head_44x.S
+++ b/arch/powerpc/kernel/head_44x.S
@@ -203,6 +203,9 @@ _ENTRY(_start);
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index 03c73b4c6435..d25adb6ef235 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -853,6 +853,9 @@ start_here:
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_fsl_booke.S b/arch/powerpc/kernel/head_fsl_booke.S
index 1881127682e9..0fc38eb957b7 100644
--- a/arch/powerpc/kernel/head_fsl_booke.S
+++ b/arch/powerpc/kernel/head_fsl_booke.S
@@ -275,6 +275,9 @@ set_ivor:
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	mr	r3,r30
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index e7534f306c8e..3c6c5a43901e 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -67,6 +67,7 @@
 #include <asm/livepatch.h>
 #include <asm/mmu_context.h>
 #include <asm/cpu_has_feature.h>
+#include <asm/kasan.h>
 
 #include "setup.h"
 
@@ -865,6 +866,8 @@ static void smp_setup_pacas(void)
  */
 void __init setup_arch(char **cmdline_p)
 {
+	kasan_init();
+
 	*cmdline_p = boot_command_line;
 
 	/* Set a half-reasonable default so udelay does something sensible */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 240d73dce6bb..80382a2d169b 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
 obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
+obj-$(CONFIG_KASAN)		+= kasan/
 
 # Disable kcov instrumentation on sensitive code
 # This is necessary for booting with kcov enabled on book3e machines
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index 41a3513cadc9..0217d1b405f7 100644
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -45,6 +45,7 @@
 #include <asm/tlb.h>
 #include <asm/sections.h>
 #include <asm/hugetlb.h>
+#include <asm/kasan.h>
 
 #include "mmu_decl.h"
 
@@ -178,6 +179,8 @@ void __init MMU_init(void)
 	btext_unmap();
 #endif
 
+	kasan_mmu_init();
+
 	/* Shortly after that, the entire linear mapping will be available */
 	memblock_set_current_limit(lowmem_end_addr);
 }
diff --git a/arch/powerpc/mm/kasan/Makefile b/arch/powerpc/mm/kasan/Makefile
new file mode 100644
index 000000000000..6577897673dd
--- /dev/null
+++ b/arch/powerpc/mm/kasan/Makefile
@@ -0,0 +1,5 @@
+# SPDX-License-Identifier: GPL-2.0
+
+KASAN_SANITIZE := n
+
+obj-$(CONFIG_PPC32)           += kasan_init_32.o
diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
new file mode 100644
index 000000000000..42617fcad828
--- /dev/null
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -0,0 +1,156 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/kasan.h>
+#include <linux/printk.h>
+#include <linux/memblock.h>
+#include <linux/sched/task.h>
+#include <linux/vmalloc.h>
+#include <asm/pgalloc.h>
+#include <asm/code-patching.h>
+#include <mm/mmu_decl.h>
+
+static void kasan_populate_pte(pte_t *ptep, pgprot_t prot)
+{
+	unsigned long va = (unsigned long)kasan_early_shadow_page;
+	phys_addr_t pa = __pa(kasan_early_shadow_page);
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++, ptep++)
+		__set_pte_at(&init_mm, va, ptep, pfn_pte(PHYS_PFN(pa), prot), 0);
+}
+
+static int kasan_init_shadow_page_tables(unsigned long k_start, unsigned long k_end)
+{
+	pmd_t *pmd;
+	unsigned long k_cur, k_next;
+
+	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
+
+	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
+		pte_t *new;
+
+		k_next = pgd_addr_end(k_cur, k_end);
+		if ((void *)pmd_page_vaddr(*pmd) != kasan_early_shadow_pte)
+			continue;
+
+		new = pte_alloc_one_kernel(&init_mm);
+
+		if (!new)
+			return -ENOMEM;
+		kasan_populate_pte(new, PAGE_KERNEL_RO);
+		pmd_populate_kernel(&init_mm, pmd, new);
+	}
+	return 0;
+}
+
+static void __ref *kasan_get_one_page(void)
+{
+	if (slab_is_available())
+		return (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+
+	return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+}
+
+static int __ref kasan_init_region(void *start, size_t size)
+{
+	unsigned long k_start = (unsigned long)kasan_mem_to_shadow(start);
+	unsigned long k_end = (unsigned long)kasan_mem_to_shadow(start + size);
+	unsigned long k_cur;
+	int ret;
+	void *block = NULL;
+
+	ret = kasan_init_shadow_page_tables(k_start, k_end);
+	if (ret)
+		return ret;
+
+	if (!slab_is_available())
+		block = memblock_alloc(k_end - k_start, PAGE_SIZE);
+
+	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
+		pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
+		void *va = block ? block + k_cur - k_start : kasan_get_one_page();
+		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
+
+		if (!va)
+			return -ENOMEM;
+
+		__set_pte_at(&init_mm, k_cur, pte_offset_kernel(pmd, k_cur), pte, 0);
+	}
+	flush_tlb_kernel_range(k_start, k_end);
+	return 0;
+}
+
+static void __init kasan_remap_early_shadow_ro(void)
+{
+	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
+
+	flush_tlb_kernel_range(KASAN_SHADOW_START, KASAN_SHADOW_END);
+}
+
+void __init kasan_mmu_init(void)
+{
+	int ret;
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg) {
+		phys_addr_t base = reg->base;
+		phys_addr_t top = min(base + reg->size, total_lowmem);
+
+		if (base >= top)
+			continue;
+
+		ret = kasan_init_region(__va(base), top - base);
+		if (ret)
+			panic("kasan: kasan_init_region() failed");
+	}
+}
+
+void __init kasan_init(void)
+{
+	kasan_remap_early_shadow_ro();
+
+	clear_page(kasan_early_shadow_page);
+
+	/* At this point kasan is fully initialized. Enable error messages */
+	init_task.kasan_depth = 0;
+	pr_info("KASAN init done\n");
+}
+
+#ifdef CONFIG_MODULES
+void *module_alloc(unsigned long size)
+{
+	void *base = vmalloc_exec(size);
+
+	if (!base)
+		return NULL;
+
+	if (!kasan_init_region(base, size))
+		return base;
+
+	vfree(base);
+
+	return NULL;
+}
+#endif
+
+void __init kasan_early_init(void)
+{
+	unsigned long addr = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
+	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
+
+	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
+
+	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
+	} while (pmd++, addr = next, addr != end);
+
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		WARN(true, "KASAN not supported on hash 6xx");
+}
-- 
2.13.3

