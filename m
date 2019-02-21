Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69569C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22A8B2086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22A8B2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFB658E0079; Thu, 21 Feb 2019 06:35:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAB3B8E0075; Thu, 21 Feb 2019 06:35:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9A028E0079; Thu, 21 Feb 2019 06:35:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA4B8E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so1903380eds.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zJK9tQmzH2wt8ZgtuBGoRD5SE3Dtp+m3gB1hPWai3es=;
        b=Y53z4OTMxQFd/JIUOL8FgtvCmRwdN0Mjz/PIUy7XTkVM202K2SoDiefzF2vMxMdDKQ
         QK9mNx2JSvfWVs2KP/ndQ4UKkTLuqSaZwKjI9Jdaup720VlNDkeF3y6Lxgsv3z5Q9SPq
         OI8X8cTBiIUM+U+qA88qQsQ5NkB+xeY0WIC6z3KlHzN6Ra4omNl84sRvjZsxDmFzQYhl
         SUGd4K8PSqB+tr84uxpIPIxExBzJYfTjW2WLBV47uqWLk63WSYcfbtfpf99J3qk0xIUh
         2N2UeC/cR09SZ/V8uDA8qwkPFa4/iag+hrhyfPWyInBfBEe7LMMrPUs/B5S8+4Foupm9
         yD1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuad+fuCSZmtzQXNQFP1XR+Q8ljKuR/C+J7aHq71N9KJx6/HOOyX
	qdXpTZE0tIXNxEYz101ZAd1zh/e+AiDukd+NEhOBlsGVZoMqIpdtkJQK1iCYLv0eL/LLlaww0Zx
	EsD5Er44zCrCaAyeqiL7V63aNCwvbZr6SgiRlMCNSRtTROb+2aPhk9VGunp/n/1ZevQ==
X-Received: by 2002:a50:d55a:: with SMTP id f26mr15214039edj.292.1550748940781;
        Thu, 21 Feb 2019 03:35:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZPdb1esJA2PJYlCysk85ZwkWrApAk3SVY9cu0iaQ753RsGACzwCHSBSogUIA2x450PzxIg
X-Received: by 2002:a50:d55a:: with SMTP id f26mr15213956edj.292.1550748939439;
        Thu, 21 Feb 2019 03:35:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748939; cv=none;
        d=google.com; s=arc-20160816;
        b=K0zfiSNTA2mXNf4y1vsb3Dm+2px/C0wXKHBQq21chDV2ZTMrwNgRlDk4R/x1id8vIN
         fXQwvw2CQ0YBZcKjmPhqT66BHE03+rEF06zCDTjvEYQel23Um1ezdn1MKvwiShYlPZsd
         FSvf6PIa2cnUN9Gf/nH66kUw+ib/EDlDdMihOAl6TZf43OftyDoxAZ6VmH2O5g6thH5Q
         5TBZb0iAct8RIl6xSVLkiF2FkIWFzgnHKUvEeZ8ZenSZCLxOUW5mktr+csP6sOujA4VE
         jB+rfSQ0ikrjmpr7oMONySAolkWNqJIijbmo6gaV6i91mZGGeNj/7Q3bX4SYMcmdBKMb
         Tdkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zJK9tQmzH2wt8ZgtuBGoRD5SE3Dtp+m3gB1hPWai3es=;
        b=WgiCoCjYBMlkXmUwU+pLgB8MAXe09E4qTBoxcJmMERCl3eeXNxEK+zwqufXP4j/U/K
         YstuVYWrMkTGGhe2YffBasRVZwfHmc4OZ8ZY6/kuVxnIbhIbu/sv5Mt4dcDdvB5IT5cX
         HhHMoEEcSSzBqCB4qTB4VhoeU/p8W85sBIVVj6xz0bloRWhuJ/fUjNAT1aLY2rYto7I1
         F3d4ux2I/afoOCwHztvvfXD96RBzpZNB6rDsf8g943iezbN013uEl6EplWZv9whyCaE0
         jwvtOF8AN4XTeKm+ZBRCpTC65e3tNp9wHhmZIOuoAKMhvDuJ7XrsbgnTFum8eiZOPv0i
         +mcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z48si40329edb.159.2019.02.21.03.35.39
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:39 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6450D165C;
	Thu, 21 Feb 2019 03:35:38 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D5F223F5C1;
	Thu, 21 Feb 2019 03:35:34 -0800 (PST)
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
Subject: [PATCH v2 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
Date: Thu, 21 Feb 2019 11:34:55 +0000
Message-Id: <20190221113502.54153-7-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190221113502.54153-1-steven.price@arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pte_hole() callback is called at multiple levels of the page tables.
Code dumping the kernel page tables needs to know what at what depth
the missing entry is. Add this is an extra parameter to pte_hole().
When the depth isn't know (e.g. processing a vma) then -1 is passed.

The depth that is reported is the actual level where the entry is
missing (ignoring any folding that is in place), i.e. any levels where
PTRS_PER_P?D is set to 1 are ignored.

Note that depth starts at 0 for a PGD so that PUD/PMD/PTE retain their
natural numbers as levels 2/3/4.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 fs/proc/task_mmu.c |  4 ++--
 include/linux/mm.h |  6 ++++--
 mm/hmm.c           |  2 +-
 mm/migrate.c       |  1 +
 mm/mincore.c       |  1 +
 mm/pagewalk.c      | 31 +++++++++++++++++++++++++------
 6 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..91131cd4e9e0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -474,7 +474,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 #ifdef CONFIG_SHMEM
 static int smaps_pte_hole(unsigned long addr, unsigned long end,
-		struct mm_walk *walk)
+			  __always_unused int depth, struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
 
@@ -1203,7 +1203,7 @@ static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
 }
 
 static int pagemap_pte_hole(unsigned long start, unsigned long end,
-				struct mm_walk *walk)
+			    __always_unused int depth, struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
 	unsigned long addr = start;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1a4b1615d012..4ae3634a9118 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1420,7 +1420,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *	       pmd_trans_huge() pmds.  They may simply choose to
  *	       split_huge_page() instead of handling it explicitly.
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
- * @pte_hole: if set, called for each hole at all levels
+ * @pte_hole: if set, called for each hole at all levels,
+ *            depth is -1 if not known, 0:PGD, 1:P4D, 2:PUD, 3:PMD, 4:PTE
+ *            any depths where PTRS_PER_P?D is equal to 1 are skipped
  * @hugetlb_entry: if set, called for each hugetlb entry
  * @test_walk: caller specific callback function to determine whether
  *             we walk over the current vma or not. Returning 0
@@ -1445,7 +1447,7 @@ struct mm_walk {
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_hole)(unsigned long addr, unsigned long next,
-			struct mm_walk *walk);
+			int depth, struct mm_walk *walk);
 	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
diff --git a/mm/hmm.c b/mm/hmm.c
index a04e4b810610..e3e6b8fda437 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -440,7 +440,7 @@ static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 }
 
 static int hmm_vma_walk_hole(unsigned long addr, unsigned long end,
-			     struct mm_walk *walk)
+			     __always_unused int depth, struct mm_walk *walk)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..8b62a9fecb5c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2121,6 +2121,7 @@ struct migrate_vma {
 
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
+				    __always_unused int depth,
 				    struct mm_walk *walk)
 {
 	struct migrate_vma *migrate = walk->private;
diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..c4edbc688241 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -104,6 +104,7 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 }
 
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
+				   __always_unused int depth,
 				   struct mm_walk *walk)
 {
 	walk->private += __mincore_unmapped_range(addr, end,
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index dac0c848b458..57946bcd810c 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -4,6 +4,22 @@
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
 
+/*
+ * We want to know the real level where a entry is located ignoring any
+ * folding of levels which may be happening. For example if p4d is folded then
+ * a missing entry found at level 1 (p4d) is actually at level 0 (pgd).
+ */
+static int real_depth(int depth)
+{
+	if (depth == 3 && PTRS_PER_PMD == 1)
+		depth = 2;
+	if (depth == 2 && PTRS_PER_PUD == 1)
+		depth = 1;
+	if (depth == 1 && PTRS_PER_P4D == 1)
+		depth = 0;
+	return depth;
+}
+
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
 {
@@ -31,6 +47,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	pmd_t *pmd;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(3);
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -38,7 +55,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -81,6 +98,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	pud_t *pud;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(2);
 
 	pud = pud_offset(p4d, addr);
 	do {
@@ -88,7 +106,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		next = pud_addr_end(addr, end);
 		if (pud_none(*pud)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -123,13 +141,14 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	p4d_t *p4d;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(1);
 
 	p4d = p4d_offset(pgd, addr);
 	do {
 		next = p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -160,7 +179,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, 0, walk);
 			if (err)
 				break;
 			continue;
@@ -206,7 +225,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		if (pte)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		else if (walk->pte_hole)
-			err = walk->pte_hole(addr, next, walk);
+			err = walk->pte_hole(addr, next, -1, walk);
 
 		if (err)
 			break;
@@ -249,7 +268,7 @@ static int walk_page_test(unsigned long start, unsigned long end,
 	if (vma->vm_flags & VM_PFNMAP) {
 		int err = 1;
 		if (walk->pte_hole)
-			err = walk->pte_hole(start, end, walk);
+			err = walk->pte_hole(start, end, -1, walk);
 		return err ? err : 1;
 	}
 	return 0;
-- 
2.20.1

