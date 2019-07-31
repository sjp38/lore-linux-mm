Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3864BC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D58F2214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D58F2214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775768E001C; Wed, 31 Jul 2019 11:46:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 726598E0003; Wed, 31 Jul 2019 11:46:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6146E8E001C; Wed, 31 Jul 2019 11:46:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 115FA8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so42618688ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=idcCraew5kDYKUJXALkAj+l9XAI2mPAFcI9lteeEtuk=;
        b=XnCvKmzgGXcvGDW5EON4jqNCBhizEGvsrKM/AwzQZsepoJTYiBgtZK/qQ2/Rw+Iuls
         F2ygIKV988GDGP75YNiMxg/VIbuD3d63M4ANScIsrag+eGMao07F0abLNhQXtSapq7A8
         ZYX60ZBysWBHqVpT1YrNcOEc+awrdTElnsA3twga8OG2ZJJwgJWT+S9bW1bBMSpRm4Za
         XBXxAA4lwX0FiKB5XaXU1KdL5QzBCp0DHYryk5qYstCVbHtlSWRaEhPW0VjouBwLQd7r
         tAxrO92YSnW18M3h/q7AfKYJro3MhMToGKTTOIR04/XXAQao40rG4Qpaco+eyVP+Sp4E
         9AcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVk3ffla+wSLRZKj4zINPB2YH9GGmdeglczOrw/nPMDaMl5elfw
	YJsR6VTBz7+DASSxMjU4IVNCIunwcn7ibZvKf//owESPk0JOXnq41k2O94LjgtDEtA/HFfQSGdI
	tmHgCCUJ43k7Y2B1YA9OkAbpjncjT/5cEeopE7jxYR46OPlDgXPjis4YeX5p8pGS40w==
X-Received: by 2002:a17:906:3108:: with SMTP id 8mr15770595ejx.196.1564588006620;
        Wed, 31 Jul 2019 08:46:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoyVIOA8B/1Ta6IKdPwpmSy1pNyoHv0Vm8RGmJmIu+u4KXVSbfLzP4S6cNoxVOgWK9vk9f
X-Received: by 2002:a17:906:3108:: with SMTP id 8mr15770527ejx.196.1564588005646;
        Wed, 31 Jul 2019 08:46:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588005; cv=none;
        d=google.com; s=arc-20160816;
        b=uWCdPHStb7T6HLTQg67iskkU1eeeTGpMDwZVAvippELtLC0J6zsgYbBPm6FhCdRm6g
         3w6EDBP7DIpLzRq2AShmp2EJga7GKyyxbEtzkFiJ8uWvvqYmNVYvCKah+0LlLxMkbNrL
         VMA0pybNFMddaUs/Oqv5SpwRSHJ92N4S2ApKN4MA5eazk9Og1iic6AMWJX/KY82zBV0Q
         FkhG37sT8mGBE1Ns6m47pZ6UFrE/utq5Shwk1UdnOmtPhMPPUtrJbym6VbbBEkbHPXxd
         BfFmaKIOXqP0PoUMdcscsFLy2kWt7EwcjTdfMZruxlCF4JKEs0C7ed1x1Z5Vsj3sIVil
         upkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=idcCraew5kDYKUJXALkAj+l9XAI2mPAFcI9lteeEtuk=;
        b=cRZgbQF6eyVcMfACe22Yl34R/+DHyk58idD2jq/50q2MoczWFbgGkJeaK/RQ4B3+yI
         bptjcwUTjvbJItQwbz0elWGOBKd/Alxw9gF8jkeYOZUSwpdxIuNbbJWc+YLVGn9DSKim
         ymxjMFiBfZYtSseGCiarGWn6RZx9TiNmefyI2/uLLZNoNY3nJ6s/A1oFSYFhjlCXhwwD
         8f67NUkPrI0cN52EkYLjaV8oS12RcIqA4FU410FJlRxviMkWRwi4Kd6k3JsoSS09U6z4
         DkduQUgOkyqC3jQd3dwp4MhA89nYJ8SMuHv2/65ym8FkGr6KDS4aECZVqEZCRdpwfxla
         k29Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o13si18319711ejb.163.2019.07.31.08.46.45
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B25621570;
	Wed, 31 Jul 2019 08:46:44 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 283DB3F694;
	Wed, 31 Jul 2019 08:46:42 -0700 (PDT)
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
Subject: [PATCH v10 11/22] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Wed, 31 Jul 2019 16:45:52 +0100
Message-Id: <20190731154603.41797-12-steven.price@arm.com>
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
 include/linux/mm.h | 18 ++++++++++++------
 mm/pagewalk.c      | 27 ++++++++++++++++-----------
 2 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..0a1e83c4e267 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1432,15 +1432,14 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
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
@@ -1453,8 +1452,15 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * @private:   private data for callbacks' usage
  *
  * (see the comment on walk_page_range() for more details)
+ *
+ * p?d_entry callbacks are called even if those levels are folded on a partial
+ * architecture/configuration.
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

