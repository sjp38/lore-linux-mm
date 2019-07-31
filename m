Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0A1FC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96D30208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96D30208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D18A88E001F; Wed, 31 Jul 2019 11:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF0D08E0003; Wed, 31 Jul 2019 11:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB8258E001F; Wed, 31 Jul 2019 11:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69E2E8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so42688922edt.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wIgp+k+2ujziSCzMqofK2+n/6Gw2lFVBBkY93b4Ysm4=;
        b=GGn7iP5z90rsnJCOK+ANtmrnfz/6G5N1uImnNDqBbhdr6QNqiW/irQrubAh2ztmcpO
         zYcPFvM8Q7VX0FJw1s3X7/Syf55ySzx/TUnC7EdOg5/wrqMKcErU7C9ULcX/H1QuXJlb
         bTebfMInYj4uB/vLzD8RYZSMNx6VobQoAvUWIompi6CXu/Wf1SU/RBP7l5FXLg88sE1e
         u4+QYIMMWI27X1gOOEqmG+ln8mQO/zkNjwqrepTNX3UkBB1Do6gukUrAaTZw6XMh60Gu
         QoTX5c5pSTef2sDj+cfip9IX4bbf2j68Bz96wcZuuf62hXGY4An5xI2htDhb8VS1mCD9
         srwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW0mOfYhKRPxRbTHHs5Zbs8yrPuGMukVw0iPo/LcHzL5PnbsYvL
	hYkWspPZT+SvYNVhhR7IcQSJD1ZXftr6zsU0OPdfLyPlk3y1Ctac2OWHRqb+0+0lANkHPkSI+E3
	Y22BRnwO2QJTRTYBu58dcI0EBYxZTMqmtfkGw0l0doni/VQFwbruaSrtDLMT+dC31Ug==
X-Received: by 2002:a17:906:1596:: with SMTP id k22mr12723267ejd.102.1564588014966;
        Wed, 31 Jul 2019 08:46:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlydKkelRmdCxCFCWvkjEJ7ngytgzIgQIcDX3aDCdrvcOht8ZDqqwzCkOqtyjxpplzRQN9
X-Received: by 2002:a17:906:1596:: with SMTP id k22mr12723202ejd.102.1564588013931;
        Wed, 31 Jul 2019 08:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588013; cv=none;
        d=google.com; s=arc-20160816;
        b=qxFqwJtG18UlI9xUe+AxpwrAVf8vtygyXQqIJ586gqxkFLFhg2h84+E9SxWyBkR0vI
         518j6bI1+Eqim5JeSyltUdjWZHosap58f5KhrY0MZTVu9fqcYIf/nLEQH6yOT3chOXO6
         q8/rRbgsNIPBM1vZuXfmr4u5EKUPSfjqUXE8SOjfnz4uHI3U5VjK5DAnsl4QIVXT9C6M
         IDfYipH6+l2c6plAXqtqux/T05yMW9jxJYDdQgt0t+D10NonFy0cgZFZeC3c24OILhfy
         N1B/XWeeg6wLr4SFZiCM//oAtYyRiYD5Ftkzk26lLFOCMMbIWFX1Jdc+hEWZ1ZD8nxjv
         KWVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wIgp+k+2ujziSCzMqofK2+n/6Gw2lFVBBkY93b4Ysm4=;
        b=gObdcThb1Mv4Wfp+37UrVkdTiMBj+2m+me/Huw74C+U3XVlCyu3MW5HLF6ZMBA57pL
         WGf1aKI6vLRpNp1ljkqkgAYsyXD1aGuWPf7WhHN7G7jHpIhT8fKTAQOBdPtsWLeGPyy+
         tgLI7bVVgwmbVgqvhsP8EuQiqwudlwrL8DnjfGBiMvgdZJnEv3q1ZQJkeGICVQd+TS58
         M0oiglLkMWC1G1efspvv6XskSrV4tGNjDeS8xB3pEoEDG+f2njijTgUy5gdT1Uliu9+M
         GpDEZfWNvKSzcL1wsw4KO/Br8TLsXwNM7m+5+RbEfAjImskWHTQAk83RN7DRrrs9ZOUb
         fuhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h10si21523838edh.141.2019.07.31.08.46.53
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 16A1B1570;
	Wed, 31 Jul 2019 08:46:53 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8125E3F694;
	Wed, 31 Jul 2019 08:46:50 -0700 (PDT)
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
Subject: [PATCH v10 14/22] mm: pagewalk: Add 'depth' parameter to pte_hole
Date: Wed, 31 Jul 2019 16:45:55 +0100
Message-Id: <20190731154603.41797-15-steven.price@arm.com>
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
index 731642e0f5a0..b2f87fde69eb 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -504,7 +504,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 #ifdef CONFIG_SHMEM
 static int smaps_pte_hole(unsigned long addr, unsigned long end,
-		struct mm_walk *walk)
+			  __always_unused int depth, struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
 
@@ -1274,7 +1274,7 @@ static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
 }
 
 static int pagemap_pte_hole(unsigned long start, unsigned long end,
-				struct mm_walk *walk)
+			    __always_unused int depth, struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
 	unsigned long addr = start;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e2581ec5324e..6b2e6d65cb4c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1440,7 +1440,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *	       pmd_trans_huge() pmds.  They may simply choose to
  *	       split_huge_page() instead of handling it explicitly.
  * @pte_entry: if set, called for each non-empty PTE (lowest-level) entry
- * @pte_hole: if set, called for each hole at all levels
+ * @pte_hole: if set, called for each hole at all levels,
+ *            depth is -1 if not known, 0:PGD, 1:P4D, 2:PUD, 3:PMD, 4:PTE
+ *            any depths where PTRS_PER_P?D is equal to 1 are skipped
  * @hugetlb_entry: if set, called for each hugetlb entry
  * @test_walk: caller specific callback function to determine whether
  *             we walk over the current vma or not. Returning 0
@@ -1473,7 +1475,7 @@ struct mm_walk {
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_hole)(unsigned long addr, unsigned long next,
-			struct mm_walk *walk);
+			int depth, struct mm_walk *walk);
 	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
diff --git a/mm/hmm.c b/mm/hmm.c
index e1eedef129cf..413944bb99dc 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -433,7 +433,7 @@ static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 }
 
 static int hmm_vma_walk_hole(unsigned long addr, unsigned long end,
-			     struct mm_walk *walk)
+			     __always_unused int depth, struct mm_walk *walk)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
diff --git a/mm/migrate.c b/mm/migrate.c
index 8992741f10aa..b92014ceb6dc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2130,6 +2130,7 @@ struct migrate_vma {
 
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
+				    __always_unused int depth,
 				    struct mm_walk *walk)
 {
 	struct migrate_vma *migrate = walk->private;
diff --git a/mm/mincore.c b/mm/mincore.c
index 4fe91d497436..8ba0fd80d449 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -112,6 +112,7 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 }
 
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
+				   __always_unused int depth,
 				   struct mm_walk *walk)
 {
 	walk->private += __mincore_unmapped_range(addr, end,
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 6bea79b95be3..cecc91259707 100644
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
 
 	if (walk->test_pmd) {
 		err = walk->test_pmd(addr, end, pmd_offset(pud, 0UL), walk);
@@ -46,7 +63,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -89,6 +106,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	pud_t *pud;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(2);
 
 	if (walk->test_pud) {
 		err = walk->test_pud(addr, end, pud_offset(p4d, 0UL), walk);
@@ -104,7 +122,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		next = pud_addr_end(addr, end);
 		if (pud_none(*pud)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -139,6 +157,7 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	p4d_t *p4d;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(1);
 
 	if (walk->test_p4d) {
 		err = walk->test_p4d(addr, end, p4d_offset(pgd, 0UL), walk);
@@ -153,7 +172,7 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 		next = p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -184,7 +203,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, 0, walk);
 			if (err)
 				break;
 			continue;
@@ -230,7 +249,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		if (pte)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		else if (walk->pte_hole)
-			err = walk->pte_hole(addr, next, walk);
+			err = walk->pte_hole(addr, next, -1, walk);
 
 		if (err)
 			break;
@@ -273,7 +292,7 @@ static int walk_page_test(unsigned long start, unsigned long end,
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

