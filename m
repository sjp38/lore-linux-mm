Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D65D3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9389521473
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9389521473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214466B026C; Tue, 26 Mar 2019 12:26:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2C76B026E; Tue, 26 Mar 2019 12:26:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B2176B026F; Tue, 26 Mar 2019 12:26:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAB066B026C
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:26:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s27so5474326eda.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:26:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=af5cRJh4Tq+8o3hmoF/y3vADwLOSPWNyyODfZV8nBh8=;
        b=ONUmqj5TS97PZmknmovy2zdLw8MMsjLNGDl2xe70JBmWICXk7KwOaouCxY8rFpLtEz
         b2X5RHE8ir/6w5aEXm41Gzgwpmje99d8FmV1Fw4VNvz+WT3Xau4BXbDVFVxDZWctu0uj
         ZalLGsSvGvcvuqV/BRbkGK0rL2Or1BK0zeABdwcpalVTh+QIMM78EI54Y/eVBrV2qGZA
         FRGWOod7/RQQt17NiGXu78qRWxmvAisA5+h0exUgYbDiEM8paa0Xk8RJeL+m3Zb4dFba
         A3SzXkOXBUsDFY9y1tiB0CrFQZJz+Y0R4JrIV8m5AeRGO+C8rv7bOJcBABS95PYzm+4t
         ptSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWA6fYxCiEbUYdIHQjGiRg1btNE5PVouY9b4PpzSS1sPR3nvdR2
	vs1Zk2R3sCOq6v5Lpju8ATbHh+nZtJSlAzoFiYDOrW7qJXEw5WPkvwqB81x4x4RpB2YNKSVte4h
	5PWcOW2cLBC9TdG91J18/qFUbaeOXt6ZNjf0AwrUYAgioniGGX+IgLvGgYTtn+Df1Cg==
X-Received: by 2002:a50:b284:: with SMTP id p4mr4109149edd.27.1553617613173;
        Tue, 26 Mar 2019 09:26:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvYE1pWwOrfhiemlPKPZaefb9dTqOyz5+O0ObqD598LlEd+WYxMtzrrhCx41j8byUdNtvW
X-Received: by 2002:a50:b284:: with SMTP id p4mr4109099edd.27.1553617612221;
        Tue, 26 Mar 2019 09:26:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617612; cv=none;
        d=google.com; s=arc-20160816;
        b=k6lZVLSJrmA75pX7sigLdKHO2EOR5DnV4hAnoW8zA+KsZul0DFFWW7yv9ZnWOEhrDO
         RrW/upgyczxEGi2z0+3Yp2ercyoofIlekrJGbILnKYSB/x35YDC2PGN4Xg+fGoCrfUOm
         7SgO+VSKbG/1jy8rzkF1ZC0ALoq38Oq2YHpjPVpvODVex/m0nysMssICkdk/i9g3YqVA
         zwHDfdNlP6A/8J5Uns/EWbcDEc18aL2ieYVOixIyGkUv41Iyk/rUnAJVrgnXEgsRoUbu
         U+aWt1XEXTSJmDD9NI26S40UtYh5UVBrcIidLoECXXVfIi3Je3d5Nf3IF79uKZzygnxN
         eeRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=af5cRJh4Tq+8o3hmoF/y3vADwLOSPWNyyODfZV8nBh8=;
        b=dzSgQfl4vYtCz1lXiA2KBt/uKhZbcwoJF6DVvVhmjZUArmksoIOhE32z1UAlXbcmKY
         NG8tScvA5wsYRI5+QG78mFCfkOTl3JyoQCQAJ8jtWVtHSL+4LbebURtpTM/FaoWkxdAJ
         QxgnRGWEOjRgR/9RA2Wk1rP4BjdEJ6eWAlXAq3wIFHemShIKVReW6TJlXukmOS1OPNp1
         WV4tDacpdBgOEdfgWIipnH9BQCwQNXcIIYNTpG3PwgiyVepFNoyqIOWopU0CusTd1cus
         egpsMZJ80OMeyVcE3i7tRkymteCNGNrp2Y+r3YBkvSWPKRznBqIMFyIxnprocB6m0PgF
         b9BA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m17si693780edm.68.2019.03.26.09.26.51
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0C016168F;
	Tue, 26 Mar 2019 09:26:51 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 12AF63F614;
	Tue, 26 Mar 2019 09:26:46 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org,
	kvm-ppc@vger.kernel.org
Subject: [PATCH v6 04/19] powerpc: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:09 +0000
Message-Id: <20190326162624.20736-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For powerpc pmd_large() was already implemented, so hoist it out of the
CONFIG_TRANSPARENT_HUGEPAGE condition and implement the other levels.

Also since we now have a pmd_large always implemented we can drop the
pmd_is_leaf() function.

CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Michael Ellerman <mpe@ellerman.id.au>
CC: linuxppc-dev@lists.ozlabs.org
CC: kvm-ppc@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 30 ++++++++++++++------
 arch/powerpc/kvm/book3s_64_mmu_radix.c       | 12 ++------
 2 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 581f91be9dd4..f6d1ac8b832e 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -897,6 +897,12 @@ static inline int pud_present(pud_t pud)
 	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+#define pud_large	pud_large
+static inline int pud_large(pud_t pud)
+{
+	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
+}
+
 extern struct page *pud_page(pud_t pud);
 extern struct page *pmd_page(pmd_t pmd);
 static inline pte_t pud_pte(pud_t pud)
@@ -940,6 +946,12 @@ static inline int pgd_present(pgd_t pgd)
 	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+#define pgd_large	pgd_large
+static inline int pgd_large(pgd_t pgd)
+{
+	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
+}
+
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte_raw(pgd_raw(pgd));
@@ -1093,6 +1105,15 @@ static inline bool pmd_access_permitted(pmd_t pmd, bool write)
 	return pte_access_permitted(pmd_pte(pmd), write);
 }
 
+#define pmd_large	pmd_large
+/*
+ * returns true for pmd migration entries, THP, devmap, hugetlb
+ */
+static inline int pmd_large(pmd_t pmd)
+{
+	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
 extern pmd_t mk_pmd(struct page *page, pgprot_t pgprot);
@@ -1119,15 +1140,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
 	return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
 }
 
-/*
- * returns true for pmd migration entries, THP, devmap, hugetlb
- * But compile time dependent on THP config
- */
-static inline int pmd_large(pmd_t pmd)
-{
-	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
-}
-
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index f55ef071883f..1b57b4e3f819 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -363,12 +363,6 @@ static void kvmppc_pte_free(pte_t *ptep)
 	kmem_cache_free(kvm_pte_cache, ptep);
 }
 
-/* Like pmd_huge() and pmd_large(), but works regardless of config options */
-static inline int pmd_is_leaf(pmd_t pmd)
-{
-	return !!(pmd_val(pmd) & _PAGE_PTE);
-}
-
 static pmd_t *kvmppc_pmd_alloc(void)
 {
 	return kmem_cache_alloc(kvm_pmd_cache, GFP_KERNEL);
@@ -460,7 +454,7 @@ static void kvmppc_unmap_free_pmd(struct kvm *kvm, pmd_t *pmd, bool full,
 	for (im = 0; im < PTRS_PER_PMD; ++im, ++p) {
 		if (!pmd_present(*p))
 			continue;
-		if (pmd_is_leaf(*p)) {
+		if (pmd_large(*p)) {
 			if (full) {
 				pmd_clear(p);
 			} else {
@@ -593,7 +587,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
 	else if (level <= 1)
 		new_pmd = kvmppc_pmd_alloc();
 
-	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_is_leaf(*pmd)))
+	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_large(*pmd)))
 		new_ptep = kvmppc_pte_alloc();
 
 	/* Check if we might have been invalidated; let the guest retry if so */
@@ -662,7 +656,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
 		new_pmd = NULL;
 	}
 	pmd = pmd_offset(pud, gpa);
-	if (pmd_is_leaf(*pmd)) {
+	if (pmd_large(*pmd)) {
 		unsigned long lgpa = gpa & PMD_MASK;
 
 		/* Check if we raced and someone else has set the same thing */
-- 
2.20.1

