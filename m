Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 642D3C282E5
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 14:02:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24DC72085A
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 14:02:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24DC72085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E96076B0003; Sun, 26 May 2019 10:02:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E477D6B0005; Sun, 26 May 2019 10:02:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE76C6B0007; Sun, 26 May 2019 10:02:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8806B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 10:02:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26so23275379eda.15
        for <linux-mm@kvack.org>; Sun, 26 May 2019 07:02:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6LZGvTAD62mMbL2kcAn9cI6Q+B9t74AkWV+jhj/3vo4=;
        b=Z2DDp5uNDd1QittCqyXxjMwYnC5biIQnezNXByNQkMjn4qTeag1/MC8cbAj1Jk3po6
         XsRDLKN5CtOZObUD/Hq8XNgh4bFqG+HRU0fN32sCm5sPqcp19TOEBon/eDonf+3DTDJ0
         bvogxxL5oiDLdf1i+43Z6KSNGm3cIiH0G9Pex73AUCI0K5QkWAmDPYI91zeAuV33lIbR
         ApFWhX4nOBz8NJ1fWtLZ92tj9xV1sPFFWasv2sJBwuW7pWYud2KQQllDIUCscXgdViI2
         C7NkyGloTK56WqkqLkErZoyVEBbCaiFNqZd5eeBp35vfR/pLgDrKTa1rjO2Zdi/GRIZX
         poeA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV9ahiFrcSTCe0CTAFjzanhVUOohxzUzumqahBD02TEie6wtlpx
	x840t4mlyiMp/eYRnY3j3hsd7qs8Bi8eRNTeH+CL4WAvKfjtKYYHiCXyr5Har/pDRndOFWyrXBo
	BRf+Gd7GDZr4ER2X78wxo3ynlMR6fPT0JGbQwlSaeYhdpyLgW+9pmc0j8NJ1GL7c=
X-Received: by 2002:a50:95b0:: with SMTP id w45mr117807737eda.221.1558879350968;
        Sun, 26 May 2019 07:02:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBYNN/l43JYJc4sIkedVu7nJ7luaij9vL5D0tESW5f2u74f8DG7lPu5yUOOpzYowdDRrwd
X-Received: by 2002:a50:95b0:: with SMTP id w45mr117807577eda.221.1558879349658;
        Sun, 26 May 2019 07:02:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558879349; cv=none;
        d=google.com; s=arc-20160816;
        b=TRbBZD5EhElWz7kTU4hRrlKuxsn0043k1JD6yiRKd1YpfdE8cPM9/oSDFhWjx0Fygs
         AVWSgUvAb2yAfBTySzz3LCpNXL3ijTHy9yDP93YKtTUbiDVTCwb8PXfcIEsp4r5JDRlT
         f9RxO4gZmk/MZBii6FGp9jYYnaWjc16SzIAlxocStdFbD7ADm77ATWFxbquM2+nYr7Wo
         Z3YUOAatXT5nvjWND0QADkQ8Ar2cNeLJ2PStI9fjILTgzWXyf+v2Hp9KKqwJN1g5cPiF
         8XmAcyJA7uuyMxY7vlh+I0p+q1d0fbTj7kY0c5OI/wwSy6PenzImPkKU6bb4pR9AqFwu
         enhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6LZGvTAD62mMbL2kcAn9cI6Q+B9t74AkWV+jhj/3vo4=;
        b=Q9NShEL+lm3YBEVpd/vtbY8mHXgYLz6xRaDpFpHFjkx37IT8ocYDrgSkhtQnSs5gPL
         3qVQnWbgBoVCqUs+JN981tgEqvId0ZrY6rcLgwK0VR7hYj+OwdTBjFq+r6qTKKP0SBlG
         2cy0eVOybTiYnzB62KwiESpAezR0cZuSnAdI4L4bUxabrwsv9EPrWv2G5ppd2xUT00Cn
         eMVNzsaFGQh/A2aGUHiZvurj5F+AX/6nCzIzo5nTa3pQXpb3bxNSLHZnVZlGeNAufh+x
         Ci1wSSxYCgUK4tx8ObWHccYTa0rm5NKDFHTRwaZG2t2rNFzJn9WaXu+HGL/unpWfW0Hc
         P/xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id v16si6164ejb.309.2019.05.26.07.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 07:02:29 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 46E5C20006;
	Sun, 26 May 2019 14:02:25 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
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
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v4 13/14] mips: Use generic mmap top-down layout and brk randomization
Date: Sun, 26 May 2019 09:47:45 -0400
Message-Id: <20190526134746.9315-14-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mips uses a top-down layout by default that exactly fits the generic
functions, so get rid of arch specific code and use the generic version
by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
use the generic version of arch_randomize_brk since it also fits.
Note that this commit also removes the possibility for mips to have elf
randomization and no MMU: without MMU, the security added by randomization
is worth nothing.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/mips/Kconfig                 |  2 +-
 arch/mips/include/asm/processor.h |  5 --
 arch/mips/mm/mmap.c               | 96 -------------------------------
 3 files changed, 1 insertion(+), 102 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 70d3200476bf..da15b02bbe23 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -5,7 +5,6 @@ config MIPS
 	select ARCH_32BIT_OFF_T if !64BIT
 	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
 	select ARCH_CLOCKSOURCE_DATA
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_SUPPORTS_UPROBES
@@ -13,6 +12,7 @@ config MIPS
 	select ARCH_USE_CMPXCHG_LOCKREF if 64BIT
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BUILDTIME_EXTABLE_SORT
 	select CLONE_BACKWARDS
diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
index aca909bd7841..fba18d4a9190 100644
--- a/arch/mips/include/asm/processor.h
+++ b/arch/mips/include/asm/processor.h
@@ -29,11 +29,6 @@
 
 extern unsigned int vced_count, vcei_count;
 
-/*
- * MIPS does have an arch_pick_mmap_layout()
- */
-#define HAVE_ARCH_PICK_MMAP_LAYOUT 1
-
 #ifdef CONFIG_32BIT
 #ifdef CONFIG_KVM_GUEST
 /* User space process size is limited to 1GB in KVM Guest Mode */
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 900670ea8531..c2effe535484 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -16,49 +16,10 @@
 #include <linux/random.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
-#include <linux/sizes.h>
-#include <linux/compat.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
-/* gap between mmap and stack */
-#define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((STACK_TOP)/6*5)
-#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
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
-static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
-{
-	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = stack_guard_gap;
-
-	/* Account for stack randomization if necessary */
-	if (current->flags & PF_RANDOMIZE)
-		pad += (STACK_RND_MASK << PAGE_SHIFT);
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
 #define COLOUR_ALIGN(addr, pgoff)				\
 	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
 	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
@@ -156,63 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
 			addr0, len, pgoff, flags, DOWN);
 }
 
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-#ifdef CONFIG_COMPAT
-	if (TASK_IS_32BIT_ADDR)
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-	else
-#endif /* CONFIG_COMPAT */
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-
-	return rnd << PAGE_SHIFT;
-}
-
-void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
-{
-	unsigned long random_factor = 0UL;
-
-	if (current->flags & PF_RANDOMIZE)
-		random_factor = arch_mmap_rnd();
-
-	if (mmap_is_legacy(rlim_stack)) {
-		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
-		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, rlim_stack);
-		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
-}
-
-static inline unsigned long brk_rnd(void)
-{
-	unsigned long rnd = get_random_long();
-
-	rnd = rnd << PAGE_SHIFT;
-	/* 32MB for 32bit, 1GB for 64bit */
-	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
-		rnd = rnd & SZ_32M;
-	else
-		rnd = rnd & SZ_1G;
-
-	return rnd;
-}
-
-unsigned long arch_randomize_brk(struct mm_struct *mm)
-{
-	unsigned long base = mm->brk;
-	unsigned long ret;
-
-	ret = PAGE_ALIGN(base + brk_rnd());
-
-	if (ret < mm->brk)
-		return mm->brk;
-
-	return ret;
-}
-
 int __virt_addr_valid(const volatile void *kaddr)
 {
 	return pfn_valid(PFN_DOWN(virt_to_phys(kaddr)));
-- 
2.20.1

