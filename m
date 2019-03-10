Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52718C43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 01:19:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01DEE206BA
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 01:19:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ne3qu3Fx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01DEE206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 912208E0005; Sat,  9 Mar 2019 20:19:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89E598E0002; Sat,  9 Mar 2019 20:19:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64EA28E0005; Sat,  9 Mar 2019 20:19:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 393288E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 20:19:14 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p5so1704629qtp.3
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 17:19:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=+4D1c6JWSWE8QT+yoi5CUv0ZKRIbRAhMzGEdnkssg9A=;
        b=bh9lZz1UP8MAGJbrgBj0SNbLtb3zjjBpIsMamy1Hp2NBsjoLY9q3rHbx05sWs2WnIe
         GNg4qBKFMDdtGvYOmHXu4XJLBByRV2iTuOmDAibhAc5nTRq2BmqlgRfaBj7WmQOSFd9T
         2HDMPNcQ8OwxNptmb+MsmmuyEG3cdebaR4vP+ItG7wBAxLNFY8959BWuAQf/EvdfdC8d
         S791uF6QHiPcSEpskuZCzvVly3bvO2PbOCh2ug8qaPIP3Qbk4PF18sgbXQMOetJYd4i1
         SSzQD54/dt5haAvko+KYRuCTJVD/EqmIR3Evu5g2A/BpWXY7EvKpLH8yjnCuaesHSjV/
         3Evw==
X-Gm-Message-State: APjAAAUVG9RoJSLmlgYkoI4ejtXldlq+Ilt38KjEHMZENG3rbFvK8fj0
	LnRas/OCllOwCJelkJQVOBiYcU32NARKIKNteSIWcTEGJveND3Owte3YL0a/5uQ7tWIRxOVILYK
	jk7T0bg05Gw+Q07UA+xZnXAIlr6jzJ2OO53Qnnxj0/5/LgNXWnq1YTR6OM2463P0JWMwExZq/6z
	JjHXyrxrx24Yn6l11HJOzHptfCM8ajNH3547cmGJGiIVgNXkfERgaZq2TZPLEMELCosQVME98y5
	4qLD1C9JSYfPLWdQl3t4LupXuGEJJ04p8eqDg5FANJXjnV6LbOleJmCgjrPO0IoKXgIgCplTltc
	V5YImKEI8uRPoLUVk5pa1zqsnrYZzwiB+J07CBBGB2VSr69ztPF2UCIUurNGb+srNLTPX3fjZnM
	+
X-Received: by 2002:ac8:29e8:: with SMTP id 37mr20906001qtt.153.1552180753970;
        Sat, 09 Mar 2019 17:19:13 -0800 (PST)
X-Received: by 2002:ac8:29e8:: with SMTP id 37mr20905972qtt.153.1552180753312;
        Sat, 09 Mar 2019 17:19:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552180753; cv=none;
        d=google.com; s=arc-20160816;
        b=Eu9PB13Ye4TB7r1JRUvl3eWTbbPo/ZlzAarWpR+DxV23hXWoWRsJyEl+c3GRwiRSQt
         59Gl2YWwFH62yZoSq627WyejGqj/gPp8kzC2zjttnADqbblMkkOsHdjSy3RZWdzvLv6K
         8c/gnj4rBoHVSuG/dQPCxXK3Rdx25mbR8PTK5tqoPSVeWcWXYNrvNknknEA9F4497keo
         xOenycNBdY5xTmF53j5PM4+wXriCvyfUnlZjvU8j3TWVygxnR+odvU7kGW1ewH17YXtF
         X7gwXVy/shE32i8Pbp81ZmqxxZ1M4SQTmfjWWIra9p2bV1tWBeT3suVuW542oUvhoWFf
         bXLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=+4D1c6JWSWE8QT+yoi5CUv0ZKRIbRAhMzGEdnkssg9A=;
        b=bpMj79onHIpjrjYS2ku+Wg3AftT96EYq6UspXSxLs4Qbh6t7clmIqJPTBgs3VZnjy/
         UaKYGZ9T0FDSHmrWMafiI4RWCvkto1/UbtPYv4RhhOVYVWjy2cucy9g2vOlB3VrPVxy7
         jTaJNLxbdPYOT8IDIRw19yUUwxGHBRNX6myp62aWL+mX/xCM4jVIYtDS4FHxqWv9Hiym
         YPYMCsOAx5KR5+zOOgrcikJaxSENkR5RFsuO1u8xQKJKWPGYXgwMemFrmOVdEr9ePyK9
         ME7QWp/z/bSVZLVDqgH1l665vjMNXkvxokFmsOpkB418HBlCkZ83kVpjTAEJtIA11wAy
         nDyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ne3qu3Fx;
       spf=pass (google.com: domain of 3ewaexaykcngsotb4iaiiaf8.6igfchor-ggep46e.ila@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3EWaEXAYKCNgSOTB4IAIIAF8.6IGFCHOR-GGEP46E.ILA@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p10sor2239640qtf.13.2019.03.09.17.19.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Mar 2019 17:19:13 -0800 (PST)
Received-SPF: pass (google.com: domain of 3ewaexaykcngsotb4iaiiaf8.6igfchor-ggep46e.ila@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ne3qu3Fx;
       spf=pass (google.com: domain of 3ewaexaykcngsotb4iaiiaf8.6igfchor-ggep46e.ila@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3EWaEXAYKCNgSOTB4IAIIAF8.6IGFCHOR-GGEP46E.ILA@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=+4D1c6JWSWE8QT+yoi5CUv0ZKRIbRAhMzGEdnkssg9A=;
        b=ne3qu3FxuNnaxTHNaR0KvnSI+dxHillTroSbc2a23I9NeDzowB1PzvJmROLLgBDQkQ
         4isyzzDBrnqmSk42wEbalVZQRdtGPCAh3G/B2qqSQtX3/BY5STPBC/0sf8VymLZxZnqv
         TFyb/EiMA0LE7HOd2jjMWMn2DLhBGtYXdC/SxMBWDrB+9bVk7z2HS1cqhsOLbpOYAqnq
         EWEylhDMVOFJ8n8MACWSvz57cSQhFCTOFpDGhLPApw5kwjO/4JcLuQBWDIBdVRtBa8MN
         6AY17se4aFWkWszozRMszsYdPmcuPedaKhntA1DBHOnvx8MI+7RGhbs5ZQZ6UykgKoku
         kghg==
X-Google-Smtp-Source: APXvYqzdCq/8JWJo7I6dgNrFQli0gtIFsccTph2MG2IS/kBQfoPBV4rNembCgH+TWILl3RUeNtEXGWzHp7A=
X-Received: by 2002:ac8:1997:: with SMTP id u23mr15120422qtj.11.1552180753103;
 Sat, 09 Mar 2019 17:19:13 -0800 (PST)
Date: Sat,  9 Mar 2019 18:19:06 -0700
In-Reply-To: <20190310011906.254635-1-yuzhao@google.com>
Message-Id: <20190310011906.254635-3-yuzhao@google.com>
Mime-Version: 1.0
References: <20190218231319.178224-1-yuzhao@google.com> <20190310011906.254635-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v3 3/3] arm64: mm: enable per pmd page table lock
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, 
	Peter Zijlstra <peterz@infradead.org>, Joel Fernandes <joel@joelfernandes.org>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>, 
	Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switch from per mm_struct to per pmd page table lock by enabling
ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
large system.

I'm not sure if there is contention on mm->page_table_lock. Given
the option comes at no cost (apart from initializing more spin
locks), why not enable it now.

We only do so when pmd is not folded, so we don't mistakenly call
pgtable_pmd_page_ctor() on pud or p4d in pgd_pgtable_alloc(). (We
check shift against PMD_SHIFT, which is same as PUD_SHIFT when pmd
is folded).

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/Kconfig               |  3 +++
 arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
 arch/arm64/include/asm/tlb.h     |  5 ++++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index cfbf307d6dc4..a3b1b789f766 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
 config ARCH_HAS_CACHE_LINE_SIZE
 	def_bool y
 
+config ARCH_ENABLE_SPLIT_PMD_PTLOCK
+	def_bool y if PGTABLE_LEVELS > 2
+
 config SECCOMP
 	bool "Enable seccomp to safely compute untrusted bytecode"
 	---help---
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index 52fa47c73bf0..dabba4b2c61f 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -33,12 +33,22 @@
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)__get_free_page(PGALLOC_GFP);
+	struct page *page;
+
+	page = alloc_page(PGALLOC_GFP);
+	if (!page)
+		return NULL;
+	if (!pgtable_pmd_page_ctor(page)) {
+		__free_page(page);
+		return NULL;
+	}
+	return page_address(page);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
 {
 	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
+	pgtable_pmd_page_dtor(virt_to_page(pmdp));
 	free_page((unsigned long)pmdp);
 }
 
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index 106fdc951b6e..4e3becfed387 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -62,7 +62,10 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 				  unsigned long addr)
 {
-	tlb_remove_table(tlb, virt_to_page(pmdp));
+	struct page *page = virt_to_page(pmdp);
+
+	pgtable_pmd_page_dtor(page);
+	tlb_remove_table(tlb, page);
 }
 #endif
 
-- 
2.21.0.360.g471c308f928-goog

