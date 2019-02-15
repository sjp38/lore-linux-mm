Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C96AC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1888D21924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1888D21924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 819C08E0009; Fri, 15 Feb 2019 12:03:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CA928E0001; Fri, 15 Feb 2019 12:03:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 692458E0009; Fri, 15 Feb 2019 12:03:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 130F38E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f11so4241998edi.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=igub7qrpJgjRv+2v35QNpXcDRvocVxsP5pFwSPlipmo=;
        b=E4h/Oz/bgeCZI4rhfYwQqmFoNN92mvBdlCL4I4I63qWs54nlEXhb3W24mq6Aff1kBx
         cK0npFrWJ2fgGikglcPRcLTAggpYj2zXTXR3luVUHITogERzAIPpHEkFnL6jzOJ806iw
         vVMROt55oL8VXhe6JAKUoACSt27QKzdLYm/JoMZHWYdY0z4eTSpFINQ7Z7stRM2wuPLd
         2G7ME/T/9mtEyAni8HVmjq7Vr6feOaqbDBBYaKemVBm2SCXzg8m/JriqMClBg6yt6uJF
         +RWAz19cJj1LRcQx4iXTCHZEPC8yiq3nHtiZ8AONzrNvnEq73B8BCKcPx/sG2H/FvX/+
         dG+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubVGporOQ8YMQyU5sgEp7dKavRBY+cwfWsu+4P7mDQPT85tC7Ah
	vnqRSUF+rw3gIvTBmsNLktazx+id/hVMb8qQNRfqKq9imwzRqzHcdkElwNorvWTgWvfsKSCyQvf
	8TUhg73+uPJicpXpYwl2VDE12aNP4+5OdRm+7YB6gNEVtoUHz2piNuyZhtFnrrpgXEQ==
X-Received: by 2002:a17:906:3b8e:: with SMTP id u14mr7406390ejf.130.1550250207548;
        Fri, 15 Feb 2019 09:03:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDBAJ0q5YL4mKmCwdufgp9UR3oZyaE28PCbVB4Z0ctwjZFyCujhCgA044GX5GUf9sT2KTE
X-Received: by 2002:a17:906:3b8e:: with SMTP id u14mr7406320ejf.130.1550250206218;
        Fri, 15 Feb 2019 09:03:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250206; cv=none;
        d=google.com; s=arc-20160816;
        b=ZXpB4Zid8Z458YH7a1Vj4OIpOgkpQJqpyPsz4TQzGnYlRFUTZDlOLSE7/CNDH/Dt2s
         usxil/gaQ54Lb9mFxA1E6kN++eq+fUZlGGNGUbqnAd61/IJhGsSqmhYzCZANTxoKefu9
         CrKAj5tzmP7oZ+4iq9ddFG70g3ZCH2cuFfrN6q7P9v3lgDKoj+jrRIxxDh22G+HLlKiu
         YUa2a0powlawFcCp4avFlx072dNTwaV6wtiXLSbjCqN1xJrHgEitD5y5sZrNatda86jp
         seUKqrfMS/+ToE5eQlHEEiqGfaPMdlXu5wvu6cyTgzvAxQX5o2b7HFfL90gEiWHLuXs1
         mWVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=igub7qrpJgjRv+2v35QNpXcDRvocVxsP5pFwSPlipmo=;
        b=nnXQmDTQyo52zr+TXpt2xIU5mBA5Nj/6L5pvVECEDwIV0uxSXg+rmsp6KhlBitdIh1
         CQUy/bcr5tNYI2RUbD3gupp99H17rcoEZyVHpjq2SVBeR5s5JI4nkKv+fKMqEdcdDoGv
         AlyV+zc1RHSJx4P4s/qmqdxOfBle0ZexjF0q+0CQ5nq4WLHxNrEmDa8ubkMq5anHGZkH
         kkbvP4/t4IETrXHobFWixXaXGxDh1pNW9Xf3grzTYdEjBP+SNl9Yn91XxL8euoTWPlhZ
         VhESq2hU7gtETKs13SBAggmBmlXPvjey+Er1o65mxOdtTlTqvUTk2fEYaDX7a3HYSK22
         mkUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s7si689087eju.171.2019.02.15.09.03.25
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:26 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1763AEBD;
	Fri, 15 Feb 2019 09:03:25 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 234B13F557;
	Fri, 15 Feb 2019 09:03:21 -0800 (PST)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
Date: Fri, 15 Feb 2019 17:02:27 +0000
Message-Id: <20190215170235.23360-7-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215170235.23360-1-steven.price@arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
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

Note that depth starts at 0 for a PGD so that PUD/PMD/PTE retain their
natural numbers as levels 2/3/4.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 fs/proc/task_mmu.c |  4 ++--
 include/linux/mm.h |  5 +++--
 mm/hmm.c           |  2 +-
 mm/migrate.c       |  1 +
 mm/mincore.c       |  1 +
 mm/pagewalk.c      | 16 ++++++++++------
 6 files changed, 18 insertions(+), 11 deletions(-)

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
index 1a4b1615d012..0418a018d7b3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1420,7 +1420,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *	       pmd_trans_huge() pmds.  They may simply choose to
  *	       split_huge_page() instead of handling it explicitly.
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
- * @pte_hole: if set, called for each hole at all levels
+ * @pte_hole: if set, called for each hole at all levels,
+ *            depth is -1 if not known
  * @hugetlb_entry: if set, called for each hugetlb entry
  * @test_walk: caller specific callback function to determine whether
  *             we walk over the current vma or not. Returning 0
@@ -1445,7 +1446,7 @@ struct mm_walk {
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
index dac0c848b458..b8038f852f06 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -38,7 +38,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, 3, walk);
 			if (err)
 				break;
 			continue;
@@ -88,7 +88,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		next = pud_addr_end(addr, end);
 		if (pud_none(*pud)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, 2, walk);
 			if (err)
 				break;
 			continue;
@@ -123,13 +123,17 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	p4d_t *p4d;
 	unsigned long next;
 	int err = 0;
+	/* If the p4ds are actually just pgds then we should report a depth
+	 * of 0 not 1 (as a missing entry is really a missing pgd
+	 */
+	int depth = (PTRS_PER_P4D == 1)?0:1;
 
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
@@ -160,7 +164,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, 0, walk);
 			if (err)
 				break;
 			continue;
@@ -206,7 +210,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		if (pte)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		else if (walk->pte_hole)
-			err = walk->pte_hole(addr, next, walk);
+			err = walk->pte_hole(addr, next, -1, walk);
 
 		if (err)
 			break;
@@ -249,7 +253,7 @@ static int walk_page_test(unsigned long start, unsigned long end,
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

