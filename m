Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94602C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B38D218FE
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:43:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B38D218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD81D6B0003; Fri, 22 Mar 2019 03:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C88066B0006; Fri, 22 Mar 2019 03:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B50946B0007; Fri, 22 Mar 2019 03:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 589BF6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:43:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o27so575298edc.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ybDGclxaljSScwU0omwGU4QDKMIsw3Rl4Ng/SK8EA6g=;
        b=uGvuVXWRIAQgmnsRa9ny2OLXCHelF2gdcq2NZlIAJjN7+k03Y4mek01Z8sdI17gh6S
         AxnnrpesRNsvMW+g0/iNbiBUMfsPUGADHHqwfyrSlARk18kq2lwvgPpS94Vou6rO217c
         YDZDAqFP760lcnnjcUiSt05G7NJUkkx5XM0+p4x65GvFjH5dBv9MRMB3dA+PQF/ZAaBS
         s2/eaPhmrkhMNWl1k8s98n/mLD6YkBo484V24EZ6bpa01z/eIUj73RCjnwPDoBD+pXEz
         41lLSv4Bc5r3Kw8DXRUhlZYGD4Re3UYbJHF4Jgn7u7BWUfSQqoRDLNcf2+lLDEA4bzw3
         n49A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVRBxahuDaw85BE3l09WB991OGiUFiK5KF1ivcFVgiNLgnNLtxR
	3S0cm6U+6K8dDsR2czNLKCBc6CJRkzR6xnvHEGFX2by4CTpBu8d+LUUl18lQwxeCR9stIISrOtH
	T9gRkoWQR8LRZ+jeW7G7zO+jFv235XLoApj0D7Rdk7EI92a8EygloqnILyxE5wPo=
X-Received: by 2002:a50:b615:: with SMTP id b21mr5095745ede.175.1553240619817;
        Fri, 22 Mar 2019 00:43:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3rFg+AO2e6D6R8NQ5KR+u8Ofq3RWtVgedPG1UDobavi1Csxk9Owo55N3m0tfnZOuBfNNb
X-Received: by 2002:a50:b615:: with SMTP id b21mr5095699ede.175.1553240618765;
        Fri, 22 Mar 2019 00:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553240618; cv=none;
        d=google.com; s=arc-20160816;
        b=qINyUefJGMbTgNyj2iFUPxfuNFswOOmHxZ9x5bQqb7WovnrxpYV9kOhnz3Zaj4C2da
         XuIhukDCMYAbG6/YlvJPNjei9u+wn6JCYsWDhp9d02Hi9MpHrICE2OYb1xeUmxdxscop
         Yl2Rn5/ZSYsdC+Icwes9D14KJgnervlWaha//Ex+3s86p4oP1b/451GlVpVtx+aaHNnv
         Cno8+Q1GK1wO47MNCD42kmEi7qLqRiGdocfxScEQZY+Fe2vi65/RuSbkm1Xivez5GSAt
         W1bH+xRPKJ/B2hvj1UtW2JHNIylYN/u1v+pHUSTz6AO7nTfRxq3BK+m+mprm10RfqyPC
         0UMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ybDGclxaljSScwU0omwGU4QDKMIsw3Rl4Ng/SK8EA6g=;
        b=b+UZV4h/G4Y9Dd1/ykcluapmvHReWaFFNXzf6djMN/gltGRYFSB5MRqO1ZbhNa2Qug
         EcfvTFm2gEy9qEODLydcgznQ+Y7dDEYl5cZtl/2IpUxCSJuFiybT73Pnoyc2kXbPekB+
         cQ61FoT2DnI6YKW5YSr4Jz+wELYB3UVFtKEh606gIKo06OVNL4Wg6XEZE2dBaR6kzmFq
         gSICD03IUbFS2dHAZZOSci9J5tn0Q6RMviztM2ODHc+NHExtsgX/KJll5p7YBbUOD//C
         xAhQuI8XOtboFHruPnkUViuULGFV3XRqfBMlDb+DIfpVWjWHPlA21sYZdgPrcy6Bw2kD
         vxrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id s1si839095edx.17.2019.03.22.00.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 00:43:38 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id D314820000B;
	Fri, 22 Mar 2019 07:43:32 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Christoph Hellwig <hch@infradead.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH 1/4] arm64, mm: Move generic mmap layout functions to mm
Date: Fri, 22 Mar 2019 03:42:22 -0400
Message-Id: <20190322074225.22282-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190322074225.22282-1-alex@ghiti.fr>
References: <20190322074225.22282-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

arm64 handles top-down mmap layout in a way that can be easily reused
by other architectures, so make it available in mm.

This commit also takes the opportunity to:
- make use of is_compat_task instead of specific arm64 test
  test_thread_flag(TIF_32BIT), which allows more genericity and is
  equivalent.
- fix the case where stack randomization should not be taken into
  account.

It then introduces a new define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
that can be defined by other architectures to benefit from those functions.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm64/include/asm/processor.h |  2 +-
 arch/arm64/mm/mmap.c               | 72 ----------------------
 fs/binfmt_elf.c                    | 20 ------
 include/linux/mm.h                 |  2 +
 kernel/sysctl.c                    |  6 +-
 mm/util.c                          | 99 +++++++++++++++++++++++++++++-
 6 files changed, 105 insertions(+), 96 deletions(-)

diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 5d9ce62bdebd..2358707c31ff 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -274,7 +274,7 @@ static inline void spin_lock_prefetch(const void *ptr)
 		     "nop") : : "p" (ptr));
 }
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
+#define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 
 #endif
 
diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index 842c8a5fcd53..c74224421216 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -31,78 +31,6 @@
 
 #include <asm/cputype.h>
 
-/*
- * Leave enough space between the mmap area and the stack to honour ulimit in
- * the face of randomisation.
- */
-#define MIN_GAP (SZ_128M)
-#define MAX_GAP	(STACK_TOP/6*5)
-
-static int mmap_is_legacy(struct rlimit *rlim_stack)
-{
-	if (current->personality & ADDR_COMPAT_LAYOUT)
-		return 1;
-
-	if (rlim_stack->rlim_cur == RLIM_INFINITY)
-		return 1;
-
-	return sysctl_legacy_va_layout;
-}
-
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-#ifdef CONFIG_COMPAT
-	if (test_thread_flag(TIF_32BIT))
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-	else
-#endif
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-	return rnd << PAGE_SHIFT;
-}
-
-static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
-{
-	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
-
-	/* Values close to RLIM_INFINITY can overflow. */
-	if (gap + pad > gap)
-		gap += pad;
-
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
-
-	return PAGE_ALIGN(STACK_TOP - gap - rnd);
-}
-
-/*
- * This function, called very early during the creation of a new process VM
- * image, sets up which VM layout function to use:
- */
-void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
-{
-	unsigned long random_factor = 0UL;
-
-	if (current->flags & PF_RANDOMIZE)
-		random_factor = arch_mmap_rnd();
-
-	/*
-	 * Fall back to the standard layout if the personality bit is set, or
-	 * if the expected stack growth is unlimited:
-	 */
-	if (mmap_is_legacy(rlim_stack)) {
-		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
-		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, rlim_stack);
-		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
-}
-
 /*
  * You really shouldn't be using read() or write() on /dev/mem.  This might go
  * away in the future.
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 7d09d125f148..045f3b29d264 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -662,26 +662,6 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
  * libraries.  There is no binary dependent code anywhere else.
  */
 
-#ifndef STACK_RND_MASK
-#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))	/* 8MB of VA */
-#endif
-
-static unsigned long randomize_stack_top(unsigned long stack_top)
-{
-	unsigned long random_variable = 0;
-
-	if (current->flags & PF_RANDOMIZE) {
-		random_variable = get_random_long();
-		random_variable &= STACK_RND_MASK;
-		random_variable <<= PAGE_SHIFT;
-	}
-#ifdef CONFIG_STACK_GROWSUP
-	return PAGE_ALIGN(stack_top) + random_variable;
-#else
-	return PAGE_ALIGN(stack_top) - random_variable;
-#endif
-}
-
 static int load_elf_binary(struct linux_binprm *bprm)
 {
 	struct file *interpreter = NULL; /* to shut gcc up */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..087824a5059f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2312,6 +2312,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+unsigned long randomize_stack_top(unsigned long stack_top);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e5da394d1ca3..ac388f8ccbe4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -269,7 +269,8 @@ extern struct ctl_table epoll_table[];
 extern struct ctl_table firmware_config_table[];
 #endif
 
-#ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
+#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
+	defined(ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
 int sysctl_legacy_va_layout;
 #endif
 
@@ -1564,7 +1565,8 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 		.extra1		= &zero,
 	},
-#ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
+#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
+	defined(ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
 	{
 		.procname	= "legacy_va_layout",
 		.data		= &sysctl_legacy_va_layout,
diff --git a/mm/util.c b/mm/util.c
index d559bde497a9..5a0d4b1e17d9 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -14,6 +14,13 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/elf.h>
+#include <linux/elf-randomize.h>
+#include <linux/personality.h>
+#include <linux/random.h>
+#include <linux/processor.h>
+#include <linux/sizes.h>
+#include <linux/compat.h>
 
 #include <linux/uaccess.h>
 
@@ -291,13 +298,103 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
 	return (vma->vm_start <= KSTK_ESP(t) && vma->vm_end >= KSTK_ESP(t));
 }
 
-#if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
+#ifndef STACK_RND_MASK
+#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))     /* 8MB of VA */
+#endif
+
+unsigned long randomize_stack_top(unsigned long stack_top)
+{
+	unsigned long random_variable = 0;
+
+	if (current->flags & PF_RANDOMIZE) {
+		random_variable = get_random_long();
+		random_variable &= STACK_RND_MASK;
+		random_variable <<= PAGE_SHIFT;
+	}
+#ifdef CONFIG_STACK_GROWSUP
+	return PAGE_ALIGN(stack_top) + random_variable;
+#else
+	return PAGE_ALIGN(stack_top) - random_variable;
+#endif
+}
+
+#ifdef CONFIG_MMU
+#ifdef ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
+
+#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
+unsigned long arch_mmap_rnd(void)
+{
+	unsigned long rnd;
+
+#ifdef CONFIG_COMPAT
+	if (is_compat_task())
+		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
+	else
+#endif
+		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
+
+	return rnd << PAGE_SHIFT;
+}
+#endif
+
+static int mmap_is_legacy(struct rlimit *rlim_stack)
+{
+	if (current->personality & ADDR_COMPAT_LAYOUT)
+		return 1;
+
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
+		return 1;
+
+	return sysctl_legacy_va_layout;
+}
+
+#define MIN_GAP		(SZ_128M)
+#define MAX_GAP		(STACK_TOP / 6 * 5)
+
+static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
+{
+	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
+
+	if (gap < MIN_GAP)
+		gap = MIN_GAP;
+	else if (gap > MAX_GAP)
+		gap = MAX_GAP;
+
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
+}
+
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
+{
+	unsigned long random_factor = 0UL;
+
+	if (current->flags & PF_RANDOMIZE)
+		random_factor = arch_mmap_rnd();
+
+	if (mmap_is_legacy(rlim_stack)) {
+		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
+		mm->get_unmapped_area = arch_get_unmapped_area;
+	} else {
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
+		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
+	}
+}
+#elif !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
 void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	mm->mmap_base = TASK_UNMAPPED_BASE;
 	mm->get_unmapped_area = arch_get_unmapped_area;
 }
 #endif
+#endif /* CONFIG_MMU */
 
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
-- 
2.20.1

