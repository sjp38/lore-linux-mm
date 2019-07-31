Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40C74C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3083216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3083216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E519E8E001D; Wed, 31 Jul 2019 11:46:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E022D8E0003; Wed, 31 Jul 2019 11:46:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA5168E001D; Wed, 31 Jul 2019 11:46:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCF98E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y15so42689321edu.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x1V6OHqN3EauZVYY6EyiL7lCxOhh04YiNYXgSPv0O1I=;
        b=MGNMjmJcZYjgM/k36ioRx/r3pzROycROHXSEmyzMP+RK3jSu0eQjpXxZTj7ve063Op
         qELeChUOrDTVJR6nZCTJ//M48qT1xCV7MtYjwebhHZCjyDJc+BMYeMc0gUEjDo798lnV
         NXg2sTym2d6LonCueGcts0rV/MW1QZQ14CmVD34KN10H56m2iP+pQ5rnNs5Ge0sLjXqe
         NGy1FEWxS48eRkkF9JAzq0qrFANLrjkx6BmBaiq/icfGTJNaKP3SlNGbDlHLAncZcgFE
         hXa36cvFV9btjQCT/XSHabd8I6a0rAKRM49s5k60HoeoS4laMzkVCBvngqPxUoxFx1EQ
         d5mg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWQnuwoF/Pp62tjx+zlwjqxLbjmsgxhpWtYFr2VFEeXxlCQNQVh
	6r1ejxQRE0lmxLO7/VPUHL0tJ3LeD/zsTQnwd8blK8USGDD1qRQtPWmnPCCDNzk5Lrz+SweEUmz
	h1gIEYNiKFW7LbguwvxmF9iTKWX5xK9YM8exf1Zal7cIXnaOkHnHVFxSqnUW+8VjT4w==
X-Received: by 2002:aa7:df8b:: with SMTP id b11mr5444071edy.6.1564588009107;
        Wed, 31 Jul 2019 08:46:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwF7HyMwsByqmFYRqqZdnU8/bdQF4ekYsIJeHEoHh65dsbdn75mzkwmRumIbTqYFqOYHsOz
X-Received: by 2002:aa7:df8b:: with SMTP id b11mr5444002edy.6.1564588008290;
        Wed, 31 Jul 2019 08:46:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588008; cv=none;
        d=google.com; s=arc-20160816;
        b=GZynEnkklfElLR7b9nxNCbg7MnKQIi1K+F9djdTkQ/ViTWi7Ms4AI6b7yXbPAA5GPs
         h8FR0f3aINCVBo+UKbvULPS4QGxk1Ayv7wsCl0VJmFdobRbLKUvHsXNMcFrrXvwgulzi
         Qrl6OiHqcfaW5i/VPsx9ygwRZwogtGP7E4AHM1evoMVdProYktzoKUXCLcf83glpMBhf
         4+BLry76Qu0jCo3KfKVAcFhQ3Cv4rZUDMFVYLbTCVVNLqpKpCE7yoztRDV0NpuPsQRcH
         z5/fEZsDHNyAbLJ/SjiemFjj4I2RP7O21LahL9O3St191I9gFN80rR0VIohQk2zNUGZa
         Bv7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=x1V6OHqN3EauZVYY6EyiL7lCxOhh04YiNYXgSPv0O1I=;
        b=k1oBH5PMsu5yS9Iuk1TmOuxj83XoY0p+5qQ2ddPNDBjYko61mc56JkvBY5qubbH8/Q
         ysJTN6t0YJ/+SlTRxLc/w4WKXYedZPSJFzQWxmGldiKM5M01auk9KZXqxH/7DtU0Xkw2
         S/EMRU5jHJ2Yld2zjh5909D3mCyMBQltri84plunpen/YvvK4i50ruqLsCfNWpmVrGkK
         b2hJJNYGE3Msp4lp0Xt6TiuSe2bhObHr8RLY1VMrjIv6M5T7WIlKzwgnZZCHCdBy6sii
         B/SwrZ4tOPr/v89dfFDK7zSCWCthmRDeVh0ZWW4JFAH+PTIz/vOo+LUzHoEpJNpOgcD8
         5Bbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id a14si18225073ejr.135.2019.07.31.08.46.48
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7E73F15A2;
	Wed, 31 Jul 2019 08:46:47 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E93093F694;
	Wed, 31 Jul 2019 08:46:44 -0700 (PDT)
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
Subject: [PATCH v10 12/22] mm: pagewalk: Allow walking without vma
Date: Wed, 31 Jul 2019 16:45:53 +0100
Message-Id: <20190731154603.41797-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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

