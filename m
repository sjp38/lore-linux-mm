Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D7DC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDE882086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDE882086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F4398E0074; Thu, 21 Feb 2019 06:35:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A1A78E0002; Thu, 21 Feb 2019 06:35:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56E828E0074; Thu, 21 Feb 2019 06:35:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E8B768E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:25 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v1so3443060eds.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mPd1aoVGFQvbKXoXf93LahtlYNZ3Q5UYsU8YHKpiyp0=;
        b=V17RdcwvgnCgU5AGjaQI3yiD2bgJ+jFcGgaUFGSa+svYtK8T0U+RBFFx97pxKYRiT6
         iRbl+AskqApeSMmARe1lOiNGCQnRfujTg4m5R12Rv9krMivG300N7TwXIkpnPl/hiJPv
         5DLXW0/qJP/2bw2o4CnjDl155ndtMnGF4bbVWONyHgVXtY8gAsrrrUU/x1cFiSZt8oNp
         G+TVnJ9bWDJyIDsZ5VVxVgR3H9fu1ydWIbBmKy2phKh5dxfoH7voICJOVBS/ne1JPj+K
         cTutnrgrpSqmg1rXQ26L/08M/MGm+Kk5taOw16cQup7HMaTvb6ojw05kuox6+/a4KnVV
         928Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubGluXOM+XNtP2YJQbMOZogfeejhEMF/Gt6r60KAzMaHKMUI91k
	TDbWHbfuaKcbhF8A0wttrv/F1mVw5VdMnRd9tUDtJEKvF8IUU6O1zKIo88QuUDz1SCU/++Ys35O
	641GwDP17QtlXb92uJbjep5HGNJEbnNJpDBIHP7VkMpFYoKWYnO2jvZDhwab0gIwpkA==
X-Received: by 2002:a50:b0e5:: with SMTP id j92mr29280626edd.188.1550748925419;
        Thu, 21 Feb 2019 03:35:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaICk3bSKyZyj71ozG2lDuZqKMBL1NKsv1OIle/XYsBu/pDSys183Ht2zOVnh6BmSD0XoOu
X-Received: by 2002:a50:b0e5:: with SMTP id j92mr29280571edd.188.1550748924337;
        Thu, 21 Feb 2019 03:35:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748924; cv=none;
        d=google.com; s=arc-20160816;
        b=d2hkCWyQpmW8m8yuX7aOQ6FSzpWyAQ88Tqc2V9cXrX3aeAsbhjaQaamUetv8h8rJP0
         kPIfkrHdEgzB0quMF7ektbzwfJz8DFNvNqHw0K06qPj9jMn/WIz1NR51oMpCgkf0Cplo
         kdTZ1BX9XAOdvroule4vuvkOY1AnbRoqdF6wloP2kQLXxmvExrsEvUG+EKDXPc9jEYzl
         k8S9cd1CJ2ETxzUlFK1k8V8G/IECxSqxV0qBjIUXEsH+rT9EmlHVJk/CNQBmMaxaxcV+
         5kitG4M5hiWh1pQWCOu0LCj3jsEF5UoKvnLoVWpWJogU0ixNpq/vk6ntcCirQZiSf9TC
         89gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=mPd1aoVGFQvbKXoXf93LahtlYNZ3Q5UYsU8YHKpiyp0=;
        b=GDCV+6Q+XIiE/OZMEjoq8jCZdlT0mM/Pll+Y2eU/peEHIpejqg+gIOXncvV8V8A/j0
         xsIB9XqCtaiV6rcUrJlel7BEUIUeswph4FnGeptzC4EoZx6SnDPk1pjqDbCqq5eUJNad
         y33eEn27MLlytp93iJ6QLWgPB+H9bMgJOCctbYzQPZSlYTQq5BaiGY5nFiS5lcZDH/r4
         bfYOSMAbSz61z+B/ClN8ln15IhcuS43EAaO8ThYEa81hlDxyIQGxLhLlmfoQSqhdQAoP
         44PupypLtUORBEpdPt7dADfsX+e0TUXtSFkaeZp+XmVUM2XRE2mpORTDzsjOpKOUsPAZ
         fTMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b16-v6si1782945ejp.242.2019.02.21.03.35.23
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:24 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 33748165C;
	Thu, 21 Feb 2019 03:35:23 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A693F3F5C1;
	Thu, 21 Feb 2019 03:35:19 -0800 (PST)
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
Subject: [PATCH v2 02/13] x86/mm: Add p?d_large() definitions
Date: Thu, 21 Feb 2019 11:34:51 +0000
Message-Id: <20190221113502.54153-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190221113502.54153-1-steven.price@arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

Expose p?d_large() from each architecture to detect these large mappings.

x86 already has these defined as inline functions, add a macro of the
same name so we don't end up with the generic version too.

Signed-off-by: James Morse <james.morse@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 3 +++
 arch/x86/mm/dump_pagetables.c  | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2779ace16d23..3695f6acb6af 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -234,6 +234,7 @@ static inline int pmd_large(pmd_t pte)
 {
 	return pmd_flags(pte) & _PAGE_PSE;
 }
+#define pmd_large(x)	pmd_large(x)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_trans_huge(pmd_t pmd)
@@ -873,6 +874,7 @@ static inline int pud_large(pud_t pud)
 	return 0;
 }
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
+#define pud_large(x)	pud_large(x)
 
 static inline unsigned long pud_index(unsigned long address)
 {
@@ -1214,6 +1216,7 @@ static inline bool pgdp_maps_userspace(void *__ptr)
 }
 
 static inline int pgd_large(pgd_t pgd) { return 0; }
+#define pgd_large(x)	pgd_large(x)
 
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 /*
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

