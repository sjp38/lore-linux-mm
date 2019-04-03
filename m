Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B20FEC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F96220830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F96220830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 217ED6B000E; Wed,  3 Apr 2019 10:17:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C97C6B0010; Wed,  3 Apr 2019 10:17:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B7036B0266; Wed,  3 Apr 2019 10:17:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B33786B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so7649389edo.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6VnZSWrBLPP0YYU4zKMRDn5dbPSJfXU3wTa2rjMcHkk=;
        b=PN0U2uu3qH+uYnn3XEmNXeWGdl4WlIaQF89xQPuPOqEUWZPCnR2i7QGl29WYZMMx/C
         V/kgihZKPwvVXfuXLNjMnQDchSOi6Qy6A1ngUPSY5tOqY6RTI5WYky3T1ZxvuEZXdyDS
         k+BpAbCYE19eFr6wK2tRcI9GogCdN7IGdDM4YSyD2iQW3SVmNgXUV+ChLtCCTm8ST9U4
         Sc2IC5ifb5Nm6ezfzzv0+VKolaG7ihhw5ScSOMlkJWL/7zxvPHsGMUNfAa8zICUbO6nH
         hQOK62hCDD0PCsLnFxr++0y8EK85pRkMIUWGaimAAbwkvENBNLlhg5oFV2LjPn6amCSI
         du9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW2Kc7rgsCPXNO5VC7TArKQlomZ5WM1dxR1IOZZ1XtiGS3FEwA7
	OM8qKhq0eBc8Ep1lbNbW119PyBtnsxRByQ4omT4MT4aD2ntUIoJdS6uE0r2huQ/qzUaThShPgqv
	dvwWEmTjbvYD88yIHZolu1mO2jMhkdWWidIy9+z9Wk4K1WtTdfOVbM1emYRKzi2ZI6A==
X-Received: by 2002:a17:906:8247:: with SMTP id f7mr17824320ejx.216.1554301050223;
        Wed, 03 Apr 2019 07:17:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVNl96F6woXc1It+RPym0tJdtkZxkKWJ2HLcgo3r5Y9pG57YlE6I72Khw59Hi51iwKw0US
X-Received: by 2002:a17:906:8247:: with SMTP id f7mr17824258ejx.216.1554301048885;
        Wed, 03 Apr 2019 07:17:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301048; cv=none;
        d=google.com; s=arc-20160816;
        b=P48inbPyu+vrkxJXE8fUv1aiaPtqxojj7InQD1myavA7BV1kj+JQLu+25tNr8gfnJm
         dxhQxufwzppas+iU9KD6VIPfElkXEEch2GFcw5qIxMFAasnuvcLVX54zQnzXAmsjt3jS
         8HUlxU2mfQSG6gm3E7YblL9BguxTEAmSGEgHVTolvWszJpNx9qX1wZCi5puEIxSuqt3e
         Lz2uQlj/mDsiIdJ6Yo8rHne0gGs7y90rJAcHRH+SSlgNBQ9e5gAng1Gtgul9GBtA34wc
         VbX9yYPWfIzi8arFJGuai0PCSwcnxKHaTIcRl4mtqow9Zn7v5veNq7Kr6saXRnWAhLNH
         yosw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6VnZSWrBLPP0YYU4zKMRDn5dbPSJfXU3wTa2rjMcHkk=;
        b=DmdN0kGih08a/nwFcUW3b06RQVOlGmU9Imu1Sjmo2dK2WCsIFM/k3o9DvII5HpEYbE
         /mm/tBio1mBAazrc0vqTfWZQs/NGA4+jEAXx09UCRt4sS3e/5yyNsumk7MgY5KxY4QJd
         givkLCea9YV2ZpGcYkoZc/aHHtbwuLCZ/j++zqTtL1J+3rOofEyznsAl8VNrQpLjvtOK
         VZcfGPXDN9ENldpSTz9fJRYZ14c4su5sJP4ijhJI7+E/bzLyKTMXy4wEzEpnxHv9coMQ
         KASRSVwYGyicLW3KlVt/IpzXI4KEeh/mE0q49D1Fg8vA+K62ECMpR3B02iAlrQ2s1ZB6
         4D+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o26si356003ejx.277.2019.04.03.07.17.28
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B25BC1684;
	Wed,  3 Apr 2019 07:17:27 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 936F23F68F;
	Wed,  3 Apr 2019 07:17:23 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org,
	kvm-ppc@vger.kernel.org
Subject: [PATCH v8 04/20] powerpc: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:11 +0100
Message-Id: <20190403141627.11664-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

