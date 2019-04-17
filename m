Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEF68C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B694217F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:34:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B694217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F4446B0005; Wed, 17 Apr 2019 10:34:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E286B0007; Wed, 17 Apr 2019 10:34:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E88606B0008; Wed, 17 Apr 2019 10:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95BE66B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:34:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so12570888edo.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P43hjsRFfbkkRybYuiqXe56a6GTahtQ7JYKITTlCoxQ=;
        b=cV/T3aGs4Ppsr3koD6gjKugcxf1AP1I5dTCGGew9nt/pVWUjDxEPvcvL3q8smuLD+X
         hnNxyeP987xAsYBBBYvXg43q0AJ7YEFCn3VHj8lcvWcsWpBbHwQkkvWd/Lu/JXosGsr6
         J/Ro5LmRyT1cbWMAYZnmx8YQm4R3dLfB83oTPqb+tpV241Nyv4vnxinlbdBq7pRP46rk
         OczyyRDSuCIrHDxdZtGEijqzn4xNf3JmUnkWEASETmB3Yb5JbRW/nQtFhm3LP6eJwZJM
         PpujYgqsvNZNqkrWK3q04Xzl7v2ev3K2bk8igP2koT0N3FVEeU4tOS5b+173Tzej9kYi
         aXhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWKoCu6xd2+r+AylaJUFYzARw81+6I4EEJH+MT7CmrmdQrL/OAO
	h/E2XYzt2x01sMbQwalkmshVar8XdyFIC/gl/kd0pQKLOhepu7DKC+idYPcjzlA3zJ6lOxP6Qi/
	Ctr7Etf30FNlOuocKS8GHW3Po+GnITciw3Urd2LK/rocpO6zLEjJEJoDzUPl5+i1c9Q==
X-Received: by 2002:a17:906:d512:: with SMTP id ge18mr47452001ejb.232.1555511680056;
        Wed, 17 Apr 2019 07:34:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTPlSobSp+XSpKl9nBUfpzf6yeewVIG2Cz1etWtC2cWttdeMHKJ7969RsphI0ZglWePCey
X-Received: by 2002:a17:906:d512:: with SMTP id ge18mr47451925ejb.232.1555511678530;
        Wed, 17 Apr 2019 07:34:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555511678; cv=none;
        d=google.com; s=arc-20160816;
        b=kpRn2+P6fVgO3U6gFEwuzVYvsH6DizoqmeXOz4bG2n0SoNzEzDK+JqR62Io6ryMBhE
         M637ctVhlWzRAnclbGmWcYERyHbvzfU9Ve21/NsUqwHi/8HzbwaHmMa6G55ct3FGqyjZ
         p8iWhHYq2qa7nBTIy66nxt0K9u8nOtC1VbgOAML4VJl7IuAaJP9DhO+rk0YL9OzLG/Gg
         MnSuuxoUHKMrDHTyC0/h3S+ANZXL2vEihYlvWTEPNf13iVVrsYBbSjC6/8LhTaUwlGGf
         wGqa2PG9adrHPUhdMsb6VC2FjWLB+PnqJhteRepahLbGB/PebKdd9nb5I4SqUbqrVFWD
         RRSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=P43hjsRFfbkkRybYuiqXe56a6GTahtQ7JYKITTlCoxQ=;
        b=Hg7061x4GT3b5HwntRXZK2hddVj6nK06Y03IfpiQc0SE6eolHjDnrh8z3OpaYTxi8X
         pywDnAfM7T7mfpTAIzpncI7L0E7gGzkVij+Urz1REGkMEleYlGLohS8RGG0te4wC588G
         wO474iaEs8mPnSQ3Y7mReJTGnlRGlKbqxIobsvpJnow9V7r6UIuIqYnJcy8G7sfVQmvT
         eReURJMHR4jNJZrCCOh56Lv3tRETjvAKDbq1cR1u6JkGaXW0HOssgwK861ol5C49bRAe
         06jQE/czCXgGcscdTqbUtokanXn9vcw1FfX2ixsU820VJUxM8GzPHxavrv2wMB/mkHX/
         uVLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k31si952944eda.393.2019.04.17.07.34.38
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 07:34:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6141B15A2;
	Wed, 17 Apr 2019 07:34:37 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B02433F557;
	Wed, 17 Apr 2019 07:34:33 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: Dave Hansen <dave.hansen@intel.com>,
	linux-mm@kvack.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	x86@kernel.org,
	Will Deacon <will.deacon@arm.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Steven Price <steven.price@arm.com>
Subject: [RFC PATCH 2/3] arm64: mm: Switch to using generic pt_dump
Date: Wed, 17 Apr 2019 15:34:22 +0100
Message-Id: <20190417143423.26665-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417143423.26665-1-steven.price@arm.com>
References: <3acbf061-8c97-55eb-f4b6-163a33ea4d73@arm.com>
 <20190417143423.26665-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of providing our own callbacks for walking the page tables,
switch to using the generic version instead.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/Kconfig              |   1 +
 arch/arm64/Kconfig.debug        |  19 +-----
 arch/arm64/include/asm/ptdump.h |   8 +--
 arch/arm64/mm/Makefile          |   4 +-
 arch/arm64/mm/dump.c            | 104 +++++++++-----------------------
 arch/arm64/mm/ptdump_debugfs.c  |   2 +-
 6 files changed, 37 insertions(+), 101 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 117b2541ef3d..4ff55b3ce8dc 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -97,6 +97,7 @@ config ARM64
 	select GENERIC_IRQ_SHOW
 	select GENERIC_IRQ_SHOW_LEVEL
 	select GENERIC_PCI_IOMAP
+	select GENERIC_PTDUMP
 	select GENERIC_SCHED_CLOCK
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
diff --git a/arch/arm64/Kconfig.debug b/arch/arm64/Kconfig.debug
index 69c9170bdd24..570dba4d4a0e 100644
--- a/arch/arm64/Kconfig.debug
+++ b/arch/arm64/Kconfig.debug
@@ -1,21 +1,4 @@
 
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
@@ -41,7 +24,7 @@ config ARM64_RANDOMIZE_TEXT_OFFSET
 
 config DEBUG_WX
 	bool "Warn on W+X mappings at boot"
-	select ARM64_PTDUMP_CORE
+	select PTDUMP_CORE
 	---help---
 	  Generate a warning if any W+X mappings are found at boot.
 
diff --git a/arch/arm64/include/asm/ptdump.h b/arch/arm64/include/asm/ptdump.h
index 9e948a93d26c..f8fecda7b61d 100644
--- a/arch/arm64/include/asm/ptdump.h
+++ b/arch/arm64/include/asm/ptdump.h
@@ -16,7 +16,7 @@
 #ifndef __ASM_PTDUMP_H
 #define __ASM_PTDUMP_H
 
-#ifdef CONFIG_ARM64_PTDUMP_CORE
+#ifdef CONFIG_PTDUMP_CORE
 
 #include <linux/mm_types.h>
 #include <linux/seq_file.h>
@@ -32,15 +32,15 @@ struct ptdump_info {
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
index ea20c1213498..e68df2ad8863 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -19,6 +19,7 @@
 #include <linux/io.h>
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <linux/ptdump.h>
 #include <linux/sched.h>
 #include <linux/seq_file.h>
 
@@ -69,6 +70,7 @@ static const struct addr_marker address_markers[] = {
  * dumps out a description of the range.
  */
 struct pg_state {
+	struct ptdump_state ptdump;
 	struct seq_file *seq;
 	const struct addr_marker *marker;
 	unsigned long start_address;
@@ -172,6 +174,10 @@ static struct pg_level pg_level[] = {
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
@@ -234,9 +240,10 @@ static void note_prot_wx(struct pg_state *st, unsigned long addr)
 	st->wx_pages += (addr - st->start_address) / PAGE_SIZE;
 }
 
-static void note_page(struct pg_state *st, unsigned long addr, int level,
-				u64 val)
+static void note_page(struct ptdump_state *pt_st, unsigned long addr, int level,
+				unsigned long val)
 {
+	struct pg_state *st = container_of(pt_st, struct pg_state, ptdump);
 	static const char units[] = "KMGTPE";
 	u64 prot = 0;
 
@@ -289,83 +296,21 @@ static void note_page(struct pg_state *st, unsigned long addr, int level,
 
 }
 
-static int pud_entry(pud_t *pud, unsigned long addr,
-		unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pud_t val = READ_ONCE(*pud);
-
-	if (pud_table(val))
-		return 0;
-
-	note_page(st, addr, 2, pud_val(val));
-
-	return 0;
-}
-
-static int pmd_entry(pmd_t *pmd, unsigned long addr,
-		unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pmd_t val = READ_ONCE(*pmd);
-
-	if (pmd_table(val))
-		return 0;
-
-	note_page(st, addr, 3, pmd_val(val));
-
-	return 0;
-}
-
-static int pte_entry(pte_t *pte, unsigned long addr,
-		unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pte_t val = READ_ONCE(*pte);
-
-	note_page(st, addr, 4, pte_val(val));
-
-	return 0;
-}
-
-static int pte_hole(unsigned long addr, unsigned long next,
-		struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-
-	note_page(st, addr, -1, 0);
-
-	return 0;
-}
-
-static void walk_pgd(struct pg_state *st, struct mm_struct *mm,
-		unsigned long start)
-{
-	struct mm_walk walk = {
-		.mm = mm,
-		.private = st,
-		.pud_entry = pud_entry,
-		.pmd_entry = pmd_entry,
-		.pte_entry = pte_entry,
-		.pte_hole = pte_hole
-	};
-	down_read(&mm->mmap_sem);
-	walk_page_range(start, start | (((unsigned long)PTRS_PER_PGD <<
-					 PGDIR_SHIFT) - 1),
-			&walk);
-	up_read(&mm->mmap_sem);
-}
-
-void ptdump_walk_pgd(struct seq_file *m, struct ptdump_info *info)
+void ptdump_walk(struct seq_file *s, struct ptdump_info *info)
 {
 	struct pg_state st = {
-		.seq = m,
+		.seq = s,
 		.marker = info->markers,
+		.ptdump = {
+			.note_page = note_page,
+			.range = (struct ptdump_range[]){
+				{info->base_addr, ~0UL},
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
@@ -393,10 +338,17 @@ void ptdump_check_wx(void)
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
-- 
2.20.1

