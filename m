Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2DF8C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7343020663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7343020663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164828E000E; Wed,  6 Mar 2019 10:51:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 115AF8E0002; Wed,  6 Mar 2019 10:51:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 031398E000E; Wed,  6 Mar 2019 10:51:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9992F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:19 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so6583024edo.5
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w/JFdsJDPYSKc00MKHrpcbCJk0SkUKoK6gsDYp4bqCg=;
        b=fuZt9xFrKM9FEH9Y+Nd1R8LYFGQ2lDye0/UsU0iAS3weVYtnYQMakUzVMd+hE1+M/O
         dEfHiW2DEusKHyxKm/mrLVHmfzuegrsbSKCVeV1BM3YX4t4dybo/y3LocJTOmYrTnX/V
         jpPN4UsO1Zi5LYCGzWCPL4VG8xzIeFnevv0Qe+OIRpeMK5WAhl88+BOjd/axav2m25eo
         UFFYEP+VgEjxZ/aOvyOHgkk+BtVx3ySdKUzqYOPw//+OyI87OJVZV3jOgraFrWqumNHt
         wqzq+R165gTOqxuWHvLls7msdKGrWicAHxWl15ngoPLWhWMYfhTK/m0vsBMhw9pZY3ao
         9M2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW7Yp5GyuBogtnWoa2q5r71wSpAPvCHVAoG0Z8RGq3iDhqfAZt/
	1cxplzrbEAZw4zSjd87TZ7bx7oeqAfoxBol3eL8khQ7BynbVq4tbnEfKj5bTfgrjlgO50XOIbLv
	Fy7FgegpOeWdamtv72e4cZlGSFmD7fRuKuXYfkGyBzr2rKmQZgBUf/izEJm4WFylMQQ==
X-Received: by 2002:a50:9908:: with SMTP id k8mr23141137edb.246.1551887478858;
        Wed, 06 Mar 2019 07:51:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqyQiTVJAIbppigMTvpVTTNriThB9j0hryLjPGc6d/iIT90T4OKPFKgV/W5/6QgjjY9FGqlM
X-Received: by 2002:a50:9908:: with SMTP id k8mr23141066edb.246.1551887477718;
        Wed, 06 Mar 2019 07:51:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887477; cv=none;
        d=google.com; s=arc-20160816;
        b=uGGoPPdrRMhlnpe9uLMsXLm3HLPvu8g659w5gGwgjXffyBn4fKiT3W+8nr6D7gMvT0
         mW31+9st2e+Qz6qkG9erkNfegQwOg0MExFno1O4S71qb+k21Xb9CJkUMw/DzSLMvwe7w
         llVEWAdw/XybIkACWqe8nJen7BKw6Yn6I+BvrbZMTByVyNcgnnfsUErUMPIq4XygC05b
         dqs3J3UI0c32nM5IXhUf8RxSztc/XtXRsJWU/M5afm6+5+Zc7c+Rvvau3bEmNzMXWJ5F
         YBN/9ogl01EIEfENsQzLp4l6Cm2jD0sg8+ah3JH1ZPei55b68ySi8tX9fHNhYarr6U6D
         v81g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=w/JFdsJDPYSKc00MKHrpcbCJk0SkUKoK6gsDYp4bqCg=;
        b=uP90hjGzNLI7Vf5k68gi9IRzGJKquj2l9ehnjpoNnznd7u8BvhqA8rTFPel7T3/ktS
         8yTlGMkCYy0vBjpq24RI8g1bDyicBfs09YPzCYNNZ+ZHmI2AH3AxREMj1yiZ3c2bUmrI
         ZAMLooDgQgripwBh926v/0wW7svVQK8rwYe/NfTFrXp6WWfgXK44fYo4VbquO72t1A7Y
         mwXVSzJ0RqiPDiWMyU8Qo3nifzQKj1iiQWHzQLQlegVH6qV9glS4rwXGuDdrTt4ZofSS
         jnrmUUQRLVIkqeKluJ5mtAOIDIONYXOkk9ZZ8lRg+x3OvM17wzjtz1YjL7rqJC4AwD+z
         woDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x4si802153edm.451.2019.03.06.07.51.17
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:17 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8F9B41713;
	Wed,  6 Mar 2019 07:51:16 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 54A923F703;
	Wed,  6 Mar 2019 07:51:13 -0800 (PST)
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
Subject: [PATCH v4 08/19] x86: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:20 +0000
Message-Id: <20190306155031.4291-9-steven.price@arm.com>
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
index e3cdc85ce5b6..cf37abc0f58a 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -432,6 +432,7 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 
 #else
 #define walk_pmd_level(m,s,a,e,p) walk_pte_level(m,s,__pmd(pud_val(a)),e,p)
+#undef pud_large
 #define pud_large(a) pmd_large(__pmd(pud_val(a)))
 #define pud_none(a)  pmd_none(__pmd(pud_val(a)))
 #endif
@@ -469,6 +470,7 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 
 #else
 #define walk_pud_level(m,s,a,e,p) walk_pmd_level(m,s,__pud(p4d_val(a)),e,p)
+#undef p4d_large
 #define p4d_large(a) pud_large(__pud(p4d_val(a)))
 #define p4d_none(a)  pud_none(__pud(p4d_val(a)))
 #endif
@@ -503,6 +505,7 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	}
 }
 
+#undef pgd_large
 #define pgd_large(a) (pgtable_l5_enabled() ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
 #define pgd_none(a)  (pgtable_l5_enabled() ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
 
-- 
2.20.1

