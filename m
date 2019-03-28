Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CCECC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41538206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41538206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE5706B026B; Thu, 28 Mar 2019 11:22:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E436B6B026C; Thu, 28 Mar 2019 11:22:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71AA6B026D; Thu, 28 Mar 2019 11:22:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 732536B026B
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c41so8244021edb.7
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=Ay53fsxAQOSwT5tPoPoQC1np6SFIr1qqDFJgqpuPY5XhDoXZ7Ql8e1aogDWAy/FPYq
         PV5uF1AX3y4slx5AnKhwEnGxYpAyJfoS/6DBBWSeOAEOzzo7+wsD+3TeH4iCNiWa778d
         zloah5ZFtocWGOfIu61Z98pfWRYuGRlkVQv7P/+ca345VpBoJhIZR6LKCH+KMOd3yH6W
         J18Zd7DSNeFcFxZkYuUtFHrJ6AegeVreUX6qDXBNPcGkiRA3crAFPBjxA/ly/DtiH431
         Jpom7Eal6I9QU7BNsHuBcrSidGw5+bWJXdOTEZL28JrH1/3dTCgC4hpV8K8m3DAN5Grh
         f+/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUqFh5Z53eWCuGbk/y0ekAieBzqP820Ze9bd/Lp+lWOKlR1LlIG
	dth8lWAOB25++taIfjNw7MY0UFUAoTg4MkdjJSAzSYb4f7cfaW+mBfz+Fivsi+99A1HPeHZqpBq
	Ojyl4HGylv6kjTwInVHH7TqDEtFX8a19p6SyWxa70rTYgwAAak2GXP3qWZv4WXyyN4Q==
X-Received: by 2002:a17:906:d512:: with SMTP id ge18mr5106810ejb.232.1553786561992;
        Thu, 28 Mar 2019 08:22:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEciAHPg6UFC3VEHiuJBbPQPVgHbSGFZcz9w65tXq+H1xQcY1HzYJNmZXneCiQ3lrUiYJa
X-Received: by 2002:a17:906:d512:: with SMTP id ge18mr5106741ejb.232.1553786560628;
        Thu, 28 Mar 2019 08:22:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786560; cv=none;
        d=google.com; s=arc-20160816;
        b=nw1bAoJiK8HLnVIKYCmahrvDr1+4flbrclFCQQ4xEYUzQs1Po0k+7HH6C2nY+U+SSE
         ++Pafm1S2tEqvxrGuZfISKKxoyozPRpQHz+q6Tq/a3Y8W8NpmgN2LexZAXBazSq5lkVq
         DUeAnY7OUDkI3YLGLqoEDz3AOquft1zrQIejXvDnUZjmpG3suNNBGkSJVh+nJZ2fYSp9
         zEVIKdtaCM9cSomXx3xaPYSBU9KqfUi6r+i4chhlOXDz4gTt1nc/REOx6A8/6Dj6WHU1
         MPj4Ma3EDjFOkWZkdY0uMz12xlTdUfslkPlcBPD7EOk1iV2a+glvofiWHwS9UNoVtDFH
         SRiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=VDhj0GXg7JsQvD7Vj01QccXpL4zj6vNo7eUEaZ/ELrfvZ+Q21lUGJyNMgGf9kdTuK1
         hvWhoPOXceJU6HL0kjvWbo04iP82sv0T0WPtbIAR80Fe4hCCedz77TvCz/TE5AqfjBLr
         73iHaTVVOSXTLZmx3Z1fPUhGLFR8vUOn4wEKvS80xDT6FQlHSYoYuwqOW6FeKlE007YV
         JBK7mbUQqtnH2XLl5HevDeDYT4KUldd0H4Yn3lOZgE3ww909iWYjxNixqFeJKhakHez1
         +ymdEfM4VSk1ySusTvxtXGROp6YiigcOh81TzJmd70Pg2FB16vkUVMjdIShcomkiI16Q
         2ihA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r4si1419254eda.282.2019.03.28.08.22.40
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AF4B216A3;
	Thu, 28 Mar 2019 08:22:39 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 687DF3F557;
	Thu, 28 Mar 2019 08:22:36 -0700 (PDT)
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
Subject: [PATCH v7 12/20] mm: pagewalk: Allow walking without vma
Date: Thu, 28 Mar 2019 15:20:56 +0000
Message-Id: <20190328152104.23106-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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

