Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 385C5C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0352620842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0352620842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6D1A8E0007; Wed, 27 Feb 2019 12:06:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1A918E0001; Wed, 27 Feb 2019 12:06:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E30C8E0007; Wed, 27 Feb 2019 12:06:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 364D98E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k21so4249773eds.19
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Y7UWc/BL+I5JF6to7BpP8ad3m37Zc7N8zd7C9Ufk2E=;
        b=alPWLLg4eNQeY790Fg5c+UmnmOKiNYs7qiBWKODVKDV7aaFgOota0CVP5+u44BnGTy
         YhJ8jNHCz5mtImBp6BpJQmmPjrzJV2AjxHHerATq0tHreKYN5wxyPZNiEdcPwJR1ynON
         NkThJmV5fBolzt/Z1knCV3JKYQcJRDv5GcPpT8HzYWprEiT0Ybi7BHut9tUwHkFg0yCi
         9DwOU+U8bmMR30c/rkbPi3GoLewGJI6h8soShlvYmOUg2hPGKquWeRe9+zUz+PQbjgyV
         6Ym1Dmrniwr2RV1nLZihYJ8buCLutDXKI+5IYSLU1f9ZNSgDWL+/ZHhbNq5nnBwrBvQp
         5t4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubALJYG6AeHUNO+/gheZPI8Z/qiVgGygvjrrQa1sUDPcBeQMQY9
	BFZfPmmCHfCYaAIn+AdsVMTP01F4WF37WdJ7ZHigxspi5FKl+X5fCK6+6oUZO+HDCxP8iRm5i8Y
	2dnFDuR4WvZSYG4eNib2wDYuhQyb1/HxxHzn4CcWo49b2lWT6oL0FGGAKvE0A/eWTHg==
X-Received: by 2002:a17:906:eb95:: with SMTP id mh21mr2273529ejb.220.1551287201698;
        Wed, 27 Feb 2019 09:06:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYDYr86BJ/luYKBd+4T+KzKQqJEOZde4H8jMwPNCdZYR+6/vgy+A5M9EiggbS6mc0MXLevc
X-Received: by 2002:a17:906:eb95:: with SMTP id mh21mr2273468ejb.220.1551287200683;
        Wed, 27 Feb 2019 09:06:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287200; cv=none;
        d=google.com; s=arc-20160816;
        b=KaGAmXpqhCxynLkPgZFr2vGaX6AyZGeHC+hQLaELxw+bLNh+C2gefppwdkJSYwjcJI
         zLFiSilH5TggUi3AR/IiQZGmhtnTzx8eqYUJ41DTiKL/JmgrnS+5DEZHT5IM0cVPR3Ou
         BG7putNQoqLZX45zoo7OuiU1LQ0F6z3tJNYXPfr4EKulO8r1W3Zpv/6/m0ok9auEoX7v
         9y9iPEARcOkrOiVrK6nLtOn1d+B8MyX2CCl7Hzal9yM8RRRGysLf1zHjOf4VT76EzuOz
         JptvSuSFDm2LFR+69XwGbYHniIbu2ZByqI/AMsINtHYLyMhBexfW78nPcWOqRqVIJIpm
         HJGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Y7UWc/BL+I5JF6to7BpP8ad3m37Zc7N8zd7C9Ufk2E=;
        b=LqIGxlNpaF1B967oXVugCAo+GNXSaH+DPz1/HKfVdtmuRCRVQiDjtABCcFTwu9TK5t
         a338uc1YILhstsLzUEsjylKivRM5gAFb15xhbz0+X4vXQSm3EHFm4EU0fiw8XgQFu+U0
         BQ25FggrhW+nn59Jo3YVK+b92zLxT+u8FlXGx7l4qT+7J6al2NC+6wKE5QQchxdnE7hx
         30e3GKegvWQUC8NBjd+enR3T2L31A/ZPChOTYCLsra7IMrZJbC2dIvZGq+fqayHENIRr
         clpIZSWQZlmmCSaSRc/CjPFvsHk3SsX7wsF6uABQa4rVXuwXpSIov6OWSkCbS6tB6FBm
         gAmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f19si1031408edf.175.2019.02.27.09.06.40
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:40 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9A01B16A3;
	Wed, 27 Feb 2019 09:06:39 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3AE843F738;
	Wed, 27 Feb 2019 09:06:36 -0800 (PST)
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
	Russell King <linux@armlinux.org.uk>
Subject: [PATCH v3 03/34] arm: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:37 +0000
Message-Id: <20190227170608.27963-4-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For arm, we already provide most p?d_large() macros. Add a stub for PUD
as we don't have huge pages at that level.

CC: Russell King <linux@armlinux.org.uk>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm/include/asm/pgtable-2level.h | 1 +
 arch/arm/include/asm/pgtable-3level.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index 12659ce5c1f3..adcef1306892 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -183,6 +183,7 @@
 #define pud_none(pud)		(0)
 #define pud_bad(pud)		(0)
 #define pud_present(pud)	(1)
+#define pud_large(pud)		(0)
 #define pud_clear(pudp)		do { } while (0)
 #define set_pud(pud,pudp)	do { } while (0)
 
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 6d50a11d7793..9f63a4b89f45 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -141,6 +141,7 @@
 #define pud_none(pud)		(!pud_val(pud))
 #define pud_bad(pud)		(!(pud_val(pud) & 2))
 #define pud_present(pud)	(pud_val(pud))
+#define pud_large(pud)		(0)
 #define pmd_table(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 						 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
-- 
2.20.1

