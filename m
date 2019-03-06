Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 970B6C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5721A20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5721A20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8D098E000F; Wed,  6 Mar 2019 10:51:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3CCF8E0002; Wed,  6 Mar 2019 10:51:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93D278E000F; Wed,  6 Mar 2019 10:51:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3ADA98E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o27so6570854edc.14
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qsXQmPprpxmuBeYVH9lG+Xt4hLaFoJ/AyXxwtZbC41E=;
        b=gCZ3elKmVHBaOgncHgUg3wRaG9actA6Wxtflx+Zq7ba6YRdq/oMZL+AdfwnldN00T6
         ybrw2H3v89+x/TBS534QrBOhFtxmVqaD4RdPsmjNynz+5tJ3+VCXzl6m1m/i+ohSIRYn
         v0kcB8QRmG7N+NOQOXne9Tfo0adkkImrXYmkHNR141qRtghRnOyKa3JtdOfw8qs65lO1
         ngSEhmwDm/PaNz1jBgGQ+yrFndfZvXe+P1i81Jr8z0P+EugZ8Gl4WKtUELV06JJddSVO
         HKk4NfRsTCeHQSBc0v6yJJESKGqz3kxGLYvuGXhqFTuv4lw3CGgvg8M3aps6nCvNuU52
         ta7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXqX03qSUrGVapBMz4l5Byi2j/3GherISSLFkCQE0xvG26F2x7c
	lzC4eVlynMkkvdtUFVj9XgEGDEnRAnV/3zK5bi2cy0BRdor9b6FIsnXn4yRKcnxllvx0qRc7QpR
	+YVVlzkfOf+OTnN7UNWSbZp2VWr9Sjtl2LjtkrwMSXcN4FMAQIm+D3N07yP+4K9GM3g==
X-Received: by 2002:a17:906:4692:: with SMTP id a18mr4389774ejr.96.1551887482425;
        Wed, 06 Mar 2019 07:51:22 -0800 (PST)
X-Google-Smtp-Source: APXvYqz0nT49JRCWl9XjczbWHdABBwsVlciQN7J+8OidGwkgFvdTlfH6J2lMukaKy2rJ+x3813IJ
X-Received: by 2002:a17:906:4692:: with SMTP id a18mr4389695ejr.96.1551887480971;
        Wed, 06 Mar 2019 07:51:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887480; cv=none;
        d=google.com; s=arc-20160816;
        b=y1P1YVE88/FEriFubiRWgMLq/yWxQEv/w6KaSX9Xc16fVRTfcy1FMp78HmdhBahoVE
         cN1Y6K8oRsGGvQM14IRF7B4ubtFTnLctfUsivt6Xj2VAY0JY1wmMjJgx6Lzl9YwbRpSz
         bpf61EdDOHO7pkfiHMnZgBE71JAS2sSvhP3WyhvgJo8mCVl2MiZIFbzg4HF2pGkPzQkc
         jSXRHr8hYjW9c5zSmcw3vmq3ccDqy111yMHIhhZWJzptvg19ioM45ts6o/4ZCYguCkaD
         H1t3/kSSED1FZcuIrrNy78/v4qBFgueO9l9ut+XmHJ9Xhb4npSRaL41TKGg9Va6acFNH
         RcwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qsXQmPprpxmuBeYVH9lG+Xt4hLaFoJ/AyXxwtZbC41E=;
        b=FwhorZYKGBBdtVTRoiPZO9/DuideTzJNZ8qdWxj+38Xt3RKPPzy0nVnvS38VsXicOD
         0sRKSi/AoivMMcUle2H2uvEqfJe6/rzj0fLIif+0xpjJr2+sok+fuxxQdEq82rkAKYlu
         BcvOZPW8g6Z7Sd+gcxY3mgY69Hh/iwaL3X5Ch7Sslr4p52phtGakOIwGdt89Y2EU2N2Y
         lU8+aeSoO8k5hVygH5JZ/1Kht307y/6BaskeMXF/jcQOvcWBQ7baK7DyeZaxbCp8HMK/
         4r+ZaZ+ryZ4T0vyAFedJeP6aY00tLIlcM5BJ8mDDMMrFC6VlYEhlPhsWSc8lE4yM++xw
         hGgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m15si781444edm.144.2019.03.06.07.51.20
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:20 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 15C1B165C;
	Wed,  6 Mar 2019 07:51:20 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CF1BD3F703;
	Wed,  6 Mar 2019 07:51:16 -0800 (PST)
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
Subject: [PATCH v4 09/19] mm: Add generic p?d_large() macros
Date: Wed,  6 Mar 2019 15:50:21 +0000
Message-Id: <20190306155031.4291-10-steven.price@arm.com>
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
index 05e61e6c843f..f0de24100ac6 100644
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

