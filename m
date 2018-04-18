Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 595AF6B000C
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x184so1398291pfd.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t184si1628425pfd.278.2018.04.18.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:20 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 01/14] s390: Use _refcount for pgtables
Date: Wed, 18 Apr 2018 11:48:59 -0700
Message-Id: <20180418184912.2851-2-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

s390 borrows the storage used for _mapcount in struct page in order to
account whether the bottom or top half is being used for 2kB page
tables.  I want to use that for something else, so use the top byte of
_refcount instead of the bottom byte of _mapcount.  _refcount may
temporarily be incremented by other CPUs that see a stale pointer to
this page in the page cache, but each CPU can only increment it by one,
and there are no systems with 2^24 CPUs today, so they will not change
the upper byte of _refcount.  We do have to be a little careful not to
lose any of their writes (as they will subsequently decrement the
counter).

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/mm/pgalloc.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 562f72955956..84bd6329a88d 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -190,14 +190,15 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 		if (!list_empty(&mm->context.pgtable_list)) {
 			page = list_first_entry(&mm->context.pgtable_list,
 						struct page, lru);
-			mask = atomic_read(&page->_mapcount);
+			mask = atomic_read(&page->_refcount) >> 24;
 			mask = (mask | (mask >> 4)) & 3;
 			if (mask != 3) {
 				table = (unsigned long *) page_to_phys(page);
 				bit = mask & 1;		/* =1 -> second 2K */
 				if (bit)
 					table += PTRS_PER_PTE;
-				atomic_xor_bits(&page->_mapcount, 1U << bit);
+				atomic_xor_bits(&page->_refcount,
+							1U << (bit + 24));
 				list_del(&page->lru);
 			}
 		}
@@ -218,12 +219,12 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 	table = (unsigned long *) page_to_phys(page);
 	if (mm_alloc_pgste(mm)) {
 		/* Return 4K page table with PGSTEs */
-		atomic_set(&page->_mapcount, 3);
+		atomic_xor_bits(&page->_refcount, 3 << 24);
 		memset64((u64 *)table, _PAGE_INVALID, PTRS_PER_PTE);
 		memset64((u64 *)table + PTRS_PER_PTE, 0, PTRS_PER_PTE);
 	} else {
 		/* Return the first 2K fragment of the page */
-		atomic_set(&page->_mapcount, 1);
+		atomic_xor_bits(&page->_refcount, 1 << 24);
 		memset64((u64 *)table, _PAGE_INVALID, 2 * PTRS_PER_PTE);
 		spin_lock_bh(&mm->context.lock);
 		list_add(&page->lru, &mm->context.pgtable_list);
@@ -242,7 +243,8 @@ void page_table_free(struct mm_struct *mm, unsigned long *table)
 		/* Free 2K page table fragment of a 4K page */
 		bit = (__pa(table) & ~PAGE_MASK)/(PTRS_PER_PTE*sizeof(pte_t));
 		spin_lock_bh(&mm->context.lock);
-		mask = atomic_xor_bits(&page->_mapcount, 1U << bit);
+		mask = atomic_xor_bits(&page->_refcount, 1U << (bit + 24));
+		mask >>= 24;
 		if (mask & 3)
 			list_add(&page->lru, &mm->context.pgtable_list);
 		else
@@ -253,7 +255,6 @@ void page_table_free(struct mm_struct *mm, unsigned long *table)
 	}
 
 	pgtable_page_dtor(page);
-	atomic_set(&page->_mapcount, -1);
 	__free_page(page);
 }
 
@@ -274,7 +275,8 @@ void page_table_free_rcu(struct mmu_gather *tlb, unsigned long *table,
 	}
 	bit = (__pa(table) & ~PAGE_MASK) / (PTRS_PER_PTE*sizeof(pte_t));
 	spin_lock_bh(&mm->context.lock);
-	mask = atomic_xor_bits(&page->_mapcount, 0x11U << bit);
+	mask = atomic_xor_bits(&page->_refcount, 0x11U << (bit + 24));
+	mask >>= 24;
 	if (mask & 3)
 		list_add_tail(&page->lru, &mm->context.pgtable_list);
 	else
@@ -296,12 +298,13 @@ static void __tlb_remove_table(void *_table)
 		break;
 	case 1:		/* lower 2K of a 4K page table */
 	case 2:		/* higher 2K of a 4K page table */
-		if (atomic_xor_bits(&page->_mapcount, mask << 4) != 0)
+		mask = atomic_xor_bits(&page->_refcount, mask << (4 + 24));
+		mask >>= 24;
+		if (mask != 0)
 			break;
 		/* fallthrough */
 	case 3:		/* 4K page table with pgstes */
 		pgtable_page_dtor(page);
-		atomic_set(&page->_mapcount, -1);
 		__free_page(page);
 		break;
 	}
-- 
2.17.0
