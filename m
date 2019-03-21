Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61E21C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B4BA218FF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B4BA218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8E666B026B; Thu, 21 Mar 2019 10:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE8936B026C; Thu, 21 Mar 2019 10:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD86C6B026D; Thu, 21 Mar 2019 10:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD446B026B
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t4so2300942eds.1
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=FY0+XuOJmiLwjxPn8lX3I8K+0uflS/d+IvJXkxvnjMKtTOz8LS+S+cTM9/i87ryrWp
         70p0uXsQENULWzPc4cAH0KrTnRsByeNXeN8Sg8JeKVPVY2w7rDXzV7VasW2jX86Y8d/1
         kqb7gehgIyJ0/kK6m9dpP/TZAWTRUHn94NlYL/ulHSPKXI28PRKPr4kg9RZvNFGURd34
         iRnc+Jmd1XaCDGtpmQ8V0qtgwC4hdWQCvQXziv8SjagBkot5n0JQDXzZrJgfeyCZwtIB
         +zckrREuLrg2+BldzAiwUohhAb2+NaLaLqrffthc6vnCPXAHuhQCs8gjLAQD9ExzGAVb
         O8YQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXY1e3tNtfDdV//zvACNW3z37cPHqjcQN1ky6jnuawCALCIGPBi
	YVv+i+qP6eui/zO2Kx+ylvtsBrsSsRnCcvGAtsmgBNMtcgE7rpD3dbrJWcCC1Sq7j8w3lObj483
	BKuNkgA+f6agm00d9sg1ow0+IyCwVzq42KMiPMydHOdbyrljQtWbkwMMd4DNh8VW31w==
X-Received: by 2002:a50:976d:: with SMTP id d42mr2650833edb.5.1553178042047;
        Thu, 21 Mar 2019 07:20:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDpTaKxml7LL0sNo3mje4/WTwT2TAKlfZo7vhANcsYZPZRbc3xFlwyackY5Ts6hK6OKngq
X-Received: by 2002:a50:976d:: with SMTP id d42mr2650785edb.5.1553178041110;
        Thu, 21 Mar 2019 07:20:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178041; cv=none;
        d=google.com; s=arc-20160816;
        b=cuApSO61b/X3GR07tQZ8cQiv4+f3qZC88Qilzy5Hbu0c1LAWsGvhr8MnBYyAIbbdzN
         HAIWqvXvf1nV4ApcW9aFjPdT0mZBuXQ7g0XTC3yIQCoos/n/t3N8xyKFVsIQ6vlzmDlk
         90xPVLrUD2x5q/+8MTDtHDmEmnupjymO4iTyuSACtHUcUkSqCWxHF+0uK3UIfOXIlbWb
         Xv6kE39dKNEC7ZyqQMI5IOuStkJJlZTPOkYvclQ8rkhrL3TrNWHi4TfOiuyzwtqI0PqQ
         NJZfI787d/O4jk6jIvxkdr8uvYaYZCqW+hUPiNnJmTFxTgkVLk81dtSIEMhtbDddZFRz
         vZjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=N/Njm9xrIhlG21t1+SUm4nqCnIKZh8kLRylNj5rldjkx1Le9NONPb+nnS75OMoeQ0W
         Qq90FrMiEvlVfpOEbV9Xoa2HCnvxfq1lJ/M5F2hsJh4591npMhh+goiNlzTNap+nsR5o
         Ft2DW0Ty0S1WMiPY5vAuTgi9NUt0W4slNK0LjNJcnG5h4xG3bV21iCnA78+qB/I8wZhl
         uldlvi8WObv0JaefLTRGIZdYZw2voNPYufCE8pjOD+XaLlTZY4H6bydQ6SuVoEHmLo+n
         VA4Uh1mYKD7ZX5TfJDdJ1ELTArytj6CHITN6CsNRAlTJLyBfRv4EtC5go5PkfA0OnvEn
         IG0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q1si952057ejs.275.2019.03.21.07.20.40
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 45337168F;
	Thu, 21 Mar 2019 07:20:40 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0A8C33F575;
	Thu, 21 Mar 2019 07:20:36 -0700 (PDT)
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
Subject: [PATCH v5 09/19] mm: Add generic p?d_large() macros
Date: Thu, 21 Mar 2019 14:19:43 +0000
Message-Id: <20190321141953.31960-10-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
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

For architectures that don't provide p?d_large() macros, provide generic
does nothing defaults.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/asm-generic/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fa782fba51ee..9c5d0f73db67 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1186,4 +1186,23 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+/*
+ * p?d_large() - true if this entry is a final mapping to a physical address.
+ * This differs from p?d_huge() by the fact that they are always available (if
+ * the architecture supports large pages at the appropriate level) even
+ * if CONFIG_HUGETLB_PAGE is not defined.
+ */
+#ifndef pgd_large
+#define pgd_large(x)	0
+#endif
+#ifndef p4d_large
+#define p4d_large(x)	0
+#endif
+#ifndef pud_large
+#define pud_large(x)	0
+#endif
+#ifndef pmd_large
+#define pmd_large(x)	0
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.20.1

