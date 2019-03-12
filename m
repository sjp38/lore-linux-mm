Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5285CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04991214D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:26:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04991214D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D51D8E0003; Tue, 12 Mar 2019 09:26:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 883838E0002; Tue, 12 Mar 2019 09:26:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 773818E0003; Tue, 12 Mar 2019 09:26:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8F38E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:26:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k21so1095398eds.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:26:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=iHOPISw2O0Y4numzfMI2cXma1RgLrE845Sp1bXx/dio=;
        b=HgOhDB9d1XW2dWlLFJdvoI3YQcwpa2k0pAURWlvBgqwbJRK2BWn0QXPNfk+Jb4xHn7
         jVJJ+BEj4wBZmU0bobThKBo/UhURNmZ+zMHO58+vAVaJFm2xCQhoPRhHzee/N9D/FBRv
         7OQhEQIbsvHHK3cmi/+U8l3Di+zhh075wpcO+JLxQP7Exr6h6POMnY+nx5L7rl8Z4zBG
         +7Af9g0pRlGShZPnPgz5kCJ1MUrQjVbiTvftezsKBwdE2lH2NirMwflrr2xzmry35SiR
         VcNaTniAFAzn/x8PA8K05LTI5J3M5JwaFkYSn+VtWkwfLGxMPccUxTS8dNeNYDBRK36g
         dldg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUap1ZpFdmhw0IFtN8Lzl/sWShCFihk3qaCHAtUvcUb6tNfqhAV
	Gx9kmNAy8TYCRsXHQ3EfLbfneqVU91IIIWKJzi+AUM8n8rtqnNa1uR23/9lXiNrosoA9xImvy5U
	MND7WMUr73Mq9ZIP/vw9WVQ5i+SzTvO31vxQSrkpx0s9isMc+yI5DNbRrlAeSFiA/DQ==
X-Received: by 2002:a17:906:4f8e:: with SMTP id o14mr5552782eju.198.1552397165687;
        Tue, 12 Mar 2019 06:26:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU/cHD8zTcG84LhaJjLfRVvVhYyxN9HbBLcAEerrLz6NPlAkfJJOeqt+ntRZc5Y0v/puF3
X-Received: by 2002:a17:906:4f8e:: with SMTP id o14mr5552707eju.198.1552397164313;
        Tue, 12 Mar 2019 06:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552397164; cv=none;
        d=google.com; s=arc-20160816;
        b=miEzpAMTr5Tenpot3z36ecdrSRj3ITwntHk7BqyCSscqs77Kb0yq7s5VZ21+V5HKJA
         FChlohKBRE/oYtuvhkf6udPKfvB/qpg5M0/4CvaOKIKIDGIubYgY02pi5fLQEEXGbqvL
         PwvXO14JSjNHTy6R6YLPlvrltM5lKQ3RSvIgwqe+4mvt9Ka4M3AcoHZ2rk6CUNKaL8Kc
         0B/NNsy+eyNb+kLrYimz7mR0NBoDlOU6we4RaXsKSo8NV2qzE7p3JeDA01Pe/Gw64Zjs
         AvkZzqAgV1epDQsjSj6tCEmMluaUQvN79c1B47l4ysc2UGeOROdS0yzesBXNkOLnUN+9
         DF5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=iHOPISw2O0Y4numzfMI2cXma1RgLrE845Sp1bXx/dio=;
        b=og85AfUbuZsA1wcCN8ZXVgSPq+mp6Y0zMi0zmUWOgjmdS/m79noJOYv8v3cqIlLSI/
         kNQi7HPwqrD52tvrbsjOYS+lGNhUdykUiRXVxkPbkLKJDBcX1XCiynmwem6tobetPFFM
         fQwwRfaLYCQI0C9y3ieQLI3PAMCTDGgCPUTYsc06Lqj4xbu4NLpFio8YrAJJMcj/awyO
         4I6fdiPzII+RriejdpSuDWwsx3XLwiUwAbNymb9obNUb+3LFNCyT0DyifWMv1RG9sPHg
         I23tgVN9mjYbgrBynqTVhqmzGnuvwqSYMBHT/PI3PZyEvLzVwbAEXciCH4SS+OWXLJN6
         PR5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w32si2416399eda.144.2019.03.12.06.26.03
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 06:26:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C7D40165C;
	Tue, 12 Mar 2019 06:26:02 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.86])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 86E473F614;
	Tue, 12 Mar 2019 06:25:56 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com,
	will.deacon@arm.com,
	mark.rutland@arm.com,
	yuzhao@google.com,
	suzuki.poulose@arm.com
Subject: [PATCH V2] KVM: ARM: Remove pgtable page standard functions from stage-2 page tables
Date: Tue, 12 Mar 2019 18:55:45 +0530
Message-Id: <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
References: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
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

Reviewed-by: Suzuki K Poulose <suzuki.poulose@arm.com>
Acked-by: Yu Zhao <yuzhao@google.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
Changes in V2:

- Updated stage2_pud_free() with NOP as per Suzuki
- s/__free_page/free_page/ in clear_stage2_pmd_entry() for uniformity

 arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
 arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
 virt/kvm/arm/mmu.c                      | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
index de2089501b8b..fed02c3b4600 100644
--- a/arch/arm/include/asm/stage2_pgtable.h
+++ b/arch/arm/include/asm/stage2_pgtable.h
@@ -32,14 +32,14 @@
 #define stage2_pgd_present(kvm, pgd)		pgd_present(pgd)
 #define stage2_pgd_populate(kvm, pgd, pud)	pgd_populate(NULL, pgd, pud)
 #define stage2_pud_offset(kvm, pgd, address)	pud_offset(pgd, address)
-#define stage2_pud_free(kvm, pud)		pud_free(NULL, pud)
+#define stage2_pud_free(kvm, pud)		do { } while (0)
 
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
index e9d28a7ca673..cbfbdadca8a5 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -191,7 +191,7 @@ static void clear_stage2_pmd_entry(struct kvm *kvm, pmd_t *pmd, phys_addr_t addr
 	VM_BUG_ON(pmd_thp_or_huge(*pmd));
 	pmd_clear(pmd);
 	kvm_tlb_flush_vmid_ipa(kvm, addr);
-	pte_free_kernel(NULL, pte_table);
+	free_page((unsigned long)pte_table);
 	put_page(virt_to_page(pmd));
 }
 
-- 
2.20.1

