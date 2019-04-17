Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0769AC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA3A920872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:30:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA3A920872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D4CC6B0008; Wed, 17 Apr 2019 01:30:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 685006B0266; Wed, 17 Apr 2019 01:30:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59B7B6B0269; Wed, 17 Apr 2019 01:30:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2F16B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:30:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so3816467edy.19
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:30:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=of8M16skONcMMW8lly/0Bgnzg2NbL2wb3TkAt3jYEls=;
        b=kApP9VGg/3Fh0HH7Xo+VQXcC6Acke8IT8ub+jpd3edah2BbB6+h+EH7z5/phRmxtJC
         sRYkkyfqsMwUJOojJY6nmD3GDI7cr8UGuqintTViwMLhIa9nUkN4OwtHC2O6259i0pYC
         Kb1H7JT36zL/DfOMdG74/bujXby7UV7bbYDoGUarvUZCFHLfiPjxZ13SilnLd1D/v/Ll
         5Fx4ddhTRE5fNbzHEpB3BpFw2PwrW2TNF2iBs2f/0gfVXWjd/p2dDFKJD3hA3Gnyu9tb
         60TaTDWld8Zb9wnemOprZVheYF+wQEEctaU3CLfXQkLFyADdJuTAqp4l8Wb9LAzfjj53
         cS9Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVElyeOB6pRXbgnLP5IT0+R8ZtnOpK8h487+jd+359VXB2tBD8j
	uUUL4ollsX0Bnrsgkmt6RmLuQICO6eNcgQKb/ytAe4dN685e8/PEON8G2ob+IVeq9WF3gT3nt4D
	k0+rfb+RYkM54esCm/y9wwenTd3HxVo5MvWN9cX4rzY+Wl7YJCR/PEAm0b3GCwVM=
X-Received: by 2002:a50:eb42:: with SMTP id z2mr10390828edp.56.1555479034559;
        Tue, 16 Apr 2019 22:30:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkrIgDuLJ+PgVkDhOnsOzWks/W6PCtCLK4SxNgARbEJq0ooeCX4y6QSVc+cg76UuF6DQrh
X-Received: by 2002:a50:eb42:: with SMTP id z2mr10390757edp.56.1555479033175;
        Tue, 16 Apr 2019 22:30:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555479033; cv=none;
        d=google.com; s=arc-20160816;
        b=0bILkwkg4jVJ4W2QmCsUwaA/B/f9EaP94Pul3j98YKHeSIKK8CcE2m3zZLwcEjAwve
         ukKVjJb85PzaFtj1qQ7g2p5/Re91JpgfPFYm9mRnDmSiQjZzODCSUiwGWrJjgfHio+5Y
         3X1jdjv2xJkB8ahPPE3g0TlUI7vDXGcqX9ENgMyd+yu5ekZ/LnWpXPYRWWpDnG020d7X
         Vqf7kbrNGY9u+mO6CXr8DPaGX0W/tie1lAN1SjzMT3UAcjdo7Y4Nk2jlkutsDfyZaUtZ
         K3pY3nPoTDzvSaDdjcc2aHiOCvzC1TaiKEYtrD18eTt1dJol5p3FchlQ7VnIjI/1CqEA
         RWKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=of8M16skONcMMW8lly/0Bgnzg2NbL2wb3TkAt3jYEls=;
        b=rdrCOCSSdN7BY7VNDuc/33N038l1T1OoQ3ZVbpCG2hpsrMZPpryRNWe1+u1W2Yvu4m
         wt2chLV7OesETkZFhrReA0YOhRV6UIL3B9Ku4CGdDuyyhSsFrtZemDzAIPZGj5xziMut
         nOaQU26hCoM2qquoFGh6EZxqeKT/njVXIZmNH+j4R/ivm8EqZ+fy+6fIwWa4Mhr9v0pp
         TcH2gW1FgPaIMg68crmkG7YEYQSu9qU8YLJ2Eq6svf3OTjjsz5xUlo4BiD5AG+u+5KoG
         72Yp/blWyUcCveDcmOh0mTMnrLfJk+0ibwC2WeGMAnn1lwZqx9KSVJo01Q1EuWC/2KEG
         LvGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id s9si7217196ejz.181.2019.04.16.22.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:30:33 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id D715120000A;
	Wed, 17 Apr 2019 05:30:28 +0000 (UTC)
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
Subject: [PATCH v3 07/11] arm: Use generic mmap top-down layout
Date: Wed, 17 Apr 2019 01:22:43 -0400
Message-Id: <20190417052247.17809-8-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

arm uses a top-down mmap layout by default that exactly fits the generic
functions, so get rid of arch specific code and use the generic version
by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm/Kconfig                 |  1 +
 arch/arm/include/asm/processor.h |  2 --
 arch/arm/mm/mmap.c               | 62 --------------------------------
 3 files changed, 1 insertion(+), 64 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 850b4805e2d1..f8f603da181f 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -28,6 +28,7 @@ config ARM
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BUILDTIME_EXTABLE_SORT if MMU
 	select CLONE_BACKWARDS
diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
index 57fe73ea0f72..944ef1fb1237 100644
--- a/arch/arm/include/asm/processor.h
+++ b/arch/arm/include/asm/processor.h
@@ -143,8 +143,6 @@ static inline void prefetchw(const void *ptr)
 #endif
 #endif
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
-
 #endif
 
 #endif /* __ASM_ARM_PROCESSOR_H */
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 0b94b674aa91..b8d912ac9e61 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -17,43 +17,6 @@
 	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
 
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
 /*
  * We need to ensure that shared mappings are correctly aligned to
  * avoid aliasing issues with VIPT caches.  We need to ensure that
@@ -181,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	return addr;
 }
 
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-	rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
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
 /*
  * You really shouldn't be using read() or write() on /dev/mem.  This
  * might go away in the future.
-- 
2.20.1

