Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03956C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B49CF20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B49CF20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70EB58E001D; Wed, 27 Feb 2019 12:08:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BEDA8E0001; Wed, 27 Feb 2019 12:08:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5876E8E001D; Wed, 27 Feb 2019 12:08:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F38148E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i22so7224300eds.20
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=ZSbXrLHDP63ELwuM8yaZH7NwGfaGt/Ny//QdjAnPUMZ5yq1vQSwv/UBixbSEhYglkw
         AFolupFomjEB9JRkj++opQ8U56FR3OJKsLhSnHfTh8G2FycTXcQHYuWBTUWjxWrGG0DB
         d4jPTlJkVW4bY/I/sI1KdqvSnJ9QoYLOevUHCesFB6/X0Vy3OoYYIn67A2bOIe8b4Cg2
         NvWRZYxKDEHd+ILvzwcncs10AFj6/LaGzmarVlIsjLvh4F9NliwH8GR80WI4RSdGf6i2
         OiHOp7dgi0bgBiK9MMMjcDroRogOgVA8cKx6O+d6pmKYWRzlZzSs5EGw0iUzoN50SLyS
         ybzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAube9SNd6t/AbevwEjTZ5Ja6skqSxebCBJwS4oh+mCZXyRxXNlO3
	1PY7AS0PSXQecFu6sM6iCRct/ZgCu2+cRQfqrkO0gGdTu53BFWT54v2vfAZsjs65kkT31jQZZo6
	XmovtVrWuwPNRvM1Npc6G7BKK5QVCKrOTOh581QnpQ0DfZTz8p3Y4MsfbCS7RRc4FQQ==
X-Received: by 2002:a50:89bc:: with SMTP id g57mr3064730edg.89.1551287289499;
        Wed, 27 Feb 2019 09:08:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iasr/11+Uuq8o8/MuoN/ti5klNYw6F1myrbe4+ES3gBmQM1iIUDOwVbFayd106ZPkweNyH4
X-Received: by 2002:a50:89bc:: with SMTP id g57mr3064669edg.89.1551287288483;
        Wed, 27 Feb 2019 09:08:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287288; cv=none;
        d=google.com; s=arc-20160816;
        b=Vw1JYIOpxbfOCgGUVrLhAJX1rsWkk5bmMmmPKTMf4/lFTnTzmHKLh3e+6/TNrDdkCT
         TS6Ib1CnFjVWgukYdBsVaFl0fTw5Jhr5q6RYx86d4DHk8Vsoa5X/PByfEStFVKSQdOhb
         0fJ+v9BX+qz0hi+k+hoPwJZBZTmN+synIiG+aFTLoF31+g5M5XcIQhdYlHlZexLQxd0B
         Ge57xWPy7/SHuaEO/qyNo7gTp3tW+Db7GolcWQKLScefR5HhdTlaoTkCI27ChzdnlqQs
         +RuaqoT8SZvUyShe0XdmP6w5+Z1jd/DZ63yPSqzTF0aKpjHUmEwNnsKmyxXV8FtUckqs
         d78g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=vgAzj1kFgoskds/pkYJb1wq3vPybn9S0WMJ/9oSNXvYnRId4tVXOsNbua7BQYTND1j
         eo5un/xczmWnU+CJxeLWoaR8tByny+B58UEOqja/gO8ssMGpDXxviPu+dT/4Sbi2lhOc
         vmjlN7Gb2o5VUR7VGQSq7aiKX90lJJFoP6btrgQt7jqpfgvzpDPqXjO3i+FeIqqzhFZw
         W8+ZUe/qO56hFcwUgi53VC163Bsuk5/sZnBqdHjNSHcNN/ug+wLivB5qn9xjks0Fan6A
         YHW34BSldCbu+tUQQZSilxAQY5Z4U+ILJ0FbYLVWqtq43EsNOfHNinJ/DkL6fKCajtM4
         v7JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r15si5665733eji.31.2019.02.27.09.08.08
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:08 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 98305174E;
	Wed, 27 Feb 2019 09:08:07 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5D15D3F738;
	Wed, 27 Feb 2019 09:08:04 -0800 (PST)
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
Subject: [PATCH v3 26/34] mm: pagewalk: Allow walking without vma
Date: Wed, 27 Feb 2019 17:06:00 +0000
Message-Id: <20190227170608.27963-27-steven.price@arm.com>
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

