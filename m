Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 856736B005C
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:50:56 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id g12so3156417oah.26
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:50:55 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 1/6] mm: add parameter remove_old in move_huge_pmd()
Date: Thu,  9 May 2013 17:50:06 +0800
Message-Id: <1368093011-4867-2-git-send-email-wenchaolinux@gmail.com>
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

Signed-off-by: Wenchao Xia <wenchaolinux@gmail.com>
---
 include/linux/huge_mm.h |    2 +-
 mm/huge_memory.c        |    6 ++++--
 mm/mremap.c             |    2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ee1c244..567dc1e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -29,7 +29,7 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 			 struct vm_area_struct *new_vma,
 			 unsigned long old_addr,
 			 unsigned long new_addr, unsigned long old_end,
-			 pmd_t *old_pmd, pmd_t *new_pmd);
+			 pmd_t *old_pmd, pmd_t *new_pmd, bool remove_old);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e2f7f5a..f752388 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1402,10 +1402,11 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	return ret;
 }
 
+/* This function copy or moves pmd in same mm */
 int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
-		  pmd_t *old_pmd, pmd_t *new_pmd)
+		  pmd_t *old_pmd, pmd_t *new_pmd, bool remove_old)
 {
 	int ret = 0;
 	pmd_t pmd;
@@ -1429,7 +1430,8 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 
 	ret = __pmd_trans_huge_lock(old_pmd, vma);
 	if (ret == 1) {
-		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
+		pmd = remove_old ?
+			pmdp_get_and_clear(mm, old_addr, old_pmd) : *old_pmd;
 		VM_BUG_ON(!pmd_none(*new_pmd));
 		set_pmd_at(mm, new_addr, new_pmd, pmd);
 		spin_unlock(&mm->page_table_lock);
diff --git a/mm/mremap.c b/mm/mremap.c
index 463a257..0f3c5be 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -178,7 +178,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			if (extent == HPAGE_PMD_SIZE)
 				err = move_huge_pmd(vma, new_vma, old_addr,
 						    new_addr, old_end,
-						    old_pmd, new_pmd);
+						    old_pmd, new_pmd, true);
 			if (err > 0) {
 				need_flush = true;
 				continue;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
