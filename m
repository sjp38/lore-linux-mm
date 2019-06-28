Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC168C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 05:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACB072086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 05:20:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACB072086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 475466B0003; Fri, 28 Jun 2019 01:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 426228E0003; Fri, 28 Jun 2019 01:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EE1F8E0002; Fri, 28 Jun 2019 01:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D38AF6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 01:20:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so7740451eda.6
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 22:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=sgQVS5Ld6i+q3V1iGMWF9bQyygmStlWXkD3hy1RM3bo=;
        b=pgmJHmabCEWQsR1AZhlG+3pDFkC3/7Re99jKR0w67vqnZhvL2JYOZE1LuFZz8Iy2VN
         Kp+QZkeLpJpGptKiY0ZXNSyHfzlx8uLE9lQssi6yJx9AnY8D0Z+Wf67H8ZleLegbSP0o
         GVCr84k/b8QrEZ2uL7/TUCIANxLEp8I0cg3DafmBcfy9m6RWXif0fWlkHT8Q2WKDqPSd
         Q1xhOTj+/6KDn2H86TOhMoQgifViUxCVoKAwtcm4DvXRY9ILdp4pYEojHuobQmbUnGTj
         ApKfXh88VcPu6AOQU1lQ3ZjP/HR97prWEl5y0l+HyudWqboQe49tNc9XTLFbRL30/PMo
         cCnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX4H19NhTsQuoZPijrv3ispXZvwbaM1cNDwyq/F1+JJBSDSAMUD
	GOfIH9dJlNZdR7d57tMIEa5/9fnKu4aEctTBdIyLw1rzx8eM5ssD2/hBCHATnjJImFmOFIWT+m3
	hEDrzDuwnfHjllWorZCq+Y/+Cp6aXUhX3rCV+55uMyAsvN4kudiDhsH7RAPTB+VaWHg==
X-Received: by 2002:a17:906:505:: with SMTP id j5mr6708924eja.261.1561699241425;
        Thu, 27 Jun 2019 22:20:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoOgWeof66NANgV++aMNkQQHZ7xmz46FHiaq4iyXzr/upAyoj2rJ4frs51+JTJ+X0WUVqu
X-Received: by 2002:a17:906:505:: with SMTP id j5mr6708857eja.261.1561699239948;
        Thu, 27 Jun 2019 22:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561699239; cv=none;
        d=google.com; s=arc-20160816;
        b=jZq6iBN8hJoPzetwJxnedgqvcfrC8A8YO/rg03RO7pIFMHOLQ6j45pbP4vgUifoXAJ
         ONJdU+VAT45d2MSG4vCv9W/YGY0QBaW6KbDFjNqm8x0DtF/paQHzPnOlyvtfimMYJ1gw
         Xfk15L9T6a2Cmoz0HQO1JKojuydLBdY89hnDUgKjYoHlyM9KNk2DgVw0AY1GfPHAwtz+
         ZYsfiLWU4wnQnupSF+Jc28aGIdYbajRskqDe/W4kgT2dB3AFgzA1c1LAknw6lmNGd17O
         jQqWUFuXEQgvi5SJ1Lwh674wb8iz9FXes5XHjAFW5O1LuXwrtSH5hgyVEOAYt5Qx+vt3
         iU7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=sgQVS5Ld6i+q3V1iGMWF9bQyygmStlWXkD3hy1RM3bo=;
        b=qpubtVhrd7V/iJTDxdxWJod5YHhFgBxLZAsmH+C2mt/+di9c/JTG5vJKCvtH6B8PX6
         kELAewocGCwBaWzkDdAtpWbhJtqH6flQSOuULwDygh+VUM9IfIT9L8w2JF2P8QgAX9WN
         fTdO0Veumt2Kq0fqRQFRUOevwSGQlkCpv6N7AER0uQIybryW1kDM98D3FHcYIG9JTZrO
         BRZRk1cUd263JU/L5pNqC4pvEEGQBs4ijYXjSbzqsLA7RHSqrRa5bH8i4bEF72lu2lxe
         Ge+JLg80jBwER8wJVsFTIh6hzJk74cIXJnmPsY5/UxKP5rEktjTHp+DRpoGr4/W9RpVM
         Jbhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i4si1084981edg.136.2019.06.27.22.20.39
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 22:20:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E3800344;
	Thu, 27 Jun 2019 22:20:38 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id C89EE3F706;
	Thu, 27 Jun 2019 22:22:23 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
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
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	x86@kernel.org
Subject: [PATCH V2] mm/ioremap: Probe platform for p4d huge map support
Date: Fri, 28 Jun 2019 10:50:31 +0530
Message-Id: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com>
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
on x86, arm64 and powerpc.

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
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: x86@kernel.org

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
---
Changes in V2:

- Added arch_ioremap_p4d_supported() definition for powerpc
- Changed commit message to add powerpc in the arch list
- Added tags from Michael Ellerman

Hello Andrew,

This applies and builds on linux-next (next-20190627) which contains

d909f9109c30 ("powerpc/64s/radix: Enable HAVE_ARCH_HUGE_VMAP")

but after

1. Reverting V1 of this patch

   d31cf72b92ec ("mm/ioremap: probe platform for p4d huge map support")

2. Removing arch_ioremap_p4d_supported() definition which was added with

   153083a99fe431 ("Merge branch 'akpm-current/current'")

- Anshuman

 arch/arm64/mm/mmu.c                      | 5 +++++
 arch/powerpc/mm/book3s64/radix_pgtable.c | 5 +++++
 arch/x86/mm/ioremap.c                    | 5 +++++
 include/linux/io.h                       | 1 +
 lib/ioremap.c                            | 2 ++
 5 files changed, 18 insertions(+)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 97ff0341..750a69d 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -942,6 +942,11 @@ void *__init fixmap_remap_fdt(phys_addr_t dt_phys)
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
diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/book3s64/radix_pgtable.c
index 22c0637..60c8fca 100644
--- a/arch/powerpc/mm/book3s64/radix_pgtable.c
+++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
@@ -1120,6 +1120,11 @@ void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
+int __init arch_ioremap_p4d_supported(void)
+{
+	return 0;
+}
+
 int __init arch_ioremap_pud_supported(void)
 {
 	/* HPT does not cope with large pages in the vmalloc area */
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index e500f1d..63e99f1 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -459,6 +459,11 @@ void iounmap(volatile void __iomem *addr)
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
index 9876e58..accac82 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -33,6 +33,7 @@ static inline int ioremap_page_range(unsigned long addr, unsigned long end,
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
 void __init ioremap_huge_init(void);
+int arch_ioremap_p4d_supported(void);
 int arch_ioremap_pud_supported(void);
 int arch_ioremap_pmd_supported(void);
 #else
diff --git a/lib/ioremap.c b/lib/ioremap.c
index a95161d..0a2ffad 100644
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
2.7.4

