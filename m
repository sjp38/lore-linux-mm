Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 0468C6B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 16:28:37 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: avoid CONFIG_MMU=n build failure in pmd_none_or_trans_huge_or_clear_bad
Date: Wed, 21 Mar 2012 21:28:31 +0100
Message-Id: <1332361711-26612-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Rik van Riel <riel@redhat.com>, Mark Salter <msalter@redhat.com>

pmd_none_or_trans_huge_or_clear_bad must be defined after
pmd_trans_huge, so add #ifdef CONFIG_MMU around the whole block that
shall not be needed for archs without pagetables.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Mark Salter <msalter@redhat.com>
---
 include/asm-generic/pgtable.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 10f8291..a03c098 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -425,6 +425,8 @@ extern void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
 				unsigned long size);
 #endif
 
+#ifdef CONFIG_MMU
+
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_trans_huge(pmd_t pmd)
 {
@@ -441,7 +443,7 @@ static inline int pmd_write(pmd_t pmd)
 	return 0;
 }
 #endif /* __HAVE_ARCH_PMD_WRITE */
-#endif
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /*
  * This function is meant to be used by sites walking pagetables with
@@ -500,6 +502,8 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#endif /* CONFIG_MMU */
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
