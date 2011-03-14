Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 09D028D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:01:07 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2018687qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:01:04 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 18:01:03 +0000
Message-ID: <AANLkTin1RfkdzK+oXG1mHR_KBAHyQfeOa_WrDEnLiFFW@mail.gmail.com>
Subject: [RFC][PATCH v2 17/23] (sparc) __vmalloc: add gfp flags variant of pte
 and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/sparc/include/asm/pgalloc_32.h |    5 +++++
arch/sparc/include/asm/pgalloc_64.h |   17 +++++++++++++++--
2 files changed, 20 insertions(+), 2 deletions(-)
---
diff --git a/arch/sparc/include/asm/pgalloc_32.h
b/arch/sparc/include/asm/pgalloc_32.h
index ca2b344..ad68597 100644
--- a/arch/sparc/include/asm/pgalloc_32.h
+++ b/arch/sparc/include/asm/pgalloc_32.h
@@ -41,6 +41,9 @@ BTFIXUPDEF_CALL(void, pgd_set, pgd_t *, pmd_t *)
 BTFIXUPDEF_CALL(pmd_t *, pmd_alloc_one, struct mm_struct *, unsigned long)
 #define pmd_alloc_one(mm, address)	BTFIXUP_CALL(pmd_alloc_one)(mm, address)

+BTFIXUPDEF_CALL(pmd_t *, __pmd_alloc_one, struct mm_struct *,
unsigned long, gfp_t)
+#define __pmd_alloc_one(mm, address,
gfp_mask)	BTFIXUP_CALL(pmd_alloc_one)(mm, address)
+
 BTFIXUPDEF_CALL(void, free_pmd_fast, pmd_t *)
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)

@@ -57,6 +60,8 @@ BTFIXUPDEF_CALL(pgtable_t , pte_alloc_one, struct
mm_struct *, unsigned long)
 #define pte_alloc_one(mm, address)	BTFIXUP_CALL(pte_alloc_one)(mm, address)
 BTFIXUPDEF_CALL(pte_t *, pte_alloc_one_kernel, struct mm_struct *,
unsigned long)
 #define pte_alloc_one_kernel(mm,
addr)	BTFIXUP_CALL(pte_alloc_one_kernel)(mm, addr)
+BTFIXUPDEF_CALL(pte_t *, __pte_alloc_one_kernel, struct mm_struct *,
unsigned long, gfp_t)
+#define __pte_alloc_one_kernel(mm, addr,
gfp_mask)	BTFIXUP_CALL(pte_alloc_one_kernel)(mm, addr)

 BTFIXUPDEF_CALL(void, free_pte_fast, pte_t *)
 #define pte_free_kernel(mm, pte)	BTFIXUP_CALL(free_pte_fast)(pte)
diff --git a/arch/sparc/include/asm/pgalloc_64.h
b/arch/sparc/include/asm/pgalloc_64.h
index 5bdfa2c..a7952a5 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -26,9 +26,15 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)

 #define pud_populate(MM, PUD, PMD)	pud_set(PUD, PMD)

+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pmd_alloc_one(mm, addr, GFP_KERNEL);
 }

 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -36,10 +42,17 @@ static inline void pmd_free(struct mm_struct *mm,
pmd_t *pmd)
 	quicklist_free(0, NULL, pmd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
