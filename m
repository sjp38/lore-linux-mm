Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B5BEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:19:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CA932087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:19:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CA932087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BDDF8E0003; Mon, 11 Mar 2019 22:19:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 944198E0002; Mon, 11 Mar 2019 22:19:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80C198E0003; Mon, 11 Mar 2019 22:19:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28A448E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:19:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i59so440334edi.15
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:19:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3pCXzyanmebXEImbNpsvxMzq7GEb2lfHeN2z4ZAilVQ=;
        b=EAetX0O0RDc2YxsCI5RCcJuZw1sAgTQjzgLQEiD1PEke+nYLr2efCzUGfyQQDjr8AQ
         NfufaafIJZmLMVqV5ls9HXfmoJpX3D1iexY7THhLoyHMOQ/AHF39/xzlKPCiJHRQRIVD
         iVouxi3AAD/y+YCqcShO/uRmJkgb17xlyvcxk0gfXOXrNhvtc0p01oMoKvJnlL3VT/aN
         iAEzCdreeOvu2L85uaTEblEn8jnCSVYJwutSj9vgs3XuYD2rIHeKRXfstPPNDazT18nu
         yhGNCY5lUl/shit/1dERED4F8zsSUMW852x3whBxNMfnkL8xIKyJii7XJx4OzA45OEgZ
         rZtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX5rDN0kdwTY2Eke62x91c5eTOHK0cqyIlWBfqaaZLtnBlSxzwW
	8TOvsALXMsym1GTOZ5HK36eSEkccGlOrh4nVdqskc2QWXeYgI2Bmj17mgggyLCOVA3yvfrESWVi
	Rf2pB6MhFRtdIbLVFj/9oyaIyvhX5yZXpYwbXtYZlfhmvkojhISah3y+lqMLiB8PB7Q==
X-Received: by 2002:a17:906:8491:: with SMTP id m17mr10295266ejx.229.1552357153397;
        Mon, 11 Mar 2019 19:19:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPzEWIJF859V2bx6+zuTfQ3dFnicddRTMivGCSw6w1TtluFXvnIJy5jGv+7llOUwmwRLJy
X-Received: by 2002:a17:906:8491:: with SMTP id m17mr10295184ejx.229.1552357151543;
        Mon, 11 Mar 2019 19:19:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552357151; cv=none;
        d=google.com; s=arc-20160816;
        b=0RXkaVk4tXjFKc5SqkTtvBn2mFgVosYNOGmNfMPHcC19YumrcQPI4WKU2N2xgxYrqC
         bTJCAcNmxJdvhJE43KNAn+pSPziVKIE6RT7LphnOxxq6jHc7z7Q/JSZWwnCexoBHOCyK
         G6CyeOkVmne3Hbf0cGIer/gFJrP2jTUUflTDNNTxCnDY7fv7JGhCNT9CAjPDs3paeIyv
         8ahjnqTMvsgyaQJZ2/E9ngUFdcZctvnbUVfDbV2O5FtUullbWq34yrCuiZv+bYY+oCiA
         lc17SIvvrNmRmJxdk8QG4QQ8PS3kce1T7tIKW1U/pyCNszx2Ql2tu9vGkyVgBv+fwmrZ
         KglQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3pCXzyanmebXEImbNpsvxMzq7GEb2lfHeN2z4ZAilVQ=;
        b=xu5dpx/QaSOQA4noUD2JgZhtn8W2ft7FLi0/Q0aqPvj83Biu3BIZQbVcWaipAanbdV
         H+c4PA8Af8ei/DkOW/QLMRFKyICscV5WWQ/zzmLM0+RRIYBurpOgBsLuq2+y+330dedb
         fvxf3Qsa6K+MVW9JDHV+XrvUGgulHp9FT0y0M/g8mMc1LZK9CgADEJ67AEc/+endiQLs
         FarIxlFhjL4zEbUSvxRxTLVbkRSioTgokIC4lwNF0jNg5FUvcCaiDZuuD2Cg/TpUNdzN
         amc85HHxJotR9+h/PJMkr9vpnprbAkyb7OLCeaiFfqGO35DMCTmYgh6keIeMvLu5Qele
         5nWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g26si4323477ejd.14.2019.03.11.19.19.11
        for <linux-mm@kvack.org>;
        Mon, 11 Mar 2019 19:19:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4E6BBA78;
	Mon, 11 Mar 2019 19:19:10 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.86])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 0C9523F59C;
	Mon, 11 Mar 2019 19:19:07 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: catalin.marinas@arm.com,
	will.deacon@arm.com,
	mark.rutland@arm.com,
	yuzhao@google.com
Cc: linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH] KVM: ARM: Remove pgtable page standard functions from stage-2 page tables
Date: Tue, 12 Mar 2019 07:49:02 +0530
Message-Id: <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <20190312005749.30166-3-yuzhao@google.com>
References: <20190312005749.30166-3-yuzhao@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
pte_free_kernel(). These will fail once they start calling into pgtable_
[pmd]_page_dtor() for pages which never originally went through respective
constructor functions. Hence convert all stage-2 page table page release
functions to call buddy directly while freeing pages.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
 arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
 virt/kvm/arm/mmu.c                      | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
index de2089501b8b..417a3be00718 100644
--- a/arch/arm/include/asm/stage2_pgtable.h
+++ b/arch/arm/include/asm/stage2_pgtable.h
@@ -32,14 +32,14 @@
 #define stage2_pgd_present(kvm, pgd)		pgd_present(pgd)
 #define stage2_pgd_populate(kvm, pgd, pud)	pgd_populate(NULL, pgd, pud)
 #define stage2_pud_offset(kvm, pgd, address)	pud_offset(pgd, address)
-#define stage2_pud_free(kvm, pud)		pud_free(NULL, pud)
+#define stage2_pud_free(kvm, pud)		free_page((unsigned long)pud)
 
 #define stage2_pud_none(kvm, pud)		pud_none(pud)
 #define stage2_pud_clear(kvm, pud)		pud_clear(pud)
 #define stage2_pud_present(kvm, pud)		pud_present(pud)
 #define stage2_pud_populate(kvm, pud, pmd)	pud_populate(NULL, pud, pmd)
 #define stage2_pmd_offset(kvm, pud, address)	pmd_offset(pud, address)
-#define stage2_pmd_free(kvm, pmd)		pmd_free(NULL, pmd)
+#define stage2_pmd_free(kvm, pmd)		free_page((unsigned long)pmd)
 
 #define stage2_pud_huge(kvm, pud)		pud_huge(pud)
 
diff --git a/arch/arm64/include/asm/stage2_pgtable.h b/arch/arm64/include/asm/stage2_pgtable.h
index 5412fa40825e..915809e4ac32 100644
--- a/arch/arm64/include/asm/stage2_pgtable.h
+++ b/arch/arm64/include/asm/stage2_pgtable.h
@@ -119,7 +119,7 @@ static inline pud_t *stage2_pud_offset(struct kvm *kvm,
 static inline void stage2_pud_free(struct kvm *kvm, pud_t *pud)
 {
 	if (kvm_stage2_has_pud(kvm))
-		pud_free(NULL, pud);
+		free_page((unsigned long)pud);
 }
 
 static inline bool stage2_pud_table_empty(struct kvm *kvm, pud_t *pudp)
@@ -192,7 +192,7 @@ static inline pmd_t *stage2_pmd_offset(struct kvm *kvm,
 static inline void stage2_pmd_free(struct kvm *kvm, pmd_t *pmd)
 {
 	if (kvm_stage2_has_pmd(kvm))
-		pmd_free(NULL, pmd);
+		free_page((unsigned long)pmd);
 }
 
 static inline bool stage2_pud_huge(struct kvm *kvm, pud_t pud)
diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index e9d28a7ca673..00bd79a2f0b1 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -191,7 +191,7 @@ static void clear_stage2_pmd_entry(struct kvm *kvm, pmd_t *pmd, phys_addr_t addr
 	VM_BUG_ON(pmd_thp_or_huge(*pmd));
 	pmd_clear(pmd);
 	kvm_tlb_flush_vmid_ipa(kvm, addr);
-	pte_free_kernel(NULL, pte_table);
+	__free_page(virt_to_page(pte_table));
 	put_page(virt_to_page(pmd));
 }
 
-- 
2.20.1

