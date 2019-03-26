Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3E8AC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 966B3206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 966B3206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC1E6B0273; Tue, 26 Mar 2019 12:27:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 482006B0274; Tue, 26 Mar 2019 12:27:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 371B36B0275; Tue, 26 Mar 2019 12:27:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9E596B0273
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17so5504317edd.20
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3QT6OWyC9JAMeDMFDYFJBPhytDtBHqA6u+Xz2reowKo=;
        b=bPRiwbJ9TkdndR9OTL2+PfpZw0luhZLVMTaxszqlNwdDtzof8dDXdslJDhcasEcABm
         0pwqfPfdmsso9c/kmkiBv1VqfDiFArJURzpEMLdj+6+yIZzcC5sg5SRF+jCExtuVkCgD
         bsjxKz8xeOq0BJKWkLmKILHslt6v/9VIrUp2r04jP3K/xo50QsICAO/08MhQ15exJTBM
         6CzNvBWJ4ZWiVduvgeUO+dVkaZsQ7RErCj0g1aDQzCC92SwprWrVXe3xFtLSbCz6FcJX
         pHZTP2nd//U1obF1scAdgp0aBeo4oEfhd1dLFprB0oUsflLHA3qSBf2qj1WG3XAQqb22
         Q2RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW4TyTKT/WjGwGFBffa/XKELLJmh0RaXfkmf9MNqZSmeHrNXXcc
	+ratyMePRcizp2eYfj+Jurk5wvzg3OTF2aEFmFLO9PmXlX1I3LjkF5LH34SNdej8+9UpYhQfKD4
	EPhuWJWWABwtOvS8EAprhbW3+c9Bxax5McyaPJw2yiqXNs7bJYMSMZ0/5HtzvdDSSSw==
X-Received: by 2002:a50:a546:: with SMTP id z6mr21272095edb.30.1553617628403;
        Tue, 26 Mar 2019 09:27:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9aDlssn+IHeoNpc3Zq2HKDJ8RQag/6ScWOfp4f7YPvLFRYlqgd++rYF7nbP6iVT6A3Eyx
X-Received: by 2002:a50:a546:: with SMTP id z6mr21272037edb.30.1553617627473;
        Tue, 26 Mar 2019 09:27:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617627; cv=none;
        d=google.com; s=arc-20160816;
        b=Ig5jCbjy5zCOdZX5klpKipt2zfBVXaPvj3qk77dzy5cP69Ow+JXzRpGLLWYdWAR3sC
         iOncoeKoBVoEGY5BL90aaeTmgiDt2t8N2tf1039zglL6iCsyc0dW961rTTMPNn4GBa7J
         ddA+59/2PQMcOiqqyl4k2tcrPpabKvRmqp8QCs6q25B41txXflMMinSGBA0pwaB8BsX9
         /zjkd5efCN/I7oUSO2WSMlFoDqNOgdiL2ra3gcQuKiWxxiZsPnVR2JwEeL+CHPxbOR5I
         +BcqQmHDtHeJfBctx85Qy3XWP5jK+TZv7p6ZwJlqhFCUSaKjcfmwactD6/pLN/IkCxDd
         roOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3QT6OWyC9JAMeDMFDYFJBPhytDtBHqA6u+Xz2reowKo=;
        b=ldYaMga0dYqcSEsMJGrRiYFz+4wmhGU1d8OBWRDncygDZU+Tj7dtb9/K6UDb/F/x17
         iQETNFu1T1xNk4GFjz4a4r80VmmqOXMeEW5jMAxcUf/FkjmLlLJR6hJiU7an+qalFsm6
         zVNK7tit52POTnLe/his0DQSl4EfM5mQafCDI+19HaGDDa2WWslFgga7RcJNddS1cMXP
         PVWxBYWMt3L5hcH0LiQ8tTtf1Sv3ed0eq9d2eJTRdqbQhFnEA9f4lXQ7owGE/dtbXOcH
         fmt0dLGSCQ/o+dh5MAgEuWwSvqVtWZj/RuLuezQbqcq9Ca+GMe+c2VoKQ5amfkZzeUOv
         vBqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m17si694019edm.68.2019.03.26.09.27.07
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3E9331596;
	Tue, 26 Mar 2019 09:27:06 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F36943F614;
	Tue, 26 Mar 2019 09:27:02 -0700 (PDT)
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
Subject: [PATCH v6 08/19] x86: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:13 +0000
Message-Id: <20190326162624.20736-9-steven.price@arm.com>
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

