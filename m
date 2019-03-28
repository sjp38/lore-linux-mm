Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D9D3C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFDD8206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFDD8206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8030E6B000A; Thu, 28 Mar 2019 11:22:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78A8E6B000C; Thu, 28 Mar 2019 11:22:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62FDC6B000D; Thu, 28 Mar 2019 11:22:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BAC06B000A
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z98so8309071ede.3
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6VnZSWrBLPP0YYU4zKMRDn5dbPSJfXU3wTa2rjMcHkk=;
        b=PmujCNQpbCngn4xNs/14/JWCYtTx6GV4ZVF7HY1P0b++XC16zNjxCOkjbucPaUhAMq
         uXm/F67vr0lPoSCbsDPSsx5z3aqKE2EmlaGCHaBAfyCiJN8xoP+WfComFos+6+brHSut
         IDzpULkZRpLeN5hxuHA3XX7qxLOGj8pmDXKa+UVcRZs3Cdb2zrrAWL2xRHqSoyOzrDhY
         rNvbXaFkxWvqx7jOB0Zziu2sk4CJWtnywQJ/Xezl3zi+shV5ixr9DbuPQrAntkPayiSO
         DTYQXjYlwUy0nII8N4rQcrtvyRv0si4X5etR61rltE39n1I4wOsNOOV7AbXAEgSPY2fB
         4t5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXbb4XfYARMTrXTlrbXdqCTuvP9NjTV7aTOvSzlib011vs8vn8Z
	lJm1EAc9h8jCHF2zrNy/hy67zQfE2N1G563Kw9ri6cj6BPd+5TJR8xsB1vhWwn1M8Bnul1FaDP1
	jzzdYuYuB1ywSR7NHEVXTznsLdBSRGBjDuz7NrpLjEixZtglQpOtdc+fFpLoTTovviA==
X-Received: by 2002:a05:6402:1592:: with SMTP id c18mr28327336edv.274.1553786532622;
        Thu, 28 Mar 2019 08:22:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHQ0P++FY1+t52fCgs9wx3MuaC/0SykMHNhMUJNloVCIz3NwKTuqoWWKX2xl5+zMeoHg4S
X-Received: by 2002:a05:6402:1592:: with SMTP id c18mr28327213edv.274.1553786530518;
        Thu, 28 Mar 2019 08:22:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786530; cv=none;
        d=google.com; s=arc-20160816;
        b=sWG5W54oagGMkf1ZBIVVYfH/yHrQfO+vkGE6h69K2Ov/M4HvnTlJWadyQXyWYmEpOW
         TTWe+NlhX6awTPKf6+bi1iOJsVLdP+HpWHld3FDJnVG4z0ByAmtOXDeBLHxrs1qbUIcc
         /F0kKJSW6WA0KtI9MPd1euPW/zljPjG0e3M55tIsV3+9d8hBbWCq13jBpbA6H4H/keZk
         McoY4r6ml7oqWnJWHcVZ854Oi3ak2DowzkmP4bSrZJ9qW0Oxx4RoZmrCTACPH+qm77H+
         IGSRxKCH9pcf0eoEyFAg3GpBxvW7Lpa1Ij5XaiVmat6DRQxxFvCbwhJNuvYBgbV5yo3U
         1LSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6VnZSWrBLPP0YYU4zKMRDn5dbPSJfXU3wTa2rjMcHkk=;
        b=mZQpVT1v0ZXG7BeoUAcuvTaatZauPb7JfH6cNekbywp6N0TBRfc4vqP5MaV2mIQu/R
         bF7veO9/AyOa4rLwBX8xlQIJTNLLZfLm0lgdSfYD1vnAid4bSedEz6hNcGWvlTjW1KPg
         Fzn6cK88Zu6LvDJU6vFah/umAAs+liHUoc06qJ3VAbtj5/JHRuC08KZyjT4ZrPFN5Yed
         E67BDNAi8Dwk1zPTZJ4Km8eGdCFZ4j+RMMYTK3/5q4cx62ckLv5kDYY+0OovucixhCWs
         TBvA8kEhVfnYvkCZnEcswggzI3IWpKxlei0Gtgjk4lyD8eJiH4eQ4KGD1GlGCvVeNDZo
         ZcYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v9si5802496edc.26.2019.03.28.08.22.10
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5801B168F;
	Thu, 28 Mar 2019 08:22:09 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 502A33F557;
	Thu, 28 Mar 2019 08:22:05 -0700 (PDT)
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
Subject: [PATCH v7 04/20] powerpc: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:48 +0000
Message-Id: <20190328152104.23106-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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
-- 
2.20.1

