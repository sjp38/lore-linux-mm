Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F24C3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9CC421924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9CC421924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D0FA8E0005; Fri, 15 Feb 2019 12:03:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A7668E0001; Fri, 15 Feb 2019 12:03:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 495BF8E0005; Fri, 15 Feb 2019 12:03:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E60158E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:14 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so4185309edd.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fNP6+ygM8w6cTGyyHjAGfLv0kdsZRzrguRwibVqIzvI=;
        b=V/WHxIkEpBrkkZwX5+2aKy38r2fFkgj8OLVliUZJAPtsWHf7wEgh6gF9voTW3IPBq6
         BcPSuyO98rikD5Ot17q5oR+qveEzLQ6phdMpsTqI56/EbsmThDxulMepDB/98uePc8JS
         XbAg048wUf5Rx2Wj2eWFuM7rjZARyRGXloAfh8c4GWTmz+RpTly2C/ZJdmfMy8xTzreq
         eWMf2rbNUQlDZQTk2w6jN4pg3HjbczqwtQJIsYjayu6d2Fh7f9TyKeOe8RLlSUF0a/MB
         tTcstaHjWy1gzIyxAUTBLpDRQM+SDjFY7fJQNH/i3UWWm2IT2Y2qNEDgeTNJnkuGrrGB
         RPmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZAR6slaci40VXP1zfvZ8kTqE+ZygS4PpaW6zxfbRvb3kZEPp5H
	VP9Hq+zZ7rJqq00Ra5omozttek8CG9J4uKdF6YZ5rDx9z+wFHmxUbLJyTZd946brokssAw0/BN8
	LOJBg7pp+BTizLls6KtmZKcQD7lDLYwC2URySvVrb+BKz4lvJjRuGprcJPONNyayD5g==
X-Received: by 2002:a05:6402:1852:: with SMTP id v18mr8066718edy.198.1550250194397;
        Fri, 15 Feb 2019 09:03:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZmjLGoOBwlpqMIRKma1V65qGE1y8TUWImYVDQsQl4ImytotuXktEtPEE/rwnV3imLr6v+S
X-Received: by 2002:a05:6402:1852:: with SMTP id v18mr8066648edy.198.1550250193267;
        Fri, 15 Feb 2019 09:03:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250193; cv=none;
        d=google.com; s=arc-20160816;
        b=yhTsqUV/0lbwximTWNeU8zFyJXY0CgusjQIs6jmZ2CsyGo1J5a7v/TgYuvAqPUdTGh
         Q9Peg7Pbr2r+xCehqjCttjKnLOipK6exNl77pIEq8wQDrPiKyZBlzuS/PpVP5KPxCxlr
         2PMTslR7uU/IJ4urL0c+rJBb0/fbwsxB4z9i+d22K0ytSj60/qLPOEI+I959NSDMey0j
         cchxoY+we3xIVdt1rFIAq77mrL8h52bHbMhkh2z1hvJmERBBZ88VyHOWvlY0n9iA4zDJ
         78iWyaYMCtdzPOlxKlkK+j2UxTQ/2zzGl7JnlUfVRxaVRC/q4WxJTn78iLBmdshmjtYm
         BNRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=fNP6+ygM8w6cTGyyHjAGfLv0kdsZRzrguRwibVqIzvI=;
        b=ITTyltyn92ImRqfwrBZRqVfXo3bTzrTBKIbf7ZY7IOFIv+yKI5eXnEG3C3qg5kspkr
         JZqZsPCjf3JG0ISL8OwevEA9NS3aXh9t6z3wml0SIvVWdfanWf9+rxY7buOxyGllPy1y
         0CoPoBaYN44AzRC0ZOgGfcoJULPlE07x887GguZROpu2P5xLfqT1YnK+iJtFcv+h6+Ds
         kFqNEeU5eLOi50ybuZWhmMzeM6sF8V0uYCJEmLMnO0Iei1z8MBeZvgl8G3H5wA4VYCrL
         25CLm5aNRtmLYED7afTeRfRSd6W/2RpQke0RTnSdxCU79+muIdUm006Um9o/4CRn75GS
         KVRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m19si215869ejz.322.2019.02.15.09.03.12
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:13 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3E46015BF;
	Fri, 15 Feb 2019 09:03:12 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4A48D3F557;
	Fri, 15 Feb 2019 09:03:09 -0800 (PST)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 02/13] x86/mm: Add p?d_large() definitions
Date: Fri, 15 Feb 2019 17:02:23 +0000
Message-Id: <20190215170235.23360-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215170235.23360-1-steven.price@arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
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
 arch/x86/mm/dump_pagetables.c  | 2 ++
 2 files changed, 5 insertions(+)

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
index e3cdc85ce5b6..695647dc9cb9 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -432,6 +432,7 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 
 #else
 #define walk_pmd_level(m,s,a,e,p) walk_pte_level(m,s,__pmd(pud_val(a)),e,p)
+#undef pud_large
 #define pud_large(a) pmd_large(__pmd(pud_val(a)))
 #define pud_none(a)  pmd_none(__pmd(pud_val(a)))
 #endif
@@ -503,6 +504,7 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	}
 }
 
+#undef pgd_large
 #define pgd_large(a) (pgtable_l5_enabled() ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
 #define pgd_none(a)  (pgtable_l5_enabled() ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
 
-- 
2.20.1

