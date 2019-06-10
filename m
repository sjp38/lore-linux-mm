Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4725C468D8
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:12:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78B4D2085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:12:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78B4D2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12C7D6B026D; Mon, 10 Jun 2019 10:12:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DCEC6B026E; Mon, 10 Jun 2019 10:12:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE78A6B026F; Mon, 10 Jun 2019 10:12:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCC96B026D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:12:25 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so15610260eda.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:12:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=d7kWs51dvbXxRIb8LEGXvdkSDZQAqi0aY4tHy4/EgU8=;
        b=JU1rQQ1VX/jyC6wiYA1lf0WQ6l2H1iwSVYxm8WPMZXyomiI/PSl4ay3wS9rQd1/Xtt
         lyVT1H6JVGf2ZwrwPm7ucCC15eAQgpbdNizMzPBvVlEnCCxqx42iZSFDeWVM6edfgC/n
         sBofbMwwx0cuuvlDoMK/f6+iQGRWZtMBjqq9waKhwfdgSg2cyhiFfqAp5JArpmcxDTZh
         4nSXrQo5XsGbNKrOgRbTAGYZ84gyBjLytVB/BZQPly5CsgsT5wAEofvX91CMjM+socfX
         dMYTzwhm93OCDLGNQba+Bni7V0v0cwgvVPdI/XoQ5BjCCzG+C7dpBdGFglKEX7xCpchE
         QY8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUDLkijDEQQ5NZ1lRMfSA5PUs7tb+Oo5138nPorTvbX46kPAayL
	FgT/iz0eCYdurnTkOHpINMR7l1C3EzhZ8TfdTVs4Fk/IuFDo9soIUKwVZrOflSo94bd4/HlwGAE
	mIvDsDtozjZpLRcqqPAA4qgRMZAXngNmX5Pn6uZzPRywXTN0joYwegtr2mNz2vHV3jA==
X-Received: by 2002:a50:cac3:: with SMTP id f3mr72668300edi.91.1560175945123;
        Mon, 10 Jun 2019 07:12:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8Vb5XVsbiyYXB2hPAQ10npb6yMHBiwiY5K+z0EKj7+VJeD9aOEVUBqvmk2CixJoI36KvP
X-Received: by 2002:a50:cac3:: with SMTP id f3mr72668216edi.91.1560175944341;
        Mon, 10 Jun 2019 07:12:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560175944; cv=none;
        d=google.com; s=arc-20160816;
        b=isqU+qGqBH8yJ+jnVZ+zlPMoIxaEGMFw9qFtv9C7VudU/Kg7NqkiYsyZQpD85CyJu6
         MB6hLL2wNUe3OLry3bnV6SH9ZSqOQ36lB5ycHDo1FsDyIFN0R4pQYqPbMjLpXqnMFZ+z
         ybrbgiUvpBQnUREd2JApvzh1Ijmo/jwPvxiXkSwvFZuyvMbwVKH1TPmpG7A7Ob482Akg
         15DFEn6WQWQn2iG+ZvxM6Zj1FY5aXWsyVqds99EQjLLDhnHaSt/0dggdtTjaonivdIkq
         PKum71w9v3vcIgDrgyHFNoY0l8ApWqdTaGTT6Ao8LPysU6DfTCt/7wjRmCkB9zyglE/U
         vWUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=d7kWs51dvbXxRIb8LEGXvdkSDZQAqi0aY4tHy4/EgU8=;
        b=E0RVjXxRwzZX+uhREb3wDW78XSsx1oEAMvP8xMpkJMMnUJXnDyYWc/JqM4UuD1wmZM
         NAYWFH8vUvH548j0b0mFLgk4CnihCF50tRzexaCrCJABqU7zhQqslk3X1GzUWO9ZGQ51
         BF3UXUnGiAbPUEKUVuxlitvtqgeuND56ShCZcdRSiiT76kzEctTMBUCwkahoiwbMIOjX
         QEYeo/eJbEcyvzfRsHtFJI3pL5IGd/PemuS2ZcRKnHPwuwK1ewQoIeYKQ+XfV4vzfaVO
         gkNKqdMInSOJr/2p03S3M1HpjfhmKCAcpKmawBYUL0P/F12MI8POy3AUukKIhd9wZ+3d
         cvRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id j21si2661191ejt.70.2019.06.10.07.12.23
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 07:12:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 54E5D346;
	Mon, 10 Jun 2019 07:12:23 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id E49C33F73C;
	Mon, 10 Jun 2019 07:12:18 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	x86@kernel.org
Subject: [RFC] mm/ioremap: Probe platform for p4d huge map support
Date: Mon, 10 Jun 2019 19:42:26 +0530
Message-Id: <1560175946-25231-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Finishing up what the commit c2febafc67734a ("mm: convert generic code to
5-level paging") started out while levelling up P4D huge mapping support
at par with PUD and PMD. A new arch call back arch_ioremap_p4d_supported()
is being added which just maintains status quo (P4D huge map not supported)
on x86 and arm64.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: x86@kernel.org

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---

- Detected this from code audit while reviewing Nicholas Piggin's ioremap
  changes https://patchwork.kernel.org/project/linux-mm/list/?series=129479

- Build and boot tested on x86 and arm64 platforms
- Build tested on some others

 arch/arm64/mm/mmu.c   | 5 +++++
 arch/x86/mm/ioremap.c | 5 +++++
 include/linux/io.h    | 1 +
 lib/ioremap.c         | 2 ++
 4 files changed, 13 insertions(+)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a1bfc4413982..646c82922d77 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -953,6 +953,11 @@ void *__init fixmap_remap_fdt(phys_addr_t dt_phys)
 	return dt_virt;
 }
 
+int __init arch_ioremap_p4d_supported(void)
+{
+	return 0;
+}
+
 int __init arch_ioremap_pud_supported(void)
 {
 	/*
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 4b6423e7bd21..6cbbec83991d 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -440,6 +440,11 @@ void iounmap(volatile void __iomem *addr)
 }
 EXPORT_SYMBOL(iounmap);
 
+int __init arch_ioremap_p4d_supported(void)
+{
+	return 0;
+}
+
 int __init arch_ioremap_pud_supported(void)
 {
 #ifdef CONFIG_X86_64
diff --git a/include/linux/io.h b/include/linux/io.h
index 32e30e8fb9db..58514cebfce6 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -45,6 +45,7 @@ static inline int ioremap_page_range(unsigned long addr, unsigned long end,
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
 void __init ioremap_huge_init(void);
+int arch_ioremap_p4d_supported(void);
 int arch_ioremap_pud_supported(void);
 int arch_ioremap_pmd_supported(void);
 #else
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 063213685563..c3dc213b6980 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -30,6 +30,8 @@ early_param("nohugeiomap", set_nohugeiomap);
 void __init ioremap_huge_init(void)
 {
 	if (!ioremap_huge_disabled) {
+		if (arch_ioremap_p4d_supported())
+			ioremap_p4d_capable = 1;
 		if (arch_ioremap_pud_supported())
 			ioremap_pud_capable = 1;
 		if (arch_ioremap_pmd_supported())
-- 
2.20.1

