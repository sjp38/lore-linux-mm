Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8E89D6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:41:41 -0400 (EDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 3 Jul 2013 09:36:34 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 171201B08075
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 09:41:38 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r638fQ7X55378110
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 08:41:26 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r638fajk031739
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 02:41:37 -0600
Date: Wed, 3 Jul 2013 10:41:34 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: PageDirty check in mk_pte for s390
Message-ID: <20130703104134.4e901aea@mschwide>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org

Hi Hugh,

I still have the patch below in my patch heap. Should I just go ahead and
add it to my s390-tree or do you prefer to take care of it yourself ?

--
Subject: [PATCH] s390/mm: move PageDirty check from mk_pte to common code

Hugh Dickins commented on the software dirty bit implementation and he
does not like the fact that mk_pte uses PageDirty under the covers.
His suggestion is to move the PageDirty check into the __do_fault
function.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h |  9 +++------
 mm/memory.c                     | 12 ++++++++++++
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 68e6168..d56dc6d 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1260,13 +1260,8 @@ static inline pte_t mk_pte_phys(unsigned long physpage, pgprot_t pgprot)
 static inline pte_t mk_pte(struct page *page, pgprot_t pgprot)
 {
 	unsigned long physpage = page_to_phys(page);
-	pte_t __pte = mk_pte_phys(physpage, pgprot);
 
-	if ((pte_val(__pte) & _PAGE_SWW) && PageDirty(page)) {
-		pte_val(__pte) |= _PAGE_SWC;
-		pte_val(__pte) &= ~_PAGE_RO;
-	}
-	return __pte;
+	return mk_pte_phys(physpage, pgprot);
 }
 
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
@@ -1599,6 +1594,8 @@ extern int s390_enable_sie(void);
 static inline void pgtable_cache_init(void) { }
 static inline void check_pgt_cache(void) { }
 
+#define __ARCH_WANT_PTE_WRITE_DIRTY
+
 #include <asm-generic/pgtable.h>
 
 #endif /* _S390_PAGE_H */
diff --git a/mm/memory.c b/mm/memory.c
index 1207cef..765d5f2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3417,6 +3417,18 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 				dirty_page = page;
 				get_page(dirty_page);
 			}
+#ifdef __ARCH_WANT_PTE_WRITE_DIRTY
+			/*
+			 * Architectures that use software dirty bits may
+			 * want to set the dirty bit in the pte if the pte
+			 * is writable and the PageDirty bit is set for the
+			 * page. This avoids unnecessary protection faults
+			 * for writable mappings which do not use
+			 * mapping_cap_account_dirty, e.g. tmpfs and shmem.
+			 */
+			else if (pte_write(entry) && PageDirty(page))
+				entry = pte_mkdirty(entry);
+#endif
 		}
 		set_pte_at(mm, address, page_table, entry);
 
-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
