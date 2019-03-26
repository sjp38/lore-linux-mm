Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD72CC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7951820863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7951820863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B0786B0277; Tue, 26 Mar 2019 12:27:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 286856B0278; Tue, 26 Mar 2019 12:27:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 176A56B0279; Tue, 26 Mar 2019 12:27:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2BA66B0277
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x13so5489337edq.11
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ahKSq6BT07JiMm6WJgk15VRtm9UPqW7p0TN43pTC2F8=;
        b=ZhWgBUhk7HKNr1qKftrZCSLs/Zp93m+Y4sB0C3QdSzQrnvk+z4OZBJfwOBmkyMAA7u
         fYIPMVUKfR/HvXqbLHWjLoV6pFExpiSiQ2gvO2AyrV8mOVFx+csz0Qa21Vtibls8T0Hz
         oSfbnl7Klm87calfCTFryoHFU38zkvMOp5fzLmKu1FvGaBWkN6HAQL3jmwhy0DJ03NXK
         7+zTgafva6FMtMOh/UI2qs2H6z9qB2hvGYvU0XVntJ7BKSvJ3ewW7rVksEAWTj3EkQge
         TkD5pz4GHgeSMOPwvol0+c/cDKLhZCcf+XTg8apS7bXAK4xKHCQ9cgfimjIeLzHAHZf0
         pHiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWAol9S4LgkGNVEc0S4dWrlFBdGxJ8u1cvMFa3p0NV0oLs3kIQ3
	0SHQAgyJqou/zpS4f7zpWQFZrskEAlEym/wbwdb12Obq1KzkwQodKqFmkhjc5fORi7lrMbUkDLP
	Kh+inFuk072a6AUw4gOo9jIGQwLQVyuVOMZMNP68CXrDqjmWuF+8S9StlQA6tupO98A==
X-Received: by 2002:a17:906:c9d0:: with SMTP id hk16mr17848306ejb.220.1553617635232;
        Tue, 26 Mar 2019 09:27:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJ+fkUwGy6W1Z5gjFijmUz12y5uq2hH8HJaxPRMAGJQs5Lsqn03VSXxXVjFbaYhMXnEVkH
X-Received: by 2002:a17:906:c9d0:: with SMTP id hk16mr17848256ejb.220.1553617634245;
        Tue, 26 Mar 2019 09:27:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617634; cv=none;
        d=google.com; s=arc-20160816;
        b=JYVl0a9TTLs4yW2qFfPlre32xZE6VJxodYOKj56lXBoBEDkkNeLVFOE+uxapK+gMRg
         SD4dBIxYOml2617d69xhFZMR64ufD/HL65byh8ADCuVInjSsqBxY+IKXGrMS3Q9Xe5Hv
         tI3KvBVWdaqVXaibpfyAh/5wcIU0BXXUtRmJR2syMjfuTNSLmwkKdQYClmtHADMsFGu5
         hruIKf3+sBjHxs83ohv85uG4goD6A5pnsH3HbS0SAANvxDoMbp5Iw7dTFLvh6QxoOSQt
         WkJVx+Kg/wXf6edY/CscrOvCsw0Z+qWL3JHyiZaa4pC/AMVefSd/Ap/juvfjILInashg
         zNlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ahKSq6BT07JiMm6WJgk15VRtm9UPqW7p0TN43pTC2F8=;
        b=GLxuk8/+PNAkwLTMX/8nrgbxgcaez9RBMfGlRiL6q7lkTrNRffTnpn5K0Wy26Iic2P
         pldTM6r/GDIaw4MblgFDEJabiWsa9+tZxotn2/n4KsEPtbMqZzTNfNYKL4kkobd+Dmk5
         EJoWeqWObDflhYo23O8Oy7Q6xLp7IBQWVO2IFNF7E98JRRjJoRG3tfFuk7eMN7o3Sd4X
         y5LPNi0smuDEYZkvbw+Wztna75vooLweDj+JxLnI3agVQ68DOEcjCJUJifI/xBojq6uP
         kS6iC9krRbLF57lt6oaP5fypn5Dp8vpi959kRkfta2Hl8dUlXlsL35kkJB0eQot+pI9V
         Oe7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s4si4657034edx.79.2019.03.26.09.27.13
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 410B71684;
	Tue, 26 Mar 2019 09:27:13 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 058A03F614;
	Tue, 26 Mar 2019 09:27:09 -0700 (PDT)
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
Subject: [PATCH v6 10/19] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Tue, 26 Mar 2019 16:26:15 +0000
Message-Id: <20190326162624.20736-11-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

