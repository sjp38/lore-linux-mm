Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 858A2C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FE9D206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:34:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FE9D206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA79A6B0007; Wed, 17 Apr 2019 10:34:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2CD26B0008; Wed, 17 Apr 2019 10:34:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCA176B000A; Wed, 17 Apr 2019 10:34:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 631DB6B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:34:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e22so11288630edd.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:34:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iP5Fk+kk715v+0mqvcL48B6aSaM3nllkLc6DHE5jkIs=;
        b=s9w/xx+jGWxal0esvnP27yJuafeRm4y9k+TyUaomaQXc6KZl7L+xso0lEItuqPOv05
         0USN5FIwQZCrQ49LFxuQn8mGX+7MZQHlmX0AWrPpchKLukioe4Y0uYerW86hSKdHmW5C
         +WFuS/NqI5boJNnj9C7qomXpMr1FexX+WztCHbI3+CxbUV2JcwZqu7uSoLnhMXBVAVO9
         /td0IMoHeXasWuIVCGyCam7GV3B8PoZ+jxUcBkheg6Ww/IpVpEfaYGLIeILBMpEv66/1
         RCjgqUbJve9fvQrphCyu2xkEv+ZA+B3oP99G1ziKPsTHqnAqZWkAMK0WUvwYD/TH6Ryh
         LGkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWGCcinM02qCOzvHiqMp6qsaeXvEtOBhW8U6yWNTLzm8OAa5GLH
	WZk0hx1mWaL3+C5m6Et3G7rHQpyc9f2HYsowL243JNtR0PxrkJOlCpWmmCUxTwy8MEY+XDdO0ri
	XzcXJRusNbQtdbHXTfzuW9UskONUFEN6w8bV1O4mdq/L8iVJnEtmiEsGgdXjsh9vyfQ==
X-Received: by 2002:a50:b6e4:: with SMTP id f33mr26539773ede.2.1555511683783;
        Wed, 17 Apr 2019 07:34:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyerhXEWKUNWZhjucsaumU/+jRrZGIHZFXp2TnpOxPNN7ltinkA0Xrqo5F6Xs/Xc4uRDY7O
X-Received: by 2002:a50:b6e4:: with SMTP id f33mr26539698ede.2.1555511682277;
        Wed, 17 Apr 2019 07:34:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555511682; cv=none;
        d=google.com; s=arc-20160816;
        b=mdv5+EGbYxfBA2NZIQanH+iIV2Lbiz1ido4D2Aa5v2BQv1qne9Rj1ISJqK5TTLWNHe
         VQL2bdVhzivSdOjk314HuyQaN7rgulAuEtT48aRNrnZhHMFOCiaYglC6KKOuuVNJezFO
         DIdXdxmyyYibDjhIgLDMT9pQoG/KHLRAsysml0M/7fTQouFVs8AOU3hy1S6yZrqP2HPY
         R0M00jhatJYORw7Hf8LM6eh8+mOb6vbrD13rr0CzTAOs14cJiy1IrilVQTq9uALWnO6n
         0Xfex/OzJNSjffDDbXdn+PoyOMzybQFSrFArwFc4MKsHDFaVtBjxp0V9i4bbsELRjWMo
         t/qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iP5Fk+kk715v+0mqvcL48B6aSaM3nllkLc6DHE5jkIs=;
        b=ifsdWuYC8VcM4VTUPqbOuY7mUK+aJGUfzEHwMaPKWCIJSB8Qg3W/eVP9U3DYng9zur
         c2VF7cPNjsZQmGbcMYOlj8D2OkWgqDgsQKNFESn4TB3q58OKEwThXXgWoPSK3LuQAag2
         BirhiCzOPu1Y8/wNjfuFLqIK1wM6IzFclj2UgRt/XgMPYOeBgnEsHY4EzwCz2PcJ9Miv
         7uIVfJEwDsMcksEBrgQPNSo8g1EhsvInx7VbIZJtQ/qXblkA23BFXCBy1TDHGDsNRf6M
         c574lIo8iQLZo03gd4gp0+hbusQ/pA0ls3GNUeQt9dYiTiVmQzBsiy5XG8p0H93FBunO
         kYIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d49si5170330ede.363.2019.04.17.07.34.41
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 07:34:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2ECD3A78;
	Wed, 17 Apr 2019 07:34:41 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A10363F557;
	Wed, 17 Apr 2019 07:34:37 -0700 (PDT)
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
Subject: [RFC PATCH 3/3] x86: mm: Switch to using generic pt_dump
Date: Wed, 17 Apr 2019 15:34:23 +0100
Message-Id: <20190417143423.26665-3-steven.price@arm.com>
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
 arch/x86/Kconfig              |   1 +
 arch/x86/Kconfig.debug        |  20 +--
 arch/x86/mm/Makefile          |   4 +-
 arch/x86/mm/dump_pagetables.c | 297 +++++++---------------------------
 4 files changed, 62 insertions(+), 260 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c1f9b3cf437c..122c24055f02 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -106,6 +106,7 @@ config X86
 	select GENERIC_IRQ_RESERVATION_MODE
 	select GENERIC_IRQ_SHOW
 	select GENERIC_PENDING_IRQ		if SMP
+	select GENERIC_PTDUMP
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
index 15d0fbe27872..dc1dfe213657 100644
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -62,26 +62,10 @@ config EARLY_PRINTK_USB_XDBC
 config MCSAFE_TEST
 	def_bool n
 
-config X86_PTDUMP_CORE
-	def_bool n
-
-config X86_PTDUMP
-	tristate "Export kernel pagetable layout to userspace via debugfs"
-	depends on DEBUG_KERNEL
-	select DEBUG_FS
-	select X86_PTDUMP_CORE
-	---help---
-	  Say Y here if you want to show the kernel pagetable layout in a
-	  debugfs file. This information is only useful for kernel developers
-	  who are working in architecture specific areas of the kernel.
-	  It is probably not a good idea to enable this feature in a production
-	  kernel.
-	  If in doubt, say "N"
-
 config EFI_PGT_DUMP
 	bool "Dump the EFI pagetable"
 	depends on EFI
-	select X86_PTDUMP_CORE
+	select PTDUMP_CORE
 	---help---
 	  Enable this if you want to dump the EFI page table before
 	  enabling virtual mode. This can be used to debug miscellaneous
@@ -90,7 +74,7 @@ config EFI_PGT_DUMP
 
 config DEBUG_WX
 	bool "Warn on W+X mappings at boot"
-	select X86_PTDUMP_CORE
+	select PTDUMP_CORE
 	---help---
 	  Generate a warning if any W+X mappings are found at boot.
 
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..5233190fc6bf 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -28,8 +28,8 @@ obj-$(CONFIG_X86_PAT)		+= pat_rbtree.o
 obj-$(CONFIG_X86_32)		+= pgtable_32.o iomap_32.o
 
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
-obj-$(CONFIG_X86_PTDUMP_CORE)	+= dump_pagetables.o
-obj-$(CONFIG_X86_PTDUMP)	+= debug_pagetables.o
+obj-$(CONFIG_PTDUMP_CORE)	+= dump_pagetables.o
+obj-$(CONFIG_PTDUMP_DEBUGFS)	+= debug_pagetables.o
 
 obj-$(CONFIG_HIGHMEM)		+= highmem_32.o
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index f6b814aaddf7..955824c7cddb 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -20,6 +20,7 @@
 #include <linux/seq_file.h>
 #include <linux/highmem.h>
 #include <linux/pci.h>
+#include <linux/ptdump.h>
 
 #include <asm/e820/types.h>
 #include <asm/pgtable.h>
@@ -30,15 +31,12 @@
  * when a "break" in the continuity is found.
  */
 struct pg_state {
+	struct ptdump_state ptdump;
 	int level;
-	pgprot_t current_prot;
+	pgprotval_t current_prot;
 	pgprotval_t effective_prot;
-	pgprotval_t effective_prot_pgd;
-	pgprotval_t effective_prot_p4d;
-	pgprotval_t effective_prot_pud;
-	pgprotval_t effective_prot_pmd;
+	pgprotval_t prot_levels[5];
 	unsigned long start_address;
-	unsigned long current_address;
 	const struct addr_marker *marker;
 	unsigned long lines;
 	bool to_dmesg;
@@ -179,9 +177,8 @@ static struct addr_marker address_markers[] = {
 /*
  * Print a readable form of a pgprot_t to the seq_file
  */
-static void printk_prot(struct seq_file *m, pgprot_t prot, int level, bool dmsg)
+static void printk_prot(struct seq_file *m, pgprotval_t pr, int level, bool dmsg)
 {
-	pgprotval_t pr = pgprot_val(prot);
 	static const char * const level_name[] =
 		{ "cr3", "pgd", "p4d", "pud", "pmd", "pte" };
 
@@ -228,24 +225,11 @@ static void printk_prot(struct seq_file *m, pgprot_t prot, int level, bool dmsg)
 	pt_dump_cont_printf(m, dmsg, "%s\n", level_name[level]);
 }
 
-/*
- * On 64 bits, sign-extend the 48 bit address to 64 bit
- */
-static unsigned long normalize_addr(unsigned long u)
-{
-	int shift;
-	if (!IS_ENABLED(CONFIG_X86_64))
-		return u;
-
-	shift = 64 - (__VIRTUAL_MASK_SHIFT + 1);
-	return (signed long)(u << shift) >> shift;
-}
-
-static void note_wx(struct pg_state *st)
+static void note_wx(struct pg_state *st, unsigned long addr)
 {
 	unsigned long npages;
 
-	npages = (st->current_address - st->start_address) / PAGE_SIZE;
+	npages = (addr - st->start_address) / PAGE_SIZE;
 
 #ifdef CONFIG_PCI_BIOS
 	/*
@@ -253,7 +237,7 @@ static void note_wx(struct pg_state *st)
 	 * Inform about it, but avoid the warning.
 	 */
 	if (pcibios_enabled && st->start_address >= PAGE_OFFSET + BIOS_BEGIN &&
-	    st->current_address <= PAGE_OFFSET + BIOS_END) {
+	    addr <= PAGE_OFFSET + BIOS_END) {
 		pr_warn_once("x86/mm: PCI BIOS W+X mapping %lu pages\n", npages);
 		return;
 	}
@@ -264,25 +248,44 @@ static void note_wx(struct pg_state *st)
 		  (void *)st->start_address);
 }
 
+static inline pgprotval_t effective_prot(pgprotval_t prot1, pgprotval_t prot2)
+{
+	return (prot1 & prot2 & (_PAGE_USER | _PAGE_RW)) |
+	       ((prot1 | prot2) & _PAGE_NX);
+}
+
 /*
  * This function gets called on a break in a continuous series
  * of PTE entries; the next one is different so we need to
  * print what we collected so far.
  */
-static void note_page(struct pg_state *st, pgprot_t new_prot,
-		      pgprotval_t new_eff, int level)
+static void note_page(struct ptdump_state *pt_st, unsigned long addr, int level,
+		      unsigned long val)
 {
-	pgprotval_t prot, cur, eff;
+	struct pg_state *st = container_of(pt_st, struct pg_state, ptdump);
+	pgprotval_t new_prot, new_eff;
+	pgprotval_t cur, eff;
 	static const char units[] = "BKMGTPE";
 	struct seq_file *m = st->seq;
 
+	new_prot = val & PTE_FLAGS_MASK;
+
+	if (level > 1) {
+		new_eff = effective_prot(st->prot_levels[level - 2],
+					 new_prot);
+	} else {
+		new_eff = new_prot;
+	}
+
+	if (level > 0)
+		st->prot_levels[level-1] = new_eff;
+
 	/*
 	 * If we have a "break" in the series, we need to flush the state that
 	 * we have now. "break" is either changing perms, levels or
 	 * address space marker.
 	 */
-	prot = pgprot_val(new_prot);
-	cur = pgprot_val(st->current_prot);
+	cur = st->current_prot;
 	eff = st->effective_prot;
 
 	if (!st->level) {
@@ -294,14 +297,14 @@ static void note_page(struct pg_state *st, pgprot_t new_prot,
 		st->lines = 0;
 		pt_dump_seq_printf(m, st->to_dmesg, "---[ %s ]---\n",
 				   st->marker->name);
-	} else if (prot != cur || new_eff != eff || level != st->level ||
-		   st->current_address >= st->marker[1].start_address) {
+	} else if (new_prot != cur || new_eff != eff || level != st->level ||
+		   addr >= st->marker[1].start_address) {
 		const char *unit = units;
 		unsigned long delta;
 		int width = sizeof(unsigned long) * 2;
 
 		if (st->check_wx && (eff & _PAGE_RW) && !(eff & _PAGE_NX))
-			note_wx(st);
+			note_wx(st, addr);
 
 		/*
 		 * Now print the actual finished series
@@ -311,9 +314,9 @@ static void note_page(struct pg_state *st, pgprot_t new_prot,
 			pt_dump_seq_printf(m, st->to_dmesg,
 					   "0x%0*lx-0x%0*lx   ",
 					   width, st->start_address,
-					   width, st->current_address);
+					   width, addr);
 
-			delta = st->current_address - st->start_address;
+			delta = addr - st->start_address;
 			while (!(delta & 1023) && unit[1]) {
 				delta >>= 10;
 				unit++;
@@ -331,7 +334,7 @@ static void note_page(struct pg_state *st, pgprot_t new_prot,
 		 * such as the start of vmalloc space etc.
 		 * This helps in the interpretation.
 		 */
-		if (st->current_address >= st->marker[1].start_address) {
+		if (addr >= st->marker[1].start_address) {
 			if (st->marker->max_lines &&
 			    st->lines > st->marker->max_lines) {
 				unsigned long nskip =
@@ -347,228 +350,42 @@ static void note_page(struct pg_state *st, pgprot_t new_prot,
 					   st->marker->name);
 		}
 
-		st->start_address = st->current_address;
+		st->start_address = addr;
 		st->current_prot = new_prot;
 		st->effective_prot = new_eff;
 		st->level = level;
 	}
 }
 
-static inline pgprotval_t effective_prot(pgprotval_t prot1, pgprotval_t prot2)
-{
-	return (prot1 & prot2 & (_PAGE_USER | _PAGE_RW)) |
-	       ((prot1 | prot2) & _PAGE_NX);
-}
-
-static int ptdump_pte_entry(pte_t *pte, unsigned long addr,
-			    unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pgprotval_t eff, prot;
-
-	st->current_address = normalize_addr(addr);
-
-	prot = pte_flags(*pte);
-	eff = effective_prot(st->effective_prot_pmd, prot);
-	note_page(st, __pgprot(prot), eff, 5);
-
-	return 0;
-}
-
-#ifdef CONFIG_KASAN
-
-/*
- * This is an optimization for KASAN=y case. Since all kasan page tables
- * eventually point to the kasan_early_shadow_page we could call note_page()
- * right away without walking through lower level page tables. This saves
- * us dozens of seconds (minutes for 5-level config) while checking for
- * W+X mapping or reading kernel_page_tables debugfs file.
- */
-static inline bool kasan_page_table(struct pg_state *st, void *pt)
-{
-	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
-	    (pgtable_l5_enabled() &&
-			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
-	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
-		pgprotval_t prot = pte_flags(kasan_early_shadow_pte[0]);
-		note_page(st, __pgprot(prot), 0, 5);
-		return true;
-	}
-	return false;
-}
-#else
-static inline bool kasan_page_table(struct pg_state *st, void *pt)
-{
-	return false;
-}
-#endif
-
-static int ptdump_test_pmd(unsigned long addr, unsigned long next,
-			   pmd_t *pmd, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-
-	st->current_address = normalize_addr(addr);
-
-	if (kasan_page_table(st, pmd))
-		return 1;
-	return 0;
-}
-
-static int ptdump_pmd_entry(pmd_t *pmd, unsigned long addr,
-			    unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pgprotval_t eff, prot;
-
-	prot = pmd_flags(*pmd);
-	eff = effective_prot(st->effective_prot_pud, prot);
-
-	st->current_address = normalize_addr(addr);
-
-	if (pmd_large(*pmd))
-		note_page(st, __pgprot(prot), eff, 4);
-
-	st->effective_prot_pmd = eff;
-
-	return 0;
-}
-
-static int ptdump_test_pud(unsigned long addr, unsigned long next,
-			   pud_t *pud, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-
-	st->current_address = normalize_addr(addr);
-
-	if (kasan_page_table(st, pud))
-		return 1;
-	return 0;
-}
-
-static int ptdump_pud_entry(pud_t *pud, unsigned long addr,
-			    unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pgprotval_t eff, prot;
-
-	prot = pud_flags(*pud);
-	eff = effective_prot(st->effective_prot_p4d, prot);
-
-	st->current_address = normalize_addr(addr);
-
-	if (pud_large(*pud))
-		note_page(st, __pgprot(prot), eff, 3);
-
-	st->effective_prot_pud = eff;
-
-	return 0;
-}
-
-static int ptdump_test_p4d(unsigned long addr, unsigned long next,
-			   p4d_t *p4d, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-
-	st->current_address = normalize_addr(addr);
-
-	if (kasan_page_table(st, p4d))
-		return 1;
-	return 0;
-}
-
-static int ptdump_p4d_entry(p4d_t *p4d, unsigned long addr,
-			    unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pgprotval_t eff, prot;
-
-	prot = p4d_flags(*p4d);
-	eff = effective_prot(st->effective_prot_pgd, prot);
-
-	st->current_address = normalize_addr(addr);
-
-	if (p4d_large(*p4d))
-		note_page(st, __pgprot(prot), eff, 2);
-
-	st->effective_prot_p4d = eff;
-
-	return 0;
-}
-
-static int ptdump_pgd_entry(pgd_t *pgd, unsigned long addr,
-			    unsigned long next, struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-	pgprotval_t eff, prot;
+static const struct ptdump_range ptdump_ranges[] = {
+#ifdef CONFIG_X86_64
 
-	prot = pgd_flags(*pgd);
+#define normalize_addr_shift (64 - (__VIRTUAL_MASK_SHIFT + 1))
+#define normalize_addr(u) ((signed long)(u << normalize_addr_shift) >> normalize_addr_shift)
 
-#ifdef CONFIG_X86_PAE
-	eff = _PAGE_USER | _PAGE_RW;
+	{0, PTRS_PER_PGD * PGD_LEVEL_MULT / 2},
+	{normalize_addr(PTRS_PER_PGD * PGD_LEVEL_MULT / 2), ~0UL},
 #else
-	eff = prot;
+	{0, ~0UL},
 #endif
-
-	st->current_address = normalize_addr(addr);
-
-	if (pgd_large(*pgd))
-		note_page(st, __pgprot(prot), eff, 1);
-
-	st->effective_prot_pgd = eff;
-
-	return 0;
-}
-
-static int ptdump_hole(unsigned long addr, unsigned long next,
-		       struct mm_walk *walk)
-{
-	struct pg_state *st = walk->private;
-
-	st->current_address = normalize_addr(addr);
-
-	note_page(st, __pgprot(0), 0, -1);
-
-	return 0;
-}
+	{0, 0}
+};
 
 static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
 				       bool checkwx, bool dmesg)
 {
-	struct pg_state st = {};
-	struct mm_walk walk = {
-		.mm		= mm,
-		.pgd_entry	= ptdump_pgd_entry,
-		.p4d_entry	= ptdump_p4d_entry,
-		.pud_entry	= ptdump_pud_entry,
-		.pmd_entry	= ptdump_pmd_entry,
-		.pte_entry	= ptdump_pte_entry,
-		.test_p4d	= ptdump_test_p4d,
-		.test_pud	= ptdump_test_pud,
-		.test_pmd	= ptdump_test_pmd,
-		.pte_hole	= ptdump_hole,
-		.private	= &st
+	struct pg_state st = {
+		.ptdump = {
+			.note_page	= note_page,
+			.range		= ptdump_ranges
+		},
+		.to_dmesg	= dmesg,
+		.check_wx	= checkwx,
+		.seq		= m
 	};
 
-	st.to_dmesg = dmesg;
-	st.check_wx = checkwx;
-	st.seq = m;
-	if (checkwx)
-		st.wx_pages = 0;
-
-	down_read(&mm->mmap_sem);
-#ifdef CONFIG_X86_64
-	walk_page_range(0, PTRS_PER_PGD*PGD_LEVEL_MULT/2, &walk);
-	walk_page_range(normalize_addr(PTRS_PER_PGD*PGD_LEVEL_MULT/2), ~0,
-			&walk);
-#else
-	walk_page_range(0, ~0, &walk);
-#endif
-	up_read(&mm->mmap_sem);
+	ptdump_walk_pgd(&st.ptdump, mm);
 
-	/* Flush out the last page */
-	st.current_address = normalize_addr(PTRS_PER_PGD*PGD_LEVEL_MULT);
-	note_page(&st, __pgprot(0), 0, 0);
 	if (!checkwx)
 		return;
 	if (st.wx_pages)
-- 
2.20.1

