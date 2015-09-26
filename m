Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 646756B025D
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 06:46:28 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so129005909pac.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 03:46:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dx9si11801022pab.202.2015.09.26.03.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 03:46:27 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 5/5] x86: charge page table pages to memcg
Date: Sat, 26 Sep 2015 13:45:57 +0300
Message-ID: <dcec0ba12d36850e1bda82b462863c662956dc6d.1443262808.git.vdavydov@parallels.com>
In-Reply-To: <cover.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As noted in the comment to commit dc6c9a35b66b5 ("mm: account pmd page
tables to the process"), "unprivileged process can allocate significant
amount of memory -- >500 MiB on x86_64 -- and stay unnoticed by
oom-killer and memory cgroup". While the above-mentioned commit fixed
the problem in case of oom-killer, this patch attempts to fix it for
memory cgroup on x86 by making pte_alloc_one and friends use
alloc_kmem_pages instead of alloc_pages so as to charge page table pages
to kmemcg.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 arch/x86/include/asm/pgalloc.h | 5 +++--
 arch/x86/mm/pgtable.c          | 8 ++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index bf7f8b55b0f9..944c543836d5 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -81,7 +81,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *page;
-	page = alloc_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0);
+	page = alloc_kmem_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0);
 	if (!page)
 		return NULL;
 	if (!pgtable_pmd_page_ctor(page)) {
@@ -125,7 +125,8 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)__get_free_kmem_pages(GFP_KERNEL|__GFP_REPEAT|
+					      __GFP_ZERO, 0);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index fb0a9dd1d6e4..c2f0d57aa7e8 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -25,7 +25,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
-	pte = alloc_pages(__userpte_alloc_gfp, 0);
+	pte = alloc_kmem_pages(__userpte_alloc_gfp, 0);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
@@ -209,7 +209,7 @@ static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
 	bool failed = false;
 
 	for(i = 0; i < PREALLOCATED_PMDS; i++) {
-		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
+		pmd_t *pmd = (pmd_t *)__get_free_kmem_pages(PGALLOC_GFP, 0);
 		if (!pmd)
 			failed = true;
 		if (pmd && !pgtable_pmd_page_ctor(virt_to_page(pmd))) {
@@ -323,7 +323,7 @@ static inline pgd_t *_pgd_alloc(void)
 	 * We allocate one page for pgd.
 	 */
 	if (!SHARED_KERNEL_PMD)
-		return (pgd_t *)__get_free_page(PGALLOC_GFP);
+		pgd = (pgd_t *)__get_free_kmem_pages(PGALLOC_GFP, 0);
 
 	/*
 	 * Now PAE kernel is not running as a Xen domain. We can allocate
@@ -342,7 +342,7 @@ static inline void _pgd_free(pgd_t *pgd)
 #else
 static inline pgd_t *_pgd_alloc(void)
 {
-	return (pgd_t *)__get_free_page(PGALLOC_GFP);
+	return (pgd_t *)__get_free_kmem_pages(PGALLOC_GFP, 0);
 }
 
 static inline void _pgd_free(pgd_t *pgd)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
