Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9ED828E2
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:20:51 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d197so216139536ioe.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:20:51 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0129.outbound.protection.outlook.com. [157.56.112.129])
        by mx.google.com with ESMTPS id h204si14404434oia.212.2016.05.23.03.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:20:45 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 6/8] arch: x86: charge page tables to kmemcg
Date: Mon, 23 May 2016 13:20:27 +0300
Message-ID: <d54cc9e4c5a0b0afd6e003e71ed2c1e7b97a9b62.1463997354.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1463997354.git.vdavydov@virtuozzo.com>
References: <cover.1463997354.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Page tables can bite a relatively big chunk off system memory and their
allocations are easy to trigger from userspace, so they should be
accounted to kmemcg.

This patch marks page table allocations as __GFP_ACCOUNT for x86. Note
we must not charge allocations of kernel page tables, because they can
be shared among processes from different cgroups so accounting them to a
particular one can pin other cgroups for indefinitely long. So we clear
__GFP_ACCOUNT flag if a page table is allocated for the kernel.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/include/asm/pgalloc.h | 12 ++++++++++--
 arch/x86/mm/pgtable.c          | 11 ++++++++---
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index bf7f8b55b0f9..2f531633cb16 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -81,7 +81,11 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *page;
-	page = alloc_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0);
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_REPEAT | __GFP_ZERO;
+
+	if (mm == &init_mm)
+		gfp &= ~__GFP_ACCOUNT;
+	page = alloc_pages(gfp, 0);
 	if (!page)
 		return NULL;
 	if (!pgtable_pmd_page_ctor(page)) {
@@ -125,7 +129,11 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_REPEAT;
+
+	if (mm == &init_mm)
+		gfp &= ~__GFP_ACCOUNT;
+	return (pud_t *)get_zeroed_page(gfp);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 4eb287e25043..421ac6b74d11 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -6,7 +6,8 @@
 #include <asm/fixmap.h>
 #include <asm/mtrr.h>
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_NOTRACK | __GFP_REPEAT | \
+		     __GFP_ZERO)
 
 #ifdef CONFIG_HIGHPTE
 #define PGALLOC_USER_GFP __GFP_HIGHMEM
@@ -18,7 +19,7 @@ gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP);
+	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
 }
 
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
@@ -207,9 +208,13 @@ static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
 {
 	int i;
 	bool failed = false;
+	gfp_t gfp = PGALLOC_GFP;
+
+	if (mm == &init_mm)
+		gfp &= ~__GFP_ACCOUNT;
 
 	for(i = 0; i < PREALLOCATED_PMDS; i++) {
-		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
+		pmd_t *pmd = (pmd_t *)__get_free_page(gfp);
 		if (!pmd)
 			failed = true;
 		if (pmd && !pgtable_pmd_page_ctor(virt_to_page(pmd))) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
