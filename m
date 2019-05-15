Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08D18C04AB4
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 02:36:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AD6C2084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 02:36:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AD6C2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6926B0005; Tue, 14 May 2019 22:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A41E6B0006; Tue, 14 May 2019 22:36:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 294396B0007; Tue, 14 May 2019 22:36:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD3966B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 22:36:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t58so1473274edb.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 19:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=k+4pG7s5PhgweA8Ds6zH7Qo1tN5HR4wog5SSw+qvavA=;
        b=MADDsGN1KrOIpOWcBgfkl50xpP9o6aX2yKf3Do3sSdXmuZV+vUL+Ur5QxMPeyyJbah
         RkRrgl0/8BhsdVpRCl//FxEAazstk3+7n1NOC1ypupuaXsZijNAqojTsJ8sOxMcHIl65
         kDGxfyYi5onyot6qUosStKTUKlA14hNMmHW0VpUVquGhTO+T81FXR9xhDlCJJ8ZNBSAX
         cCm2Ya82T/VUgrL1nNmjNxbwq0oWi+qWHgNrOZHhzrxe37OF/jgkYjpxotf9BY7jCPJy
         2x2FGgDOan+0YAxhZs/ja04PwkEQg03qGzpPHUijeKJWzCQhnFlbYvsBPV2BHkfOI3vC
         JadQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV67nXpk1qFws/TBYNnEX640YzJ8FpjxtTmNLtHVgQZdo+A9nmw
	1OfdUUhE1hZyb5ipR2gwFjdqZWJutCcrgihg9qhRer2nWtCubfXDelNI04La9J9YZkkz5lbKStN
	3jRzm53FBpAj0kq+gRFurv3P3/p1KRDT5LDaxJtO4dVeuRQVrjWw0Eqdd6LruVnetBg==
X-Received: by 2002:aa7:c919:: with SMTP id b25mr40249214edt.274.1557887767360;
        Tue, 14 May 2019 19:36:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvyfnq35P1mgO+favCa+VZx8jwcFUP2VM7SqHDS4iIJ7Rd4H7iBKmjzDxgo1dxHIUpNT9n
X-Received: by 2002:aa7:c919:: with SMTP id b25mr40249133edt.274.1557887766346;
        Tue, 14 May 2019 19:36:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557887766; cv=none;
        d=google.com; s=arc-20160816;
        b=gezeJN5s/g6JY2aNgbsA2Y4JO9SDpA0FgvB6f3w2SdR5YVKt7vc8rGR3E9rrK/eYCp
         naWW+1y44sTt7zvq6E+dyx2C6/WeVez6t4KRKxHkChcS7DWUOIdsTOMBFg+Av+EXwMjW
         c8RnQ4qNhmFZTaIWKhgd8rzD5ETA/l3Ed5tTuLcLEc0PraxWYbWQrUtlLWC4/YglpWLB
         16Djm7d0GXC0GaC4vX+E4CZee900e5HNR6thp5w2dnUOjoaF/MdG4+eC1HmNoif4dE5y
         5HIRldfG9nmFYBKXkA8C6S1uYeYfj68MVv2K8T9e3AEfDpYn0uHC2PNrwe7h3lCgRsnQ
         4snA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=k+4pG7s5PhgweA8Ds6zH7Qo1tN5HR4wog5SSw+qvavA=;
        b=y87lmI9GUocpMUnNFMsXJuU8HyqcuQR3FvEs5iWcNIn/k4Vm2LjqWqcAa9COqWv2UL
         NC0F0l6ZT0Wv8gTjAWKUzi2z8JmOVr/ubUEOncjBAz6ztQoSvgsNpGSt8vbS/aYJxQBE
         KH5CCAK57M4Xe9soY1B1Wt5n0YXfMiPslzuCjxKdppS21IvJ0O1xauj0TNVLTIGQh9ka
         iA/KB/DqEnLVKLbKh1LqddZFP/zXZMOYQHxfW+nAtL+FWy2T+f9QO3Up4eq6whInU8hc
         7D/jhMnHIhh0wGzTuKDB8rKsnj0i8eYLPVXjTs59CVtDfGjCBcCNqHxHdqdJ4ty1SYcV
         eOxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p18si421306ejq.220.2019.05.14.19.36.06
        for <linux-mm@kvack.org>;
        Tue, 14 May 2019 19:36:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4A0CF341;
	Tue, 14 May 2019 19:36:05 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 7A45C3F703;
	Tue, 14 May 2019 19:35:58 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Toshi Kani <toshi.kani@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH V4] mm/ioremap: Check virtual address alignment while creating huge mappings
Date: Wed, 15 May 2019 08:05:16 +0530
Message-Id: <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
References: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
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
Changes in V4:

- Added similar check for ioremap_try_huge_p4d() as per Toshi Kani

 lib/ioremap.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 063213685563..a95161d9c883 100644
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
 
@@ -166,6 +172,9 @@ static int ioremap_try_huge_p4d(p4d_t *p4d, unsigned long addr,
 	if ((end - addr) != P4D_SIZE)
 		return 0;
 
+	if (!IS_ALIGNED(addr, P4D_SIZE))
+		return 0;
+
 	if (!IS_ALIGNED(phys_addr, P4D_SIZE))
 		return 0;
 
-- 
2.20.1

