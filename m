Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id A79366B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:29:13 -0400 (EDT)
Received: by mail-oi0-f41.google.com with SMTP id w20so2837996oia.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:29:13 -0700 (PDT)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id p204si117525oib.146.2016.03.22.19.29.11
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 19:29:12 -0700 (PDT)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 5/5] mm/mempolicy: vma_migratable can be boolean
Date: Wed, 23 Mar 2016 10:26:09 +0800
Message-Id: <1458699969-3432-6-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, baiyaowei@cmss.chinamobile.com

This patch makes vma_migratable return bool due to this
particular function only using either one or zero as its return
value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mempolicy.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 2696c1f..6978a99 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -172,14 +172,14 @@ extern int mpol_parse_str(char *str, struct mempolicy **mpol);
 extern void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
 
 /* Check if a vma is migratable */
-static inline int vma_migratable(struct vm_area_struct *vma)
+static inline bool vma_migratable(struct vm_area_struct *vma)
 {
 	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
-		return 0;
+		return false;
 
 #ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
 	if (vma->vm_flags & VM_HUGETLB)
-		return 0;
+		return false;
 #endif
 
 	/*
@@ -190,8 +190,8 @@ static inline int vma_migratable(struct vm_area_struct *vma)
 	if (vma->vm_file &&
 		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
 								< policy_zone)
-			return 0;
-	return 1;
+			return false;
+	return true;
 }
 
 extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
