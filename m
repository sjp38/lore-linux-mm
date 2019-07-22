Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F1B5C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03BFA219BE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03BFA219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06D678E000D; Mon, 22 Jul 2019 11:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3E2E8E0001; Mon, 22 Jul 2019 11:43:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06EF18E000D; Mon, 22 Jul 2019 11:42:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A28AA8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so26564296eda.2
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dPEWpckwXrtBUX8yDOGJOQcBqCT/ECFEDWDvh1GayzY=;
        b=QJswxKaT9HtsdeK0URvDOP4mYppSYiknQrmFIPcNw31XULS9DxGv42jowLY2ygHrb6
         EEUnwzABlfkATj7FA88NDI2qIoJhZGOigyqeg6W4jTLkAXOmH2UZlE3CpyCz0qwvMwKt
         jsVbZX4TwD+ynV7EVzo/LZWLw2pobJcf7qPh0asIQ/YXtvrzETCgNHC1P0Yaw/sa4ASz
         MVa5rGokShECQHOSRo3P6leBWcfya7wQfG0upljicM8GVE3aazJMqBtzU0qjQpzQBf9D
         17oldqSQpg7jxgL7oUYKpOpk3cl21so+FwSWq67ml5ZFcMA6pfwKuZrRLUxR2lqUpoqu
         AQew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU/o/NkSrQ5ho8cl/uQsz8D3uRydjqbmZNZEt+zyYk/n+wJIREw
	5s3ynSiGL1kyL3brWTTt64YdrrBOed4POS9+MA2rfHogKl0RokxC8Y3o59FqEap4BuLH83+zr5+
	MmZVnPBXxZWQxm+CTKO/Mz7uJULQ2ZFsyebB7aGOxcdtlApjt0kfl9ArmRM0mUp4BDA==
X-Received: by 2002:a50:b635:: with SMTP id b50mr60714847ede.293.1563810178224;
        Mon, 22 Jul 2019 08:42:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyipgJNHsNgUv1fwwr42iQqJ/80NR+R2YocYkugl1aNs+wxNG+xunWLzkDaiuF9r5AX0ut
X-Received: by 2002:a50:b635:: with SMTP id b50mr60714788ede.293.1563810177359;
        Mon, 22 Jul 2019 08:42:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810177; cv=none;
        d=google.com; s=arc-20160816;
        b=Wd1HThr/IdE5sd1H38EZrN3EkJ6s1me6SX+CLkZDSyV22V/m8tWnh8ZE+BOTQ/VrVo
         FyX0cqGC1yuNzXC/0WylEOnYgr8IsaofGS6mMeXLtxlPGQxCsXFs4DI6WhAGJLUO4wH4
         rQ1N/qbxyIjXCsYRXX2KrwbRt2ztJmL2AaSqKKpa1ebTbEI1TWnOouaiY28EdsgKLXGd
         /CPSp21+90QBbuUdnAdZ9K/gnglJu8oKBHAJNRqCg/WfmM3l9iaAP5yEbc/BLlzJOt+U
         6NbevJpr5+ZtbC2W0hUN3z9b1jSUzhKk/VM8BzffiPeetm+9+0UmVZ0nnNdVQzQ3sTQj
         C3sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dPEWpckwXrtBUX8yDOGJOQcBqCT/ECFEDWDvh1GayzY=;
        b=VX408uG+PXOG4QLfISvnGKKhikG9GnOsbMRmWOrGLOwxcCF1abSFC6am1ScAYqOS5O
         XuBAmHTfmggcUzvPJSwfOSKRHjlV2Sxck2VgXSpOSno2luFzuuW9NmT4NlsjHIjUlin8
         kS6q2GrLa9+HgaEd+NeK84ECPZEvKrvseufYdhpkZleOm+PNAmRjTTjYqPvpt7Lmtnji
         UWuhu520pstNJX5B1ajID/Sh8sz65bWmq9bVQkKRQLzUx2Z9NqYUBth+Zp7EQzNV5Dpo
         kI26mfsMMjPKaHugzTpKU3WrUVvQARTsvW6mxsXnsMikytyJetRVuovUvXI2yGgFVBjN
         QR4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id nm5si4553120ejb.223.2019.07.22.08.42.57
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 65B0B1596;
	Mon, 22 Jul 2019 08:42:56 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CECB03F694;
	Mon, 22 Jul 2019 08:42:53 -0700 (PDT)
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
Subject: [PATCH v9 11/21] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Mon, 22 Jul 2019 16:42:00 +0100
Message-Id: <20190722154210.42799-12-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
index 0334ca97c584..b22799129128 100644
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
@@ -1455,6 +1454,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
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

