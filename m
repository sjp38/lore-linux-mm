Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C277CC10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BBEF20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BBEF20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5368C8E0011; Wed,  6 Mar 2019 10:51:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50CA38E0002; Wed,  6 Mar 2019 10:51:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B0238E0011; Wed,  6 Mar 2019 10:51:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D18548E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:26 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so6554638edh.10
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=Wn2QlhgETdDm74tHABXwcp0K811oUlajnhNPMj1/ZeLIY9vDQ9J4s72MhxoCpluC1H
         e+AEC6SVikkuiYiRvvVwKRiAjDTkC59SLrUEjjpFL0O0CLvRQcU+tfAJnnwirSito0vA
         mlGVqQmPvw2CJnmqFflL62oTj124BA56jtSGYr3TF7nExVrJlvh3Vq+XST8Qbky5uMN0
         /oGA3mZhdkea8m62jJk10RMpmZ84j6MuLYBwMl7WzO//TN8FLsAo2Gzph6c/18YSUrUu
         XrEVFFXB+PZKaUvm/sgazAsODX883BNeGPY1OymjcoXbfrMfzQj2MU/SnnWwLX8pdnpW
         WOkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUyT9xBfXv1yIfAZZl02a941m5aeIcI6WdkTl0RVc7ZNZePD+DP
	hoCvaFNsRbnB0yV3+abTX9vJlw4Xbc7EFdc2F6N5wDngyjr5xtKhXacaRcEEepJUKxrCcqiwk8f
	s/islXMUsh8Oqpjh7ilsZKFmbmiJaQ6aHva+qqd5+jMHzTvVSZtOtXb69NqtssT/8XQ==
X-Received: by 2002:a17:906:3fd1:: with SMTP id k17mr4389844ejj.87.1551887486084;
        Wed, 06 Mar 2019 07:51:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqzsgDepq6DqlPpUVSeGQvbyGlQ30Zk3tRTnu8xDrk//uZrwOO7K0jqnTozc5SBWDuWAouIa
X-Received: by 2002:a17:906:3fd1:: with SMTP id k17mr4389768ejj.87.1551887484791;
        Wed, 06 Mar 2019 07:51:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887484; cv=none;
        d=google.com; s=arc-20160816;
        b=bTQRp2ZsT5d8wu0oB7TzuDcIyj7gtBUgpfyJLqsMIsOCrxh5U6kb+xXKNe+H0+MEAw
         KTZMg9rjhZsJwmJE7YPM8WMjcowRuJI50Vvwd3TLGDgbfcEkk5K1zJyy0sdiKSSOVMPD
         YMwO34YeKxERr3/8RwyBYZth1b+q8r0DPGbXmcKB8YNhSR2anxwT01FZHrc8OFOs2Yyc
         7d1grk+JXOAPjxuTELTl4lIw++VXIntEtCWPzc9IXgFpGN57FxflEZMY6i0VmkElUjNZ
         NiqWRduAA23Zj125yvGV3VhSiqDzH6i7r+tE2z2rQBR/Yhi3+/TM3eW92Ln3mo6hvF96
         X+Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=zomZ5nLBvawLg0HI/Pmt/VJhCQjm5igD9XkeS+JgA28yjlvjlVkUxZ+o4ythzwYu3e
         VWQfCTVRZwwxjb9JjtSH/XbKqLOgQJ4PGyZRsAOqnU1Cu5N110gowhOOC9aB7rpEQckr
         xuqLmFNbyox4FanpQ630yB3Sw7VsxLoXghD9fyAt6a0PMGqwRp4fHijR2kmpGjW0Osv4
         C+BObF3g4RxNScneZLUL8GIL4Hs/PwFIrifsvgUDS/SplZR4abWDH/3BWJljxzruL+fJ
         NgZFCbNWypAOqhcS/fcSO5E4E39wjTM+VrmBg/5+N9Ad4UdZrgvkK5wqrZX8U0tiD0gA
         tusQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d19si724078ejk.294.2019.03.06.07.51.24
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:24 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 90991174E;
	Wed,  6 Mar 2019 07:51:23 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 559333F703;
	Wed,  6 Mar 2019 07:51:20 -0800 (PST)
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
Subject: [PATCH v4 10/19] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Wed,  6 Mar 2019 15:50:22 +0000
Message-Id: <20190306155031.4291-11-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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
 include/linux/mm.h |  9 ++++++---
 mm/pagewalk.c      | 27 ++++++++++++++++-----------
 2 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..1a4b1615d012 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1412,10 +1412,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
+ * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
+ * @p4d_entry: if set, called for each non-empty P4D (1st-level) entry
  * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
- *	       this handler should only handle pud_trans_huge() puds.
- *	       the pmd_entry or pte_entry callbacks will be used for
- *	       regular PUDs.
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1435,6 +1434,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
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

