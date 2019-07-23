Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19CE2C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7A092239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ESc5AccD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7A092239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A1C08E0001; Tue, 23 Jul 2019 02:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32B958E0006; Tue, 23 Jul 2019 02:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189E78E0001; Tue, 23 Jul 2019 02:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D24658E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:26:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so25501008pfn.15
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:26:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HWfaGSGIcQ2TlhH4i7ElyoGsDhVzg5vFtyNIv3y8QK8=;
        b=YfWBkwGkBFhj4g0uN6woVYDOVQm6Y/aoTlWcd1bfWdB1fSPZMXqDjxOpDI3hEwfQlw
         BVRTtVQF5ZPFsnnVsvxS7RT0mVNTifnSXz3Ir6dIAuhkNwmnKYWdpNnnc9JCXVwWUHFg
         e4g/8Vt/5bX+9uvjtViwdEMO26SIuIQOPMaF4GkMXGkH65w0PIlzeO40uuPUza8ZQ6DB
         SF7TPcvnvtFGro7lhpv8jkimi3nCCnMuWFkVugpfCzmodIaXu9z6dO7LNGrENOxP/Z7Z
         qz2oQBCWCDk4e/RJHRiA28fGxqio9fGampoZKiEdd98IZMgAP1noQnlBpih3q4LuCahM
         /nRQ==
X-Gm-Message-State: APjAAAXBa/zYX0F8/YvtFguNsp9tXNm4x36dFUZA/7pMnxKirvRIT4sO
	Z0Ncw74qXHWBajLy71sy4eOIHbdFYRPFf5upA4+MeQ5CYSdnSyHR3XyNxZmFHJ1bZW7RvK09F/4
	lUIHKm55HbeERvK23AceSuRDcQEq+6SgtpMT3FbLOeqf2PjxpStcWnqcpXDhb/z0=
X-Received: by 2002:aa7:843c:: with SMTP id q28mr4228630pfn.152.1563863177512;
        Mon, 22 Jul 2019 23:26:17 -0700 (PDT)
X-Received: by 2002:aa7:843c:: with SMTP id q28mr4228578pfn.152.1563863176651;
        Mon, 22 Jul 2019 23:26:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863176; cv=none;
        d=google.com; s=arc-20160816;
        b=h+ugiv3gPVdTQxp4Zenf32C5Z2BDg7SrPHEj7JevC2BGKqf5WGChZ/FytY+s4P2p8f
         XyAsykaMKon4hkyzEa4rI4NOrx+BhzfVsSXZ+WEVB0LeqY5D3tAS7qpcvz6QdxUtoniw
         fHPLdSdIqtpgfslV/m+vVsab+u+uRw7SwGEj0/gwrsIZf7pwHy9ffKxVUYvLN4RaWBC+
         wih8JjeKClfYwBqLCuUfCpYImXQyhn4TnyL1iOD7ZrlR23eWsRomz+Qfxjn57IfASQZ/
         Lio4vi/VaOE2pPQqpeq7aLW600KzOEju/FI8LaTv+tPN3z5Ill/E4q8tK2gIfLI8glZf
         BhcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=HWfaGSGIcQ2TlhH4i7ElyoGsDhVzg5vFtyNIv3y8QK8=;
        b=t8oUAJLP7Bx5PIw2+9CndTplQ/fVTaNGQKEWk0V22n60sr/rlhhInNbR7Y3GQ9h6Jo
         xW8d6u9dp8SW9+qjLUVNDPkO/kYfrtm0Ok6Ayfa3R5sIGypXg7cr6qQYg3DYXn6EXLAF
         WzMjuoqHwrHZnpsQW/X1hbKaxBW3Z5KMGnqH3apOATBSAjL2we5HaM2yEF0K+T0GX+VK
         9kE9oz2JKaOr34LMBtssMGmTpggcDoGA1vNP4W/XYCQeehEnazxUye/pqXQUSj8owZ4L
         TcP2vUnJQ1c0LSlra2dgcFxY7thkj54B4JHGFeCxlLaUYF8lUsCn/dYJHz/YwkcyoBPF
         W3sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ESc5AccD;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor50789241pli.56.2019.07.22.23.26.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 23:26:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ESc5AccD;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=HWfaGSGIcQ2TlhH4i7ElyoGsDhVzg5vFtyNIv3y8QK8=;
        b=ESc5AccD3fIY+3GLvmiAB0kep7+tfzAbjWyIwC8m0DV2gPhz1xDNb1b/gD95eYmOhC
         a4QqxTdoyeWeZ60pl615dQiMsUh0zICwi4+9xxYb+6M08mGulaz2XGZhtfsUJpO7C9Rd
         WdFr8V18O/v9nAWvxksmW0c+Q8avtZBKDwOTQ7i2G1eJnxU+gTSRHfG//NR5OQKYeA1P
         IlLuSIleWH3wy4M1cb8rte6uyzhWyJYX48HsO+2wsw0ItMAfmogWoaXROgkBOH6GKVVJ
         zudhs/4cejJlVbUnUjKWeKMNO/6WiskFxdoUgjZmg8ThfqDjVznGMtOBCY6Y5THMugVi
         0oRg==
X-Google-Smtp-Source: APXvYqzxpTQSdvmtEP25pudnB7+4N4RCNywSv31s7Zvji+D9HZedbBwT3mlGwaWkgSnoDjdv0i3NLg==
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr75384177ple.228.1563863176244;
        Mon, 22 Jul 2019 23:26:16 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s66sm44630376pfs.8.2019.07.22.23.26.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 23:26:15 -0700 (PDT)
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
Subject: [PATCH v6 5/5] mm: factor out common parts between MADV_COLD and MADV_PAGEOUT
Date: Tue, 23 Jul 2019 15:25:39 +0900
Message-Id: <20190723062539.198697-6-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
In-Reply-To: <20190723062539.198697-1-minchan@kernel.org>
References: <20190723062539.198697-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are many common parts between MADV_COLD and MADV_PAGEOUT.
This patch factor them out to save code duplication.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 193 ++++++++++++---------------------------------------
 1 file changed, 46 insertions(+), 147 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 24ded9f9e0fab..22be197c7cc9b 100644
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
 
 	arch_leave_lazy_mmu_mode();
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
2.22.0.657.g960e92d24f-goog

