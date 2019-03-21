Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B0F4C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EAD218FF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EAD218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31BB76B0266; Thu, 21 Mar 2019 10:20:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A0A76B0269; Thu, 21 Mar 2019 10:20:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 168D56B026A; Thu, 21 Mar 2019 10:20:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B56676B0266
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v26so2244219edr.23
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=BnUL4HKd1GxO3txNz8pb1jfqzKxiEv6jRFOgVoxnaeaoRV3hsJpcOKfeiXJ33PDY+K
         Zc15ud+zTCMP0d/AbrNjzPfbkz1V61ZYf7ZFhWzP7s8xl7t2Z91mfBOTQcNwJa63xwRg
         fbeR9jSqCG6efCW7FqLpHIkFKRxbFmMRyiKCm6xWUdVqvAzeGsYOcC+7KMrXDRd5nYZz
         K6VC0MlEnxC6KoqMqclXHKyk4HeFSBchGYh54RJD6JjIAfaH10yXyBbgJPgcuRCwC4gh
         910DXFciv/IhZKLJLn38zg3cPng8ah9ZPpG4tIQLvq5FyDgZWkE31C3jSQ3CxsKjd9Hv
         qDng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV2qXPvhP55h+uPV6q4mOsDMyRZ10zDXCOMe2Gisx/hZABFrpZ/
	TypwSAcfnNUnZfhBv5nY90L/MApDNs65ULB0lx17YAKnIghPNJ+Bkwy880niony6PblXFtwhl1l
	8mckb6c/FYWbRtJaNa3kV2ZEyDUv/OIwEwI/uIuleq7DVScAVlCJAF3BiaWI++Bx0Mg==
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr2505077eje.5.1553178031276;
        Thu, 21 Mar 2019 07:20:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1ARIHJQlqUjM+cATkP9zGJpekhQDJtmJfGyl4BQHMSHlDLtTcjVwVs0SR2LbmzU8tygS0
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr2505042eje.5.1553178030385;
        Thu, 21 Mar 2019 07:20:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178030; cv=none;
        d=google.com; s=arc-20160816;
        b=EByZdCVVvztJxZldlWgZ9DnzbXyN2xO3hIZaBvKnz2JyGPuGXqM3dt4wW86NLX/vqf
         Dq0tn9tKsXAjDgLNIQ4Jq8DZbwvncyzs+LAznAC9JQAyqouJeUHbhkQ/XNxyZlQZc6eN
         IC4iXJ2bIEjkq0kxBlA8ffxfPx0PXsKPIzcZcwcvAll4y1O1IPz87/VSQdodQ8DjVURU
         20oUDEpuKd0YRINgXm5UrYat1nlF1YmMHDws1gg8pQDo/W6/Z6+s2H4IquF9FKqfSvbw
         KQaipno4+sBOm+RjweHUb0NhM1qN8YTuzI0eMB+tzAhj/gDiw9RlxXArKdomyzsGCGrA
         Qh8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=k4ITfEhZ2eyvtKlgXTa2MipOYASg6tNFwCi0muCU65yI7B13J52vS1dgq+6xjdAThU
         zP5cBwBtrtcNsG1m3XLmJWsx7ATG+wHxScYNM1svAzsPzjuBqO4CauysF6fcZYGujdAz
         YB53FSnWQIlzAbGB9zHW1hIlgsKZwYhb2GZJ6P5cSVg4u9XRiRdzANCMKe05pfTk9ixD
         7r/5wmp1tIywghVOtXeCmkyUdD3IgQTjQ+5vx6JRcQp7e5XcQuS/SE5dwhADKJz8N7+v
         e9X4Cl9XDYWf4fDgxmizPKuqimn+eZ/eE6G61H2v/BKv0xSaAOyNG/z+Gh86St995zRV
         zstQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p24si1732630ejg.203.2019.03.21.07.20.30
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 770BE80D;
	Thu, 21 Mar 2019 07:20:29 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C5D203F575;
	Thu, 21 Mar 2019 07:20:25 -0700 (PDT)
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
Subject: [PATCH v5 06/19] s390: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:40 +0000
Message-Id: <20190321141953.31960-7-steven.price@arm.com>
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
index 76dc344edb8c..3ad4c69e1f2d 100644
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

