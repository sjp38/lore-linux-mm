Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19330C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD0AA214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD0AA214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 810358E0019; Wed, 31 Jul 2019 11:46:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EA3B8E0003; Wed, 31 Jul 2019 11:46:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D7F38E0019; Wed, 31 Jul 2019 11:46:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2146A8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so42690436eda.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9yNPMoYJcGoxoxeHWzB9fU8wwaC0bR8nBAs+Hiw9CLE=;
        b=jQU3/zT7RbPE2sKg/Hk5R/ZwK6tcGDADomUOlL0+ytMrkuIA8zO0rubNMPrR/uB1UA
         sE9XK4nTVaEEXJQMjOSnW/szS4geMVB7EgH80x73VW7UHA6uhazPNyYHXviA0EiqOO8s
         Cos9iedCiWtjuUU2ECPC0L8RpcveeRqmRYlSbZJUuexShCn9LR5Fx6Pvh4UC7/mcMmkf
         4S2Wy9zmk/CGhKz6wglSWTIJ24RFpLomxCHMBjLDqvNseKbfvmerJmi5P4W86wF592Nx
         ZBmUWS4hVlb1VvJLn/dFuhL+ohkbPBQg0S3i/bVmxal43A0ZY6vbRBDlt4fN5WZQlAnX
         PblQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUVIW4Ck0YLF8fyz+0YrwEKUlluD9NDjaz29N0Sw8iruijqV8bJ
	pG15/WAZxWV5ZybHe+zQ9vUFSw+iko41ALASDEtVv88nx2SqbfWWeulgZg2MAoct5RSXjPzN9ef
	78SoVIYtKAmA7T0heT/mc+7XgXmLuQ2rrr0wdAVNeKWY/V6PbAbFev/xI6pS/zjwGeQ==
X-Received: by 2002:a17:906:2ecc:: with SMTP id s12mr43274727eji.110.1564588000720;
        Wed, 31 Jul 2019 08:46:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1YGFCB+M/ZBi9US5g06ZBRz7ICqwoxVgL06JiR9hO2qM8wNToRgBceZdQgkJ/0FRCG2do
X-Received: by 2002:a17:906:2ecc:: with SMTP id s12mr43274677eji.110.1564587999879;
        Wed, 31 Jul 2019 08:46:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587999; cv=none;
        d=google.com; s=arc-20160816;
        b=PKbwIg6VpC1UHBYVdhSl5gcbY81NV7Cr7KFQgx9crkf9dGqmqx9vdKogtGh8vmGzMd
         t8zTjvdxTq5UQMRaPLEgunaSmWpry4xxzNizUasisyPHhvVCz8B3eLqzcS2SjEUlmR0g
         ZqDlX7It4ornsXjkar+7pklg9CDIperUGhkucKP+UZSKvqiCOn4aiVh/fjnfgNVlRiJ9
         CGhKcLy+vvgi8t3yXjwtiqPbKRAtu6IiSedSy53s2z1YvzWu15vZ3901qtX/z2gszeZV
         90bzgWb3Og3kqI/nn6evKnaT1oVye7nyjO8eTnAeqDrT6xyw0kBRXxIui87bKBaqeoqb
         a2mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9yNPMoYJcGoxoxeHWzB9fU8wwaC0bR8nBAs+Hiw9CLE=;
        b=M0byZ7v4xI3vIMsPZIVCL+C/DypS51dSc5X4Zr4GbRmdvsx+832KyI/Xhl7/0+kuD2
         Z3330CrrvoJZeFwDnAuZLrIK3sm98hXw8VUmTgfnfK7AulssL2BoceApz/5d/0xWTYyW
         WH6fZhwYZosrt6Es+cndsboS4CkMjkfppzDYH+EPfKTgZVvgv9mV8lMVZuBXdgCAvfOL
         YIQME8iAnysFsuhuvqHZ1mzgvND99ubl3l1IvuhWlknjMAL2dRdI2ciN5/R70zcA1p6x
         u/dTKkufGDwhVWuYqJ75F4mx2aOF+W/MvuvyXv7rHjQ9ou/rJ/t6Y66/HjDSmmnE+Jgn
         J5ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y11si18696076ejp.213.2019.07.31.08.46.39
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 267971576;
	Wed, 31 Jul 2019 08:46:39 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 59AAA3F694;
	Wed, 31 Jul 2019 08:46:36 -0700 (PDT)
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
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org
Subject: [PATCH v10 09/22] sparc: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:50 +0100
Message-Id: <20190731154603.41797-10-steven.price@arm.com>
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

For sparc 64 bit, pmd_large() and pud_large() are already provided, so
add macros to provide the p?d_leaf names required by the generic code.

CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/sparc/include/asm/pgtable_64.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1599de730532..a78b968ae3fa 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -683,6 +683,7 @@ static inline unsigned long pte_special(pte_t pte)
 	return pte_val(pte) & _PAGE_SPECIAL;
 }
 
+#define pmd_leaf	pmd_large
 static inline unsigned long pmd_large(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
@@ -867,6 +868,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 /* only used by the stubbed out hugetlb gup code, should never be called */
 #define pgd_page(pgd)			NULL
 
+#define pud_leaf	pud_large
 static inline unsigned long pud_large(pud_t pud)
 {
 	pte_t pte = __pte(pud_val(pud));
-- 
2.20.1

