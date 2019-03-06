Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 077A0C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAFFB206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAFFB206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B75C38E0009; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4DBF8E0002; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1B4B8E000B; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39F698E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f2so6456789edm.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FbmI8H/LDLwwCfkSNCFyqL30B69VDCB+cT3TXJ207I8=;
        b=GXbTa+mmmNXYgx5uWqFJp1I7/QxjSXeF5ray8lLSHSoZWWKKUsMpUBI6UyxpPuOGTF
         DVGLx2ka13H1RB9yr+i5PpDjVOKedQfQdwsD4xLOnppmcebPzzixFwTasjRRkz4/MwLC
         linpcvwyxqiVdPSDYrUzb9Kde/jEJ2B7E5zQwNklnTUeNVp2Vi9TA+6MSavsHvvUPuU3
         QpCaXzxpvMnyi/vzio3n7D2nTGyNIt8BGTH1f07l62EhP7BUUenjTl8dHWBerNRnzIv7
         BFAAcHL23kOzKMeL6wO0ehasm0r59VpaD3ICRzuEO2qKqXTQRn4rNsMtgUWghRbw8V1W
         RRlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUewThDso6FNnSrRbm8qoEkifjjxCK+IcN9+MkV7zU1vk9kB5LI
	dE+FAPPsW1UgCfnzZUEiZGeLEIKHKwOIVhOBWE0fmov3ux2ZOxph+XIwBJ9bAFLvrxhY1Mh/tFl
	bx1tpFI/FIMfSKvNOuFUhmP6mPX+pBQ1ijhn09FVl8uvdhWKJP5tmekji5/a7qLkFQA==
X-Received: by 2002:aa7:db14:: with SMTP id t20mr23906858eds.231.1551887471484;
        Wed, 06 Mar 2019 07:51:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqyiLtwa3olOJ27DEGKDs6T7LVT6+cB+sjWA7jwyhywQw1Pdpd1V11kTxju87e++LNTBbZ5w
X-Received: by 2002:aa7:db14:: with SMTP id t20mr23906777eds.231.1551887470269;
        Wed, 06 Mar 2019 07:51:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887470; cv=none;
        d=google.com; s=arc-20160816;
        b=kxH83nkLKX4XrwqQSijdpyJ33ILWLdzm5RxLgCG6ih9D20NlFpHXpbkOOr5BnHsZxB
         5nwQZTxDAarsrnEFDWFwWR0dAFL0RTTikkKO+NMdHk/yd6XO8bTM/kYCYJaYWqEX2/ho
         ozHyXgq57vq4yVDCJkAjxFeTxWJCq/Ecr0jZuSTiAT7A8zwyt2sYz3QDnb5nqgGbZKME
         ojWfw6iEBmN32+RdW+Dm+72nWmzEI2ZKCd5wD9jfdENglEEHuceuulfIqVDj8Bb1/5qV
         2vvHCM4Q/WZvdcrtzhQZz1X33ztNPLCk82tmkm5JUF7m+Np29jwoUnnl7aeNc9DURUKE
         DiSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=FbmI8H/LDLwwCfkSNCFyqL30B69VDCB+cT3TXJ207I8=;
        b=E7OG9sAPcnCOOPAubxLzZh7m6jAKPTtIzqAZu6/04CRrMrLJOVkZxJnWUXFIeHkR4w
         PXWWmjOisRz2dIZaRw9soim4enedheSLcsfA2XVwxeRe07PXCg3d/q6xBnzqTUmf9IeS
         i7LLx5BtY4fF/ppZy0O/L84K84RINPq1oKea+SXRojaEG/PuxBJDpgczgIACBFhaCG3J
         TqdKeyf0/VJsCuqm/4X3cYl76m0Hc2aAxVpqKIeEgKRXnAlk32+boSSRIunKrNAhMGIL
         C1x5qoB0BF/q28QgwVsbXErqX1CKPSXi8BRqtraPWltpmUK5dy4YX0tG+4G53xKgq4Rv
         mvww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 22si767445edu.228.2019.03.06.07.51.09
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:10 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4631D80D;
	Wed,  6 Mar 2019 07:51:09 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 94F673F703;
	Wed,  6 Mar 2019 07:51:05 -0800 (PST)
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
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
Subject: [PATCH v4 06/19] s390: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:18 +0000
Message-Id: <20190306155031.4291-7-steven.price@arm.com>
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

For s390, pud_large() and pmd_large() are already implemented as static
inline functions. Add a #define so we don't pick up the generic version
introduced in a later patch.

CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: linux-s390@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/s390/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 063732414dfb..1f188004ba95 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -679,6 +679,7 @@ static inline int pud_none(pud_t pud)
 	return pud_val(pud) == _REGION3_ENTRY_EMPTY;
 }
 
+#define pud_large	pud_large
 static inline int pud_large(pud_t pud)
 {
 	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) != _REGION_ENTRY_TYPE_R3)
@@ -696,6 +697,7 @@ static inline unsigned long pud_pfn(pud_t pud)
 	return (pud_val(pud) & origin_mask) >> PAGE_SHIFT;
 }
 
+#define pmd_large	pmd_large
 static inline int pmd_large(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) != 0;
-- 
2.20.1

