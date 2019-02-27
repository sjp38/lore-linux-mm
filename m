Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEB4C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6724E20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6724E20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0575D8E0014; Wed, 27 Feb 2019 12:07:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00A1B8E0001; Wed, 27 Feb 2019 12:07:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E148D8E0014; Wed, 27 Feb 2019 12:07:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83F9E8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o27so7249613edc.14
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=L7+4dfDNLeQ8Cyqd1Z54ELoUfhtBI7Oe/4rtJxjOb50=;
        b=dqK25XP9oavqD6wc2DH29RDVaVYzSipcha1C6TxD2aOzwDsiEJeVwFUsRFn2HfUVeW
         bWPvAR1hl+odRvpi8iFUeoFIAQUXSmjhBhgsiFIeeK6Get/kVxsGKCsPttYgb2UaZQM9
         z2ZGwz6ZkgE2iU6CznasbDAXKj4coQIQTiuPHxzb8mcrl+Tptz6hatCj7NmgTZhQkfLE
         WqZzEobl2AD0lgSg2yU5MKLbGZWj6/U28/zLFhHborzfzjdxT5en1cx9svSObGaVHuJ5
         /qlCodkB6KImNYOoqs4b2Rw8ApcYPBtlR8jnUCwtAVctrIP2U0dVwTq/bYa3UMm0ly2e
         shqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubE4P8IZ5hfxX/V+P5+4MHfdKw1W2QMEgmgNS9coALDKEDdi4gU
	2w3+a3jM0btsXtZul6HlU9C7LI6YHJ1RN3PWGnKDUMF7kU2m6ZI67zP9n++HrxQYapuYX8BFXNG
	MsxkKotSefEWPMnTiNuAlVWTX11OCOloQHsoGooRVrDu7IVJIdpRbk/EboLPNe8a4TQ==
X-Received: by 2002:a50:ed81:: with SMTP id h1mr3185051edr.145.1551287252026;
        Wed, 27 Feb 2019 09:07:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaxNWgfuXgJOJB8Jxn+WnUmUJYSI1Q2Rc7iTy1TvH1t/kSpWghTRQrYyuTQIG87xkjJHzs/
X-Received: by 2002:a50:ed81:: with SMTP id h1mr3184977edr.145.1551287250901;
        Wed, 27 Feb 2019 09:07:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287250; cv=none;
        d=google.com; s=arc-20160816;
        b=R343KazA07d3NZ9nUJu2Xn0QhZrTwMuw46SqLKhVWoe7legkrTtSHcpqTYbaB6t5QR
         sgNLPSAIK64dC4b9arbvBNqhl5f6hEzuC1ZxSBXLb1CD8ilmw00SgyUyLIbPErYKp/Uo
         Me5AYNmFaIGDVNZnhl+w5syr9Acnw0kYw2bg1XDz/mLTcP+n7kC3dZNgEpNOXYT4sOH2
         emWXtDx7BVZHsED+n+AmPoWRZGtrpQwJgar3fqycMX66hSmlja5cLiFnprxy5IU8eu7V
         vjSUXQYtj67kSuKlnIa4gxKeb4ZaYPKtIBsDQUMX+11YsLe1ZPrunZAJwAAviiQ0U7Q1
         p5nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=L7+4dfDNLeQ8Cyqd1Z54ELoUfhtBI7Oe/4rtJxjOb50=;
        b=D2nVdAc+XoM2UqXEEkk6Yap+pnuy7D8a2df9xPRFgiucMXjvmEBeoiQLnNHsz+CjBH
         NAjwxJM8httj+tsVQnRR4JXnA826sZrUMSF1gB+dx0W5JI251fA+psNG4Afq4gXNr+Vl
         FWTwxLAv35el8OdFGFhjhTAW4yv2E5sQz0TOXnOWrEBDEE/yoV6KftJUwJpEarLFNgfn
         IkILmSZukUzUuNk+rmG/C6fAU28XsughbcSpgWxRzn1Y+6sipFz4uMtpcTA/oe3Ps0i4
         ot/eB2Eqpr2OT8sEYqZtq9T5sBiIkibJbQBADaWF22jIuUrqO+0pn5GvgeJ8bSFd/LRz
         RMpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g11si6392472edf.313.2019.02.27.09.07.30
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:30 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C98EB16A3;
	Wed, 27 Feb 2019 09:07:29 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D008C3F738;
	Wed, 27 Feb 2019 09:07:25 -0800 (PST)
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
Subject: [PATCH v3 16/34] powerpc: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:50 +0000
Message-Id: <20190227170608.27963-17-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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

For 32 bit simply implement stubs returning 0.

CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Michael Ellerman <mpe@ellerman.id.au>
CC: linuxppc-dev@lists.ozlabs.org
CC: kvm-ppc@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/powerpc/include/asm/book3s/32/pgtable.h  |  1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h  | 27 ++++++++++++-------
 arch/powerpc/include/asm/nohash/32/pgtable.h  |  1 +
 .../include/asm/nohash/64/pgtable-4k.h        |  1 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c        | 12 +++------
 5 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index 49d76adb9bc5..036052a792c8 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -202,6 +202,7 @@ extern unsigned long ioremap_bot;
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_bad(pmd)		(pmd_val(pmd) & _PMD_BAD)
 #define	pmd_present(pmd)	(pmd_val(pmd) & _PMD_PRESENT_MASK)
+#define pmd_large(pmd)		(0)
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	*pmdp = __pmd(0);
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index c9bfe526ca9d..1705b1a201bd 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -907,6 +907,11 @@ static inline int pud_present(pud_t pud)
 	return (pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pud_large(pud_t pud)
+{
+	return (pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
+}
+
 extern struct page *pud_page(pud_t pud);
 extern struct page *pmd_page(pmd_t pmd);
 static inline pte_t pud_pte(pud_t pud)
@@ -954,6 +959,11 @@ static inline int pgd_present(pgd_t pgd)
 	return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
+}
+
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte_raw(pgd_raw(pgd));
@@ -1107,6 +1117,14 @@ static inline bool pmd_access_permitted(pmd_t pmd, bool write)
 	return pte_access_permitted(pmd_pte(pmd), write);
 }
 
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
@@ -1133,15 +1151,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
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
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index bed433358260..ebd55449914b 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -190,6 +190,7 @@ static inline pte_t pte_mkexec(pte_t pte)
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_bad(pmd)		(pmd_val(pmd) & _PMD_BAD)
 #define	pmd_present(pmd)	(pmd_val(pmd) & _PMD_PRESENT_MASK)
+#define pmd_large(pmd)		(0)
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	*pmdp = __pmd(0);
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable-4k.h b/arch/powerpc/include/asm/nohash/64/pgtable-4k.h
index c40ec32b8194..9e6fa5646c9f 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable-4k.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable-4k.h
@@ -56,6 +56,7 @@
 #define pgd_none(pgd)		(!pgd_val(pgd))
 #define pgd_bad(pgd)		(pgd_val(pgd) == 0)
 #define pgd_present(pgd)	(pgd_val(pgd) != 0)
+#define pgd_large(pgd)		(0)
 #define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~PGD_MASKED_BITS)
 
 #ifndef __ASSEMBLY__
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

