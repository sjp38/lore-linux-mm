Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33C1AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D88BF2087F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HBNdWh+/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D88BF2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AF9F8E0006; Mon, 11 Mar 2019 20:58:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 762EB8E0002; Mon, 11 Mar 2019 20:58:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62AA78E0006; Mon, 11 Mar 2019 20:58:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3690F8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:58:10 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id i4so819791itb.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:58:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=GuInaEquY9cKCo+/R3bLL1KFcpfX5BwU8EHfq1hu08M=;
        b=YH0maHXCKWg7jkGbpEqwIdYy7QjEpmIE76+xicZ3efAJbeC/dP/HwS+ils4FH8c9Fn
         s2ulVm0dd8qKQ8iE3iqP9gq8pi/4iLtisUMFmA+/nDiPc+eRXqPNnG3aEDauNDeeQLql
         E/ASGzNQdb0IEbQzRcz4K7GsERjDin3EzN7DkzLGKai+aOOQH9E2bEt9q7fz89pOBsoa
         8h2P2rPYVyxSJJVl5aXNGTKJteEN5fAXTKKUpJWqXFPhBE+jpTjhyPE54NvnLUr3VK8U
         0JgyJ9u3rL1sGvZfo1kGWHOekR1fE3GsfVYOHn9zZFVhyAUlQ6Rh5s1inm6DxEL5erLl
         3czQ==
X-Gm-Message-State: APjAAAXXZolywcdnutPSnhIVb26xmfHaM56O4iN0RKelDHWqJs1+LqGw
	P/SVInvHFclozaWiUISXOPKuc+mmt+sgcIiqD53AsDwFTzALaFyvzOw+zy3y4YLuOh7qsdOlNRS
	0thl6i1COBNsvy2kOvHA0pLs4EdAWJ3fjJMdZ6JHzO5wQUZzM+CHuEN0Kulf3MJgLNw==
X-Received: by 2002:a24:ac9:: with SMTP id 192mr663657itw.15.1552352289988;
        Mon, 11 Mar 2019 17:58:09 -0700 (PDT)
X-Received: by 2002:a24:ac9:: with SMTP id 192mr663634itw.15.1552352289178;
        Mon, 11 Mar 2019 17:58:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352289; cv=none;
        d=google.com; s=arc-20160816;
        b=ZKhGkO2Od9J1lLvwnk2fIZ5l0oISDqHAs07IXupHYQmpQKjPz+YyfKocBW+ZG0GYGw
         LO4ijSs2qTmT6VD0QO0KhqIrCqNBrYKoPUNC9jxYvlxuivXPD6A2Ybkh3hs7dMeHCa+B
         nhmiiM7rU8OLy8Jk3fGg7zoSAa+vx4mYldi66wdKM5RBrl3MQ85DYi2VdAhSrI7d68C6
         l8Rf72aqJ75a+OUqn811mQUEBztV4g1Nz6tBjSFAfh4SUDJtVX+vQxnWwNo62dU29fV9
         n9zv55Ny1hl3lj031wgCUqswSJXJlzVVB7Gd7rP9g7+pUCrukC/r5om5Sn8nvpFER4ph
         DsoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=GuInaEquY9cKCo+/R3bLL1KFcpfX5BwU8EHfq1hu08M=;
        b=F5OqJbVSXo/VgSwyX9HDsp5dV+X45jyvCu4J9PnnonK4dQ99AuJIUvDc8M0KIfzchq
         s1XSIXDsDKnB7lWDrM1fD/AkN/T4xKKyTByuCdnmYpYQM/T9+jttHDSJxsA6LeE3eIsI
         sTHleXfl/zuM8WjZhNx3EtyVzgalhWYYqRuXwUz4CL7JCQxsaLdtG7F51h/a3QbP82CW
         pUI1fZ0bX0E2i9XZtg9X2W+bzZv641jZ8NeHmbTne8PBPJanc559BNdgwU2cgPgJz1Rh
         tMS5z316QzQq16kJt5+n7K1Sc99MFJULtJv8tPofnE3/Jp4U9M/HPxMXdFNcfP67Q6CM
         wl/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="HBNdWh+/";
       spf=pass (google.com: domain of 3iashxaykcc8jfkslzrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3IASHXAYKCC8jfkSLZRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b102sor1218270itd.30.2019.03.11.17.58.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 17:58:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3iashxaykcc8jfkslzrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="HBNdWh+/";
       spf=pass (google.com: domain of 3iashxaykcc8jfkslzrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3IASHXAYKCC8jfkSLZRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=GuInaEquY9cKCo+/R3bLL1KFcpfX5BwU8EHfq1hu08M=;
        b=HBNdWh+/H/UQD3+xTCC5Gk1vTOFdi8buqG7IOzQCbqWRid+PcTT/T4iKPfX1Muy57H
         mA9gcEpPcKUv1DaJBopn5SU1wwyHnz+qqvQzVQiKuH4IuAZHw8WmPDHRTekZ4RoJuPoI
         k8fyIUxtuU7UBUmfFhSlmXIqDkwkNUo2QrkJLaPkIgWzkEwroQQwBNFou6cniBzdTUeU
         pguYiLIcrrFrKPeCm6lJ2yAvRHkaGHnYB9ACSfOKeP/GH7Q1zppaEI6Nk5aSRMS5Mt3C
         9GOsSCQ8e1rnKd9uYUOK1sUbi9ceU8L2Dtpr15+FePDmyFg81CK03OWXDcm0/xCUaK9T
         fuqw==
X-Google-Smtp-Source: APXvYqxhul1R8mnVTm2ANYck/U0sQICDmCd8jsCIgw/3U8ahE12sg7YNMdshwxSVxfvSc2y++gz3qAvURMY=
X-Received: by 2002:a24:6b55:: with SMTP id v82mr545054itc.37.1552352288828;
 Mon, 11 Mar 2019 17:58:08 -0700 (PDT)
Date: Mon, 11 Mar 2019 18:57:49 -0600
In-Reply-To: <20190312005749.30166-1-yuzhao@google.com>
Message-Id: <20190312005749.30166-4-yuzhao@google.com>
Mime-Version: 1.0
References: <20190310011906.254635-1-yuzhao@google.com> <20190312005749.30166-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v4 4/4] arm64: mm: enable per pmd page table lock
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
pgtable_pmd_page_ctor() on pud or p4d in pgd_pgtable_alloc().

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

