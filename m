Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D34A4C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 06:19:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 958B120866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 06:19:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 958B120866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21C976B0003; Thu, 13 Jun 2019 02:19:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3186B0005; Thu, 13 Jun 2019 02:19:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BBBC6B0006; Thu, 13 Jun 2019 02:19:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B293F6B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:19:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so22133627eds.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 23:19:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=FsoFixaKJvs5VrdRU+ynOeqA4zuY8/XTgXqh/DG6ZKw=;
        b=K3CcApf9e9W8QmrbVeyxzpv+kjqhd4PpPgYg1ZdXwB0r+pexgFlitcG6OCyaVLwrN1
         dKFF1flrsY4fmipR4mlNduj41tPKIgkMFVSYQTLGZKHwH77dpLRGb/PrmkVFFS5mnLWd
         FlqfDm7Xdhjk9oIGBnR+pl9Y6RFp0np3RfcspwKd/u9z81YhA6mm8zhvSV54A0bPfxKV
         kAjXdIICf8TW2NJusfpfNYnd4jXQbDlcH+2SnujrPgiEw31XLACzTHd3kCFtcrcwjvmM
         15nrm9Z3G38wKbztQd6IkuSiwCUq3AA5SjQo9m7o5miKozhEmMha1n9U+V1RHseZp0/4
         aFjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVdtFy+dMcLky4142ZqABxHijEUgAlA75yzs09af/fy05jjISKc
	IuSn0YIvKeLtJlvWYJn5Zb0hK0W86/S5uRu371DEP2UEaTdsb7J/eWA0jE+9uHwReZ6Ml3gy3a8
	b9LVfovzei3GuFTT5moGYBUZGlWVy7ziuQ0eHxuyvUJUXisbtoUEUdCKL3aD+DGve+g==
X-Received: by 2002:a50:9846:: with SMTP id h6mr37369270edb.263.1560406792170;
        Wed, 12 Jun 2019 23:19:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWgSOfoytOJ7cK0/tDNf1ai0HxF19LNeX7ElGiD4ITA0R+Wvxs/LwhnAf/TBqJ4vklWtpB
X-Received: by 2002:a50:9846:: with SMTP id h6mr37369225edb.263.1560406791226;
        Wed, 12 Jun 2019 23:19:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560406791; cv=none;
        d=google.com; s=arc-20160816;
        b=H+ayLOmrkZbcTI8XSrRA5Ar0+Gjs8+Fe3sVP3oF2mWAcjSDPsXmD02WfI8pdXAg5NL
         fRYAE7wWoSopxPFKDMftcm+W741kSW5zh4gQKBphlYKAvmD7f2xgU1Y9cJKOcz42wXNS
         EJMpUhTGX5DHX6dxrOn8MCrIrcsbUgKH60+tm8EnFmGvvLljt/IlxH7bFA8g4TcG5Fbv
         VsGIcApXknF2WVdepR+k/IVTylpjm9bwe2azG2yoRnIqUncWlQt5AbED5VJl3GxoENG0
         h7u16/2PETOFniutYPADVzjVYFDFzeL70zIphE1D1zq8JP1vg7uzXy6OIrg2vd0IXypq
         Ti5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=FsoFixaKJvs5VrdRU+ynOeqA4zuY8/XTgXqh/DG6ZKw=;
        b=TuXeOHaha5dge6poeAv47nVVZm6Zg24lkxYdqU2jm1ZH4Kq5HCocUz+iVt8d8oYP1H
         m4yRlY7zTx5M9hUGOWGAdVH4F8di5Y4KdBGM7fh8CvmKE/fMG2HEm4oI4A9rmAtnRzUV
         ibWe7JHraYDfI8cxPSuUIZHRNtnkjR5wtSjYxxIlM59eMZUtKGc+DnU8dzfmNv+0gWlr
         +eB4Tm8GQPNNMGus+eJiWCywpSc48dnR/lGZk7tL6XFzuL7q9hycWdX5DmkgeIXbhg9Z
         20sjQ+ledPpwdWg6ogIVgSM/sTcG8b0/B9DzvY9+9JcD90goPdGwFpbZFveNaV1seXsL
         2gAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b50si1704184edb.127.2019.06.12.23.19.50
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 23:19:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3F15028;
	Wed, 12 Jun 2019 23:19:50 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.191])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 3CB5A3F73C;
	Wed, 12 Jun 2019 23:19:46 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	x86@kernel.org
Subject: [PATCH] mm/ioremap: Probe platform for p4d huge map support
Date: Thu, 13 Jun 2019 11:49:41 +0530
Message-Id: <1560406781-14253-1-git-send-email-anshuman.khandual@arm.com>
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
- Detected this from code audit while reviewing Nicholas Piggin's proposed
  ioremap changes https://patchwork.kernel.org/project/linux-mm/list/?series=129479
- Build and boot tested on x86 and arm64 platforms
- Build tested on some others

Changes in V1:

- No changes

Original RFC (https://patchwork.kernel.org/patch/10985009/)

 arch/arm64/mm/mmu.c   | 5 +++++
 arch/x86/mm/ioremap.c | 5 +++++
 include/linux/io.h    | 1 +
 lib/ioremap.c         | 2 ++
 4 files changed, 13 insertions(+)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a1bfc44..646c829 100644
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
index 4b6423e..6cbbec8 100644
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
index 32e30e8..58514ce 100644
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
index 0632136..c3dc213 100644
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

