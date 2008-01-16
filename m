Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m0GHROqL005670
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 12:27:24 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m0GHRNUA014920
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 12:27:24 -0500
Received: from redhat.com (lwoodman.boston.redhat.com [172.16.80.79])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id m0GHRNva014053
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 12:27:23 -0500
Message-ID: <478E3DFA.9050900@redhat.com>
Date: Wed, 16 Jan 2008 12:25:14 -0500
From: Larry Woodman <lwoodman@redhat.com>
MIME-Version: 1.0
Subject: [RFC] shared page table for hugetlbpage memory causing leak.
Content-Type: multipart/mixed;
 boundary="------------040903090809070209060208"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040903090809070209060208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I think the shared page table code for hugetlb memory on x86 and x86_64
is causing a leak.  When a user of hugepages exits using this code the 
system
leaks some of the hugepages.

-------------------------------------------------------
Part of /proc/meminfo just before database startup:
HugePages_Total:  5500
HugePages_Free:   5500
HugePages_Rsvd:      0
Hugepagesize:     2048 kB

Just before shutdown:
HugePages_Total:  5500
HugePages_Free:   4475
HugePages_Rsvd:      0
Hugepagesize:     2048 kB

After shutdown:
HugePages_Total:  5500 
HugePages_Free:   4988 
HugePages_Rsvd:      0 
Hugepagesize:     2048 kB
----------------------------------------------------------

I think the problem occurs durring a fork, in copy_hugetlb_page_range(). 
It locates the dst_pte using huge_pte_alloc().  Since huge_pte_alloc() 
calls huge_pmd_share() it will share the pmd page if can yet the main 
loop in copy_hugetlb_page_range() does a get_page() on every hugepage.  
This is a violation of the shared hugepmd pagetable protocol and creates 
additional referenced to the hugepages.  

I think we can skip the entire replication of the ptes when the hugepage
pagetables are shared.  This patch skips copying the ptes and the get_page()
calls if the hugetlbpage pagetable is shared.





--------------040903090809070209060208
Content-Type: text/plain;
 name="linux-shared.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-shared.patch"

--- linux-2.6.23/mm/hugetlb.c.orig	2008-01-16 12:05:41.496448000 -0500
+++ linux-2.6.23/mm/hugetlb.c	2008-01-16 12:09:57.184746000 -0500
@@ -377,18 +377,22 @@ int copy_hugetlb_page_range(struct mm_st
 		dst_pte = huge_pte_alloc(dst, addr);
 		if (!dst_pte)
 			goto nomem;
-		spin_lock(&dst->page_table_lock);
-		spin_lock(&src->page_table_lock);
-		if (!pte_none(*src_pte)) {
-			if (cow)
-				ptep_set_wrprotect(src, addr, src_pte);
-			entry = *src_pte;
-			ptepage = pte_page(entry);
-			get_page(ptepage);
-			set_huge_pte_at(dst, addr, dst_pte, entry);
+
+		/* if hugetlbpage pagetables are shared dont take additional references */
+		if(!(is_vm_hugtlb_page(vma) && dst_pte == src_pte)) {
+			spin_lock(&dst->page_table_lock);
+			spin_lock(&src->page_table_lock);
+			if (!pte_none(*src_pte)) {
+				if (cow)
+					ptep_set_wrprotect(src, addr, src_pte);
+				entry = *src_pte;
+				ptepage = pte_page(entry);
+				get_page(ptepage);
+				set_huge_pte_at(dst, addr, dst_pte, entry);
+			}
+			spin_unlock(&src->page_table_lock);
+			spin_unlock(&dst->page_table_lock);
 		}
-		spin_unlock(&src->page_table_lock);
-		spin_unlock(&dst->page_table_lock);
 	}
 	return 0;
 

--------------040903090809070209060208--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
