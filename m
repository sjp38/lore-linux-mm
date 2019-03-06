Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC975C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 663FD206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 663FD206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 078A28E0003; Wed,  6 Mar 2019 10:51:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02A2A8E0002; Wed,  6 Mar 2019 10:51:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5C718E0003; Wed,  6 Mar 2019 10:51:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2C08E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o27so6570482edc.14
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jPV2QhL324pMmsFwCL76K/pZK2wary4s770HvasTlro=;
        b=mfDwCyUMCrsuCdYTdNocQben+q7tftNtEBTVZhSANUXZ1MCXi7JF8JabKWL1gZlnbF
         014G1DPB9TZplXw2b2Mir3a/xAeTP8RddX8KIvcAD2JwXaiVPAXnn6vZMr7SbgBZwKEB
         WtcYNpENcWicPwHC7Y47cn9hGdCSBPwZ2aWjFgPY3HSK2tjx/Upxj5cCMt5FOpCRq0Sj
         0AAn15W52g8sQ6gG5V7YY48i8IopROoETKGLj4T+g+MXBnt/TRoqPtAuESoH5sOTYuor
         Fy/2woi+h6iejTgaiIELCIKjk4qVEcDfs3EiIjJWKG5LJH/5F5iw9crPXEj+oFCcIey4
         Ifng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVftBzyVnalaDsx+jYkX75CiGa1KuIebEpCbg8f912eBY9xkKYe
	PlGDyWAL7lrEzt9cs+GMTt2V5wdIYGDPnSju7V8yQzDrmK2CcrFf/KfW3mFpLk1pmedzKr4Nt1X
	KYb0N8C2te2Ny687elFp88hH1zahCk0nFUIyaEBFkjWh+LxF9jNWkkwFvpf4/oOqefg==
X-Received: by 2002:a17:906:2a86:: with SMTP id l6mr4382305eje.186.1551887464774;
        Wed, 06 Mar 2019 07:51:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqzxjZtfTOgvqq3sHmHmVujHMmuHbz2Biv5ylg4TPD1+Y1E1v9lqZypqUoriNZhWe6Ox9Ogg
X-Received: by 2002:a17:906:2a86:: with SMTP id l6mr4382187eje.186.1551887462551;
        Wed, 06 Mar 2019 07:51:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887462; cv=none;
        d=google.com; s=arc-20160816;
        b=t5CxRLpYcydFCEreh5S1UWQt7oyu5khsX7pKo1szqxVJzeAIOSSwash/qDxEDJsp40
         aOxIG+NI7QUAA7qptLq7M28HORszU/sGj6Mef6MNpya94fKOTwE3Juy6ymf6NNtZPBjL
         uNmcUi0kNmlv2DgybTyPgXLaLc9bO1Pl55E7IpfPTr+BbiHqKM6/qT82jY2ym9Jmsw71
         geRMicgcizemUq+1favWloKOnvNPr9mSrFUf4G9pvWkF/K5mYA/fuzxXzP+bjikT8fBM
         WcBYUaFfWWt7vAcYm702t6Wp96P1YWwWn5sJ56T8NYx0O/zYZKT+a5tw2q1n3zwNfRbA
         IAiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jPV2QhL324pMmsFwCL76K/pZK2wary4s770HvasTlro=;
        b=YalLPn4+qzKZK4a9JkwRu98kiaDmsePBGUBoSPC/dIotjxvfaHvmMh6NYuc4mQmmub
         s6ODHbxEgvuC4718y7H3FJNWqHddV/4EBLw5aBKJODd/XONMA28zF+VzrTwxjZdagNqo
         pbnG/iE0rwsaYERpz276bEnOzyUpg+kZ/X4/bO5W/I2WHKoOl/56bNbMJ5MT5GhE3jT+
         RjKgXtZhgUPFm/LW8RCXmEiyRR2fk+FOwoEYoeE5yIoN2Vdi1uWkA/Ixya1zGVnUhFT5
         nqOK55Neoysj4QTaDKEnfMMioZdwGThQdQ7xvq/FZK48N75n28VBoxBMkzrcPPTGNM0Y
         aLNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r15si749714edd.284.2019.03.06.07.51.02
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:02 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6361C1596;
	Wed,  6 Mar 2019 07:51:01 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6AC853F703;
	Wed,  6 Mar 2019 07:50:57 -0800 (PST)
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
Subject: [PATCH v4 04/19] powerpc: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:16 +0000
Message-Id: <20190306155031.4291-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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
index c9bfe526ca9d..c4b29caf2a3b 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -907,6 +907,12 @@ static inline int pud_present(pud_t pud)
 	return (pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
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
@@ -954,6 +960,12 @@ static inline int pgd_present(pgd_t pgd)
 	return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
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
@@ -1107,6 +1119,15 @@ static inline bool pmd_access_permitted(pmd_t pmd, bool write)
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
@@ -1133,15 +1154,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
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
index 1b821c6efdef..040db20ac2ab 100644
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
@@ -455,7 +449,7 @@ static void kvmppc_unmap_free_pmd(struct kvm *kvm, pmd_t *pmd, bool full,
 	for (im = 0; im < PTRS_PER_PMD; ++im, ++p) {
 		if (!pmd_present(*p))
 			continue;
-		if (pmd_is_leaf(*p)) {
+		if (pmd_large(*p)) {
 			if (full) {
 				pmd_clear(p);
 			} else {
@@ -588,7 +582,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
 	else if (level <= 1)
 		new_pmd = kvmppc_pmd_alloc();
 
-	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_is_leaf(*pmd)))
+	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_large(*pmd)))
 		new_ptep = kvmppc_pte_alloc();
 
 	/* Check if we might have been invalidated; let the guest retry if so */
@@ -657,7 +651,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
 		new_pmd = NULL;
 	}
 	pmd = pmd_offset(pud, gpa);
-	if (pmd_is_leaf(*pmd)) {
+	if (pmd_large(*pmd)) {
 		unsigned long lgpa = gpa & PMD_MASK;
 
 		/* Check if we raced and someone else has set the same thing */
-- 
2.20.1

