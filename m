Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F2A9C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3888820B7C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:26:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3888820B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D56DC6B0006; Thu,  8 Aug 2019 02:26:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D070E6B000A; Thu,  8 Aug 2019 02:26:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCFEB6B000C; Thu,  8 Aug 2019 02:26:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DABA6B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:26:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k37so851455eda.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:26:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F6AwJVNQYUFCq6QO/Xu8IsZAVcgcHmfXp23XkgiBWO0=;
        b=dMAXYzhx6o/VBxmZVBgtaYj69qIXmqLaQf8SLwdhHOjxmL+HcuRdTmjw1xJR+5JmX+
         mXNaZzS3IcMwVrk79NsCeds7tC43NaRP9CH6aaxJKzrAlu8v79SAWSvkUCI9UUwmlnYP
         VW54mMnwunkXjjf9tbWVUEpZjIn7LoBtF1FtOUaMsetIgU5RJIXelhecyliZGbbj1djP
         wETP1uW26VGoKExy1G+cAiVgcllOqHWKV9RK9Uk2hwmbCFnVctJcn2z2RarxxMTeZ4lx
         0tI5iSMgBcCSelPvsEPhN/Y/D5BbX2RWNw1DHAjvautA2u8Wa6rWdC7bSaBRRISvyRxp
         v3Ig==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUg/qQQ24FDyNuwsEm7/V0mBmNs9LcHt7H/YAhHd9YFxcQykp/U
	7LZnUdjybZeiUuQdAl4rVsmpFPjFGUueD6tfLAF5c0u9L/Fb2epQArVORIecypqO/5PRoR5GtgT
	hIkBwn5BQvHUVCXXQARp/S8kPXLem9owc5sLfyboytsE2crWq1YxWhRyhiG7MRXs=
X-Received: by 2002:a05:6402:782:: with SMTP id d2mr14223768edy.80.1565245613013;
        Wed, 07 Aug 2019 23:26:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVkgbHNu4upeptNY9wlznyGJ6hiiwJs8ALJoibKRmc1dm0rdTdviFkBo+MQtSDvTwUYceE
X-Received: by 2002:a05:6402:782:: with SMTP id d2mr14223701edy.80.1565245611739;
        Wed, 07 Aug 2019 23:26:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245611; cv=none;
        d=google.com; s=arc-20160816;
        b=V0oE0YpbaDoLtbtmxtVyrwCD2HygzgeOKSwlPRsLAhAPN2Qoyh+sCJrSc17HuxQF/e
         oauGKd+1/Xsn3LpMlpB4POJeUgkIj+aXbqHGkqfcH5ClgNdTDfHaBvDxhqfUbqJSdiz4
         AvS03mEukHFIFE3yM3+p/CBRbCcLJr8n9PKeZA4Ih/TnhHth6BBn5uwatdsRzYhgF4tO
         BlFwBW3uxoOxfbD0tAzF+YULlzmPeRJe05alFgFQIuzCiQIFPW37zJ6ebGRHmt316+7D
         ZFTwYbnimprx1XBuQ5fM4k6Xc9RFVY9S93n8ZCWwmKQuhenkBY4dgPoASyp+wGbx32RY
         u6hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=F6AwJVNQYUFCq6QO/Xu8IsZAVcgcHmfXp23XkgiBWO0=;
        b=ZXqvu2rSL3MmTgAT0b1AzDNHwr4tARjGIPyO+d5CfNGY/g23dFDUHHyFRguSOndgiV
         HJnhy1CRtttom6csRyWB81N0AAlgHKQePGxWexfXHEgL8dvPxotZveNey6BIBd8oTeax
         m8yRZSWWHxc8jtWCkPzfWN3hM9BuFTTd2VNw3b/6m82VOM9ulqyNUKDF9gzMKXK+9225
         kLnFrcAMAUnYdMh8GJUTgJemzXV6GbHBU6EI1+DPFkxqfxhNfDhOInQLvxpkz6KQSkcn
         IyIBOy2wcORQ+93Uy2G0eCUsYzKGhWNJ1alKQtAPpqPYDT1CPyTMWGpeYrzuO5/aqk3I
         jyxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay10.mail.gandi.net (relay10.mail.gandi.net. [217.70.178.230])
        by mx.google.com with ESMTPS id p6si10031930ejg.75.2019.08.07.23.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:26:51 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.230;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay10.mail.gandi.net (Postfix) with ESMTPSA id A9D96240006;
	Thu,  8 Aug 2019 06:26:45 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v6 08/14] arm: Use generic mmap top-down layout and brk randomization
Date: Thu,  8 Aug 2019 02:17:50 -0400
Message-Id: <20190808061756.19712-9-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
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

As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
use the generic version of arch_randomize_brk since it also fits.
Note that this commit also removes the possibility for arm to have elf
randomization and no MMU: without MMU, the security added by randomization
is worth nothing.

Note that it is safe to remove STACK_RND_MASK since it matches the default
value.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm/Kconfig                 |  2 +-
 arch/arm/include/asm/processor.h |  2 --
 arch/arm/kernel/process.c        |  5 ---
 arch/arm/mm/mmap.c               | 62 --------------------------------
 4 files changed, 1 insertion(+), 70 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 33b00579beff..81b08b027e4e 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -7,7 +7,6 @@ config ARM
 	select ARCH_HAS_BINFMT_FLAT
 	select ARCH_HAS_DEBUG_VIRTUAL if MMU
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_KEEPINITRD
 	select ARCH_HAS_KCOV
@@ -30,6 +29,7 @@ config ARM
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BINFMT_FLAT_ARGVP_ENVP_ON_STACK
 	select BUILDTIME_EXTABLE_SORT if MMU
diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
index 20c2f42454b8..614bf829e454 100644
--- a/arch/arm/include/asm/processor.h
+++ b/arch/arm/include/asm/processor.h
@@ -140,8 +140,6 @@ static inline void prefetchw(const void *ptr)
 #endif
 #endif
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
-
 #endif
 
 #endif /* __ASM_ARM_PROCESSOR_H */
diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index f934a6739fc0..9485acc520a4 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -319,11 +319,6 @@ unsigned long get_wchan(struct task_struct *p)
 	return 0;
 }
 
-unsigned long arch_randomize_brk(struct mm_struct *mm)
-{
-	return randomize_page(mm->brk, 0x02000000);
-}
-
 #ifdef CONFIG_MMU
 #ifdef CONFIG_KUSER_HELPERS
 /*
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

