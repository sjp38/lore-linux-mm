Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2463C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 04:45:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 648D72070D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 04:45:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 648D72070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E52FB6B0006; Fri, 28 Jun 2019 00:45:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDD8E8E0003; Fri, 28 Jun 2019 00:45:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA6B68E0002; Fri, 28 Jun 2019 00:45:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3FE6B0006
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 00:45:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so7684629eds.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 21:45:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=yqR2A9BF5z1WiyLGSQ+X9x0SHG4YYsD89TXzq8JJB2o=;
        b=CGh3TH3JX7FdPKs/1VUp2X7HsrutwNAIj1M6+9ttnkpC2q+ae3G22VHvk/SAnbSWxR
         E8j/5PZ3NzD/q0I9rVKs+qen4HrsViV3jhs55AkASqyG6Zhv8fw2nhjp7LchtNnmqmyP
         EfaGex+kSftyHE5wOt34m9Fg5SCsrFkQlZbhdcp+GFWwsHJcGDwNf47q8ZEhZ//rPnnU
         Q2rCiELc9U5oRiumpn4CyKCXwo5LyqQNxohdZYkrFxeocplxZHsef8XC6o6Ebtg90Dpn
         /NdrTZDv4pHYenvqt7cB+qVzDyj1vNoa4rufkkDjYTeh4UCcpds5mUhVB86i4hAkO8c0
         oh0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXKmQpet/vFTLKJerlXSXM7Gc+ZRYqQKQaGK351w3JWzRUwk2rj
	ZUjWOEN2sd9lz62BD+c1fMODtshIpy35kFEW0t1UTU6S5iVcCefKVnoN6ic9xlXSnO8d/j85UU9
	CDuCr4ONkshpCJs8hpJoXrrA7ulc6t6K3fLzAEzowB1cyv1tmjqLFpsNQnXtJE5hNuA==
X-Received: by 2002:a50:8b9c:: with SMTP id m28mr9082478edm.53.1561697112007;
        Thu, 27 Jun 2019 21:45:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOgVuX80aAjzVCcsszdqmQcr3hYN+Ne02jVlTJ5jRP68Im1vVhSbcp2pTShpjewu+481vD
X-Received: by 2002:a50:8b9c:: with SMTP id m28mr9082406edm.53.1561697111015;
        Thu, 27 Jun 2019 21:45:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561697111; cv=none;
        d=google.com; s=arc-20160816;
        b=VsSx8FQ4tOK93zWZgCwY0jttOlMPqaWcuAcNKuYn1PPj+Zan9KxovUXu076kQXP2AG
         WPTcZ/JCoQMOiuKssDRUeN/0IgHfwj5LY0NnNnrE9Lw7eRA4zXcWixY2PAN0NiJyXVSy
         xspkAJ/Drl19onBJmZqmXDFrkeLlemejpfojLv4jORjfVGpSu4OOvk5k202NRJeLnlD3
         /sSKf79P7wAWEh7K6j9RrQOJNt4kVdJciUYgKhUFScbuRYNc1Ff3u3WwyvAbk4tCpKYe
         8gvM1ws3lBNoETc/MrlJj4U+enPjOuuWxWqCDw08SGSuonoJAVoe872Qjky/1nCMvqFM
         XNLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=yqR2A9BF5z1WiyLGSQ+X9x0SHG4YYsD89TXzq8JJB2o=;
        b=MgVDm428pSZC1P/F7ZTtPx4nWUDkxyExM5UdvNKCPRYTcOJeIi50wmbgteW7d714le
         GOHvwHzpTAeIIHzZeX98lsskbQ7qhpaSaeyHgSWO9qCxxlY7ubJ4LhG3i2C4yYE4iOPr
         yDNSg2extMY1FFDlsBBbFhXbJtZXnLlPhB3er0auIYiPfIOF+nuZFbNA2Qz4asH8zCn3
         KgehQrTr3/fXdNO+IEFaryDe5Eq0SMHaf6CGjIz+NIT2lB91BFwGDJWt5ZOU04kAAJsv
         U4eoa0f3ITDpEUxEf/bwM/K+MWvCHFP1vbJFaIQSc0DgPDiNFBai3SiUkZf3sFAyHuHL
         uV5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id t5si999508edd.61.2019.06.27.21.45.10
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 21:45:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0B5DA344;
	Thu, 27 Jun 2019 21:45:10 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 805AA3F706;
	Thu, 27 Jun 2019 21:45:06 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-ia64@vger.kernel.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 1/2] mm/sparsemem: Add vmem_altmap support in vmemmap_populate_basepages()
Date: Fri, 28 Jun 2019 10:14:42 +0530
Message-Id: <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic vmemmap_populate_basepages() is used across platforms for vmemmap
as standard or as fallback when huge pages mapping fails. On arm64 it is
used for configs with ARM64_SWAPPER_USES_SECTION_MAPS applicable both for
ARM64_16K_PAGES and ARM64_64K_PAGES which cannot use huge pages because of
alignment requirements.

This prevents those configs from allocating from device memory for vmemap
mapping as vmemmap_populate_basepages() does not support vmem_altmap. This
enables that required support. Each architecture should evaluate and decide
on enabling device based base page allocation when appropriate. Hence this
keeps it disabled for all architectures to preserve the existing semantics.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/mmu.c      |  2 +-
 arch/ia64/mm/discontig.c |  2 +-
 arch/x86/mm/init_64.c    |  4 ++--
 include/linux/mm.h       |  5 +++--
 mm/sparse-vmemmap.c      | 16 +++++++++++-----
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 194c84e..39e18d1 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -982,7 +982,7 @@ static void remove_pagetable(unsigned long start, unsigned long end,
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap)
 {
-	return vmemmap_populate_basepages(start, end, node);
+	return vmemmap_populate_basepages(start, end, node, NULL);
 }
 #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 05490dd..faefd7e 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -660,7 +660,7 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap)
 {
-	return vmemmap_populate_basepages(start, end, node);
+	return vmemmap_populate_basepages(start, end, node, NULL);
 }
 
 void vmemmap_free(unsigned long start, unsigned long end,
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8335ac6..c67ad5d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1509,7 +1509,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
 			continue;
 		}
-		if (vmemmap_populate_basepages(addr, next, node))
+		if (vmemmap_populate_basepages(addr, next, node, NULL))
 			return -ENOMEM;
 	}
 	return 0;
@@ -1527,7 +1527,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 				__func__);
 		err = -ENOMEM;
 	} else
-		err = vmemmap_populate_basepages(start, end, node);
+		err = vmemmap_populate_basepages(start, end, node, NULL);
 	if (!err)
 		sync_global_pgds(start, end - 1);
 	return err;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c6ae9eb..dda9bd4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2758,14 +2758,15 @@ pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
 pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
-pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
+pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node,
+			    struct vmem_altmap *altmap);
 void *vmemmap_alloc_block(unsigned long size, int node);
 struct vmem_altmap;
 void *vmemmap_alloc_block_buf(unsigned long size, int node);
 void *altmap_alloc_block_buf(unsigned long size, struct vmem_altmap *altmap);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
-			       int node);
+			       int node, struct vmem_altmap *altmap);
 int vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap);
 void vmemmap_populate_print_last(void);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 7fec057..d333b75 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -140,12 +140,18 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 			start, end - 1);
 }
 
-pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
+pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node,
+				       struct vmem_altmap *altmap)
 {
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
+		void *p;
+
+		if (altmap)
+			p = altmap_alloc_block_buf(PAGE_SIZE, altmap);
+		else
+			p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
@@ -213,8 +219,8 @@ pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 	return pgd;
 }
 
-int __meminit vmemmap_populate_basepages(unsigned long start,
-					 unsigned long end, int node)
+int __meminit vmemmap_populate_basepages(unsigned long start, unsigned long end,
+					 int node, struct vmem_altmap *altmap)
 {
 	unsigned long addr = start;
 	pgd_t *pgd;
@@ -236,7 +242,7 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 		pmd = vmemmap_pmd_populate(pud, addr, node);
 		if (!pmd)
 			return -ENOMEM;
-		pte = vmemmap_pte_populate(pmd, addr, node);
+		pte = vmemmap_pte_populate(pmd, addr, node, altmap);
 		if (!pte)
 			return -ENOMEM;
 		vmemmap_verify(pte, node, addr, addr + PAGE_SIZE);
-- 
2.7.4

