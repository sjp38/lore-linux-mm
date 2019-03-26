Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CCB3C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27E3A206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27E3A206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CED1E6B0279; Tue, 26 Mar 2019 12:27:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9BD46B027C; Tue, 26 Mar 2019 12:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B12316B027B; Tue, 26 Mar 2019 12:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 607AE6B0279
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so4170659edq.0
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=WxLmeBl6WAraYF8HjBpkCz+kI2JCMYvFT/L+SmCsiyBkW5YgH8rn3zigjXWj7ajEik
         jCbeanMKCJuowkfmhDmKLU0XBdqQ4bnmNcxppk3bNF2hBB6HoyHjP7hpj66s3w5XIKla
         44mkR1ulkqP3O1SmdHB3u99Xix4/97PCrKPensNHSH4oNN60aROEZa5PV8SS4Vv/oAnT
         iZm2AOcwjP6o7H9P/23I4mdgWL1/JwSAtiy0NZX8tqOOeHA67x6ZdYwd2W3R3YvWGPOQ
         ytYEc1PagKzfyf0DFNhV3YTq7sqzwHPHIq6WuxQOMh0+ozD6HFKymWS5zuklQBjqcCMf
         MsAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAX74akgJXlkZ+8QS5vwLl7EV5Wfd94+KEP4RplBnLF+ohXB2kfP
	Vf19SKJz/ZXdFXlI4A6KEauu3QzcYDRLZpQVi3QPwePavauoYm7Ry7u5Rntn9g/cF+8WlTdsCbg
	V3Ip0BZGZ+VM1O0CHnFU/VvikDwGPM2Q7tpi0BfLQGBlR34xJ+GJtGvpQGRNXHPpnVA==
X-Received: by 2002:a50:b4c9:: with SMTP id x9mr10474834edd.132.1553617638907;
        Tue, 26 Mar 2019 09:27:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHxG0jXjZVU+L8YFPxcqJFXjdcAMYnM4ZBm5uMO2w0Qgd9lJ87S/n5yfpDQZxiJ9VUn09l
X-Received: by 2002:a50:b4c9:: with SMTP id x9mr10474768edd.132.1553617637601;
        Tue, 26 Mar 2019 09:27:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617637; cv=none;
        d=google.com; s=arc-20160816;
        b=gAsWQcf9xSPWDI3MEnSs+3FApRmiEReIpLV8fm6mXApHe1Rreml4H3aqe9ynTAu2/h
         Ux3UQkj1bW0KbURxu8dsqM2QKa8Op3yCVVL9I3+rUsy3ICmvvOrv9WOxHt/6oLfqjFL1
         G8j4MncNqlyCI4AM1Hst0CVzFVPMmJDoGpaNa7k/LUdCkCS6nL70mcspHFXRwvx0vsoC
         eSAWfnWPfAbDRagB1FWDg2vu5K7JUamw90bfIdsPsodLoTHj0z1mYNvdJoh/+aiUwXr1
         6+gW4D+bJhzJcg1cS9JoEYP7VJNwNzbMi9tCCCtcn8xmwMwKjUc0lF8ngrlwx6VO91qr
         UrhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=rVfMWnZ09JYFAOtRV/bANq/xeVx/JGXS2jvTkn9XrO2g8UPkkuTJDSUxK64wkWvuW4
         T1BKCpa7O0UKkgBpAxgqBmTPL+/EH9p0hS+8/rf4OcQNC4ksVOUt76I2CLeSrxbmwR11
         MmfjoUHRFPfBmosxVSnajwsP/Avurl7ci/l00oL+shaEtukwXzil29EfUYiNrcPNrQVQ
         hzpracWtiZEacP5Xoj01LOUWJXkMFmaMB9qSeIScNZ09mR46xC6vvj+YQeGwsNicLClg
         ticVerdmeFBRh/39tsaFbEL7g2J33VQA/QD25rItiz/zNWW58aANt+g/OG5AAGHqsmYZ
         pJvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y7si2569577ejc.246.2019.03.26.09.27.17
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BC7D6174E;
	Tue, 26 Mar 2019 09:27:16 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 805E93F614;
	Tue, 26 Mar 2019 09:27:13 -0700 (PDT)
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
Subject: [PATCH v6 11/19] mm: pagewalk: Allow walking without vma
Date: Tue, 26 Mar 2019 16:26:16 +0000
Message-Id: <20190326162624.20736-12-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

