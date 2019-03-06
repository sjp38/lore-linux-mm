Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A6EFC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD1CC20842
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD1CC20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BA838E0007; Wed,  6 Mar 2019 10:51:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 866BB8E0002; Wed,  6 Mar 2019 10:51:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72FDD8E0007; Wed,  6 Mar 2019 10:51:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4CF8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k32so6452150edc.23
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cPKBnLK8oZvB2lWO7ABGhCwqW0QzKgUdLTrWIxZALpE=;
        b=BhNwqyf3QDO1vjeMwm9T2Rfxfpjjo2XJjs4fALvGNZ5wTMBjdK5+KETTcXom9KTUlI
         NBOepAuzMpR2pnRv84n2k/YkyJoaVxSSQ0c03WEUWxBnBxAM6sf/7ZzxU0BzSoF/Paz/
         lndRS2aHj0Ab0TWNvFkBe4Y2hEmbG9Me0Wr/PUADSHmZC/gmauefXhNXvML9U/3XZUqO
         eHxJLNeZIXKFaiZC2e2vtegtOl9C7R5UiaK92LiNd+mizKEJLAXuDsdseefdtRXjp4Ye
         iDP0LCGX3jFCayt5DVvmBZELW+fTGvLjwvXVxaLnc/h7YKKER0i1CcbMMHzr8R43pfql
         OLBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU68E9YGjS5qVXgLIWljzmvCDxFy2+fcfsSXw5iToZyKwvNl86r
	wFmAMUij3LS+HWXOUO9dfspbV8sBlIODcTCrI2TlPFfG8p9GIZT2CmZ/v1oyUnVEham0om0Jpt8
	5EBNvn/fg1voveI48d7adsGUbNKNr+SkEhbRxrjlUKIH4wsYO6A6NeZ5evdUZfjXiAA==
X-Received: by 2002:a50:ac55:: with SMTP id w21mr24526117edc.121.1551887459492;
        Wed, 06 Mar 2019 07:50:59 -0800 (PST)
X-Google-Smtp-Source: APXvYqwQ5YFSDM3CxFDOEI88nEXldDoWQDNnTon2Ccrl4D+sQQ9r6dtxMmMhdyqYNN3EGHllVIhY
X-Received: by 2002:a50:ac55:: with SMTP id w21mr24526030edc.121.1551887458176;
        Wed, 06 Mar 2019 07:50:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887458; cv=none;
        d=google.com; s=arc-20160816;
        b=w1p5KHRlHHFKGsZwkPPLhbGao2A4h3lRYuX/VrQ/PEhwU9pecpvDSQ2F9gQQ4YTTUF
         qXZAPGvnhUICH0hyniYPGvS4IdOnz4b0LIDlt+pMWwWA9GNZPPQHQF27kbOo9r3hFMa6
         6odbNe3OR+Kvcskq4aFcqAacKj4mRpITYKRc/HuSLONDftiEZctKno7WKXVuMDQjmu5g
         0pPV95LS43zNbrfhouc3kPT+HGO4s8Vkw3U6QYudLvpSHWVjv4NJJSrQKKyDeaaUOTDV
         9uc6Ohrl9JM8oWZT7sTwg4fjAoiTTM7NLjcJ/ZsKWBqANOKjNAvntI06uyjJIYbE+8RU
         V/sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cPKBnLK8oZvB2lWO7ABGhCwqW0QzKgUdLTrWIxZALpE=;
        b=Pv9qSWA+GMjL9PqcI6lltjMIWWqPfVqLXcePu/eN5HKxvLCbAGVRika0dj9HK02imQ
         YSuDzyn6TaZMNAw854nXYxiD5zuj+inp2RyGad3MfPol+12hTL0dpZ4z6Rf8yWbm0YHN
         1GUdWk13jnYbbWik1etVpEFo4SA/Q6rbbxRir7qRcfxr9+yEVbkOsdr7aKGc9kQblt/e
         q5YvkTvXu0a0t9RHXLXAvIQM5cbPMRFHLfIvw33JEh6pKt4Vr1sYmvD/1/O+e617YcY+
         XNVZVLCyyJTrGz1FiXVyHuCcU9ZVBW9djDQKe1rSA72rbBQ7J8bKXn/SCTvhVWTu3jxp
         ulJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n15si742321ejk.117.2019.03.06.07.50.57
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:50:58 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2A69C80D;
	Wed,  6 Mar 2019 07:50:57 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 567923F703;
	Wed,  6 Mar 2019 07:50:53 -0800 (PST)
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
Subject: [PATCH v4 03/19] mips: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:15 +0000
Message-Id: <20190306155031.4291-4-steven.price@arm.com>
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

