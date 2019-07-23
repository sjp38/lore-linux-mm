Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36807C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6CDC2239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S6N72sPt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6CDC2239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AAB88E0005; Tue, 23 Jul 2019 02:26:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 836408E0001; Tue, 23 Jul 2019 02:26:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5958E0005; Tue, 23 Jul 2019 02:26:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEEB8E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:26:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so21339727pla.7
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:26:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bfQQP9NHAJxmbSqu89eS8TN5Wu7mwb+7DHz3Y7mBEH8=;
        b=Qv+MwqJzDrzaZcvscetRqvpBPt6rSMFc3yJr8Gmxtyx0bfQRBfLfwHhdFi50EdZkJL
         89SJdDHBWYbC2/kiCcKdhCLbrw8ty+SZeM2t8ywVjJ3oIRZ+KkQQgWYdSH1O9UduHKI9
         80X0LzS+OJVIX+IviNEjMtMg3Wgd918zp849TbEZJR6Aag9Lxxsz81KNXYDOjK38OQqr
         2wwWYtNPmBXNffYd/wJ8NeCrfOhslqvG1TJBMPJUR7BsslvVkR+iyu+bHWVwGlKt1NmC
         43HMD5uFWc4CNVmJ2y3NhSGpBbESXKldkhoXYub5+9bUm3iQsScVxtx/ZxZu7ox4RbhB
         rLcg==
X-Gm-Message-State: APjAAAXkoShxK+RJ7cQRv/loDc7IWKjRQegL19yEozX+G7nwjS8pf8zH
	4Aab5a8HXF/LU3dh0LYUNdvhMvUrhUV36ER2mQtPxwEfifFHOT1LXuOHgfVVRu8UkzwRFssL4bQ
	/QE9MimuiK8wviaAbMftFlTvfQEfeq7xQgPhMdiDOWXp9xVoKWHhvXrdm+wEWPtA=
X-Received: by 2002:a63:6154:: with SMTP id v81mr42110044pgb.296.1563863172601;
        Mon, 22 Jul 2019 23:26:12 -0700 (PDT)
X-Received: by 2002:a63:6154:: with SMTP id v81mr42109985pgb.296.1563863171358;
        Mon, 22 Jul 2019 23:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863171; cv=none;
        d=google.com; s=arc-20160816;
        b=XPrwp6Sta0WzVLHTphz5fozrnM1VGqcKLHI2X0sOQBzOQ3C2vJPdfi+MRjiQca77cA
         Ef8IZqGIOW7377VvqdM8Vf2k/nPloH9E+p8W/GOeFPxmfWlJVVq5Ff337oZotXiaYaA+
         X30Sw3tv1Am8mFIxPzIUzruVZWFmoYyjvrlnPBl9t7y3/e9OF7FnwAJvqndo/DWy/Ql7
         YKTiWxq7gIUW7oZzxMZNGoVyb2yi0eNgfCLTx6lp8BNwgxd6tQ9KJOUDQah6XN+bpdjY
         5OBaesO2oPXVFr986tDlElsk4uepXM8sxslJpB+SvG5mOG+0ADJCh18nfssrsFiOXL8R
         V0Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=bfQQP9NHAJxmbSqu89eS8TN5Wu7mwb+7DHz3Y7mBEH8=;
        b=Ohz62Ti1AQzzxKMT3CIUKIDvwXsxBrxWRhWvcOVWQMfVn9Mo3tVzG/HI4G8pY07RoZ
         8ZxY2TC8zToFF8MfKp5jFll37BYwesPWa9BTc+9pmi0aQXC5dJPlsQmgTUMc3P+Feav+
         sSv0Szv7af6LR48Jkkaq9TZkWAsCd+EJLsNeu9Ux3Aok14hHxTDIUPVAkY8pluaOI5ei
         YzKX19C7irUnWLd3nQgc/aAWkdpqIHRNL2I6b1uLuCV9jFzxBPsXROKVAWdJNsEVfbY2
         qOJ6ddjtmHD5zPd1mEgRjd0HMUqSL+M6OD5FLynIXRrIXFvgUxzTs6rGcjClppPL8mnh
         BP5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S6N72sPt;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor52015433pjc.24.2019.07.22.23.26.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 23:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S6N72sPt;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bfQQP9NHAJxmbSqu89eS8TN5Wu7mwb+7DHz3Y7mBEH8=;
        b=S6N72sPtSLT5BRbZkdM7yLT3KExklat/g0/M44vLcLXzTOmhpazeQPD6qTDZxZI+bq
         tOhuIAReOaMz2Z0OZIRW40cU6cA1iD7WQx/951IkNbNwE4/D1F4A+HG7/F144NqlHmA8
         nqF8Mxb4eYZX/AWt3D+y2o3GBL0P0iQTMkUyPUjmDdi3dpGbj6Ss20rX4TykbwN+7qpF
         zXOW2GdXWSgODEB5naQOgr6pstUNYHFkv2re13znj4gbj6YhC25RWc8qo8oDw5ZwMhNh
         rkzgsHolS/aE1+HKaNZRefLcDFVoRmd/Ga4IdoHXk/H6RDwZ9c69onc0c9H2AYXbddcx
         XWCg==
X-Google-Smtp-Source: APXvYqzb7z49tOq+c3J6HBU0OTLCnyy3BYi10kL+NmLUNZO2UTErjgIy0BnBNxMhCLHmTvwhOXpq1g==
X-Received: by 2002:a17:90a:346c:: with SMTP id o99mr79200719pjb.20.1563863170869;
        Mon, 22 Jul 2019 23:26:10 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s66sm44630376pfs.8.2019.07.22.23.26.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 23:26:09 -0700 (PDT)
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
Subject: [PATCH v6 4/5] mm: introduce MADV_PAGEOUT
Date: Tue, 23 Jul 2019 15:25:38 +0900
Message-Id: <20190723062539.198697-5-minchan@kernel.org>
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

When a process expects no accesses to a certain memory range
for a long time, it could hint kernel that the pages can be
reclaimed instantly but data should be preserved for future use.
This could reduce workingset eviction so it ends up increasing
performance.

This patch introduces the new MADV_PAGEOUT hint to madvise(2)
syscall. MADV_PAGEOUT can be used by a process to mark a memory
range as not expected to be used for a long time so that kernel
reclaims *any LRU* pages instantly. The hint can help kernel in
deciding which pages to evict proactively.

A note: It doesn't apply SWAP_CLUSTER_MAX LRU page isolation limit
intentionally because it's automatically bounded by PMD size.
If PMD size(e.g., 256) makes some trouble, we could fix it later
by limit it to SWAP_CLUSTER_MAX[1].

- man-page material

MADV_PAGEOUT (since Linux x.x)

Do not expect access in the near future so pages in the specified
regions could be reclaimed instantly regardless of memory pressure.
Thus, access in the range after successful operation could cause
major page fault but never lose the up-to-date contents unlike
MADV_DONTNEED. Pages belonging to a shared mapping are only processed
if a write access is allowed for the calling process.

MADV_PAGEOUT cannot be applied to locked pages, Huge TLB pages, or
VM_PFNMAP pages.

* v4
 * clear young bit regardless of success of page isolation - hannes

* v3
 * man page material modification - mhocko
 * remove using SWAP_CLUSTER_MAX - mhocko

* v2
 * add comment about SWAP_CLUSTER_MAX - mhocko
 * add permission check to prevent sidechannel attack - mhocko
 * add man page stuff - dave

* v1
 * change pte to old and rely on the other's reference - hannes
 * remove page_mapcount to check shared page - mhocko

* RFC v2
 * make reclaim_pages simple via factoring out isolate logic - hannes

* RFCv1
 * rename from MADV_COLD to MADV_PAGEOUT - hannes
 * bail out if process is being killed - Hillf
 * fix reclaim_pages bugs - Hillf

[1] https://lore.kernel.org/lkml/20190710194719.GS29695@dhcp22.suse.cz/
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           | 195 +++++++++++++++++++++++++
 mm/vmscan.c                            |  55 +++++++
 4 files changed, 252 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 0ce997edb8bbc..063c0c1e112bd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -365,6 +365,7 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
+extern unsigned long reclaim_pages(struct list_head *page_list);
 #ifdef CONFIG_NUMA
 extern int node_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index e9aeda400af3a..be83a785d1cc4 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -46,6 +46,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
 #define MADV_COLD	5		/* deactivate these pages */
+#define MADV_PAGEOUT	6		/* reclaim these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/madvise.c b/mm/madvise.c
index 10255bb23aa73..24ded9f9e0fab 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,7 @@
 #include <linux/syscalls.h>
 #include <linux/mempolicy.h>
 #include <linux/page-isolation.h>
+#include <linux/page_idle.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/hugetlb.h>
 #include <linux/falloc.h>
@@ -41,6 +42,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_COLD:
+	case MADV_PAGEOUT:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -480,6 +482,196 @@ static long madvise_cold(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	struct mmu_gather *tlb = walk->private;
+	struct mm_struct *mm = tlb->mm;
+	struct vm_area_struct *vma = walk->vma;
+	pte_t *orig_pte, *pte, ptent;
+	spinlock_t *ptl;
+	LIST_HEAD(page_list);
+	struct page *page;
+	unsigned long next;
+
+	if (fatal_signal_pending(current))
+		return -EINTR;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd)) {
+		pmd_t orig_pmd;
+
+		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
+		ptl = pmd_trans_huge_lock(pmd, vma);
+		if (!ptl)
+			return 0;
+
+		orig_pmd = *pmd;
+		if (is_huge_zero_pmd(orig_pmd))
+			goto huge_unlock;
+
+		if (unlikely(!pmd_present(orig_pmd))) {
+			VM_BUG_ON(thp_migration_supported() &&
+					!is_pmd_migration_entry(orig_pmd));
+			goto huge_unlock;
+		}
+
+		page = pmd_page(orig_pmd);
+		if (next - addr != HPAGE_PMD_SIZE) {
+			int err;
+
+			if (page_mapcount(page) != 1)
+				goto huge_unlock;
+			get_page(page);
+			spin_unlock(ptl);
+			lock_page(page);
+			err = split_huge_page(page);
+			unlock_page(page);
+			put_page(page);
+			if (!err)
+				goto regular_page;
+			return 0;
+		}
+
+		if (pmd_young(orig_pmd)) {
+			pmdp_invalidate(vma, addr, pmd);
+			orig_pmd = pmd_mkold(orig_pmd);
+
+			set_pmd_at(mm, addr, pmd, orig_pmd);
+			tlb_remove_tlb_entry(tlb, pmd, addr);
+		}
+
+		ClearPageReferenced(page);
+		test_and_clear_page_young(page);
+
+		if (!isolate_lru_page(page))
+			list_add(&page->lru, &page_list);
+huge_unlock:
+		spin_unlock(ptl);
+		reclaim_pages(&page_list);
+		return 0;
+	}
+
+	if (pmd_trans_unstable(pmd))
+		return 0;
+regular_page:
+	tlb_change_page_size(tlb, PAGE_SIZE);
+	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	flush_tlb_batched_pending(mm);
+	arch_enter_lazy_mmu_mode();
+	for (; addr < end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		/*
+		 * creating a THP page is expensive so split it only if we
+		 * are sure it's worth. Split it if we are only owner.
+		 */
+		if (PageTransCompound(page)) {
+			if (page_mapcount(page) != 1)
+				break;
+			get_page(page);
+			if (!trylock_page(page)) {
+				put_page(page);
+				break;
+			}
+			pte_unmap_unlock(orig_pte, ptl);
+			if (split_huge_page(page)) {
+				unlock_page(page);
+				put_page(page);
+				pte_offset_map_lock(mm, pmd, addr, &ptl);
+				break;
+			}
+			unlock_page(page);
+			put_page(page);
+			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+			pte--;
+			addr -= PAGE_SIZE;
+			continue;
+		}
+
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+
+		if (pte_young(ptent)) {
+			ptent = ptep_get_and_clear_full(mm, addr, pte,
+							tlb->fullmm);
+			ptent = pte_mkold(ptent);
+			set_pte_at(mm, addr, pte, ptent);
+			tlb_remove_tlb_entry(tlb, pte, addr);
+		}
+		ClearPageReferenced(page);
+		test_and_clear_page_young(page);
+
+		if (!isolate_lru_page(page))
+			list_add(&page->lru, &page_list);
+	}
+
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(orig_pte, ptl);
+	reclaim_pages(&page_list);
+	cond_resched();
+
+	return 0;
+}
+
+static void madvise_pageout_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk pageout_walk = {
+		.pmd_entry = madvise_pageout_pte_range,
+		.mm = vma->vm_mm,
+		.private = tlb,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &pageout_walk);
+	tlb_end_vma(tlb, vma);
+}
+
+static inline bool can_do_pageout(struct vm_area_struct *vma)
+{
+	if (vma_is_anonymous(vma))
+		return true;
+	if (!vma->vm_file)
+		return false;
+	/*
+	 * paging out pagecache only for non-anonymous mappings that correspond
+	 * to the files the calling process could (if tried) open for writing;
+	 * otherwise we'd be including shared non-exclusive mappings, which
+	 * opens a side channel.
+	 */
+	return inode_owner_or_capable(file_inode(vma->vm_file)) ||
+		inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
+}
+
+static long madvise_pageout(struct vm_area_struct *vma,
+			struct vm_area_struct **prev,
+			unsigned long start_addr, unsigned long end_addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+
+	*prev = vma;
+	if (!can_madv_lru_vma(vma))
+		return -EINVAL;
+
+	if (!can_do_pageout(vma))
+		return 0;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
+	madvise_pageout_page_range(&tlb, vma, start_addr, end_addr);
+	tlb_finish_mmu(&tlb, start_addr, end_addr);
+
+	return 0;
+}
+
 static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 
@@ -870,6 +1062,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_COLD:
 		return madvise_cold(vma, prev, start, end);
+	case MADV_PAGEOUT:
+		return madvise_pageout(vma, prev, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -892,6 +1086,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_DONTNEED:
 	case MADV_FREE:
 	case MADV_COLD:
+	case MADV_PAGEOUT:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c693585c3facd..9f4aa350b020d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2158,6 +2158,61 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }
 
+unsigned long reclaim_pages(struct list_head *page_list)
+{
+	int nid = -1;
+	unsigned long nr_reclaimed = 0;
+	LIST_HEAD(node_page_list);
+	struct reclaim_stat dummy_stat;
+	struct page *page;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_writepage = 1,
+		.may_unmap = 1,
+		.may_swap = 1,
+	};
+
+	while (!list_empty(page_list)) {
+		page = lru_to_page(page_list);
+		if (nid == -1) {
+			nid = page_to_nid(page);
+			INIT_LIST_HEAD(&node_page_list);
+		}
+
+		if (nid == page_to_nid(page)) {
+			list_move(&page->lru, &node_page_list);
+			continue;
+		}
+
+		nr_reclaimed += shrink_page_list(&node_page_list,
+						NODE_DATA(nid),
+						&sc, 0,
+						&dummy_stat, false);
+		while (!list_empty(&node_page_list)) {
+			page = lru_to_page(&node_page_list);
+			list_del(&page->lru);
+			putback_lru_page(page);
+		}
+
+		nid = -1;
+	}
+
+	if (!list_empty(&node_page_list)) {
+		nr_reclaimed += shrink_page_list(&node_page_list,
+						NODE_DATA(nid),
+						&sc, 0,
+						&dummy_stat, false);
+		while (!list_empty(&node_page_list)) {
+			page = lru_to_page(&node_page_list);
+			list_del(&page->lru);
+			putback_lru_page(page);
+		}
+	}
+
+	return nr_reclaimed;
+}
+
 /*
  * The inactive anon list should be small enough that the VM never has
  * to do too much work.
-- 
2.22.0.657.g960e92d24f-goog

