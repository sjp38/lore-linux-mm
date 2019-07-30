Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B4BCC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:05:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F13C42087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:05:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F13C42087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 941AB8E0019; Tue, 30 Jul 2019 02:05:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CACD8E0003; Tue, 30 Jul 2019 02:05:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76BD08E0019; Tue, 30 Jul 2019 02:05:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 241548E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:05:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so39652006edc.6
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:05:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B3VegeOhL+k8hWxAR+QQjfphQk03GqtZuzVPPfLXv/o=;
        b=UOTPHiallnHIRVoASurhIgrGvfsGnjs3jMh//4DVOWyt2wwhdw6lJFG5l0dkfVtd6Z
         r+iiR9lMXdAjA4Qm/V8UElyiFMfLBUA1uisMmSpQGcH+pffnb2u8Le4w7tLwu/j9iYrY
         JZ7jrRZBRw6f/AR/NIKztcO2wDjJWOWvEbnzwGQ1jOY+Y6ZKqTnPOizbic1wFWvyZo53
         Uk+7oj0xMnP0qkFRE2eNzn9m1YutX3mqzKtJB5vkc+4Nn8la0vFJrGhQ/gGGW+nmUEay
         6goLLXXrJtabxm3QTiskew+vVCsQacnJu9zE0OjAJXDMpGLuFLoK/jYCzvQJQKw6+OTW
         3hOA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXZrTJXMg4tzZ8FSmOrj2CoOOwg7IJOlqANiao0UoAaJVvV1Zg/
	LwmIYJFGx5TIIdJ2OAqmqGwmILYVkmx8i5ZzK0tZYTQBKT5CcMyRcg9NlqTnC0j64c1T3rVXHB+
	Bp3IdAJ5sNS9aGjqERmgw3rValdVit1Nup64y0YRSRzjZ6grkJXaxSEjH24hqSjw=
X-Received: by 2002:a05:6402:145a:: with SMTP id d26mr99488742edx.10.1564466737704;
        Mon, 29 Jul 2019 23:05:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUB387WOrYE+XLWvqRM+rqCiemi/z5BU8vngGQWexrvsXj0Ee2GboIvzFcEi7GSHx3V3Vf
X-Received: by 2002:a05:6402:145a:: with SMTP id d26mr99488673edx.10.1564466736461;
        Mon, 29 Jul 2019 23:05:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466736; cv=none;
        d=google.com; s=arc-20160816;
        b=c7De30y8rMPgi/FCM9IXqwDHjQ6XwWMRULpnE7cZnaqE4a4osFjFdOkpFIZ25RTOLk
         x0qn+Fm6FWwcPZwm98Pmc0Wyg8dyqmOn9KdD+Y9fizi7yxQMEf2mI3GqXwqNSJnaQurJ
         iJfCQblr8B4kWNJ+vCnlIIeobc1cG+UW3JCtBO4qup66vzSQxbsPmTY+Z2AAfU1BxxXZ
         LliH/qF+o0ijKMrPAR1RXwW7Aefc+x4kF/RgNYQNI4mQ6Ru7ib16NUE5N6wgF/0gISbO
         kqr+m45DLaR34R8gfXP/OExH1+XGEkVDwpJbYQ7wT8SAS4D6dA+DhYtWpgwWB41jjjcE
         bGJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=B3VegeOhL+k8hWxAR+QQjfphQk03GqtZuzVPPfLXv/o=;
        b=mAN/bB2ynHHiYlJ/TukqZacD7iMHVevLqcRChx+JzJlaLSpnufAqSc+2Ps+ds3FDKt
         GrTMW/g6g9O2qicBP2rLQJEM9E6dT8laMReVhgONwCv6SX74IMdDNxHQJwyxpivs0qZw
         N/ym5pw7B9i30P8eRvxuBpxIEUQeY8hhcqQX2Plzg89KOWXqToqJnwnACCNMdVOBh+ta
         fCpbx5L+7egqFp2S7WqUXN3uOJWRoh78RY/Uf8eufPeGs3XvSNmZHwIESZuJ8TwpAdQc
         +UT2cWsElDD/tp/e5dMCEk9if/8vVb6uc3b/f3Nqzu+ouyG/s+LdjF/KaNNaJ4Fcv1EY
         oQNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id 47si20219725edu.294.2019.07.29.23.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:05:36 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 148D9E0005;
	Tue, 30 Jul 2019 06:05:31 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 13/14] mips: Use generic mmap top-down layout and brk randomization
Date: Tue, 30 Jul 2019 01:51:12 -0400
Message-Id: <20190730055113.23635-14-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
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
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/Kconfig                 |  2 +-
 arch/mips/include/asm/processor.h |  5 --
 arch/mips/mm/mmap.c               | 96 -------------------------------
 3 files changed, 1 insertion(+), 102 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index d50fafd7bf3a..4e85d7d2cf1a 100644
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
index d5106c26ac6a..00fe90c6db3e 100644
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
-		rnd = rnd & (SZ_32M - 1);
-	else
-		rnd = rnd & (SZ_1G - 1);
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
 bool __virt_addr_valid(const volatile void *kaddr)
 {
 	unsigned long vaddr = (unsigned long)kaddr;
-- 
2.20.1

