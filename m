Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 210DCC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF9C0206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF9C0206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70F8D8E000C; Wed,  6 Mar 2019 10:51:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 693708E0002; Wed,  6 Mar 2019 10:51:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537B08E000C; Wed,  6 Mar 2019 10:51:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F09268E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:15 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id j5so6551319edt.17
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5THteukl9LjchCZjOSfwp3HvyVvejyfMSn/dfz+5mKg=;
        b=MMb2CJITT9gBkeqmhu+MiCChrskTDMLgUFh0NEX43NETCKemgpl3mPybT+H710OBPT
         F031bziGkvLdg3n6tbpIsUQL7PWa6eGHS57pCh6XDHVQwll7TmKlQf6VsbVMthd3i4Q2
         WbviynohICAAy6oJdDSAuqy4c3aK2c5qkk2Pr97paWjFtquhVVXhFH5TdgrO1TTmhBRS
         uKX0zzQuQgnZj7q8csjaUbLhrxQVactEEhGVDZZqXWadnU/t7/vqew+FEO/hSkDHakgt
         iegSljusoK4dPGFI9HQVrfmKpPuppcm5lTxu5C3fT30467x1K5j1s1RWsnnNoLW2dGYn
         7WHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUOEla94tPePDrINVmH7HWIQIPydCNxBC9O/sLhjQGkZskr7Pak
	kbB1sX4DxaNycXOU2jC7hn6rauSgickSPrTRU45D6bNfKrhn/gQxiXs5v5gvuE9mxKL5iuFt5w7
	u2Hs+PJIO/86KpFj6xt38KTXgkMK+jJLEnj5ESGocZWla8ToJce179w/eeBeAqRTxtg==
X-Received: by 2002:a50:97b3:: with SMTP id e48mr24500671edb.159.1551887475191;
        Wed, 06 Mar 2019 07:51:15 -0800 (PST)
X-Google-Smtp-Source: APXvYqzEQn+yv1N6YMz3y5Zm3b8437s6OgXCPmuw/TVdzJxh4FIVd5rYtAcbjr4bTG3AKHy857cD
X-Received: by 2002:a50:97b3:: with SMTP id e48mr24500587edb.159.1551887473986;
        Wed, 06 Mar 2019 07:51:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887473; cv=none;
        d=google.com; s=arc-20160816;
        b=yF6GsVzWTcfirxYNDvxs5R4j1vtnrzwmYycUmF1T4hAsxHxC4MCaLRbFxk3/4xZfEQ
         VYXtOQEhL+X2jz1SDaG0d+FPzT1YFYmmPmqsvttIlnSZK18ahI6f21+eUSP/i5D4fW6E
         /XOATNVayU56oB70UFULXvfDvJ6cgFQDRNGeSw/b6wqrZP8wFJR0F+mFwlDomgmge9eF
         UAeYDLwA5ztM++w4CtZ8H/yxkqYlGFDtq21CTqGrwiqzD76bvlDKTtjpQpV/LHdQtt/W
         7k4b83EP0rO/Ie1jOoW8GZeEpb9J6oywEyzS6oYqh/ohwlX0icWvo+sGDRcFDNU7EzBy
         YiJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5THteukl9LjchCZjOSfwp3HvyVvejyfMSn/dfz+5mKg=;
        b=VzGlNatfSqcLzBrsyPLTS2GW/rAdYRquJYcZld+o8yCL0OIN7dlWuxO5w2rMHz+flu
         nYwXCB/iDn4oNMvMgg+9g84cceATOy0Rf9o9qTH/4Fp0RjFgsaEoi35pKa3+al2/3x0t
         d2IbRRymLLBZTNnJ4V7nNfnsvoNlWaHyi8zqlyS9mvZp06BGeEtGd1YvObOMvpZmb09Z
         LDO7/eImJjM/znn99shfonsXVQUZB6rPz1TgtulAbhHE0e30iroAXiRtwM8UatzxL6mD
         i0QrmLcupLY/9j8uLIPTMzqLkRxaPVlVy9d4YlEEvKSR8Gkl6DBcIETv/mqJqXX+GtdO
         djgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z37si742759edd.282.2019.03.06.07.51.13
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:13 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 142FE1684;
	Wed,  6 Mar 2019 07:51:13 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8609E3F703;
	Wed,  6 Mar 2019 07:51:09 -0800 (PST)
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
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org
Subject: [PATCH v4 07/19] sparc: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:19 +0000
Message-Id: <20190306155031.4291-8-steven.price@arm.com>
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

For sparc 64 bit, pmd_large() and pud_large() are already provided, so
add #defines to prevent the generic versions (added in a later patch)
from being used.

CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/sparc/include/asm/pgtable_64.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1393a8ac596b..f502e937c8fe 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -713,6 +713,7 @@ static inline unsigned long pte_special(pte_t pte)
 	return pte_val(pte) & _PAGE_SPECIAL;
 }
 
+#define pmd_large	pmd_large
 static inline unsigned long pmd_large(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
@@ -894,6 +895,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 #define pgd_present(pgd)		(pgd_val(pgd) != 0U)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 
+#define pud_large	pud_large
 static inline unsigned long pud_large(pud_t pud)
 {
 	pte_t pte = __pte(pud_val(pud));
-- 
2.20.1

