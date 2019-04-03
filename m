Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 470DFC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE46A20830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE46A20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0491D6B0274; Wed,  3 Apr 2019 10:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E71826B0275; Wed,  3 Apr 2019 10:18:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86576B0276; Wed,  3 Apr 2019 10:18:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8546B0274
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s27so7619727eda.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=R/2g6wXbQvq0j6YpBbVyNmocexQ59yef+7O8KKz5iJWBKpcDxQQFjss/h/6gNfdNp7
         aLWsTdEN1H+obUqZBOOCKj5+gAMogD1kpAeJcY6jXHnwIHRRClKefrp0mn/+b3Mglzxj
         i41bVkIHLYkKt+/glIkvyDpMBxTEvPOzp6clfgXSipNterpNGWZBNnBS4bqUDrjG0gAC
         Yq3Hn6g7lfLy4AJVg9o4+Jjc5wOm/QG094ww0Jt2dLlDFoDR00J1qzptwoi7IPusJQxg
         B4v9d5TwoYrmRDTmdK7SAYibHuRG9CXcAOFA+mNlj8XayylELoasAuCWuRQ7trpbz1ye
         uNEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWYPpzCasXam56bVbnIMpxR+9Z1n0Evnkh7uoo+Ob3JIyaS0xaQ
	Cmh5StGEXN9YQNVBqHRra1pkTLOqyqJKGPxGfqpp08XrFbT+6olTCJfCunoTmFGaPLbxFGdbW3J
	+gtLr2aJK+0RPKeFuWWgVMKcVyX1WkhuezC5hNDHuA3stHd84nyhNDhEpJ9WVaI/iZg==
X-Received: by 2002:a50:a515:: with SMTP id y21mr35388657edb.135.1554301081016;
        Wed, 03 Apr 2019 07:18:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOsDBDf3Qlf/LQxJ0avvtDU7E5sR0voVi3ZbDouse6QxqqybjHZxjDeyXttLbKlArK43NQ
X-Received: by 2002:a50:a515:: with SMTP id y21mr35388579edb.135.1554301079749;
        Wed, 03 Apr 2019 07:17:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301079; cv=none;
        d=google.com; s=arc-20160816;
        b=ILRG3r6peTeuJufrqRwp9ygRENz0czXQRfH44XO7n1VWyKx/6Ne+y4ysWz66LqDGD6
         V/Zt+Sb+QGeuBLfHi63cSMdAQF+SfOsQXgystRTZV56JhGfI7Xne0cDtOOvg5ygdh1SA
         7XBxjbk2L8iYaVY6IhEiTHP/6v/jfl8CZO63namYDPj8hW4LEh5HGjdULKdWvKmkltCr
         aQVRyxLqUiFJjGM3bNYJkCcb57sBoWtR6qiqHRBLgHcR3ce2WjuUEetzPURpGWVdUbMJ
         pP5QhVqnbWNFxcLht2lGkHurwNvlNaO0yyEpnsd5sxQUbvsy4lqPWeL9cCQDQuof6o3h
         yblQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=wLKVf7v1gKP3qLhW3Ffu2CUlMCOa0OV6BGbqgXwz1sW80+YLHk1ovbjKHG+nnKEzIa
         J8tbw+YSYIAbT3phe7GlF6CFlMhYh/sU1svx+1arNKJE7Lr9AjeZLDLikVC025oEoCSo
         i//FKts/pgNP3Y0QpUr50WBAEs8sM8/dfrJx1eeaf7vr59BspKpeTaXulvBryMuD/5lb
         BLheeBpI6+nR+KSBUjGeXZR98ErazBH0jYtx5luQGUYxkyO9wZLwvjbLy0cjhStn0qAj
         usayBrdqiHDalE4QlEvC6wDvH2jzSajiZoCHUIyTctDktUNtXFNogCpGFbNzBxeTFEcd
         CydA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s39si2088937eda.15.2019.04.03.07.17.59
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D4615169E;
	Wed,  3 Apr 2019 07:17:58 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 759873F68F;
	Wed,  3 Apr 2019 07:17:55 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 12/20] mm: pagewalk: Allow walking without vma
Date: Wed,  3 Apr 2019 15:16:19 +0100
Message-Id: <20190403141627.11664-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

