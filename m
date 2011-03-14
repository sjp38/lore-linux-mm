From: Prasad Joshi <prasadjoshi124@gmail.com>
Subject: [RFC][PATCH v2 11/23] (mn10300) __vmalloc: add gfp flags variant of
 pte and pmd allocation
Date: Mon, 14 Mar 2011 17:48:31 +0000
Message-ID: <AANLkTikbco0iTe05iD4S+=Tsoi=k=STU-2aiv7+EDF9j__8782.78195527873$1300124926$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PzBsh-0007UM-Mg
	for glkm-linux-mm-2@m.gmane.org; Mon, 14 Mar 2011 18:48:36 +0100
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B5C928D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:48:33 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2005479qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:48:31 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux>

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/mn10300/include/asm/pgalloc.h |    2 ++
arch/mn10300/mm/pgtable.c          |   10 ++++++++--
2 files changed, 10 insertions(+), 2 deletions(-)
---
diff --git a/arch/mn10300/include/asm/pgalloc.h
b/arch/mn10300/include/asm/pgalloc.h
index 146bacf..35150ae 100644
--- a/arch/mn10300/include/asm/pgalloc.h
+++ b/arch/mn10300/include/asm/pgalloc.h
@@ -37,6 +37,8 @@ extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *, pgd_t *);

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
+
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/mn10300/mm/pgtable.c b/arch/mn10300/mm/pgtable.c
index 450f7ba..05077b4 100644
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -62,14 +62,20 @@ void set_pmd_pfn(unsigned long vaddr, unsigned
long pfn, pgprot_t flags)
 	local_flush_tlb_one(vaddr);
 }

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask);
 	if (pte)
 		clear_page(pte);
 	return pte;
 }

+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
+}
+
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
