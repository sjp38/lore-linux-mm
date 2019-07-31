Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC2C6C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FE7420C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FE7420C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE07F8E002E; Wed, 31 Jul 2019 11:47:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B92528E0003; Wed, 31 Jul 2019 11:47:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91FBD8E002E; Wed, 31 Jul 2019 11:47:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2BC8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:47:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so31543077edv.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Tw4jEDZ4CrtR6AkFxGso+mamrW+YV+8R26O5CKGhn+M=;
        b=ekqThMY+ZrrvmRbT2X4LUKxm6YyjiZncbyK6N6JogiQOG0xKcDnJo4OHWiENYRtlOF
         qhLQSXCHI/KqDGNlCC90I+skihNPQAxf3VOBozgEslBVLpzNngetc0ikrvEztb3tFH8x
         SwxdK7eVM4L+sXVWcVvNEKJOdF4gbsJG38mnV7RCTKKZXtVtK32u8LjfXVMW7fU9OccG
         XCZa0AAGDaNre4xPZrfu2I43dm/w24spy4hGgeWquXuXF/0SmtBr3sjDCgT6Hj7EiRp0
         eRon6/U5YYSBqTlD73Qsn+s4o3lg0fwpYKOsmes+wcOiHaMgSO9RB9Y4agO2i0cIr36L
         RC1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXnpn2z+skyhcUnxsNICW2uXSlb5M8rop6Xbv/VqCFy/sr83lz/
	p56eRnUfja5Tt2rWz0ztXOkhny3nwecXzXx26HwlKA3ORtZcKdvT7e2dpWq5Detfv/UOadexzBV
	VgTxdigvEzHuMpxrcDGbn1khpBLznmIbgdZsTRjSlNPqXmH5f+oEVzMt3HIgCVi0ZRg==
X-Received: by 2002:a17:906:2ecc:: with SMTP id s12mr43277028eji.110.1564588034769;
        Wed, 31 Jul 2019 08:47:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxe6M9/OuB+tBhdzE/Gf6VDhaD1OVSA0jK+E/r2FRKNYFc1/i3jZK+gmnoXIj/Pn7xy0uaw
X-Received: by 2002:a17:906:2ecc:: with SMTP id s12mr43276950eji.110.1564588033545;
        Wed, 31 Jul 2019 08:47:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588033; cv=none;
        d=google.com; s=arc-20160816;
        b=HBURMZo34Y1txMiz1HV2UHLdOo/c6k0K64sB9ixTAq9ohniaMf1Rvfj5WXCn9bmwc9
         ZBl0VE3ne7EZcUMGNhDmL1u+lgC4X/3kryHaC0Fd33FAsrc0C4BbgQW1bKNtR5Q0CYBh
         msHg7u4vMHQDRUVzGsxq2+XJGmok1yFN+HF89OQfhAheZog+2qa1M2wXE/qLay5H84cr
         4Lhv3wunz2zKPJKiHvW9cLIdWlO7TvWA6KFjdsJFp7nN6y9Bck4LbmdhLKdCSV2vg95C
         OGlVWOgEl7R8OSo7SzOEyAA0eR8ko+6ZPXF2jaYxLlrVl12XOzj1raugWysfFueeUK+7
         5bAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Tw4jEDZ4CrtR6AkFxGso+mamrW+YV+8R26O5CKGhn+M=;
        b=XW27last1bXq1o8aJ/9bIxtc+t6T9nzjk9RsxyZL5wmBExzyotRrduZb+5a/me4hpg
         0Jb8sL4F04uEAhCcYEftIXX0m1FohxgGgcVfmKUeAW+dbeq3DUA0qFFlvSxLSVQ+h3F9
         h1LYLmtI0fP+6vyuSBzW0bnJTqybV9mIYUApkUFQsPq+EL23lvleVNZ+77fLcw1JQhlL
         6USslcNTJVXXlB58XjG2z97mwIiDjAd6Et+lza58BYWhh4qW3XGiyqoSnjESMKTls/Dy
         0lzSuf2lYWjEuOnHM+/RbmW94pFst+TU2Dx0QswFxti+8RB1VSJwVzjMC4M4ljyfwAMi
         h08g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k5si18575251ejp.230.2019.07.31.08.47.13
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:47:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ADABC344;
	Wed, 31 Jul 2019 08:47:12 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 244843F694;
	Wed, 31 Jul 2019 08:47:10 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v10 21/22] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Wed, 31 Jul 2019 16:46:02 +0100
Message-Id: <20190731154603.41797-22-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now walk_page_range() can walk kernel page tables, we can switch the
arm64 ptdump code over to using it, simplifying the code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/Kconfig                 |   1 +
 arch/arm64/Kconfig.debug           |  19 +----
 arch/arm64/include/asm/ptdump.h    |   8 +-
 arch/arm64/mm/Makefile             |   4 +-
 arch/arm64/mm/dump.c               | 117 ++++++++++-------------------
 arch/arm64/mm/mmu.c                |   4 +-
 arch/arm64/mm/ptdump_debugfs.c     |   2 +-
 drivers/firmware/efi/arm-runtime.c |   2 +-
 8 files changed, 50 insertions(+), 107 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..5a32c87f37c6 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -105,6 +105,7 @@ config ARM64
 	select GENERIC_IRQ_SHOW
 	select GENERIC_IRQ_SHOW_LEVEL
 	select GENERIC_PCI_IOMAP
+	select GENERIC_PTDUMP
 	select GENERIC_SCHED_CLOCK
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
diff --git a/arch/arm64/Kconfig.debug b/arch/arm64/Kconfig.debug
index cf09010d825f..1c906d932d6b 100644
--- a/arch/arm64/Kconfig.debug
+++ b/arch/arm64/Kconfig.debug
@@ -1,22 +1,5 @@
 # SPDX-License-Identifier: GPL-2.0-only
 
-config ARM64_PTDUMP_CORE
-	def_bool n
-
-config ARM64_PTDUMP_DEBUGFS
-	bool "Export kernel pagetable layout to userspace via debugfs"
-	depends on DEBUG_KERNEL
-	select ARM64_PTDUMP_CORE
-	select DEBUG_FS
-        help
-	  Say Y here if you want to show the kernel pagetable layout in a
-	  debugfs file. This information is only useful for kernel developers
-	  who are working in architecture specific areas of the kernel.
-	  It is probably not a good idea to enable this feature in a production
-	  kernel.
-
-	  If in doubt, say N.
-
 config PID_IN_CONTEXTIDR
 	bool "Write the current PID to the CONTEXTIDR register"
 	help
@@ -42,7 +25,7 @@ config ARM64_RANDOMIZE_TEXT_OFFSET
 
 config DEBUG_WX
 	bool "Warn on W+X mappings at boot"
-	select ARM64_PTDUMP_CORE
+	select PTDUMP_CORE
 	---help---
 	  Generate a warning if any W+X mappings are found at boot.
 
diff --git a/arch/arm64/include/asm/ptdump.h b/arch/arm64/include/asm/ptdump.h
index 0b8e7269ec82..38187f74e089 100644
--- a/arch/arm64/include/asm/ptdump.h
+++ b/arch/arm64/include/asm/ptdump.h
@@ -5,7 +5,7 @@
 #ifndef __ASM_PTDUMP_H
 #define __ASM_PTDUMP_H
 
-#ifdef CONFIG_ARM64_PTDUMP_CORE
+#ifdef CONFIG_PTDUMP_CORE
 
 #include <linux/mm_types.h>
 #include <linux/seq_file.h>
@@ -21,15 +21,15 @@ struct ptdump_info {
 	unsigned long			base_addr;
 };
 
-void ptdump_walk_pgd(struct seq_file *s, struct ptdump_info *info);
-#ifdef CONFIG_ARM64_PTDUMP_DEBUGFS
+void ptdump_walk(struct seq_file *s, struct ptdump_info *info);
+#ifdef CONFIG_PTDUMP_DEBUGFS
 void ptdump_debugfs_register(struct ptdump_info *info, const char *name);
 #else
 static inline void ptdump_debugfs_register(struct ptdump_info *info,
 					   const char *name) { }
 #endif
 void ptdump_check_wx(void);
-#endif /* CONFIG_ARM64_PTDUMP_CORE */
+#endif /* CONFIG_PTDUMP_CORE */
 
 #ifdef CONFIG_DEBUG_WX
 #define debug_checkwx()	ptdump_check_wx()
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 849c1df3d214..d91030f0ffee 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -4,8 +4,8 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   ioremap.o mmap.o pgd.o mmu.o \
 				   context.o proc.o pageattr.o
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
-obj-$(CONFIG_ARM64_PTDUMP_CORE)	+= dump.o
-obj-$(CONFIG_ARM64_PTDUMP_DEBUGFS)	+= ptdump_debugfs.o
+obj-$(CONFIG_PTDUMP_CORE)	+= dump.o
+obj-$(CONFIG_PTDUMP_DEBUGFS)	+= ptdump_debugfs.o
 obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_DEBUG_VIRTUAL)	+= physaddr.o
 KASAN_SANITIZE_physaddr.o	+= n
diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index 82b3a7fdb4a6..5cc71ad567b4 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -15,6 +15,7 @@
 #include <linux/io.h>
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <linux/ptdump.h>
 #include <linux/sched.h>
 #include <linux/seq_file.h>
 
@@ -65,10 +66,11 @@ static const struct addr_marker address_markers[] = {
  * dumps out a description of the range.
  */
 struct pg_state {
+	struct ptdump_state ptdump;
 	struct seq_file *seq;
 	const struct addr_marker *marker;
 	unsigned long start_address;
-	unsigned level;
+	int level;
 	u64 current_prot;
 	bool check_wx;
 	unsigned long wx_pages;
@@ -168,6 +170,10 @@ static struct pg_level pg_level[] = {
 		.name	= "PGD",
 		.bits	= pte_bits,
 		.num	= ARRAY_SIZE(pte_bits),
+	}, { /* p4d */
+		.name	= "P4D",
+		.bits	= pte_bits,
+		.num	= ARRAY_SIZE(pte_bits),
 	}, { /* pud */
 		.name	= (CONFIG_PGTABLE_LEVELS > 3) ? "PUD" : "PGD",
 		.bits	= pte_bits,
@@ -230,11 +236,15 @@ static void note_prot_wx(struct pg_state *st, unsigned long addr)
 	st->wx_pages += (addr - st->start_address) / PAGE_SIZE;
 }
 
-static void note_page(struct pg_state *st, unsigned long addr, unsigned level,
-				u64 val)
+static void note_page(struct ptdump_state *pt_st, unsigned long addr, int level,
+				unsigned long val)
 {
+	struct pg_state *st = container_of(pt_st, struct pg_state, ptdump);
 	static const char units[] = "KMGTPE";
-	u64 prot = val & pg_level[level].mask;
+	u64 prot = 0;
+
+	if (level >= 0)
+		prot = val & pg_level[level].mask;
 
 	if (!st->level) {
 		st->level = level;
@@ -282,85 +292,27 @@ static void note_page(struct pg_state *st, unsigned long addr, unsigned level,
 
 }
 
-static void walk_pte(struct pg_state *st, pmd_t *pmdp, unsigned long start,
-		     unsigned long end)
-{
-	unsigned long addr = start;
-	pte_t *ptep = pte_offset_kernel(pmdp, start);
-
-	do {
-		note_page(st, addr, 4, READ_ONCE(pte_val(*ptep)));
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
-}
-
-static void walk_pmd(struct pg_state *st, pud_t *pudp, unsigned long start,
-		     unsigned long end)
-{
-	unsigned long next, addr = start;
-	pmd_t *pmdp = pmd_offset(pudp, start);
-
-	do {
-		pmd_t pmd = READ_ONCE(*pmdp);
-		next = pmd_addr_end(addr, end);
-
-		if (pmd_none(pmd) || pmd_sect(pmd)) {
-			note_page(st, addr, 3, pmd_val(pmd));
-		} else {
-			BUG_ON(pmd_bad(pmd));
-			walk_pte(st, pmdp, addr, next);
-		}
-	} while (pmdp++, addr = next, addr != end);
-}
-
-static void walk_pud(struct pg_state *st, pgd_t *pgdp, unsigned long start,
-		     unsigned long end)
+void ptdump_walk(struct seq_file *s, struct ptdump_info *info)
 {
-	unsigned long next, addr = start;
-	pud_t *pudp = pud_offset(pgdp, start);
-
-	do {
-		pud_t pud = READ_ONCE(*pudp);
-		next = pud_addr_end(addr, end);
-
-		if (pud_none(pud) || pud_sect(pud)) {
-			note_page(st, addr, 2, pud_val(pud));
-		} else {
-			BUG_ON(pud_bad(pud));
-			walk_pmd(st, pudp, addr, next);
-		}
-	} while (pudp++, addr = next, addr != end);
-}
+	unsigned long end = ~0UL;
+	struct pg_state st;
 
-static void walk_pgd(struct pg_state *st, struct mm_struct *mm,
-		     unsigned long start)
-{
-	unsigned long end = (start < TASK_SIZE_64) ? TASK_SIZE_64 : 0;
-	unsigned long next, addr = start;
-	pgd_t *pgdp = pgd_offset(mm, start);
-
-	do {
-		pgd_t pgd = READ_ONCE(*pgdp);
-		next = pgd_addr_end(addr, end);
-
-		if (pgd_none(pgd)) {
-			note_page(st, addr, 1, pgd_val(pgd));
-		} else {
-			BUG_ON(pgd_bad(pgd));
-			walk_pud(st, pgdp, addr, next);
-		}
-	} while (pgdp++, addr = next, addr != end);
-}
+	if (info->base_addr < TASK_SIZE_64)
+		end = TASK_SIZE_64;
 
-void ptdump_walk_pgd(struct seq_file *m, struct ptdump_info *info)
-{
-	struct pg_state st = {
-		.seq = m,
+	st = (struct pg_state){
+		.seq = s,
 		.marker = info->markers,
+		.ptdump = {
+			.note_page = note_page,
+			.range = (struct ptdump_range[]){
+				{info->base_addr, end},
+				{0, 0}
+			}
+		}
 	};
 
-	walk_pgd(&st, info->mm, info->base_addr);
-
-	note_page(&st, 0, 0, 0);
+	ptdump_walk_pgd(&st.ptdump, info->mm);
 }
 
 static void ptdump_initialize(void)
@@ -388,10 +340,17 @@ void ptdump_check_wx(void)
 			{ -1, NULL},
 		},
 		.check_wx = true,
+		.ptdump = {
+			.note_page = note_page,
+			.range = (struct ptdump_range[]) {
+				{VA_START, ~0UL},
+				{0, 0}
+			}
+		}
 	};
 
-	walk_pgd(&st, &init_mm, VA_START);
-	note_page(&st, 0, 0, 0);
+	ptdump_walk_pgd(&st.ptdump, &init_mm);
+
 	if (st.wx_pages || st.uxn_pages)
 		pr_warn("Checked W+X mappings: FAILED, %lu W+X pages found, %lu non-UXN pages found\n",
 			st.wx_pages, st.uxn_pages);
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 750a69dde39b..ff612579ca75 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -954,13 +954,13 @@ int __init arch_ioremap_pud_supported(void)
 	 * SW table walks can't handle removal of intermediate entries.
 	 */
 	return IS_ENABLED(CONFIG_ARM64_4K_PAGES) &&
-	       !IS_ENABLED(CONFIG_ARM64_PTDUMP_DEBUGFS);
+	       !IS_ENABLED(CONFIG_PTDUMP_DEBUGFS);
 }
 
 int __init arch_ioremap_pmd_supported(void)
 {
 	/* See arch_ioremap_pud_supported() */
-	return !IS_ENABLED(CONFIG_ARM64_PTDUMP_DEBUGFS);
+	return !IS_ENABLED(CONFIG_PTDUMP_DEBUGFS);
 }
 
 int pud_set_huge(pud_t *pudp, phys_addr_t phys, pgprot_t prot)
diff --git a/arch/arm64/mm/ptdump_debugfs.c b/arch/arm64/mm/ptdump_debugfs.c
index 064163f25592..1f2eae3e988b 100644
--- a/arch/arm64/mm/ptdump_debugfs.c
+++ b/arch/arm64/mm/ptdump_debugfs.c
@@ -7,7 +7,7 @@
 static int ptdump_show(struct seq_file *m, void *v)
 {
 	struct ptdump_info *info = m->private;
-	ptdump_walk_pgd(m, info);
+	ptdump_walk(m, info);
 	return 0;
 }
 DEFINE_SHOW_ATTRIBUTE(ptdump);
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
index e2ac5fa5531b..1283685f9c20 100644
--- a/drivers/firmware/efi/arm-runtime.c
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -27,7 +27,7 @@
 
 extern u64 efi_system_table;
 
-#ifdef CONFIG_ARM64_PTDUMP_DEBUGFS
+#if defined(CONFIG_PTDUMP_DEBUGFS) && defined(CONFIG_ARM64)
 #include <asm/ptdump.h>
 
 static struct ptdump_info efi_ptdump_info = {
-- 
2.20.1

