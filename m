Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3F72C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A28F3206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A28F3206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F55B6B026A; Thu, 28 Mar 2019 11:22:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47E5E6B026B; Thu, 28 Mar 2019 11:22:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286026B026C; Thu, 28 Mar 2019 11:22:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA6B96B026A
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c40so6983861eda.10
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ahKSq6BT07JiMm6WJgk15VRtm9UPqW7p0TN43pTC2F8=;
        b=ob8WGew60srqyDqBMANqsre5UOO7DKk5A5BKLKZgIGzwQREZxtFV6C305Q15wAbvbq
         XPKnH/pWrcxdTMC+qkyAQcF8Lbwt4/U1fBT6aQYonbUKnOwhWVqgSw1Vq5BNLzXr7Lsx
         KToUsBu4tvOj+kEVTWOCQp2jgIjd6f2Hv/Ngy87KvsuK1qSORmW0OJePQovNYksQA8LB
         wmV4goybjIxiryGg2hvLMr2B7MgtuMWY0B+5jmbg3RfCRTi3VkOmqcgzqdB9ujqvgtiq
         QOGwUJiXk9jKGBnFNjmcPDvdztU+YQmREHoRpW+sxrmoBQAz8ar3h9JLdao+d9VGB9DU
         CKJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWClZIyuR0OF4WJMI6ParFqCvuzG9hzLmzVZ6ytGFttotwrSnLG
	9t80jgYSWH04QpDH4cAykMRA3qfp7ForocGOaNw4YfUILrwT5ATMSmtDVHQm3hpZNbYr9iItFEZ
	7KN/V6B9v21ztT14ifL0y2AtuwaoLx+WrqMlrI7MX5EWdrl9Lww1jOBG3mwkY0M6h/g==
X-Received: by 2002:a50:a546:: with SMTP id z6mr29181390edb.30.1553786558329;
        Thu, 28 Mar 2019 08:22:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIBiSZXn18Zee8yCIqCB9me1PY5Lnz22hnKXgK7u6PDjj0IlBHSRfpkXKGdyc2zDbAFBXp
X-Received: by 2002:a50:a546:: with SMTP id z6mr29181321edb.30.1553786557294;
        Thu, 28 Mar 2019 08:22:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786557; cv=none;
        d=google.com; s=arc-20160816;
        b=dFdwGsmkfJbVqZ9YxXP1F0FJkRwYRBokK2GVGHfd9QO3gMKTDi5U29A+j9H8nyxi1q
         I5lUo04dvROv3AjvjFAQXHvklaLk+iR0vDCwXKnrpzQwz0Oh8ZEGWA7dmR77SSTVUIUO
         x/j0jHf6Le0Q1y9Kik7Mmveh/FG/VWrXJ+7WcfpTy+VrJT893SKhe3igxvkUhUpJ8pCC
         V2/E30uCMCtvtUauJ7XoDZaWBJQIHUyWsqR0A6uJsOLjbUrrcaQiuopj7L1ftlEdmTKJ
         e74cinPQJrc4cc2uXlY+WgGiowouSZJ8K6NwwRiorV5Ecu4z3VFydBDbxrT5dxVOw9Em
         8oPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ahKSq6BT07JiMm6WJgk15VRtm9UPqW7p0TN43pTC2F8=;
        b=hsIh2a+XEyJaxISzbJ1Bix1IQjq6VkHPMpO67NNpIgrM1+h+LaSoY8lo9DRIxrs3X1
         ISxCoOxgqL6/uOC08NjppKVCWw29CN3uZVIYL9/QLRTT98HgYuzt+fBAJWMRLPv2o8kY
         VbVyGeg1NYJ/ny7LAvLvm04MOYanbIAUBJWrvvJqY1/KBSMXiTabGxn8f0rHJbFeXYYM
         1u3EC+ane2pEvFFYMS2JQc4MXCyihUgQVNQO8Za/ZK70RJCaw1Q7Gir99Zx29vjwBSSl
         KaACtMnYgtYG/OezeYvS+uc8x29stYyQzDSdymwL/xr5ed8ZzSPJKahPKIjv7O7f2Iob
         hkbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r3si2419585eda.229.2019.03.28.08.22.36
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 28EF7169E;
	Thu, 28 Mar 2019 08:22:36 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D662E3F557;
	Thu, 28 Mar 2019 08:22:32 -0700 (PDT)
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
Subject: [PATCH v7 11/20] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Thu, 28 Mar 2019 15:20:55 +0000
Message-Id: <20190328152104.23106-12-steven.price@arm.com>
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

pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
no users. We're about to add users so reintroduce them, along with
p4d_entry() as we now have 5 levels of tables.

Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
PUD-sized transparent hugepages") already re-added pud_entry() but with
different semantics to the other callbacks. Since there have never
been upstream users of this, revert the semantics back to match the
other callbacks. This means pud_entry() is called for all entries, not
just transparent huge pages.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/mm.h | 15 +++++++++------
 mm/pagewalk.c      | 27 ++++++++++++++++-----------
 2 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..f6de08c116e6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1367,15 +1367,14 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
- * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
- *	       this handler should only handle pud_trans_huge() puds.
- *	       the pmd_entry or pte_entry callbacks will be used for
- *	       regular PUDs.
- * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
+ * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
+ * @p4d_entry: if set, called for each non-empty P4D entry
+ * @pud_entry: if set, called for each non-empty PUD entry
+ * @pmd_entry: if set, called for each non-empty PMD entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
  *	       split_huge_page() instead of handling it explicitly.
- * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
+ * @pte_entry: if set, called for each non-empty PTE (lowest-level) entry
  * @pte_hole: if set, called for each hole at all levels
  * @hugetlb_entry: if set, called for each hugetlb entry
  * @test_walk: caller specific callback function to determine whether
@@ -1390,6 +1389,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
+	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
+	int (*p4d_entry)(p4d_t *p4d, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
 	int (*pud_entry)(pud_t *pud, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index c3084ff2569d..98373a9f88b8 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -90,15 +90,9 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		}
 
 		if (walk->pud_entry) {
-			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
-
-			if (ptl) {
-				err = walk->pud_entry(pud, addr, next, walk);
-				spin_unlock(ptl);
-				if (err)
-					break;
-				continue;
-			}
+			err = walk->pud_entry(pud, addr, next, walk);
+			if (err)
+				break;
 		}
 
 		split_huge_pud(walk->vma, pud, addr);
@@ -131,7 +125,12 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (walk->p4d_entry) {
+			err = walk->p4d_entry(p4d, addr, next, walk);
+			if (err)
+				break;
+		}
+		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry)
 			err = walk_pud_range(p4d, addr, next, walk);
 		if (err)
 			break;
@@ -157,7 +156,13 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (walk->pgd_entry) {
+			err = walk->pgd_entry(pgd, addr, next, walk);
+			if (err)
+				break;
+		}
+		if (walk->p4d_entry || walk->pud_entry || walk->pmd_entry ||
+				walk->pte_entry)
 			err = walk_p4d_range(pgd, addr, next, walk);
 		if (err)
 			break;
-- 
2.20.1

