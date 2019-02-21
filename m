Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25EEBC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE1D32086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE1D32086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792068E0073; Thu, 21 Feb 2019 06:35:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73DFF8E0002; Thu, 21 Feb 2019 06:35:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E11A8E0073; Thu, 21 Feb 2019 06:35:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEFCA8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:21 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so11459788edd.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MCQE4kh5SXgiU/bXz8lLVd48nfz6SGnOiJwrDNu6rZg=;
        b=sJZhZlJnOUrbreV4AQIethBwT1PJ1EIIi3j2Du7ENcGNcK9t42zJ7sjBBIFlfwULiq
         X+P/IxzKgD7BCseYU21B4Kjf8sMed3YKcSkwy8tEKLDCef6SOQ3sOyF14jJmMuDo110n
         sIi35B+FRjDSlaPbqtspD3Tq54v8orMGSDwqu3BhwTX++q+qskDxKzKx9DzBiocU6JNq
         av41yaGomd9oeEkIMc8OYpL5Ap9aZqdvchjTgFF4muAv661stEvQcno2YqpHCT1Fow63
         9HOp2zOQgPsvWi7cpS1rzl3msHSc+fMVlItUfFoVQ2xEAgtOwXjKouAApQ7bTGatGrtH
         PVPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubYAF0YxEc/LhXeEb5pJviSDvXwy47+RKiZkw4VnmOpEW7F8ERv
	x8xUloePna1eD796rwwc4svzynmNBWXgMNmwRR3lKHb2vtmrNyC+/W47Wo58lGCLlqsjIZMmb+F
	aDElwrps7mf3Rz/+6s6Dw5dgnKsgM2yHfSf8rTgqoln+YoAJEOkIL2kD8oXelf+ywvA==
X-Received: by 2002:a50:b1cd:: with SMTP id n13mr11738784edd.224.1550748921419;
        Thu, 21 Feb 2019 03:35:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaeYtmWbiY5Z5CwZi8HfputQzQO1snHvttuWPu0Z+QTUr+uchwP39gOtCfrlSn7k01StoCn
X-Received: by 2002:a50:b1cd:: with SMTP id n13mr11738722edd.224.1550748920401;
        Thu, 21 Feb 2019 03:35:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748920; cv=none;
        d=google.com; s=arc-20160816;
        b=KaWbUvj9kbBvjb1jWHlkC0qcXxP0XxWdKFzeZmZIwHffdC8MtFDOU/UxnM2JZ28UDb
         Gu+rAooAASqoHGVXizJtz31TFBvyT7QXVneNiNtQg0KPlKrNja7Om37Uvg77K73L92Qg
         rrTXtx/yhHoWH8ZD3TLfI2hz3XRsG7TS7begvTk1sXmYZsbUI9Tr2RiRB1WkTIdQ3Jq3
         48QSyzc1wRmsPBWIKJdSs2pVmMslfBi6UpkCpwIvd6OjTXh4fj3jfeFn1BOKLAaYHyzP
         kM2jEB+TNR3kuXm7tnuBbCjsqFRxMpYQdiq3v2YIGkY5zgOAAVNplWrdkjILPgPSyfU7
         q8rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MCQE4kh5SXgiU/bXz8lLVd48nfz6SGnOiJwrDNu6rZg=;
        b=aFcdFDIowHAAp8q6OAHfgYF9vD1vPhRD+ccMndf3LzO0bSQVEVV0uI1cdeJUBf5QMV
         pYa1p5JGxWoYEvZVYuA6iHyRp6S/jrRymZuVEgKo+zrstz/GXen1JNZEESpxBho6xobu
         wWzZI9Zwi8q7kpXyqSxdKegAt/hGN9gSRNTeibafAEuLN9v9RlD1skaQsCJVM5nogAw4
         782r4Umc+IGqmyp6HwNpt0YoQLZXM4ca+L2po8wRbyAy7N9cGHFQR1kJQ2oo09PC3Srf
         Z5ed1PJxEt+iNR1LjPjCtSchm2LXE5QSSZBbXI6VeKrWJr+W2gVQdnoYy2soyEK+OWak
         xo2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k20si773696ede.343.2019.02.21.03.35.20
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:20 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 64CE215AB;
	Thu, 21 Feb 2019 03:35:19 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D93133F5C1;
	Thu, 21 Feb 2019 03:35:15 -0800 (PST)
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
Subject: [PATCH v2 01/13] arm64: mm: Add p?d_large() definitions
Date: Thu, 21 Feb 2019 11:34:50 +0000
Message-Id: <20190221113502.54153-2-steven.price@arm.com>
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

From: James Morse <james.morse@arm.com>

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

Expose p?d_large() from each architecture to detect these large mappings.

arm64 already has these macros defined, but with a different name.
p?d_large() is used by s390, sparc and x86. Only arm/arm64 use p?d_sect().
Add a macro to allow both names.

Signed-off-by: James Morse <james.morse@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index de70c1eabf33..09d308921625 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(x)		pmd_sect(x)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 #else
 #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
 				 PUD_TYPE_SECT)
+#define pud_large(x)		pud_sect(x)
 #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
 				 PUD_TYPE_TABLE)
 #endif
-- 
2.20.1

