Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16166C04AAF
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA73420675
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:47:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA73420675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ACF16B000A; Thu,  9 May 2019 00:47:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75C536B000C; Thu,  9 May 2019 00:47:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64CDA6B000D; Thu,  9 May 2019 00:47:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1813B6B000A
	for <linux-mm@kvack.org>; Thu,  9 May 2019 00:47:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so553896edm.16
        for <linux-mm@kvack.org>; Wed, 08 May 2019 21:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DYixvt1jDbt1vu6MAn5rwFWxpCwVL0maYvtuuMFfkM4=;
        b=MEnUF+hLD6khBcNXJAHwx6vC1A/iKvuI0Pp/JqW7QwPAm3RUS4F8F3pH5EbbAs+MAb
         8LjgXHeyc1FoDOFmWmVysN5UeWufQk01ZXqeTEZMZSC646DZf869lVEStgvIV5NOdBjw
         wbJ/+J3JSeReSWmozAMh80P2OMEC59FYyZ2b9HkqU7RtlipTJk5Wf0FRvELaURPQq9oT
         4DvIFaspuyHof8tEZRZiDZzWXSOcL8SA1GYKSDk0rVQvBmzM0cpNG3oAdmM7LxAj3LUx
         my6eVGDI/h0c72+CN1dKWrUTY1cUeE/amfX6HjpyyC8J7kH/Nxz599RHCqkT14wDiVHk
         FGdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUm8zOxgkElpzPrPn8Hzfamo+JXs2Lbuiz8Y/Xq94gO2o+0+P9O
	/S8EHC9Azy4ypc2oWPUOKnurFiqAfl9IISM4DC89+Pf+uh8uhrTzLOa8eT1olbAtgEdL7a2Kik0
	1aojykY2JO/QuwXsNmMpMU/r7lNIIxXPaf9R5NhF2Z4UDaaHyyccA/OtoHhnGrss31g==
X-Received: by 2002:a17:906:6aca:: with SMTP id q10mr1486124ejs.54.1557377241581;
        Wed, 08 May 2019 21:47:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn5HdeFruxHtfU+wQPzWdX07jEz6taIAigHjEXy0OUD9R97YWBwwNvAeIvzCQLHElcgH3p
X-Received: by 2002:a17:906:6aca:: with SMTP id q10mr1486081ejs.54.1557377240743;
        Wed, 08 May 2019 21:47:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557377240; cv=none;
        d=google.com; s=arc-20160816;
        b=PGfmJkUEOBhqZDkXzq6SlJGn2BsISB/dEDPElp6NftCQcMlBoSV5wzmxJRGVxqD4Y9
         k0MF1WQcuHpaYR3NKx1PyJy57usaMqNx6xSu57YuJS9UIfJrsBNSTveIt6fGQusD+y2Y
         1P5yLtLcHxoPpzNcawfozMXZGaORZJt2bpAXB/C8DX1LHJ7BCYxeWosXdAX/Yiul3CAy
         YoL0k6RBAT28b2q1KypdFuzhmbxzeLrD6n7QxLJP/w/lNDm8sRL8Nyl/7SIvN8kSd7i6
         aereLV2iDshRNresxxJPDjZh/pC20iX38KS3uCrEShEuG1E0FE+BKS2GlpsazA5JcXDJ
         wypQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DYixvt1jDbt1vu6MAn5rwFWxpCwVL0maYvtuuMFfkM4=;
        b=PPLStWfLhB8Tgm/eTkyIMUwCRUPkVRfe5pzjhsChjWMtpGxQAH6TZBZji87xgMhiFD
         7Opn1nt1wOSOPz8C205Kro/NZla18tplOCCobIKiLk/+JqEZM5L5hubuCVoHfvU+oqFx
         p1h8GhAFxQgPsDEX7E7ESc/0GU6/8DsgcBdt2QsBS2qNvqnY5bsk09HQjB/B5sKRjldg
         QYoQT7I6Hu9qZ8tBg6oLRa8eTjqWWMibiKL85638blzQg4+rXTxcJWdGp04LRPrUn8Vy
         N0nx57XLUO5tDxETrZ3eQfKvVcgercCmg5G6LlMbRySuC2hgukTHe24kPXapPUem2oq8
         hx3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g1si469352ejc.373.2019.05.08.21.47.20
        for <linux-mm@kvack.org>;
        Wed, 08 May 2019 21:47:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C10A9374;
	Wed,  8 May 2019 21:47:19 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.46])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 07BC43F575;
	Wed,  8 May 2019 21:47:14 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>,
	Robin Murphy <robin.murphy@arm.com>
Subject: [PATCH V3 2/2] arm64/mm: Change offset base address in [pud|pmd]_free_[pmd|pte]_page()
Date: Thu,  9 May 2019 10:16:17 +0530
Message-Id: <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Pgtable page address can be fetched with [pmd|pte]_offset_[kernel] if input
address is PMD_SIZE or PTE_SIZE aligned. Input address is now guaranteed to
be aligned, hence fetched pgtable page address is always correct. But using
0UL as offset base address has been a standard practice across platforms.
It also makes more sense as it isolates pgtable page address computation
from input virtual address alignment. This does not change functionality.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: James Morse <james.morse@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>
---
 arch/arm64/mm/mmu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index e97f018ff740..71bcb783aace 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1005,7 +1005,7 @@ int pmd_free_pte_page(pmd_t *pmdp, unsigned long addr)
 		return 1;
 	}
 
-	table = pte_offset_kernel(pmdp, addr);
+	table = pte_offset_kernel(pmdp, 0UL);
 	pmd_clear(pmdp);
 	__flush_tlb_kernel_pgtable(addr);
 	pte_free_kernel(NULL, table);
@@ -1026,8 +1026,8 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
 		return 1;
 	}
 
-	table = pmd_offset(pudp, addr);
-	pmdp = table;
+	table = pmd_offset(pudp, 0UL);
+	pmdp = pmd_offset(pudp, addr);
 	next = addr;
 	end = addr + PUD_SIZE;
 	do {
-- 
2.20.1

