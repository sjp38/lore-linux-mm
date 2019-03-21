Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF22CC10F10
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AF97218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AF97218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A4036B000E; Thu, 21 Mar 2019 10:20:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 229BB6B0010; Thu, 21 Mar 2019 10:20:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3136B0266; Thu, 21 Mar 2019 10:20:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF5A46B000E
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o9so2275364edh.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=af5cRJh4Tq+8o3hmoF/y3vADwLOSPWNyyODfZV8nBh8=;
        b=tgkF7hdQpqsBoGJ9jnpkjGSLxvlJ+CgjQrIYX/Y+Y5bzdhguz7yiUGzc8t7sBomNvk
         HuMRydERYUQ8H4vp9gG80ruk58GetRLGQRl2NJn0U1y/x4X8dKtIfoYoytHgl8CON6fY
         j1/5DV8u8kYWx/ecmz7eoUZjjddMF8LlWHCs83vtCzYlYvMFINIAjSTvYBmz1mMWIAwj
         SHqpof+CxP+iMj5VdpizBLvc3N2uJsZTIowql8vkDVbVt9ENKsbczOrFQmyFkeR8Rjhj
         ekEkYxwBqa1KKtShjwn8iC41gMGUS+gCDQM6XYAYvL5HnlBGkAdavpcV660pfmFusL0G
         8wLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUOgrR4sYGQK0NQT70vB9dmkm6JjCoKyE1e2YVckg1q2ikpz9/Z
	3edYoFiHzUGpxllq9i+PIp4RPU+LpXC8dt2vpiBDLUzjZpmCN+OGPSzutOAcxeeP/btUAR8Uop+
	8o1Co5B+5e0Cy9lfoWZrFPDM4nCxqN9oLWjqhM0P/W0hz2GqBlV7Vb9iYWXABk5B31w==
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr2735935edd.142.1553178024231;
        Thu, 21 Mar 2019 07:20:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ1fcwVydW8ibxqc92amlEZSvRWV9pqZhvMnzU+VTJPGKdBL/i843Hto4FYCYhHJRBwxj2
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr2735861edd.142.1553178022662;
        Thu, 21 Mar 2019 07:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178022; cv=none;
        d=google.com; s=arc-20160816;
        b=FfA+V8EZUqijX4Gwo+fwhW+qXv657wIS75eCRhw96viUsGyfCyHM9tAY0OgYbJPE1P
         78ZkgOne70s8XCDXlRSlgUatOaBb/M/jtlDdq3dAiG7g0q5dI5SzvtQgTh0Rz3/MFFgc
         qS9WfgIgGCB8pE4Tc5zD260MrLoRz3QASJzVOBUc/Ed6jGrqLf8ITsGDV7MpQ8a/hhan
         30sQqguYQWpUxCtiv1bI9HOJ7E402CKSrLZw3KQdhrl4tpGV/oqM4D4bIyMgjnXPLfi0
         1mcGBHI8eSus6kyofl8phPF9gNKNWXucSyFR6A+3Md8SMPMd+X0RZ9wQpXu1LEx2xxFt
         zgJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=af5cRJh4Tq+8o3hmoF/y3vADwLOSPWNyyODfZV8nBh8=;
        b=NoDjWeyP/WPQWw+q7JHhaDru41haXSuW/Yzjqk3D2ZONoyS/tmfC7LabSRTaoCeVpg
         7zDl77RWNvLDCm/LBfvV3JIXVx+CPUDERNzgx9kR4yOuJ0RaRAvwtMyPeKLGprzqt/dK
         h2p+WafIXPOUyIn7XK7Tn+D5VvPscmEgFl1506AcJjljlAqyVGCWkm1Jzv5mJEkQNcvp
         CSp1AW29MvIBJ/EQLTlE8GkFuX1GgJRnViDj6VG9s+za4YvaASmtMW1NSe4LYdKMsvZq
         bSjqG2MUIv+kSLRlTH7aEsn/M3kFCvxRTpdguSH8CCKlpueSENH82mXKlBSidJGtrKmU
         N5NA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a51si476428edc.78.2019.03.21.07.20.22
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9283CEBD;
	Thu, 21 Mar 2019 07:20:21 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 99F713F575;
	Thu, 21 Mar 2019 07:20:17 -0700 (PDT)
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
Subject: [PATCH v5 04/19] powerpc: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:38 +0000
Message-Id: <20190321141953.31960-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
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

