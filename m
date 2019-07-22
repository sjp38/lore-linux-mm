Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4928C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C2372171F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C2372171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACD288E0001; Mon, 22 Jul 2019 11:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A57658E000E; Mon, 22 Jul 2019 11:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F8E68E0001; Mon, 22 Jul 2019 11:43:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 279308E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so26564339eda.2
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x1V6OHqN3EauZVYY6EyiL7lCxOhh04YiNYXgSPv0O1I=;
        b=O5b0jt8IMVi1V6KHwfH+uK3vbh6hz5HIF3rYe15lVxnUNkMfauKezw8B3Rl+CB+GiE
         FW2I/3K3l7mvwh7SE0O6Fxfe0bLbQ71gs1h3HNd9J5AOdSEz2WvOqGdRSWgITAwjkeOi
         m54Z6mtPoTKNtxk6FB36IdrZDATYFnuPAFIz56wqAuy7GaCZfSaphl21mso2EuNe4wR1
         uUQSM2st//UqptDbWZIrlDoe+eRJlk7Q7xbM9X4/I9ae69DtK04zG7c6FXFyYcNe/Jl9
         DZqk9udGLdGg3hwswMFh/Nr38WQ2ejxNjFlEkDUbqWeFU1AIcSqlOAHjRU0A1BEAFKdG
         rg7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXCD4WzgTiWvHc7BQTrPBBihNEXXzTvS20HlCpbjjMM+xu9UvzL
	vnCvXDJVBu/CNRlPrpZbDov7b4fqLqYu57rDaj+3VB/um4w5mQoOg0auQQNI4abkg4SbCpz39/g
	JjJiE1iB5PNLuX3CcELQ8prv04yrTMsB2i4Y82vS8UfH5w9dnrRjR/IBVmNi36rcTPA==
X-Received: by 2002:a17:906:1496:: with SMTP id x22mr54267276ejc.191.1563810180741;
        Mon, 22 Jul 2019 08:43:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxba3NUI+BcKZmATHCh03tAKpnNWeScK4YFUuyejk9bLd3Ey8PbqcgDol1ZaoS6NZDu3izs
X-Received: by 2002:a17:906:1496:: with SMTP id x22mr54267231ejc.191.1563810179958;
        Mon, 22 Jul 2019 08:42:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810179; cv=none;
        d=google.com; s=arc-20160816;
        b=Dm24tJrGAvB+9Qo4xwzqngawxwaUFIwo2TmZB6GWEN5Boh4cvg9xkIhEWkg68v1+Ec
         noQus9Tuw/mEfkUqD4AT4tPrRbzQH1uuJDOzIKTd/BhUAHUMqxXl81THzJ3+fZxFwmTw
         sMhOBdi89hq7wfZV9JJ7WNAXvhrKDDkXCe4ziHSZbG5kCLhzWcXUVrrhjtPKGBpw+o5p
         8t1rBjGxOu9DCL8lHaZ6FD9PAxe8WJnB0E3DEeBuf/Gy7EZveAtNcaU2cz6AU7eqMfXm
         tvton/x5ToWXEvgqO/SWFOBjzTGXB2a0ND1Ir4Difmo90FJQYHbgZV1uUi7fiV2ffWaF
         gUag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=x1V6OHqN3EauZVYY6EyiL7lCxOhh04YiNYXgSPv0O1I=;
        b=DuItzAC2wslf4j+neoCjcpzo6r3lzac9OttpFqvytr92U8Z3931X3pHe2FYXhJMK2+
         gP3pe06dfhV3MWPyUnG40t+mA5Y4f0psUlZFv7S/DyOn3uz8tOtAgflVf8jFI4FtH9lE
         TkqTd62edEn/gDg//crUzpybVHLhcdR3na38CIRs6kupF5FOutSM+A5VwPOAZckPoceY
         3W+0dKH0rTBx7KNzlIZNiVNvYj5ezlXDLBCj4UhZRBQJfO4fdqX/lcNUGKMNdhssvZm0
         Odviul747Ptw/mRADwXEccUWHBTwdSp2YTSavMVwursWH7eWYtIyLJ+OGukJlWg2Hc9u
         45+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w16si4843449ejj.232.2019.07.22.08.42.59
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 30DF515A2;
	Mon, 22 Jul 2019 08:42:59 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9B72F3F694;
	Mon, 22 Jul 2019 08:42:56 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 12/21] mm: pagewalk: Allow walking without vma
Date: Mon, 22 Jul 2019 16:42:01 +0100
Message-Id: <20190722154210.42799-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
index 98373a9f88b8..1cbef99e9258 100644
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
+		} else if (pmd_leaf(*pmd)) {
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
+		} else if (pud_leaf(*pud)) {
+			continue;
+		}
 
 		if (walk->pmd_entry || walk->pte_entry)
 			err = walk_pmd_range(pud, addr, next, walk);
-- 
2.20.1

