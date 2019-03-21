Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79058C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D340218FF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D340218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC65C6B026E; Thu, 21 Mar 2019 10:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D74FE6B026F; Thu, 21 Mar 2019 10:20:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C62CD6B0270; Thu, 21 Mar 2019 10:20:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 743E26B026E
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t13so2305839edw.13
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=nC4ayWdsfWt4QYRwGB90LCN64ylmeuFsPHTgnpHN0o+WAkp6hxuY8A9xj00TQr0lfm
         4RL2ARhX42qbMAuMp2GrdyEK2oNw8DvFtvXj94OZv6t8g9pM1nERWsg+ghdjtFRbzgYH
         4Q+kNnBIu+DF1Yx/0KPobjp1tsTB8BTXIM2Tof23TE19x79Jkq6VfszJpGT0JA06KQUp
         svEm3C6O7BISk+Z9Aa6U3YVMMX6ppi7skQAh25R8yCYudWsxNB0BGM0oNIxfTFwGxZd/
         8MR3FoLAitP4LkWID0Rh1xBcBJSjQh+mSqfixZgY0RSBYpmTb0oFpljjkJL1Uy6Ugnlo
         hbnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVp3QZ22/TDKENPDu3mxPBMixYo5PqOEGbBuYY3IDAR2BabK0nE
	mAbnicss/6Zr8BLNFXhGWpd3Eg173B32fFx/SiKh6kHoMPlupnWY6iKIP0Ti+iZHNo5obRMMuZJ
	uu8u3N2uN+ZropQ1oNoj7F3QdmXhzHNf3OuSCplY8vjSYLLEqY+x6GHb2sMtsRV41Lg==
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr2533240edp.237.1553178049011;
        Thu, 21 Mar 2019 07:20:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxySE6hr8eYm10y6ahBOgpEXpDaj8n3iKGmeR51mfeUxvO/oD4dBSbKLJ50qjaZ8O61dWRs
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr2533194edp.237.1553178048129;
        Thu, 21 Mar 2019 07:20:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178048; cv=none;
        d=google.com; s=arc-20160816;
        b=Ay5aqmhG2BtQFNEcLwTQnWgoYtG1w7nyQD0IdcftJS3aURhWQbp82r4ewLkgOdlKqM
         9rn1oHjqMI7/KHtc7A3VjNu82EbAEl4CHdqsr3sbJ5GxnQFWGTafvOuxRAMUxdzqDUlC
         sQ77KDJ5/ybKOIi83qNSYO81vm5xFBGUa1piSuXjjZdDye/RdLsEewPCaYb/isc03N3w
         K0VEZ0xReB4IwPl8NYkBAWokDYFKXF7VbSB5drQ8KRB8NJ2S/VTGcawtN9jPOM1bCzqA
         uFizYl9k0SHI5Rtr206eh5Yn61H59WBkByw4LhxwMN6c6ycRk7s61zR7wgvfrOhW4vYc
         GHmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=hVkrZ/mNvNsKEJHbqC+gUmzh8+oxScB+5WJtU0AKhBSMgTp5QBcS8ODCMPTu6u9Lzz
         83RvXVgNbu5ZHGYhxUumIJ/ySnhGu8+w/AsHHfURdiDUpwRsHZBx0rITV3DaW042uR7a
         YJpHcANcKbR2ckOuhHgwrm4FeFsWna/hF7XfEczBrejJ8XN9TvcDszH4EzHCFm3p3vnQ
         zVxQ7nsphp9aH5mnlcU0duvbVYyaiGTwuVfqG+NnzaRTgJI2MLRuTmpiVC2XE4tRfZI2
         mYeRIySaQBo11AevCG5zKAthJmrPaLbkcQr3tGz5z2FFWHojnf/6Zd/uW8VKqyLjwZfs
         +UqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 90si1175545edq.392.2019.03.21.07.20.47
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 45F781A25;
	Thu, 21 Mar 2019 07:20:47 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0B5563F575;
	Thu, 21 Mar 2019 07:20:43 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v5 11/19] mm: pagewalk: Allow walking without vma
Date: Thu, 21 Mar 2019 14:19:45 +0000
Message-Id: <20190321141953.31960-12-steven.price@arm.com>
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

Since 48684a65b4e3: "mm: pagewalk: fix misbehavior of walk_page_range
for vma(VM_PFNMAP)", page_table_walk() will report any kernel area as
a hole, because it lacks a vma.

This means each arch has re-implemented page table walking when needed,
for example in the per-arch ptdump walker.

Remove the requirement to have a vma except when trying to split huge
pages.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 mm/pagewalk.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 98373a9f88b8..dac0c848b458 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -36,7 +36,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	do {
 again:
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(*pmd) || !walk->vma) {
+		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
@@ -59,9 +59,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		if (!walk->pte_entry)
 			continue;
 
-		split_huge_pmd(walk->vma, pmd, addr);
-		if (pmd_trans_unstable(pmd))
-			goto again;
+		if (walk->vma) {
+			split_huge_pmd(walk->vma, pmd, addr);
+			if (pmd_trans_unstable(pmd))
+				goto again;
+		} else if (pmd_large(*pmd)) {
+			continue;
+		}
+
 		err = walk_pte_range(pmd, addr, next, walk);
 		if (err)
 			break;
@@ -81,7 +86,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	do {
  again:
 		next = pud_addr_end(addr, end);
-		if (pud_none(*pud) || !walk->vma) {
+		if (pud_none(*pud)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
@@ -95,9 +100,13 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 				break;
 		}
 
-		split_huge_pud(walk->vma, pud, addr);
-		if (pud_none(*pud))
-			goto again;
+		if (walk->vma) {
+			split_huge_pud(walk->vma, pud, addr);
+			if (pud_none(*pud))
+				goto again;
+		} else if (pud_large(*pud)) {
+			continue;
+		}
 
 		if (walk->pmd_entry || walk->pte_entry)
 			err = walk_pmd_range(pud, addr, next, walk);
-- 
2.20.1

