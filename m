Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF0A8C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADBF420663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADBF420663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9EAB8E0013; Wed,  6 Mar 2019 10:51:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B76E18E0002; Wed,  6 Mar 2019 10:51:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A156A8E0013; Wed,  6 Mar 2019 10:51:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 485D98E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m25so6553359edd.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=RWGP8MQSkVeoeLICm8a+huNeS+QgLG9x4b8zbJ3u22Q0Od5cSZLMyNXtDmD5XJnK2K
         UstEu7e7ygrqx3G1qX7CWkuJu8pbhSTrx+rYlM/dfv/HsV9gsGM2ObDat5IKFkj26A/y
         LXH9ggj/uAY0+KGxL/1VV9sPutygGhNRnkjagec0IjPTA4w5EfIUcVl2G/1FZ+Xss4en
         5BX5yGNJjn8wBd/ShH9Mjeb+CekGgmkmXZIfnIg6PCf2Ko67NTHoOoTYiFGF9u3scfOJ
         g7yOXjIJSVe50wlfWY9Qb/SGIYXLgccxQbccZhDh1lTFH3G37MJnsBVI2WobXI8oDCwW
         uElg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVVbyu8b8NzISMaTiwIqw8UnAbsCIgtnl8oHZMS04W9rQGhajbp
	6C+sIIsHzFaqOspF04LLzs1G+3wi0/6iRzAR8r1xRg42c4ATaDDr5SambjvQKpMtkjL/I4gYvy4
	R3xcDO63bwRO1l3m0rdVd4/5QAUXXsctVnoZTfnhO1zuIi3IxtOTWNK56yK2M3Ky0xw==
X-Received: by 2002:a50:8eab:: with SMTP id w40mr24985888edw.172.1551887489515;
        Wed, 06 Mar 2019 07:51:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqwk9yH1bT3T7hC8Tl+StBsl9D2vekfGpdFU6gKha8/VtRTVeSftgJQJWM7hmzXmbPQAm9XC
X-Received: by 2002:a50:8eab:: with SMTP id w40mr24985784edw.172.1551887487981;
        Wed, 06 Mar 2019 07:51:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887487; cv=none;
        d=google.com; s=arc-20160816;
        b=JEilWf5TWxO7eo0C3g7xNWZiOdhHMfehKQoM4PGNMmOt3dSfAgK2T1Qw5CEnfCT03T
         tcGbt/LBl0WqZOwscduGX92OKu+d4VejNzipAjeZ/n0fPh1PMqLiyYevsgl7oQDAkUnm
         WKAELDkU/8pd1uyUoV/ngVNchQIcfdPKqBZkwrsbaR7tp7QA5qSmzyxIEqU8H4JH+5oN
         joiGm2NcI23irmpAQrGMMlj/Af0uy7h4IQakH64OO8/1rvMqq/qo2I6zjymMFZ6mrEX7
         U6gZWS6zo0J/W3yUGD2RdWQKJAk6uUB7K/5l1P8LyltQPuJoOfBzL7+bZCFhsYckLjdF
         PJ4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=DFHihknwM89do0+VIBn+dxBxbnUsigVuyvfjYgwl6DRk/c83vUPLlnO7lNT/VG6OMY
         fiqh59Bfk3C/j90QJHx5p7d4QwC8161avN24X9daUNmBMR8Xg/wVsTT+EYrfHpiFUofj
         hPkvOGqgrJrnLnCuVgOlp8RtViAowpffML3rxIA4bvMegIDO0tKHZ8ECuR831rM8+rqm
         zY89B5gGCEUnITOhkl04FLP681WMUfbM11yxl7Yv5lSuY6/2miJtM87ZiQsShAqfXjn5
         8a+qxJiRRR2wO+6Xf1yKSVe3lc0WOcQPmVLISXjEkGNWrfgXTwhJ99D+yn1W8xAayWwt
         J99w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p18si725435ejz.318.2019.03.06.07.51.27
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:27 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1760F1993;
	Wed,  6 Mar 2019 07:51:27 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D017A3F703;
	Wed,  6 Mar 2019 07:51:23 -0800 (PST)
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
Subject: [PATCH v4 11/19] mm: pagewalk: Allow walking without vma
Date: Wed,  6 Mar 2019 15:50:23 +0000
Message-Id: <20190306155031.4291-12-steven.price@arm.com>
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

