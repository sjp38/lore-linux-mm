Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B28B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:09:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a12-v6so413635pfn.12
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 14:09:04 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id m4-v6si495130pgp.512.2018.06.19.14.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 14:09:03 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] thp: use mm_file_counter to determine update which rss counter
Date: Wed, 20 Jun 2018 05:08:38 +0800
Message-Id: <1529442518-17398-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit eca56ff906bdd0239485e8b47154a6e73dd9a2f3 ("mm, shmem: add
internal shmem resident memory accounting"), MM_SHMEMPAGES is added to
separate the shmem accounting from regular files. So, all shmem pages
should be accounted to MM_SHMEMPAGES instead of MM_FILEPAGES.

And, normal 4K shmem pages have been accounted to MM_SHMEMPAGES, so
shmem thp pages should be not treated differently. Accouting them to
MM_SHMEMPAGES via mm_counter_file() since shmem pages are swap backed
to keep consistent with normal 4K shmem pages.

This will not change the rss counter of processes since shmem pages are
still a part of it.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 4 ++--
 mm/memory.c      | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a..2687f7c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1740,7 +1740,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		} else {
 			if (arch_needs_pgtable_deposit())
 				zap_deposited_table(tlb->mm, pmd);
-			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+			add_mm_counter(tlb->mm, mm_counter_file(page), -HPAGE_PMD_NR);
 		}
 
 		spin_unlock(ptl);
@@ -2088,7 +2088,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			SetPageReferenced(page);
 		page_remove_rmap(page, true);
 		put_page(page);
-		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+		add_mm_counter(mm, mm_counter_file(page), -HPAGE_PMD_NR);
 		return;
 	} else if (is_huge_zero_pmd(*pmd)) {
 		/*
diff --git a/mm/memory.c b/mm/memory.c
index 7206a63..4a2f2a8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3372,7 +3372,7 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 	if (write)
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
-	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
+	add_mm_counter(vma->vm_mm, mm_counter_file(page), HPAGE_PMD_NR);
 	page_add_file_rmap(page, true);
 	/*
 	 * deposit and withdraw with pmd lock held
-- 
1.8.3.1
