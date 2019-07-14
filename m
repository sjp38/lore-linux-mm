Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D8CEC742D2
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35AA2214C6
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:34:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rf4itW1I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35AA2214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3CF06B000D; Sun, 14 Jul 2019 19:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE6856B000E; Sun, 14 Jul 2019 19:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5896B0010; Sun, 14 Jul 2019 19:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5B8B6B000D
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:34:38 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id p29so1376404pgm.10
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 16:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KfEiOXyW4kuzduZtxistAHn9ZpsA2gWKadebZDAjUeQ=;
        b=IpdAVV9pPdu5KNH7Zp5C6kyC8YV7JYZDu/Jv6OSwvNKZnEvaNcKnFFKZ4GYlXRdi8Y
         9oq+jx/r3m5P5sBLQes/VLY3fwRXn1nMpmnPhSnNjJFW7ba3KX1zMekZ1Rr/BlkU7fL3
         ZqMrnSTERfFTKGps7+KFWKddryPNxo6dcHdUI9cUk3tGlBX6qDiwJZgP4jWzhUEQD1Sw
         lwqVXPeGt95S52GLbNgx0PpivTY7ZdhVXYgr7xGmeESPmlw7P4QC1VjnsYPo1NRmvgZe
         inRReEp26oWDwt75rCBnJQVK+rtTofIGU6cfALPAbVyT7zOaiZPc6ZNAcutZOHrnMDm9
         ODrw==
X-Gm-Message-State: APjAAAWciX0Gx/WzOMN+Jxsly/qOFjqZ1zTBnE6E3ueqHy/PkTH65pZm
	omI4mTNYilUiwON5+IATsAnhaWhwGwM/zWwytm92ynAbOGr63FChuCWZoRsRW3P8vmgv5qnuajV
	BQHoJNgPcB5eSMtFSMqb09RMQVhXMe7Omc+bQC97sIqNZl+0OdgPuEh7legSx6zY=
X-Received: by 2002:a17:90a:8c0c:: with SMTP id a12mr25894647pjo.67.1563147278355;
        Sun, 14 Jul 2019 16:34:38 -0700 (PDT)
X-Received: by 2002:a17:90a:8c0c:: with SMTP id a12mr25894603pjo.67.1563147277558;
        Sun, 14 Jul 2019 16:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563147277; cv=none;
        d=google.com; s=arc-20160816;
        b=Ot4JY3SovF3VHHUXh2RqC8Af82F0uUaXkTsuuP317Rfj6JQngtq6QL1XHMpVwsbcr1
         xoxX3Q13aE6NB7ieY1mHv/kY85y595H+RlpVuUUoHPNDEozMgJrvobyRkg0HY/Y/Prpw
         3T2+6xuf3AY/fxc5m4S4y7wCgmreDyqn+GH0yJLgpVZhl2/6NML1Pkw/h/WUzofgpMST
         t4TlJpMKp8a4aIJfILIG9Fjy997rXAoS0B3On1tOuqtr93jziOEdXq4bqM/zMvmo9G1T
         u8Tl8l4p+D7E4BrKZke4NYHC+wKME7UzjT6UR+6NQcTwfxHc+P1jsqQVy0Fkd764p5q/
         rxsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=KfEiOXyW4kuzduZtxistAHn9ZpsA2gWKadebZDAjUeQ=;
        b=PpABCUd5vPK48KVoaQgzURb0hce2MU9GHIOC2DCbRKhuAAUwYs6nrkxy7aO/fkYRF7
         P5mXWKI9A2RbwqbxSPCZz30uHEh35GnyDYdTh8PhMeH0cCxp9CJ8FqXIo7ja60u2B5+z
         EbLS3TpT7T16kCR2bSfEuevMkb+pDmkmOo/Hs692W5+mUcZ7TZw2mfDrHzDWU71X6DrF
         eLtoP2dMN2x0xGdE6HEpN04dHYAejGVdtDYKVOZkWGPhLEyUvWpRGw2NBartIOrrMnNk
         XG8UI5lCX59meNimDfbET1u/WftCo+Sfw+VXGcgURFOYi09Sy+EWXUP7ZdX6Sp4d11Z0
         hT9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rf4itW1I;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor8389774pfn.15.2019.07.14.16.34.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 16:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rf4itW1I;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=KfEiOXyW4kuzduZtxistAHn9ZpsA2gWKadebZDAjUeQ=;
        b=rf4itW1IsHxAFs9MxOB0TmnKsP3+cBK+3y0QWniCdN9fc36+7Wn17VNe/511cQywEj
         nwKt2XJoD9k9jweT3ijg2UwqWMp2UBUFM4wr4WdcfgixPwrvVcbyA+zeUlatwyJkYjHt
         FUKsEjRrldB2OmI3pHGg1pppPkGN7ok9C95b8NeDAELf2N+g/ai3UfPtG4mWQlLktgxF
         QlmWAdn/h767jcyQ665JXOHeko34GAqkIPVR9ztFU2XnY+W46OlbWMMMppaNG+vuqfiy
         +4o/1VI8cvBCCFy12b0GDdum4qatHpezBIrd518V1f0JgdnySCEMnFJEktvngZ1dsbLK
         Oj9A==
X-Google-Smtp-Source: APXvYqzC7RBZaMwY5bYAkeGQmgM4AZYBlT/9oSZ7xWAe4a7ZbX2ktJRZOUhtUi1xyjHDdH3K4Bjarg==
X-Received: by 2002:a63:f04:: with SMTP id e4mr23148786pgl.38.1563147277064;
        Sun, 14 Jul 2019 16:34:37 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id n26sm16256923pfa.83.2019.07.14.16.34.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 14 Jul 2019 16:34:35 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 5/5] mm: factor out common parts between MADV_COLD and MADV_PAGEOUT
Date: Mon, 15 Jul 2019 08:34:00 +0900
Message-Id: <20190714233401.36909-6-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
In-Reply-To: <20190714233401.36909-1-minchan@kernel.org>
References: <20190714233401.36909-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are many common parts between MADV_COLD and MADV_PAGEOUT.
This patch factor them out to save code duplication.

Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 193 ++++++++++++---------------------------------------
 1 file changed, 46 insertions(+), 147 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 8db102f170ef..693239a8f67b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -30,6 +30,11 @@
 
 #include "internal.h"
 
+struct madvise_walk_private {
+	struct mmu_gather *tlb;
+	bool pageout;
+};
+
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
  * take mmap_sem for writing. Others, which simply traverse vmas, need
@@ -310,16 +315,23 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
-static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
-				unsigned long end, struct mm_walk *walk)
+static int madvise_cold_or_pageout_pte_range(pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
 {
-	struct mmu_gather *tlb = walk->private;
+	struct madvise_walk_private *private = walk->private;
+	struct mmu_gather *tlb = private->tlb;
+	bool pageout = private->pageout;
 	struct mm_struct *mm = tlb->mm;
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *orig_pte, *pte, ptent;
 	spinlock_t *ptl;
-	struct page *page;
 	unsigned long next;
+	struct page *page = NULL;
+	LIST_HEAD(page_list);
+
+	if (fatal_signal_pending(current))
+		return -EINTR;
 
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
@@ -366,10 +378,17 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		}
 
+		ClearPageReferenced(page);
 		test_and_clear_page_young(page);
-		deactivate_page(page);
+		if (pageout) {
+			if (!isolate_lru_page(page))
+				list_add(&page->lru, &page_list);
+		} else
+			deactivate_page(page);
 huge_unlock:
 		spin_unlock(ptl);
+		if (pageout)
+			reclaim_pages(&page_list);
 		return 0;
 	}
 
@@ -437,12 +456,19 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 		 * As a side effect, it makes confuse idle-page tracking
 		 * because they will miss recent referenced history.
 		 */
+		ClearPageReferenced(page);
 		test_and_clear_page_young(page);
-		deactivate_page(page);
+		if (pageout) {
+			if (!isolate_lru_page(page))
+				list_add(&page->lru, &page_list);
+		} else
+			deactivate_page(page);
 	}
 
 	arch_enter_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
+	if (pageout)
+		reclaim_pages(&page_list);
 	cond_resched();
 
 	return 0;
@@ -452,10 +478,15 @@ static void madvise_cold_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end)
 {
+	struct madvise_walk_private walk_private = {
+		.tlb = tlb,
+		.pageout = false,
+	};
+
 	struct mm_walk cold_walk = {
-		.pmd_entry = madvise_cold_pte_range,
+		.pmd_entry = madvise_cold_or_pageout_pte_range,
 		.mm = vma->vm_mm,
-		.private = tlb,
+		.private = &walk_private,
 	};
 
 	tlb_start_vma(tlb, vma);
@@ -482,151 +513,19 @@ static long madvise_cold(struct vm_area_struct *vma,
 	return 0;
 }
 
-static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
-				unsigned long end, struct mm_walk *walk)
-{
-	struct mmu_gather *tlb = walk->private;
-	struct mm_struct *mm = tlb->mm;
-	struct vm_area_struct *vma = walk->vma;
-	pte_t *orig_pte, *pte, ptent;
-	spinlock_t *ptl;
-	LIST_HEAD(page_list);
-	struct page *page;
-	unsigned long next;
-
-	if (fatal_signal_pending(current))
-		return -EINTR;
-
-	next = pmd_addr_end(addr, end);
-	if (pmd_trans_huge(*pmd)) {
-		pmd_t orig_pmd;
-
-		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
-		ptl = pmd_trans_huge_lock(pmd, vma);
-		if (!ptl)
-			return 0;
-
-		orig_pmd = *pmd;
-		if (is_huge_zero_pmd(orig_pmd))
-			goto huge_unlock;
-
-		if (unlikely(!pmd_present(orig_pmd))) {
-			VM_BUG_ON(thp_migration_supported() &&
-					!is_pmd_migration_entry(orig_pmd));
-			goto huge_unlock;
-		}
-
-		page = pmd_page(orig_pmd);
-		if (next - addr != HPAGE_PMD_SIZE) {
-			int err;
-
-			if (page_mapcount(page) != 1)
-				goto huge_unlock;
-			get_page(page);
-			spin_unlock(ptl);
-			lock_page(page);
-			err = split_huge_page(page);
-			unlock_page(page);
-			put_page(page);
-			if (!err)
-				goto regular_page;
-			return 0;
-		}
-
-		if (pmd_young(orig_pmd)) {
-			pmdp_invalidate(vma, addr, pmd);
-			orig_pmd = pmd_mkold(orig_pmd);
-
-			set_pmd_at(mm, addr, pmd, orig_pmd);
-			tlb_remove_tlb_entry(tlb, pmd, addr);
-		}
-
-		ClearPageReferenced(page);
-		test_and_clear_page_young(page);
-
-		if (!isolate_lru_page(page))
-			list_add(&page->lru, &page_list);
-huge_unlock:
-		spin_unlock(ptl);
-		reclaim_pages(&page_list);
-		return 0;
-	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-regular_page:
-	tlb_change_page_size(tlb, PAGE_SIZE);
-	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	flush_tlb_batched_pending(mm);
-	arch_enter_lazy_mmu_mode();
-	for (; addr < end; pte++, addr += PAGE_SIZE) {
-		ptent = *pte;
-		if (!pte_present(ptent))
-			continue;
-
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page)
-			continue;
-
-		/*
-		 * creating a THP page is expensive so split it only if we
-		 * are sure it's worth. Split it if we are only owner.
-		 */
-		if (PageTransCompound(page)) {
-			if (page_mapcount(page) != 1)
-				break;
-			get_page(page);
-			if (!trylock_page(page)) {
-				put_page(page);
-				break;
-			}
-			pte_unmap_unlock(orig_pte, ptl);
-			if (split_huge_page(page)) {
-				unlock_page(page);
-				put_page(page);
-				pte_offset_map_lock(mm, pmd, addr, &ptl);
-				break;
-			}
-			unlock_page(page);
-			put_page(page);
-			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-			pte--;
-			addr -= PAGE_SIZE;
-			continue;
-		}
-
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
-
-		if (pte_young(ptent)) {
-			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
-			ptent = pte_mkold(ptent);
-			set_pte_at(mm, addr, pte, ptent);
-			tlb_remove_tlb_entry(tlb, pte, addr);
-		}
-		ClearPageReferenced(page);
-		test_and_clear_page_young(page);
-
-		if (!isolate_lru_page(page))
-			list_add(&page->lru, &page_list);
-	}
-
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(orig_pte, ptl);
-	reclaim_pages(&page_list);
-	cond_resched();
-
-	return 0;
-}
-
 static void madvise_pageout_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end)
 {
+	struct madvise_walk_private walk_private = {
+		.pageout = true,
+		.tlb = tlb,
+	};
+
 	struct mm_walk pageout_walk = {
-		.pmd_entry = madvise_pageout_pte_range,
+		.pmd_entry = madvise_cold_or_pageout_pte_range,
 		.mm = vma->vm_mm,
-		.private = tlb,
+		.private = &walk_private,
 	};
 
 	tlb_start_vma(tlb, vma);
-- 
2.22.0.510.g264f2c817a-goog

