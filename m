Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F38FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC2A421904
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:45:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC2A421904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 954086B0003; Fri, 22 Mar 2019 03:45:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9027F6B0006; Fri, 22 Mar 2019 03:45:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CB716B0007; Fri, 22 Mar 2019 03:45:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3173F6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:45:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s27so572458eda.16
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:45:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LUGImeOjzmNJpIPAM8RQUWM+8kkl6UbTjBKYFhKUvaE=;
        b=hKXH0GYskHPB7VrmZsmdxyikuevNqG4bpS2j+Rs9YRviNp6tsU1lXATRyBC01eOJPX
         BvyWTsHQ42AGLP1WckNDRN8I80E5QKyFF/uM3gdeDMlBGjvRNAkPpFKmSW9fdpxKnXDq
         J3qXGOdm4Y57/ujnPnwOyjO09sCEgsUHrVene9LYlVbYVEHkCtoLE3PLFh7QlH5a4PEG
         V4x0AoTuQTsJwb5XeXb5yRDiH78P9S/+7uHF3qm+l9Xzi5ZTc4wtXGrEH81ufBxY81Z5
         hi//6eB9I5wn6wuABxzV3D2r87z0s/jNi5oe7HqII/2u4b2FMerykeRwfNFgfUdBWfaB
         p3Vw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXV8gJZMas0BxG74a6VFq2dXf0Z5HG9pcUG5HUYw4MW4LMxnAe0
	tLpvh4oczwofgtFBiAsN7ccGgNo9pVxBdpPRFBMJDX0KHAS1ObGx3ddgsMgPvKhKRJNUrkecwkc
	ovZKE4dX24fPU8wQhteFSDEDg7hpJQyQ/UGsukT8fnFjuXjNV4E6dvvw9Zq0lRzc=
X-Received: by 2002:a50:ad72:: with SMTP id z47mr5394504edc.270.1553240748723;
        Fri, 22 Mar 2019 00:45:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2r8MPPlzle2xiUiBqJ54GWuWSaYAZNi5PoypuqPAcZ9UbbiGnWI+/3hPou05ECMTy83P4
X-Received: by 2002:a50:ad72:: with SMTP id z47mr5394460edc.270.1553240747766;
        Fri, 22 Mar 2019 00:45:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553240747; cv=none;
        d=google.com; s=arc-20160816;
        b=XL/VXIIJ4CRTSD2z2PlGR0HbbsTxhuzKw1+3K4kb8VE5shvA+sSY0dGmd1RLcjr5xL
         yedFtyS10hyEJSPuzUmkxS9NuXFs1LQkmYf1+RSgk4U3P74EV03tJirAc+lq9TnqZjib
         mIYlmYag3zaD7J3eBIphYN6YnOhPhtO10URK6emCofftcTX8kycQAHHCGAw20z93BE9f
         Zhg5SYd6ND2Gr7+xOqmOikLR0Il+cxkntmZ5kGanUjxvX/4MFUw89ts9ap/+EnbKd56t
         xRzPEu6QrR+X/U1xWRtE5HP5AK+DPTMjjny6TskkErCR914IJPEQnJaPJ98v8pJtBEF6
         lfbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LUGImeOjzmNJpIPAM8RQUWM+8kkl6UbTjBKYFhKUvaE=;
        b=l2EF7+JVRUkHoFkjkR51BYqbXYnJHVH9WosGIHIfycEY+3caU//7a7QQzq0JakDUQa
         +Z8WS5OJM+1yCAiS931htJ8Pz0akMy3aXUsdROlD+G1v+Rt90hMarjNc4KNFk8y//otT
         Rc8f/5p86dLGULs2lqRz9/TyIAvsHqygNykar5u0PVyplpjadTi7aP7mW3QTGe+hHFmB
         pRBBUBObBv62m2SXmf9048aCmrKAOfZwxvM4ULvM+E9xoz5PexElBaLNUHTo0/dX+nHn
         4BqC5Usu+BQUonUWsKOeR9ym6x7s11NhCi1WIhTJaGAKpIkfYxYwvIYwPJ1Ea4HwLrqu
         aEBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id i4si2518218ejb.200.2019.03.22.00.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 00:45:47 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 4A88E20001D;
	Fri, 22 Mar 2019 07:45:43 +0000 (UTC)
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
Subject: [PATCH 3/4] mips: Use generic mmap top-down layout
Date: Fri, 22 Mar 2019 03:42:24 -0400
Message-Id: <20190322074225.22282-4-alex@ghiti.fr>
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

mips uses a top-down layout by default that fits the generic functions.
At the same time, this commit allows to fix problem uncovered
and not fixed for mips here:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/mips/include/asm/processor.h |  4 +--
 arch/mips/mm/mmap.c               | 57 -------------------------------
 2 files changed, 2 insertions(+), 59 deletions(-)

diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
index aca909bd7841..f8e04962b52d 100644
--- a/arch/mips/include/asm/processor.h
+++ b/arch/mips/include/asm/processor.h
@@ -30,9 +30,9 @@
 extern unsigned int vced_count, vcei_count;
 
 /*
- * MIPS does have an arch_pick_mmap_layout()
+ * MIPS uses the default implementation of topdown mmap layout.
  */
-#define HAVE_ARCH_PICK_MMAP_LAYOUT 1
+#define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 
 #ifdef CONFIG_32BIT
 #ifdef CONFIG_KVM_GUEST
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 2f616ebeb7e0..61e65a69bb09 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -20,33 +20,6 @@
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
-/* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
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
-
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
-
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
-}
-
 #define COLOUR_ALIGN(addr, pgoff)				\
 	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
 	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
@@ -144,36 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
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
 static inline unsigned long brk_rnd(void)
 {
 	unsigned long rnd = get_random_long();
-- 
2.20.1

