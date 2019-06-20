Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5819EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:12:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15F30206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:12:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15F30206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B526B0006; Thu, 20 Jun 2019 01:12:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC5F68E0002; Thu, 20 Jun 2019 01:12:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 965DD8E0001; Thu, 20 Jun 2019 01:12:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 458D26B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:12:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so2572597eds.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:12:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=38aPMSE0cd9+t8GyN9A5LNY8mTJqABB1k8K8E77COyE=;
        b=OSDhXTEhW34ZSFv0Hc2/ddYz1mcdwhHuAtsgUF7rsSDn6ABddcuRX/eJMKRbkUdJNI
         n8v3hJuGyI4jhpx8ygz6VEu236eV6L9yxxAv81L3riOAdEkM6ansprCsaiPRWV/LRXvO
         kLTt69mjzpTnOsxXz4lBBsJlfXwDHxXRTHgtFcccVIdCCxZgTteZvx7s1R8weHYILqBG
         DnQYZmbpWgYNrxJIvFl/HpFCa/IZ9mzZqOn2RWwkf7kTEqa+vaLFm8rPPYPBb+0CpIy9
         TlqTNQExI2OjLxydu5a+uf6LspLQ9AW285OKBK7dWJyf9FhkbhhIEgyQwPmV/VToUceO
         HA5A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUNA/tqFvOBTAs0nP5+LI3yums8N3Mqrrfc2siqxmSq3+O7HvPB
	dx8pWkRl6uCLfyDV6+mlxoAZkkFuNNQoClon2ezw3AZW2WqnZpfCzj6ZYSm2Q5KHD4MRr6FO+Th
	0I64XXFuA0xyrpWOimQVSr5JhI9GZHPszpqh/byOp4EaXoIzvNmMl6wLNt9behXU=
X-Received: by 2002:a17:906:3382:: with SMTP id v2mr72940865eja.25.1561007543758;
        Wed, 19 Jun 2019 22:12:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5dS72s3QsJtJo16ngrtaIPuwFvXlmLZBIVf8gDQKG1pn/cCpBAXell2B2rWzCurjhFcSm
X-Received: by 2002:a17:906:3382:: with SMTP id v2mr72940814eja.25.1561007542722;
        Wed, 19 Jun 2019 22:12:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007542; cv=none;
        d=google.com; s=arc-20160816;
        b=sbNXXkduAHTxuZej/Na4zfrA8BwAtZIIaHSoBFTtE0g5oiqaj5pEXYXDtlIdRJgdTi
         Ecu+17mEddaQ4Q1nknrFtE+jX/RX2vFO6t0dLJoyBvrpP/2up1SVxhr2e0eWg2Z9Zir3
         buuXautLvW6SYQamCAlWPmeTQWA1xiqxXVlbbm4xp5bftsp/k7Ru52yAJk9RcFzwaypy
         v5W7BKcIHdWtz+8BSn/0EVlEh+x0rbOZSFsGOYCq0XKdWE2wXzcMLslR6unV1QL4SKlX
         9cEfBcqkqha3e0z9UgTqs7Uhcj4qFQxaRHErMKEUiLw8EO3WevoTKguOaXAvnUBtGUxH
         isLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=38aPMSE0cd9+t8GyN9A5LNY8mTJqABB1k8K8E77COyE=;
        b=xlA97o7Ro1kN0bIoNGYtXGtoQaNOiOcVxlUCd2IBkhJ5+/qUBPrK1SRRXsMJcmCWZE
         v22MU7dik6RZayaiOnI8VvxHZKl3gEAsG2mSqzBw4IxQS+iiYVfLxXEfa44Mcgbh21Xh
         O8BcZKS7CZLTbz8/AenZAQcmk5HYa2Z/rWHnRYqDReSVaBS+3uTMtDer5URtfVfriyI4
         2BXizwaPlHHVb6siwoaQOqotFZfAQFvY+DUrPYEq44+lx0vKlmgwdO090lL5AwS8jHlS
         AoWaA3eUWZBN8zFVTbTlXdLsjPhKEv/DGQ9Axg+oUmpLW6oY7Kemu8sYZYehKK7WVWWJ
         sJhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [217.70.183.198])
        by mx.google.com with ESMTPS id p5si7261242edh.409.2019.06.19.22.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:12:22 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.198;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id B26EDC0005;
	Thu, 20 Jun 2019 05:12:17 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH RESEND 7/8] x86: Use mmap_*base, not mmap_*legacy_base, as low_limit for bottom-up mmap
Date: Thu, 20 Jun 2019 01:03:27 -0400
Message-Id: <20190620050328.8942-8-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
References: <20190620050328.8942-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Bottom-up mmap scheme is used twice:

- for legacy mode, in which mmap_legacy_base and mmap_compat_legacy_base
are respectively equal to mmap_base and mmap_compat_base.

- in case of mmap failure in top-down mode, where there is no need to go
through the whole address space again for the bottom-up fallback: the goal
of this fallback is to find, as a last resort, space between the top-down
mmap base and the stack, which is the only place not covered by the
top-down mmap.

Then this commit removes the usage of mmap_legacy_base and
mmap_compat_legacy_base fields from x86 code.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/x86/include/asm/elf.h   |  2 +-
 arch/x86/kernel/sys_x86_64.c |  4 ++--
 arch/x86/mm/hugetlbpage.c    |  4 ++--
 arch/x86/mm/mmap.c           | 20 +++++++++-----------
 4 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 69c0f892e310..bbfd81453250 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -307,7 +307,7 @@ static inline int mmap_is_ia32(void)
 
 extern unsigned long task_size_32bit(void);
 extern unsigned long task_size_64bit(int full_addr_space);
-extern unsigned long get_mmap_base(int is_legacy);
+extern unsigned long get_mmap_base(void);
 extern bool mmap_address_hint_valid(unsigned long addr, unsigned long len);
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index f7476ce23b6e..0bf8604bea5e 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -121,7 +121,7 @@ static void find_start_end(unsigned long addr, unsigned long flags,
 		return;
 	}
 
-	*begin	= get_mmap_base(1);
+	*begin	= get_mmap_base();
 	if (in_32bit_syscall())
 		*end = task_size_32bit();
 	else
@@ -211,7 +211,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = get_mmap_base(0);
+	info.high_limit = get_mmap_base();
 
 	/*
 	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 4b90339aef50..3a7f11e66114 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -86,7 +86,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 
 	info.flags = 0;
 	info.length = len;
-	info.low_limit = get_mmap_base(1);
+	info.low_limit = get_mmap_base();
 
 	/*
 	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
@@ -106,7 +106,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 {
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
-	unsigned long mmap_base = get_mmap_base(0);
+	unsigned long mmap_base = get_mmap_base();
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index aae9a933dfd4..54c9ff301323 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -113,13 +113,12 @@ static unsigned long mmap_legacy_base(unsigned long rnd,
  * This function, called very early during the creation of a new
  * process VM image, sets up which VM layout function to use:
  */
-static void arch_pick_mmap_base(unsigned long *base, unsigned long *legacy_base,
+static void arch_pick_mmap_base(unsigned long *base,
 		unsigned long random_factor, unsigned long task_size,
 		struct rlimit *rlim_stack)
 {
-	*legacy_base = mmap_legacy_base(random_factor, task_size);
 	if (mmap_is_legacy())
-		*base = *legacy_base;
+		*base = mmap_legacy_base(random_factor, task_size);
 	else
 		*base = mmap_base(random_factor, task_size, rlim_stack);
 }
@@ -131,7 +130,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 	else
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 
-	arch_pick_mmap_base(&mm->mmap_base, &mm->mmap_legacy_base,
+	arch_pick_mmap_base(&mm->mmap_base,
 			arch_rnd(mmap64_rnd_bits), task_size_64bit(0),
 			rlim_stack);
 
@@ -142,23 +141,22 @@ void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 	 * applications and 32bit applications. The 64bit syscall uses
 	 * mmap_base, the compat syscall uses mmap_compat_base.
 	 */
-	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
+	arch_pick_mmap_base(&mm->mmap_compat_base,
 			arch_rnd(mmap32_rnd_bits), task_size_32bit(),
 			rlim_stack);
 #endif
 }
 
-unsigned long get_mmap_base(int is_legacy)
+unsigned long get_mmap_base(void)
 {
 	struct mm_struct *mm = current->mm;
 
 #ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
-	if (in_32bit_syscall()) {
-		return is_legacy ? mm->mmap_compat_legacy_base
-				 : mm->mmap_compat_base;
-	}
+	if (in_32bit_syscall())
+		return mm->mmap_compat_base;
 #endif
-	return is_legacy ? mm->mmap_legacy_base : mm->mmap_base;
+
+	return mm->mmap_base;
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
-- 
2.20.1

