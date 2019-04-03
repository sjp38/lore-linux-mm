Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1F5FC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9389520830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9389520830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A0D6B026F; Wed,  3 Apr 2019 10:17:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 410EC6B0272; Wed,  3 Apr 2019 10:17:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 300C16B0274; Wed,  3 Apr 2019 10:17:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D39BF6B026F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j3so7642911edb.14
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ahKSq6BT07JiMm6WJgk15VRtm9UPqW7p0TN43pTC2F8=;
        b=RSwNtLkHu/2fP4viVN9tshN0GE4dvzQ19aKHti/so1/59YGmbpqj+wBaMnzOafnx2z
         3zyE/KFAsEYoBvmU0DLcDsSnKxRiZ1piWxEeuQXvhHz8p9PS5+RHgxX1cPq4Z+eemozn
         RdAOJs7IoNiMrfCBIDiqy4gCm9n5yAiC3kjVNUFCUDbHFKcQ9ieD30lnJOxy7nITKcwH
         RynL8KN64xvYLWT1Xldffzz+faxykMKzSGAhwPLDjxRoTMiAL/FqWTwbRxKwtB6tniLe
         smlDsBEijomrFKSohSXb3adENBF09Emq5QUp9qfkMogJt48NVfA69cDAeQzTNAnvOVr+
         48Pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUiI3aJOUx4jYiPICxLtVhca/1OeVBKNFOD4FibdkJrcQasaxii
	b1kgOpLMiEjZEQaOGTLYabWsM9KM4ifnfhCIRus9LxiqHLnCt/KrUS0ovBzsVXmKkoyLROVSj7D
	KdY6EeFR4oCqYlhYPCO8VMKWxkAQ8jihZSofaBlQBI9icZZW4qsaUm5DPV6HDI8DFBA==
X-Received: by 2002:a50:94aa:: with SMTP id s39mr52978144eda.191.1554301077378;
        Wed, 03 Apr 2019 07:17:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyui37x9wnzXRrzQphAEuqNZaJCW+Z8TID8rtsbkBgyBqmzOL2B92QIq9o2ke5GBlB6tcL
X-Received: by 2002:a50:94aa:: with SMTP id s39mr52978091eda.191.1554301076211;
        Wed, 03 Apr 2019 07:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301076; cv=none;
        d=google.com; s=arc-20160816;
        b=PWaEHOD/qbJQ71sR+DHPSOt5quAIZfPKeS7jO7NYJrJNzxDia+g1iIqgysyqoHTpy/
         W2av4IJDCCm7Xtgrw4N+N4yZxuRBEQAsZTnP8AQVamSO2h4He/Rbjspuino5dQWRNRSD
         vPPc1uCrmUG1TsZkoVoz5JEsmfG4hQrdbDkmWwURSeBOIiiL8ErMXlJBT0myHBduzWKN
         ep4UKgIHMTycYg6hG9CiPBGb6UFnuTq0PjwkYqkGpUtGaLDP3ZRkVraKgPyE/ZU8arkf
         lSepmZvKPEtdp8ZKmUzqPQbDbChivom+3ZeUgEnZjBvDI4z7HtGKS4lyLZWAvPyb+w4Y
         ANBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ahKSq6BT07JiMm6WJgk15VRtm9UPqW7p0TN43pTC2F8=;
        b=SdSD5DnFZmpwNVzu48bQsw+2uiI7VdlVvhRGGN6Abrm+R/eO0+bKiQhi49vZAczdEU
         URqiZ1PHHbR8ewCNY+cwLF5jP0Sui0dBQk+xplRr+YmcZsw/FlNhTDyiJN0+yKWoFKwA
         3T4xYPr6BPdhS8FADUAHpi7eTEw7KAmQlyMiUemf1YYN6f41lTTkpscGB2Q18k8eqplD
         C1LP+ZzC2yxI1zMcFpRQCbR9J/tW5fdBK4BICVeoxRSq+O2i37jfh8/f4JoN/oH0kq2t
         lvsNmvm4LzVAhUlo50nVc6J3V4H88GJj53PYpQvftLtPAEy/u3+KCBMT4KRMWLL5mjBn
         //YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e33si1622709ede.76.2019.04.03.07.17.55
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 35F061682;
	Wed,  3 Apr 2019 07:17:55 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C9B353F68F;
	Wed,  3 Apr 2019 07:17:51 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 11/20] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Wed,  3 Apr 2019 15:16:18 +0100
Message-Id: <20190403141627.11664-12-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

