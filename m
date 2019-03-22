Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A980C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4791A218FE
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:44:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4791A218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84886B0006; Fri, 22 Mar 2019 03:44:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E342D6B0007; Fri, 22 Mar 2019 03:44:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFDE86B0008; Fri, 22 Mar 2019 03:44:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82B016B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:44:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x29so570731edb.17
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Uz7p6g8xsr4/tuzcqVtmbZTVNIaPsr5ZFq4yt3MBowc=;
        b=R+C22ii40rD/UA/GB2H3a1RcxaVi5JRL6/Ta6JtlNY7bSuJ28nSpWV2use0qhrqq/6
         lHArlhBELf9t8FRKc1IZthxK/wWSBoPGll/EYbrou6l1rMtvusPXC9V1ocak6WD9SSTi
         jCS+jy9hcK9qjyq30AGAYzg4DHZkLgXkI1F1C74MF3TreoFRcjFhD2EF82LB6cYoCq2C
         0mQ9FAWdV01h0VbT9WcWOJye8dgsSvJfwH94ZX6peb95dM46PVs28v/2n0eQfeg1yutC
         8NNZMJyReMPdf/ub1FDE9gKZdLSJYLu+1D2egwif2eHAIMdjwxKEZi7ZHARCrl+ZUnO+
         xogQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVM429fSE+pJuohdouDcn/1KU2F/dkb8QxJZ1uTissJueaYM9fJ
	LL3TF55w+RfsQnb+z9z7KpAMMrBtzwqa+3YRhqTzeFMv9jdBUAvWCZgNB1Kdo+4wl21QekPv3Sm
	dK11f7umFUFBzSOWMgAF8ZFFtZ1IBmGEyOj2xYb2Th8pDhdZM0+xkR+33RI67zoE=
X-Received: by 2002:a17:906:6d8f:: with SMTP id h15mr4688273ejt.107.1553240684030;
        Fri, 22 Mar 2019 00:44:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHQu01vpk/ugAd1PtvK4cyASoEAFphxkXeJnFDqTY98vsJkRC9bCUtkNiKEW4mHSapO3UQ
X-Received: by 2002:a17:906:6d8f:: with SMTP id h15mr4688245ejt.107.1553240683171;
        Fri, 22 Mar 2019 00:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553240683; cv=none;
        d=google.com; s=arc-20160816;
        b=N33l6Yf/IJggpWqn0DhxthzYt0MimeweIC5mGwUI3/C7sNSqqgMIeWVhttU/6Der+3
         2yA1VBHRrrsd7yTFvsOqPgpIh6YoyRidTL/rUUyum3m6GlHArdG6s3SkP74Q7Td3loWh
         DqHFSCI3JK3SkGpj9ivmVLh0ZbKQEHdwtDiMyNRkgPLaKb/SOW5NXWVqILwUc4NTdbJH
         QCwalc/0xygBXZuPIh4kRqClVXjkqUfat7qR2a0Ol1+3kkWczfzdAVJuCePJjZAgZ7qT
         nqR74PD5zVcj7Wpo56dY8QQPdp+dvbpKbo36X5QLCp1O/rE9XOZOuKoiXvaCJv0pdM8w
         8ksQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Uz7p6g8xsr4/tuzcqVtmbZTVNIaPsr5ZFq4yt3MBowc=;
        b=RdeB/3khSkPPmH358ljo7gQ2lEUUS9ML9wJCyizPhVK6iwHFvwGCkBtXtu/Adrfaus
         BnIN76QD68KPObebOESoEtUFkaALRhhJK2bjGPs/vHyPO7X0KvVKuCfk36qig2f8UbzZ
         8N5H9pSCTaZtuMQLXNfUPwWVXj07VI85pZFhCT3fAPWqF69/2IHqzUKejs/6VzCQAXww
         GnK43ibLlZLEcUS07v6MTRpEx2Z7TZxFFdE6WgU0x1m8cYL7jkn3hZ6HuVy4DHBs4zhz
         BYLTB8iR9nkCvPq64/H6XrM89LhIs2dlieSQy27g2p5m+2kYUFYhWlujODm+GPrqI/71
         ahbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id e47si2318365edd.164.2019.03.22.00.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 00:44:43 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id E7FFE20000D;
	Fri, 22 Mar 2019 07:44:38 +0000 (UTC)
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
Subject: [PATCH 2/4] arm: Use generic mmap top-down layout
Date: Fri, 22 Mar 2019 03:42:23 -0400
Message-Id: <20190322074225.22282-3-alex@ghiti.fr>
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

arm uses a top-down layout by default that fits the generic functions.
At the same time, this commit allows to fix the following problems:

- one uncovered and not fixed for arm here:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

- the use of TASK_SIZE instead of STACK_TOP in mmap_base which, when
  address space of a task is 26 bits, would assign mmap base way too high.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm/include/asm/processor.h |  2 +-
 arch/arm/mm/mmap.c               | 52 --------------------------------
 2 files changed, 1 insertion(+), 53 deletions(-)

diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
index 57fe73ea0f72..03837d325a2f 100644
--- a/arch/arm/include/asm/processor.h
+++ b/arch/arm/include/asm/processor.h
@@ -143,7 +143,7 @@ static inline void prefetchw(const void *ptr)
 #endif
 #endif
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
+#define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 
 #endif
 
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

