Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DF82C6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 17:24:55 -0400 (EDT)
Subject: [PATCH] Hugepages should be accounted as unevictable pages.
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
Content-Type: text/plain
Date: Mon, 22 Jun 2009 14:25:41 -0700
Message-Id: <1245705941.26649.19.camel@alok-dev1>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Looking at the output of /proc/meminfo, a user might get confused in thinking
that there are zero unevictable pages, though, in reality their can be
hugepages which are inherently unevictable. 

Though hugepages are not handled by the unevictable lru framework, they are
infact unevictable in nature and global statistics counter should reflect that. 

For instance, I have allocated 20 huge pages on my system, meminfo shows this 

Unevictable:           0 kB
Mlocked:               0 kB
HugePages_Total:      20
HugePages_Free:       20
HugePages_Rsvd:        0
HugePages_Surp:        0

After the patch:

Unevictable:       81920 kB
Mlocked:               0 kB
HugePages_Total:      20
HugePages_Free:       20
HugePages_Rsvd:        0
HugePages_Surp:        0

Signed-off-by: Alok N Kataria <akataria@vmware.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>

Index: linux-2.6/Documentation/vm/unevictable-lru.txt
===================================================================
--- linux-2.6.orig/Documentation/vm/unevictable-lru.txt	2009-06-22 11:49:27.000000000 -0700
+++ linux-2.6/Documentation/vm/unevictable-lru.txt	2009-06-22 13:57:32.000000000 -0700
@@ -71,6 +71,12 @@ The unevictable list addresses the follo
 
  (*) Those mapped into VM_LOCKED [mlock()ed] VMAs.
 
+ (*) Hugetlb pages are also unevictable. Hugepages are already implemented in
+     a way that these pages don't reside on the LRU and hence are not iterated
+     over during the vmscan. So there is no need to move around these pages
+     across different LRU's. We just account these pages as unevictable for
+     correct statistics.
+
 The infrastructure may also be able to handle other conditions that make pages
 unevictable, either by definition or by circumstance, in the future.
 
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2009-06-22 11:49:57.000000000 -0700
+++ linux-2.6/mm/hugetlb.c	2009-06-22 14:04:05.000000000 -0700
@@ -533,6 +533,8 @@ static void update_and_free_page(struct 
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
 				1 << PG_private | 1<< PG_writeback);
 	}
+	mod_zone_page_state(page_zone(page), NR_LRU_BASE + LRU_UNEVICTABLE,
+				-(pages_per_huge_page(h)));
 	set_compound_page_dtor(page, NULL);
 	set_page_refcounted(page);
 	arch_release_hugepage(page);
@@ -584,6 +586,8 @@ static void prep_new_huge_page(struct hs
 	spin_lock(&hugetlb_lock);
 	h->nr_huge_pages++;
 	h->nr_huge_pages_node[nid]++;
+	mod_zone_page_state(page_zone(page), NR_LRU_BASE + LRU_UNEVICTABLE,
+				pages_per_huge_page(h));
 	spin_unlock(&hugetlb_lock);
 	put_page(page); /* free it into the hugepage allocator */
 }
@@ -749,6 +753,9 @@ static struct page *alloc_buddy_huge_pag
 		 */
 		h->nr_huge_pages_node[nid]++;
 		h->surplus_huge_pages_node[nid]++;
+		mod_zone_page_state(page_zone(page),
+					NR_LRU_BASE + LRU_UNEVICTABLE,
+					pages_per_huge_page(h));
 		__count_vm_event(HTLB_BUDDY_PGALLOC);
 	} else {
 		h->nr_huge_pages--;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
