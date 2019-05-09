Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EB0DC04AAF
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE22020989
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE22020989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7386E6B0008; Thu,  9 May 2019 00:47:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E7AD6B000A; Thu,  9 May 2019 00:47:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B1146B000C; Thu,  9 May 2019 00:47:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E15D6B0008
	for <linux-mm@kvack.org>; Thu,  9 May 2019 00:47:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n23so565612edv.9
        for <linux-mm@kvack.org>; Wed, 08 May 2019 21:47:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=smRSWtMfbzqp9e26+Uu8/I42k9wBiKKP23FnAZWrewY=;
        b=M9fm1amS8//SacWYsdoCM76ACwSYp/ce3IF9gUv0ynHx3RhVdZxgsbjDujVhDUiSye
         0nCMcg1ycMdTDkhl2wuoJLNO0Am+30ijc6laOPLCh9PkvRQoXeWnC9FGNuHbnU90lQmQ
         nLu+BIT7MRoIHSJHX/bpvcksyMZ4VbBZ2w5WSjSZnmpMIbECD5QIDUGbmqfAR/QHNex/
         lcaBZSZRdWOupFHkz4o05tunXJlHzJJ9NAlEtAdYxIykbOZgkntfw8hQxTNXnqk0TEpU
         /hDtHHrX8P+168l73ev862G+fec4/eQM79DKpXP83XMs2RLqzdBZzHSUKioYHu9qRCTq
         FqrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVJV+nRwePRBDV/m4ApnFQbxtKx6RThmMxfPTPMVpVkOL4BgjHg
	2U5qrCCqTiufRtGk5X3DMGgNjSHwwWNHh1FLY5k8D6/BpoEOoVbb82gkMn2NCT8jibvb9JD4ntD
	mfKMbiWTjdhJFG0oPL2njGeforvN2JSeZ9psDWOqKj+irQk8Jv2nnjPZ2WroUqIkZDQ==
X-Received: by 2002:a17:907:104e:: with SMTP id oy14mr1434244ejb.253.1557377231572;
        Wed, 08 May 2019 21:47:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx71cNrWAtbOne2mZzz1Q21Z8MTjS7xAY4H3zjoRj21wYU0OlQYigqTEuA23Q5kNYVEjxKu
X-Received: by 2002:a17:907:104e:: with SMTP id oy14mr1434201ejb.253.1557377230486;
        Wed, 08 May 2019 21:47:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557377230; cv=none;
        d=google.com; s=arc-20160816;
        b=c1fQfeqaSKDRTaGZhEVxgRXKxwocQD4MEEoPbbfeyGQ5lSbag/GdHUXfM7lgWZCH9N
         PBSJItkxZd77ZcvbI82wSv1ZmybwCceyEERoCQa5VNo1L+icJG58z01CMHyQR3QWFHLj
         obqRkbCoAHoliqRH2nPFtmd1Xeda/Zy3tTrojpz5GzKE45r8p64LLDvP1v20kQeM+npL
         RUpPEokyuKylcpDiPUWj3qBd9Lh4zTNXWLr0HHEyYIo+yPc144ES/LatvHbCDEOOdXVW
         j0i6UItaKqAAuw1j/ZyJN0BwmKykBopNhoocTnGE4DmXYR02OpKLAFH8pRosqy0WbiQX
         pDRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=smRSWtMfbzqp9e26+Uu8/I42k9wBiKKP23FnAZWrewY=;
        b=Kz+y4bRroN048uUep/5r8BCS0OneHGWwDTJFYYPy243moL4+kRY8SOjUTsud2NOXI0
         C7dH4/unMctisItaKXpBAfX5twehn5mIdTvi3TrSWyQ+mbvUIyi1Zm3c1NOKafa45O5F
         i6mP1ZWcRFwIduaAg+gY7o6NBchowHd1QsNqfOZoDdLKiM9whUNxXumw/ZYS4Txpig1m
         KdPOAcRl1YdO8L1Y7dXrnENMMkC7n0zKalfEGNvMgwGvTo+NITJ8b/nS+eeGtlqgdg+Z
         PaN1Mx0pVUhTL3iysff36I0wZfeMd0ZX31Zn59c+RZlkb743vWbRNiOvWxFY4oVxsc8A
         gQSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k57si690192edb.36.2019.05.08.21.47.10
        for <linux-mm@kvack.org>;
        Wed, 08 May 2019 21:47:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7F7BE374;
	Wed,  8 May 2019 21:47:09 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.46])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 3F0C93F575;
	Wed,  8 May 2019 21:47:03 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Toshi Kani <toshi.kani@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH V3 1/2] mm/ioremap: Check virtual address alignment while creating huge mappings
Date: Thu,  9 May 2019 10:16:16 +0530
Message-Id: <1557377177-20695-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Virtual address alignment is essential in ensuring correct clearing for all
intermediate level pgtable entries and freeing associated pgtable pages. An
unaligned address can end up randomly freeing pgtable page that potentially
still contains valid mappings. Hence also check it's alignment along with
existing phys_addr check.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>
---
 lib/ioremap.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 063213685563..8b5c8dda857d 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -86,6 +86,9 @@ static int ioremap_try_huge_pmd(pmd_t *pmd, unsigned long addr,
 	if ((end - addr) != PMD_SIZE)
 		return 0;
 
+	if (!IS_ALIGNED(addr, PMD_SIZE))
+		return 0;
+
 	if (!IS_ALIGNED(phys_addr, PMD_SIZE))
 		return 0;
 
@@ -126,6 +129,9 @@ static int ioremap_try_huge_pud(pud_t *pud, unsigned long addr,
 	if ((end - addr) != PUD_SIZE)
 		return 0;
 
+	if (!IS_ALIGNED(addr, PUD_SIZE))
+		return 0;
+
 	if (!IS_ALIGNED(phys_addr, PUD_SIZE))
 		return 0;
 
-- 
2.20.1

