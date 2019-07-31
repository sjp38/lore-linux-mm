Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC9E1C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 890D620C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 890D620C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32EB48E0013; Wed, 31 Jul 2019 11:46:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3087E8E0003; Wed, 31 Jul 2019 11:46:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CE768E0013; Wed, 31 Jul 2019 11:46:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C205D8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so42690155eda.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EC/gTJC/ZTlBnG7KHf3GkHZ2M0gvGSck7pciHwmxI7s=;
        b=RsahkDywWtPjTzVWDRDNsfGReN/gmMzfz2yMCihjDnePmuF9CRFA1C/Ey2hu74JIaa
         0w9G0HSoL/GuPCpmFNuRdxmA6Rt+/Kzeg5iMz4+vTF9a5q2xLqX2VC7H96I4WPaVhpWY
         AOWSAOyBrVj2AD0FMH7a+6N2+d+0xIA4ENFa16bB3IotDGsjy6ALz0mHC7Tyk7G/JmVV
         /FLykw5DrgZIVjzkcxYV3VhhPtDZauVq7Kd/2grUybVAHSwb33dIGfChC1RLwG7Jx5De
         3OT2Ggunf4cJ0QMaooaNPx+mGli/BMPKFRHT9IxilsQhbD2laq/YxP0nSBV2yQ9pFPeH
         0a/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUxhEbcV9rrLkKuVrlKxEMc5NcmDEl5jPY3uE22sXoFWNGWLqyx
	ZvdYgIqeQM637IGPREMaMA4Z+N89iJBeEsHrFm1jycnCwcHWoi8WmXWTb+LcgHg5SKsdsxmgY7E
	c+a3J486PW4QzHnN4R+mlNcN3fgP8v+zKtnYdRhPDPecmnJrCCHWfQOXxDufW6fjGcA==
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr107564937edb.43.1564587991367;
        Wed, 31 Jul 2019 08:46:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7SYVySIOkDowuPNrUi/D2RgyypJwRi1JZjtvx/3ItjDD9GmKEp4qIwz6LGbX/H2mZRRaY
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr107564876edb.43.1564587990638;
        Wed, 31 Jul 2019 08:46:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587990; cv=none;
        d=google.com; s=arc-20160816;
        b=RcWHLrwfpM6ICEvHospPtFPN+uhwEAtohyi+hodUrT04l1l9ce9NxkwaRCyM+gjT5i
         46pHue5QW/5nVcn3n4qVWkgnNKB6pEMcobxryiCVGa1olwZxIaa9v0X6gQJpxOiLsoqx
         muGb1KsSgJucamUo8n1/SUnFMqYin4buz188nsKbZ4w9B5woASqGMNhf9n71TrChqIUm
         6JegOBztpMaz/8Fn+gsPiYsoleuYUFibx/nFPWY21m3oWcxrPOWT5iFondB9Hdsx7KfJ
         68MymJ78FRBLcnIHMC7C0W2lZ9Mtgu0hSc77XWWqfXOMXdKfVoQNTclJxP5nlMHWCloD
         BTqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=EC/gTJC/ZTlBnG7KHf3GkHZ2M0gvGSck7pciHwmxI7s=;
        b=Bbg6YH7h9+cfDvBUYfMbhWkWS47b0ByOubOfDky3FIc39seS7M0IqFau+yfVZPdlhD
         4VgBzRlbk5fDgWynPCJdZW0POvIXDhWsFy8GtwgiMNgbRmLeuDN3W+SiiNmjQG6x/6va
         sxsChbp/FZ2yb61JPJ2UhG1F+S3BP3ZfY2IA1Wn9qym+sASIpUE3d2ELIv5F0dDF5ajv
         opqrDxHJdn2MUgejn0Al7pHiptaoTAzj/5caynrLCt3cPU4xVWAeznBEmTeFWtwagd0y
         76qeMEWdgwNXalSmg4u2GyBOAIkpjIydPmAU+4Uk4dzxtu/8/6kTUlfsbR/wPHB01wrl
         QVAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id j17si20098029edh.221.2019.07.31.08.46.30
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C06831576;
	Wed, 31 Jul 2019 08:46:29 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A45C73F694;
	Wed, 31 Jul 2019 08:46:26 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org,
	kvm-ppc@vger.kernel.org
Subject: [PATCH v10 06/22] powerpc: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:47 +0100
Message-Id: <20190731154603.41797-7-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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
p?d_leaf() functions/macros.

For powerpc pmd_large() already exists and does what we want, so hoist
it out of the CONFIG_TRANSPARENT_HUGEPAGE condition and implement the
other levels. Macros are used to provide the generic p?d_leaf() names.

CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Michael Ellerman <mpe@ellerman.id.au>
CC: linuxppc-dev@lists.ozlabs.org
CC: kvm-ppc@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 30 ++++++++++++++------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 8308f32e9782..84270666355c 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -921,6 +921,12 @@ static inline int pud_present(pud_t pud)
 	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+#define pud_leaf	pud_large
+static inline int pud_large(pud_t pud)
+{
+	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
+}
+
 extern struct page *pud_page(pud_t pud);
 extern struct page *pmd_page(pmd_t pmd);
 static inline pte_t pud_pte(pud_t pud)
@@ -964,6 +970,12 @@ static inline int pgd_present(pgd_t pgd)
 	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+#define pgd_leaf	pgd_large
+static inline int pgd_large(pgd_t pgd)
+{
+	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
+}
+
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte_raw(pgd_raw(pgd));
@@ -1131,6 +1143,15 @@ static inline bool pmd_access_permitted(pmd_t pmd, bool write)
 	return pte_access_permitted(pmd_pte(pmd), write);
 }
 
+#define pmd_leaf	pmd_large
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
@@ -1157,15 +1178,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
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
-- 
2.20.1

