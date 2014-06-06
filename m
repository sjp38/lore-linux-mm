Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 601576B0096
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:59:03 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so1751985wib.10
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:59:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o15si19770360wjq.126.2014.06.06.15.59.01
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:59:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 5/7] arch/powerpc/mm/subpage-prot.c: cleanup subpage_walk_pmd_entry()
Date: Fri,  6 Jun 2014 18:58:38 -0400
Message-Id: <1402095520-10109-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Currently subpage_mark_vma_nohuge() uses page table walker to find thps and
then split them. But this can be done by page table walker itself, so let's
rewrite it in more suitable way. No functional change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/subpage-prot.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/arch/powerpc/mm/subpage-prot.c v3.15-rc8-mmots-2014-06-03-16-28/arch/powerpc/mm/subpage-prot.c
index fa9fb5b4c66c..555cfe15371d 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/arch/powerpc/mm/subpage-prot.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/arch/powerpc/mm/subpage-prot.c
@@ -131,11 +131,10 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
+static int subpage_walk_pte(pte_t *pte, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->vma;
-	split_huge_page_pmd(vma, addr, pmd);
+	walk->control = PTWALK_BREAK;
 	return 0;
 }
 
@@ -143,9 +142,14 @@ static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
 				    unsigned long len)
 {
 	struct vm_area_struct *vma;
+	/*
+	 * What this walking expects is to split all thps under this mm.
+	 * Page table walker internally splits thps just before we try to
+	 * call .pte_entry() on them, so let's utilize it.
+	 */
 	struct mm_walk subpage_proto_walk = {
 		.mm = mm,
-		.pmd_entry = subpage_walk_pmd_entry,
+		.pte_entry = subpage_walk_pte,
 	};
 
 	/*
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
