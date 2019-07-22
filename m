Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FE4DC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEF472199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEF472199C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 816138E0009; Mon, 22 Jul 2019 11:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79BF78E0001; Mon, 22 Jul 2019 11:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54F8E8E0009; Mon, 22 Jul 2019 11:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 008C68E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so26548266eda.9
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j8DVKsa3geScdVXHlFrTdufGUqyaSXLPJxaAhWlrnjk=;
        b=S10Uxb8VC1J0LdAeQ6j+baosfPGJV2zdUKMGhuHfUHUoWJIX5pZSaCW7Dp6Pw64I7H
         3Yy+t5AfUsYtDHj0eOeDh9wPguEjSh6QNo+mrNb70NC6DsBPNnGWrpOtPR2Fpfow9FEi
         xnelcw8vwkk/IhjHr8x7/LpPgXazrIgJ6ZPtnt3SssrUvwrduR8KGG8oqj0ylosCmxNc
         P6bFvyqUxiSY4PdflJlarcbfPjpmy1k08znDbhXYL2mPZ7nE377PsqjGDvU9tGQdoGER
         5oOhSRUdyy2lgG2HYtad4LZWKjgDDAyhOCn5/B4Ge4YqTeL5x4oJXKP8SLKU052YoXWy
         rD6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUVOj5qF4l1JvqOMBkKNOd4wWejgPQdwBlxTyA729cbZ2uTZRmJ
	ta1oT6GCwm+1crkQuKQi/A7t4JoJrGsIDjN4lhyV4qXqq89nhncfRr3g0U1t37qa9IA9CGvb+HR
	hm9tI/DhXEvDop0WZ8b0kVKvLVIGiJcjCfRzAkPIYK6bt8hgmi3oRni5KOlSWB2uFWg==
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr52971967ejx.37.1563810166588;
        Mon, 22 Jul 2019 08:42:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/e6oP4oCcQRE5Bu1CdnME8uQQF2rYFrQ85DRSFHKyHKRIbGoBTKA5+Jpg1vmakNmOJ5hR
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr52971935ejx.37.1563810165837;
        Mon, 22 Jul 2019 08:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810165; cv=none;
        d=google.com; s=arc-20160816;
        b=gSiHCoHjx4DFd5GB2OcFZVTR5HtT6D12ew31GyqHxE8KZB42sP1uFYT1J3UphDImZL
         pMtPrjciS7Jq+PJL3GKEU3WpHityaSRH+1ol/u1sazUltf4jPU9S1G4lzXOGf5P/oMVN
         lCmLGuVNrcTCTptcR1BKMFC7SntgGGJmojBCCys3EEB6oGo5Pj/6FHEftMXp5WQStDFI
         DTOGAVJwlLDGfI36HMTGxf2NU2h+xgICM3bRg8P81Eb+F5wqbEFyabOerPx7az76c4hS
         ts4UN2hJeKuicN9/Ie17H/puHLDGKejeCTtSKvUPccXWIUzVk4KwK9ig0qMsVa62oPW+
         Zfiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=j8DVKsa3geScdVXHlFrTdufGUqyaSXLPJxaAhWlrnjk=;
        b=TPKRKqJsZ1sq3ReCz/FB53sWA5YQAFcWMHubucx8ZRU87HpSl73teIQpUdLKh/oVWi
         Sx0SE7NnvKLtpYlgRJeXeHmRJdOgw49NwiTTR/t4uoZvVnVdyqomo1lb8TkBsYu6gd7D
         +yzH2GG/cEm3YukzSNkmUMwi9YpKE31wGSYX5/ClMOUWmyW1cgEL21KXWVpDUxnRXR4M
         TNnfP1OIq3lW8SnodKNQinvSa6yZAvrxA9E4xoNZTt7TnR+0uByB14sipx/vnS7Hcp+w
         f8g03nHKRx29tCpW5pLyzKtphbxTZyFOy9eK83ij7XsQbb08t8klEVrvHp6mrDp7X5x1
         qi4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q29si4909429eda.83.2019.07.22.08.42.45
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0BDA01509;
	Mon, 22 Jul 2019 08:42:45 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 257E33F694;
	Mon, 22 Jul 2019 08:42:42 -0700 (PDT)
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
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
Subject: [PATCH v9 07/21] s390: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:56 +0100
Message-Id: <20190722154210.42799-8-steven.price@arm.com>
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

For s390, pud_large() and pmd_large() are already implemented as static
inline functions. Add a macro to provide the p?d_leaf names for the
generic code to use.

CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: linux-s390@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/s390/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 9b274fcaacb6..f99a5f546e5e 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -674,6 +674,7 @@ static inline int pud_none(pud_t pud)
 	return pud_val(pud) == _REGION3_ENTRY_EMPTY;
 }
 
+#define pud_leaf	pud_large
 static inline int pud_large(pud_t pud)
 {
 	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) != _REGION_ENTRY_TYPE_R3)
@@ -691,6 +692,7 @@ static inline unsigned long pud_pfn(pud_t pud)
 	return (pud_val(pud) & origin_mask) >> PAGE_SHIFT;
 }
 
+#define pmd_leaf	pmd_large
 static inline int pmd_large(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) != 0;
-- 
2.20.1

