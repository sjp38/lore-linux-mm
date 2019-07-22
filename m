Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 679F0C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3466321E70
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3466321E70
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91FDA8E000B; Mon, 22 Jul 2019 11:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 884968E0001; Mon, 22 Jul 2019 11:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 611128E000B; Mon, 22 Jul 2019 11:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07CF58E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so26540698eds.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nxKy+dHCcQ52WwJbQmiHduBQhK1uZKwGIaDaQ5m0n9k=;
        b=LpmVvY3DlHz1ShUe5CV1NHYD6s5XWC14PjQ71FWNbIn1VXkhW9NAytqI28UMk6VaZT
         sVfEiLAM+TFRymuX7hIYi7Hzc4RwWGBmz34KuOd2FmWfgfp9/iTQKMT7Gfu/gHX+b/rx
         EHZjf+lMqwPvNZewl3tHU82WdhTapDDyTyFYSJ1MnCxaEuz/DkVZpD3e3FZKVdir573b
         tHar7OMNZayJJVrLVSjpMhP2UZlQOFGKjzXBLfqVsBB/vUd1wvyEpibeyqSMnKC2qA9I
         ppRbEBkdKr0JZRFZ112+67OBA0JCEoedCu/RZSmfru32RRwJx+ZfC7j47xOKoU0tV8/b
         dYEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW9rah/7XnFoWC3MVM6zYe2zo05tF1B0n92YXP1fOp6bLygpvWy
	5gl60CGTQC34UAYeVI0p6kzjAVk8BBCTtJJBTDthmymDN1CW21fYsVUr2ti8Lcp8awJWQuh611j
	Fjl/2mn0IPvbilH8nS5/5fHXgi7/pNNpYNt/N36xEFmB8FL7hTJQZ8Bpq1uIJrdisNg==
X-Received: by 2002:a17:906:2599:: with SMTP id m25mr52881137ejb.177.1563810172549;
        Mon, 22 Jul 2019 08:42:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVQoV2py3oXnj0vksbitZBnkbHMltjaRBZv/hT09wKmsLrWOTfYkNW3nLUOv+uSgV+uzbE
X-Received: by 2002:a17:906:2599:: with SMTP id m25mr52881076ejb.177.1563810171605;
        Mon, 22 Jul 2019 08:42:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810171; cv=none;
        d=google.com; s=arc-20160816;
        b=dIxVST4BvzmLSTOhlL91bWgrn2OJXI2b0ByjR5GNlJkZYtNoPWfLUxjZlS4N8T02pA
         j9cvF94Qy246tb2KzLW87aQ0JmTpBFKWs4OleNWB5ln5ZVvGfhqA0h1HiRxSmvX68qyY
         AExVPuX5PUqrisYo4cGrz+wxO+yROU0kk1aqqe088UaQZmH0A5d+P+/MUYrzfhcClzqT
         r6+E8mvzQitS9CUQdRourzybPtR5f4nPJU4RcRjMVyOCwcIQrM2frmOvmWPBs404HHV9
         TIvMXTpYOpnZksXBK2/ocD1iMsN2ggO2yNb6AmGRWz60jTPh5HuF7B0a3txJ24Do30sN
         jokA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nxKy+dHCcQ52WwJbQmiHduBQhK1uZKwGIaDaQ5m0n9k=;
        b=KuO9OqxQ8be+A1DQfXaRRTlOhZ1XVpPRDwjYnhIzKpyNDxPV6BH2C3H9ow2Vr+8oeQ
         mkIshWMcWEwgj139eoCYODalHHnnfIR1IiUqHU81c0x25HPWXy5imXKbJ3cTXASDqRNE
         RGcobU97I9JQOEJ0bK3Ge1JdhAaejAnYXEqXfxfbRdPQaCFUs9ygQRA44b7cmzY1QhHT
         5EmLAg2ARoD0gROzIkUiGMroOZKpLSz2K0wGiqhAQoYyapMtHA/Qdxy7EfosNkWDejAS
         xVCu52wLJ3uYoPPJ45dIN3NKrakNFW6akSi6otjbRK35RkD7D6LHZqTEPBZMsSK8ndmo
         BoQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id oc23si4326684ejb.369.2019.07.22.08.42.51
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CE1BE15A2;
	Mon, 22 Jul 2019 08:42:50 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 430953F694;
	Mon, 22 Jul 2019 08:42:48 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 09/21] x86: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:58 +0100
Message-Id: <20190722154210.42799-10-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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

For x86 we already have p?d_large() functions, so simply add macros to
provide the generic p?d_leaf() names for the generic code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0bc530c4eb13..6986a451619e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -239,6 +239,7 @@ static inline unsigned long pgd_pfn(pgd_t pgd)
 	return (pgd_val(pgd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
+#define p4d_leaf	p4d_large
 static inline int p4d_large(p4d_t p4d)
 {
 	/* No 512 GiB pages yet */
@@ -247,6 +248,7 @@ static inline int p4d_large(p4d_t p4d)
 
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
+#define pmd_leaf	pmd_large
 static inline int pmd_large(pmd_t pte)
 {
 	return pmd_flags(pte) & _PAGE_PSE;
@@ -874,6 +876,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 	return (pmd_t *)pud_page_vaddr(*pud) + pmd_index(address);
 }
 
+#define pud_leaf	pud_large
 static inline int pud_large(pud_t pud)
 {
 	return (pud_val(pud) & (_PAGE_PSE | _PAGE_PRESENT)) ==
@@ -885,6 +888,7 @@ static inline int pud_bad(pud_t pud)
 	return (pud_flags(pud) & ~(_KERNPG_TABLE | _PAGE_USER)) != 0;
 }
 #else
+#define pud_leaf	pud_large
 static inline int pud_large(pud_t pud)
 {
 	return 0;
@@ -1233,6 +1237,7 @@ static inline bool pgdp_maps_userspace(void *__ptr)
 	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < PGD_KERNEL_START);
 }
 
+#define pgd_leaf	pgd_large
 static inline int pgd_large(pgd_t pgd) { return 0; }
 
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-- 
2.20.1

