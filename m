Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DBDBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B63032173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B63032173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 322ED6B0266; Thu, 28 Mar 2019 11:22:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AAB26B0269; Thu, 28 Mar 2019 11:22:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D6F96B026A; Thu, 28 Mar 2019 11:22:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA1BD6B0266
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so8220104edd.21
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3QT6OWyC9JAMeDMFDYFJBPhytDtBHqA6u+Xz2reowKo=;
        b=D68kFkgLAcBYIeUOgLqDNuQiZJ3pIjtv3XBG7o4/tff/KaAF+OA3oQbouPRA/qKGWK
         eJwGBc0kYzYrH2FyTRS02wMNoA4l3XNarlGAM4X5DDgqERx2xJAT87/X75kTdOWGqxCy
         43AnPNN10uxWApexCHv41A+5GAE+AEXfAm1HYPuF8mNt5Mcv/zCrU+LPRz7wllf+EUq4
         91gMKD/4UFLIwmsTcADiV/basUOPWESk2ycQxhwOVPDaoDjgzzAo31D4WlXyCGih1Lt1
         5811fAN3jV9rOpGk/sLI8ucPKEVZcFxw2TrXoXKCVUu1O9EeDv18f018ZBSPJ2dvzv4v
         r63g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXzVwDT3y8cRS1m9iI+lVb3OLZfO/7EOYw1dvWKb90PcYJzd1FZ
	XcyvGmKoHyNT6YNY0x4k+Kd3RrKz6RihRa6edMc5LfMDXOBGojNojaWnV0lQPBfgqh0AxKnFulF
	izCdcczu4a5qgdOBhLPu3a8iuibg3GLLLPIEfhQHWpjTXqgg+VNOZP0rBs4K/NPM2iQ==
X-Received: by 2002:a50:86dc:: with SMTP id 28mr29182789edu.258.1553786551196;
        Thu, 28 Mar 2019 08:22:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhJ+j5kDGR7segffCd1rRvFJU+Kd6/jQu3uqz1aWLc1hGxkhIvv9f9hu2KhiPIuGMPKvNt
X-Received: by 2002:a50:86dc:: with SMTP id 28mr29182723edu.258.1553786550217;
        Thu, 28 Mar 2019 08:22:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786550; cv=none;
        d=google.com; s=arc-20160816;
        b=0yHGa0KModGSsaVyJOC3gJbEd0qhwNo/OFtD9LLfn9FK9vN7hU67IXTpP9TGdUZbet
         B8gzepHI3t276W7WexMb0yfkNtuxyMOR0//CJv9kx6LkMMnVa2Q6wD6zZKk4JJcYnEbk
         Cuey0ekJFjSMyWKkdyQL62hDmKVED0g0/wGLBIb+r+9rZTEr8wBPMSIVArxuZTLLGhN/
         WO/Gm6Ig0G5g8LPHoC5Xy94zvmcqD0vxacbFHctVy0QdutN9fazpSGd8zDj0pc2douI1
         elTO9LD+1eR00cpqZN6qKBi/5JPmZ3PfAZwWjl1RrPmrat5HfKE3ORWzE6Vf97LTDBcu
         0XBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3QT6OWyC9JAMeDMFDYFJBPhytDtBHqA6u+Xz2reowKo=;
        b=BOyKR9zNZ82X0slDTUfr1/cbklydhDkfYTjnRyKqYXkg/UOesDIo7m+sZrAPccrMLk
         8i7cPTLlaczkolJrtw5/JIpQ6DFuTC0YjpZVra6SdGK2UWJ9wLtXwJ5HrDh3NIuFSWbZ
         cZb3LJ8vhvXItNXEFrPphtY2IsvlcSsqbYgmzrqNUm61STE9E3M9xDlvlwPMQ5UvCeTN
         GwfL5ZYmJsaukIowTB6WYeLxNkruziO1JTNsuuNWKEaWqo0HqeVqtx/5Lmv3qEo+6LfF
         k666DLmnSaeKov06ijxalinVagCkqNd2+dzNqQOzBtM/EuI7fXq8AHN8NaqPDkPdJgMH
         /pLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y27si418839edb.370.2019.03.28.08.22.29
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E718168F;
	Thu, 28 Mar 2019 08:22:29 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BB5CF3F557;
	Thu, 28 Mar 2019 08:22:25 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v7 09/20] x86: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:53 +0000
Message-Id: <20190328152104.23106-10-steven.price@arm.com>
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

For x86 we already have static inline functions, so simply add #defines
to prevent the generic versions (added in a later patch) from being
picked up.

We also need to add corresponding #undefs in dump_pagetables.c. This
code will be removed when x86 is switched over to using the generic
pagewalk code in a later patch.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 5 +++++
 arch/x86/mm/dump_pagetables.c  | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2779ace16d23..0dd04cf6ebeb 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -222,6 +222,7 @@ static inline unsigned long pgd_pfn(pgd_t pgd)
 	return (pgd_val(pgd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
+#define p4d_large	p4d_large
 static inline int p4d_large(p4d_t p4d)
 {
 	/* No 512 GiB pages yet */
@@ -230,6 +231,7 @@ static inline int p4d_large(p4d_t p4d)
 
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
+#define pmd_large	pmd_large
 static inline int pmd_large(pmd_t pte)
 {
 	return pmd_flags(pte) & _PAGE_PSE;
@@ -857,6 +859,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 	return (pmd_t *)pud_page_vaddr(*pud) + pmd_index(address);
 }
 
+#define pud_large	pud_large
 static inline int pud_large(pud_t pud)
 {
 	return (pud_val(pud) & (_PAGE_PSE | _PAGE_PRESENT)) ==
@@ -868,6 +871,7 @@ static inline int pud_bad(pud_t pud)
 	return (pud_flags(pud) & ~(_KERNPG_TABLE | _PAGE_USER)) != 0;
 }
 #else
+#define pud_large	pud_large
 static inline int pud_large(pud_t pud)
 {
 	return 0;
@@ -1213,6 +1217,7 @@ static inline bool pgdp_maps_userspace(void *__ptr)
 	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < PGD_KERNEL_START);
 }
 
+#define pgd_large	pgd_large
 static inline int pgd_large(pgd_t pgd) { return 0; }
 
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index ee8f8ab46941..ca270fb00805 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -432,6 +432,7 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 
 #else
 #define walk_pmd_level(m,s,a,e,p) walk_pte_level(m,s,__pmd(pud_val(a)),e,p)
+#undef pud_large
 #define pud_large(a) pmd_large(__pmd(pud_val(a)))
 #define pud_none(a)  pmd_none(__pmd(pud_val(a)))
 #endif
@@ -467,6 +468,7 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 
 #else
 #define walk_pud_level(m,s,a,e,p) walk_pmd_level(m,s,__pud(p4d_val(a)),e,p)
+#undef p4d_large
 #define p4d_large(a) pud_large(__pud(p4d_val(a)))
 #define p4d_none(a)  pud_none(__pud(p4d_val(a)))
 #endif
@@ -501,6 +503,7 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	}
 }
 
+#undef pgd_large
 #define pgd_large(a) (pgtable_l5_enabled() ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
 #define pgd_none(a)  (pgtable_l5_enabled() ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
 
-- 
2.20.1

