Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C02C1C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EC7F2192C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EC7F2192C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A1CB6B000D; Thu, 21 Mar 2019 10:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2514E6B000E; Thu, 21 Mar 2019 10:20:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 142CB6B0010; Thu, 21 Mar 2019 10:20:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B33386B000D
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t4so2300433eds.1
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=UxiSczopN3UepZAddtjQxdlXzpDlGXg3u9owE1Rg0uW0SLdAaIVDdEFaub9Vi16No9
         vr844AkHb+mz9rStJQfmvqkP7R071l01KYoWSwvQs6jDZhZxlMhMW0FhryDxlnr6khSo
         fpHuF2s5Btsfdzru50Xcj3YPCGUU6S0FXkxgii2lyfeJvY/WPjfonOaO1miEHu4zycI0
         1o1EWdDJQxTYEJjRx5SSyLFJOLkKPm91boILXxlldYULKS8qaP1jfdJdmL4ZaObEfx1h
         fEZxTYH0iAwY/QbZduF18Tdr3tYPF/uQnrubP70DhgFCUzkjJFDw49Nj8vyy5Bc4zHD/
         4TPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUZCbEHpmtjIg+TPyQB8S8F9fm9Tc0IaffUJtGPS8MzP1hxuI61
	WeO21oHRq76HJ1syGDihJ6irCPn8KfDBvECd4qCI4pIAx3nAn6uh7M3XXDbj0fmDVKhIMRsXEfF
	Zv1EXp2D2lGPRfT+3J6Wvv0SpcbOOxR7pKkMcX7L/tDCKtcMEUqAjSmcozGy3Ejvx1Q==
X-Received: by 2002:a50:8ed1:: with SMTP id x17mr2627388edx.168.1553178019255;
        Thu, 21 Mar 2019 07:20:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXn0M2spWIw9+Bhyc3nvCYusy0dX8xyvrlN0Od1ogogG980QYivZWWMVI1TI/CI1GcFHto
X-Received: by 2002:a50:8ed1:: with SMTP id x17mr2627337edx.168.1553178018308;
        Thu, 21 Mar 2019 07:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178018; cv=none;
        d=google.com; s=arc-20160816;
        b=mn7spcl9ETJCcyfXJheSFP1Xn9VDA381xQUYTzRbCXrRqw7SXpPf3RwgJqbivCkDrA
         IQ08VK3ocZu34/hu4Loi9da4bGBr+XMsVsb3lj1UuVE0+yoQ/bIMPZlM7e7pfTnUJl/m
         vZUHeFsX2ML9m8ieqSy5GTx/SudqGODXdFok3WKtQpgYJggj2F0b/rCppZ74bZ04c0EY
         /02frRcowOnXxVZcdllaGv9iCWwPtC7OgoS4mk1Q3iSaisWSgFr2jjuNf/D2KcldOLrf
         HPWZhfPDEN6TBf7Wr5KCC2X2I4UGQGCdcT4haIPUjYoWhjpAl5qdxhxlTtA2gnxZmYIB
         jHiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=nq2ra2uMG8HOQgxX1m+XcIVBjRQ2ltP6Gji4DxtaKqYmAVTrWYiHq89N1mxxOytukn
         mSOrSaSgdcWlfBBkgbGuGavthKHckBfo5esVDbzJ5uflPEJ80gorwSg49nSvN+0Tr1Wc
         lGTZ4Q59w7nrXtprhHkA1r25S8WYM8eS7B299Zmi4j4fAh7TYGtoMU5wTjnkVKL69ASj
         UhywC72XbBkODHAjS2bXkXK7YhlsL4ZlWvBH8wCD99IDK9BKPYNNzUBFsSnMcKcAocMc
         qrFshmYCJz56G9puQUIDZnnbVjdC2FSDYGvg4MKFIAS0GG7bXLz702WrIuI1DXAtqvN9
         vzCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g24si125209eje.214.2019.03.21.07.20.18
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5957680D;
	Thu, 21 Mar 2019 07:20:17 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 84C153F575;
	Thu, 21 Mar 2019 07:20:13 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH v5 03/19] mips: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:37 +0000
Message-Id: <20190321141953.31960-4-steven.price@arm.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For mips, we only support large pages on 64 bit.

For 64 bit if _PAGE_HUGE is defined we can simply look for it. When not
defined we can be confident that there are no large pages in existence
and fall back on the generic implementation (added in a later patch)
which returns 0.

CC: Ralf Baechle <ralf@linux-mips.org>
CC: Paul Burton <paul.burton@mips.com>
CC: James Hogan <jhogan@kernel.org>
CC: linux-mips@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/include/asm/pgtable-64.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index 93a9dce31f25..42162877ac62 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -273,6 +273,10 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_val(pmd) != (unsigned long) invalid_pte_table;
 }
 
+#ifdef _PAGE_HUGE
+#define pmd_large(pmd)	((pmd_val(pmd) & _PAGE_HUGE) != 0)
+#endif
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	pmd_val(*pmdp) = ((unsigned long) invalid_pte_table);
@@ -297,6 +301,10 @@ static inline int pud_present(pud_t pud)
 	return pud_val(pud) != (unsigned long) invalid_pmd_table;
 }
 
+#ifdef _PAGE_HUGE
+#define pud_large(pud)	((pud_val(pud) & _PAGE_HUGE) != 0)
+#endif
+
 static inline void pud_clear(pud_t *pudp)
 {
 	pud_val(*pudp) = ((unsigned long) invalid_pmd_table);
-- 
2.20.1

