Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 168B6C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:54:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C56B220855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C56B220855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 770CD6B026A; Thu,  4 Apr 2019 01:54:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71F756B026B; Thu,  4 Apr 2019 01:54:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E8E46B026C; Thu,  4 Apr 2019 01:54:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1039D6B026A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:54:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e55so787079edd.6
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:54:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sU9HZfgPaKNHBQ0fjctkOcrIiYmSQbuucDIbf7Melp0=;
        b=I46oebhWKH8S8DCvzQoZ2EaVdfIfuFZuHTn6t+em9Vjs+hYckXrX8gNF3/bkFv0EiO
         UAEAJU2YzPx+EO2jiJKrw9L1kQUTB/lN3l3ppzDfCtOwV3+yJrXWu2ynskFGFLTfkGie
         VIczG7JIKz7AnIHoOi/M0CXQ7pf21bW5+tdxHq/4YHkydi7MwPxU0pLZGUMRJ6izg2QF
         4yUFk43GdmkdHhBfutn7VDISd5Gu2uEuL9OOt4kgVx4JwOIuiByoJ/oLvuGqdsawKGZL
         3mtfwlj9X1MxUsYVEzBIQyq+ROlYFX5iQ3lKOjzfxi+M+HHk/Xd8Y/E0dqBCJCefxHMF
         afJw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUo3PcmsIokoPRLU9dMXe9h18qU2qSKmz0JZQ9XVYIU+KLylZvS
	vPUcTk8rVKgDeHYYnvX/v3TxtuGtRIEZycLijAf+gwf9WM379/CniWfhg7mG84mllkSM3hYXRzF
	HzqofGfWC8gIxRT1fTB5EGO1uFayJ4ZIPs5gcLDEaSlSfiW0GAa/4UY68KlGONaM=
X-Received: by 2002:a17:906:6a12:: with SMTP id o18mr2370283ejr.204.1554357295566;
        Wed, 03 Apr 2019 22:54:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZvDMhfZ0f49oumu9w6etYeEph/3N0Mxq+ebAmKUxyqW9EKyqsI20msGquslRBZ/7zZeJ0
X-Received: by 2002:a17:906:6a12:: with SMTP id o18mr2370249ejr.204.1554357294601;
        Wed, 03 Apr 2019 22:54:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554357294; cv=none;
        d=google.com; s=arc-20160816;
        b=paC1XG6r+0YlRc/kJiwHtPjQVw3rVQvBKI6ThC88mEDg95ZBHTzRtmTefR/o+pN5lp
         x8parCGMDJVB9yHpsiWio63WAJxyPjkah2Tfl8EokM8eCaIzt0tMoexVivh41oR9GwTM
         eohNKeVHg+gccToqSMs5yX2b6f/c4o335P684amzlNcXudKfs2Pvf8DMg4k6NuKS8LrN
         hLlo/puyqtTN5SpVMRHXzjlU7BaZ1W2TwMeR2MqfLxtmF4u8FWhWHJpiE/GjPkzXBckl
         4nEcjxPBM+PxBdpyepYElgbMYmD7fhj6ZjS5fIYXlUchONIG9zhdw99pMc++iJfBQ/BX
         r4bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sU9HZfgPaKNHBQ0fjctkOcrIiYmSQbuucDIbf7Melp0=;
        b=kF4+NiUyPrARPjtgyalrk8GU+pDfvtULW3TRInJl9IPV0hCAXTlMwp0unNqJXJNHiT
         tjB6ieCXTRk70gds6s8xSuBCoF8AVT7PJMVtOPj4WE19R5fKYLmeNA+fmD5FLrrX8VqI
         sb9Mj4XAxzXQgSYpvgLQ0bHcG+PCBOidgf/HQQIjHEhQJpe0nJgNvhG+Qm9LUKtY1fX1
         EaXQ6N55AHOuGMtI0VrcoyHxoB7et9falw0GSm7QTqbTFWkYT/nkJo8GADINtSTvGtsu
         BMzE+A4njAd26/7ZeE4t+FpSWWTMiPK232RLnPn2VGh1G4g8tdh53Oc9flBhtowmzMWE
         bLxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id m1si1127128edb.138.2019.04.03.22.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 22:54:54 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id BDCFF60007;
	Thu,  4 Apr 2019 05:54:48 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
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
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v2 3/5] arm: Use generic mmap top-down layout
Date: Thu,  4 Apr 2019 01:51:26 -0400
Message-Id: <20190404055128.24330-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404055128.24330-1-alex@ghiti.fr>
References: <20190404055128.24330-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

arm uses a top-down layout by default that fits the generic functions.
At the same time, this commit allows to fix the following problems:

- one uncovered and not fixed for arm here:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

- the use of TASK_SIZE instead of STACK_TOP in mmap_base which, when
  address space of a task is 26 bits, would assign mmap base way too high.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm/Kconfig                 |  1 +
 arch/arm/include/asm/processor.h |  2 --
 arch/arm/mm/mmap.c               | 52 --------------------------------
 3 files changed, 1 insertion(+), 54 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 850b4805e2d1..747101a8e989 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -28,6 +28,7 @@ config ARM
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
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
index f866870db749..b8d912ac9e61 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -17,33 +17,6 @@
 	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
 
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
 /*
  * We need to ensure that shared mappings are correctly aligned to
  * avoid aliasing issues with VIPT caches.  We need to ensure that
@@ -171,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
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

