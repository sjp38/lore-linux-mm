Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2C8BC04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 13:47:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 887962166E
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 13:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 887962166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6F796B0274; Tue, 28 May 2019 09:47:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1FC96B0276; Tue, 28 May 2019 09:47:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D370C6B0279; Tue, 28 May 2019 09:47:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86B976B0274
	for <linux-mm@kvack.org>; Tue, 28 May 2019 09:47:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r48so33183008eda.11
        for <linux-mm@kvack.org>; Tue, 28 May 2019 06:47:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aMFru+FDM/TDLQp4wYpaQ25MLnIXUbp+IgwfShTVwUs=;
        b=mSoxiLc1uxLN8f6Xe5+vFby9OLg3exrRaqX34dzikHri2Z8Bk1vzIfA/0pm2VbWePJ
         X0+cSzLBpkelca1oFYISD6iPHUF5E711De2Ur8zZvMOTmzVtK+gYbhz8EbsZV4ttufGK
         57Aq1k9Qdsqrh8RSFja3nxhvGgqANBDPx+AFoD2RQF2XJyKzJ5kVjq8dy6yUQuRj2H3T
         9GIP9pwuS8+nNQmtgILUF8IDSBj3xlqX7SWDSgr1yXCsjTXZlsi5vf1yvO8PTvOxd9KO
         lnb0hlrI0axwnAkUHMNPqi1N0kzuJLmbaIIvH/5TK2Q9K3mW8u+Z2i5bwyMuxWzRJWDF
         NRMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWiszhif7XU76b9WF/JamMLlqkA8FMIBb59lUFyqv0XAEB/hcwd
	qrwjxbq/VT7/eCzh1tem5u1y+92gLpUhqVQfJcHEIqPWP1FRUzId+dpR7Em5n8adajf/E5UF3oQ
	xC7q9wGI0EGzLxrvyqqpt5HFWVMz4j24sKwiEG45hzHg5rA6OzA8r7809pnId6paXAw==
X-Received: by 2002:a50:95af:: with SMTP id w44mr128682763eda.95.1559051231141;
        Tue, 28 May 2019 06:47:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+v2TwecY5jYaxSVbEvsnWHsjSf2fupbDXEffa+WePMYWBx89PPhtMadHwH5TOlbfmZGWa
X-Received: by 2002:a50:95af:: with SMTP id w44mr128682659eda.95.1559051229921;
        Tue, 28 May 2019 06:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559051229; cv=none;
        d=google.com; s=arc-20160816;
        b=BZQq0a1ec7hfDUNmg6dvEWbzAMQOMV8Ab/u3ycy5JKY4xkNMr6a0P1I2/sVzFGCIp1
         GXWbyqXqc2vBopLofa2Mepf4EPKANMxWfHKsURvnpp/z0F606uKh//+4CjIH0Itz+CCv
         /vpHQ/MFZ85K0BhKpqY8XYQJ2tOXcyuxqUyCX8Z9GXtVxJTIL8mOUwU3yPPPGdK82GD6
         adDR0gaxbElMhN0sI1jqvRppKdUoP3RZgNN7+Az+u+AcAzHrf03pAHFlftOvinaVVD69
         7a70WjICSF34hktSIOl4ADGDxe+YHz7nunkEEKugirgfEbIXn1t+pyn5mVbBY9/QMeFr
         BHsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=aMFru+FDM/TDLQp4wYpaQ25MLnIXUbp+IgwfShTVwUs=;
        b=vQMNTma1mmT4g+f++HN2GZlAqAL/eRzRdmmGN6BSLSxkSJk1Od5qaC/ALZWAZ2AvWG
         H0bE3audyzv1ZfjI5qiKsEFGaGx16tDyqa9LVGYY4b8hKG+Y7kKZUPtAlokTrMOHbZza
         3YSnOXIgNdKuOWr5cc4Wqycwq2umzXbYDunQ+X8+ejrpJwz0Lgi5YANN5lFKz7TCQMC5
         k73O0s6X0gXegiEV9joC/QcWEoJHPuYuRFTYn6+a5Ni5rM+cRToO63pxJHZ0/g6sp9x1
         aT6xAkggj8eMhgDKrdK0tmkTWPaBaDTfwOauYtzh82JXCsKWLmbv1xZq0rr05gfRywLB
         kBmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h3si2405672edn.330.2019.05.28.06.47.09
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 06:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 56D3F80D;
	Tue, 28 May 2019 06:47:08 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 22C303F5AF;
	Tue, 28 May 2019 06:47:06 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: will.deacon@arm.com,
	catalin.marinas@arm.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3.1 4/4] arm64: mm: Implement pte_devmap support
Date: Tue, 28 May 2019 14:46:59 +0100
Message-Id: <13026c4e64abc17133bbfa07d7731ec6691c0bcd.1559050949.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com> <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order for things like get_user_pages() to work on ZONE_DEVICE memory,
we need a software PTE bit to identify device-backed PFNs. Hook this up
along with the relevant helpers to join in with ARCH_HAS_PTE_DEVMAP.

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---

Fix to build correctly under all combinations of
CONFIG_PGTABLE_LEVELS and CONFIG_TRANSPARENT_HUGEPAGE.

 arch/arm64/Kconfig                    |  1 +
 arch/arm64/include/asm/pgtable-prot.h |  1 +
 arch/arm64/include/asm/pgtable.h      | 21 +++++++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4780eb7af842..b5a4611fa4c6 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -23,6 +23,7 @@ config ARM64
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_KEEPINITRD
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
+	select ARCH_HAS_PTE_DEVMAP
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SETUP_DMA_OPS
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
index 986e41c4c32b..af0b372d15e5 100644
--- a/arch/arm64/include/asm/pgtable-prot.h
+++ b/arch/arm64/include/asm/pgtable-prot.h
@@ -28,6 +28,7 @@
 #define PTE_WRITE		(PTE_DBM)		 /* same as DBM (51) */
 #define PTE_DIRTY		(_AT(pteval_t, 1) << 55)
 #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
+#define PTE_DEVMAP		(_AT(pteval_t, 1) << 57)
 #define PTE_PROT_NONE		(_AT(pteval_t, 1) << 58) /* only when !PTE_VALID */
 
 #ifndef __ASSEMBLY__
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 2c41b04708fe..7a2cf6939311 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -90,6 +90,7 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
 #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
 #define pte_user_exec(pte)	(!(pte_val(pte) & PTE_UXN))
 #define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
+#define pte_devmap(pte)		(!!(pte_val(pte) & PTE_DEVMAP))
 
 #define pte_cont_addr_end(addr, end)						\
 ({	unsigned long __boundary = ((addr) + CONT_PTE_SIZE) & CONT_PTE_MASK;	\
@@ -217,6 +218,11 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
 	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
 }
 
+static inline pte_t pte_mkdevmap(pte_t pte)
+{
+	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
+}
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	WRITE_ONCE(*ptep, pte);
@@ -381,6 +387,11 @@ static inline int pmd_protnone(pmd_t pmd)
 
 #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmd_devmap(pmd)		pte_devmap(pmd_pte(pmd))
+#endif
+#define pmd_mkdevmap(pmd)	pte_pmd(pte_mkdevmap(pmd_pte(pmd)))
+
 #define __pmd_to_phys(pmd)	__pte_to_phys(pmd_pte(pmd))
 #define __phys_to_pmd_val(phys)	__phys_to_pte_val(phys)
 #define pmd_pfn(pmd)		((__pmd_to_phys(pmd) & PMD_MASK) >> PAGE_SHIFT)
@@ -666,6 +677,16 @@ static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
 {
 	return ptep_set_access_flags(vma, address, (pte_t *)pmdp, pmd_pte(entry), dirty);
 }
+
+static inline int pud_devmap(pud_t pud)
+{
+	return 0;
+}
+
+static inline int pgd_devmap(pgd_t pgd)
+{
+	return 0;
+}
 #endif
 
 /*
-- 
2.21.0.dirty

