Message-ID: <478F74A2.9090406@redhat.com>
Date: Thu, 17 Jan 2008 10:30:42 -0500
From: Larry Woodman <lwoodman@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] fix hugepages leak due to pagetable page sharing.
Content-Type: multipart/mixed;
 boundary="------------080803000409090203020307"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080803000409090203020307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The shared page table code for hugetlb memory on x86 and x86_64
is causing a leak.  When a user of hugepages exits using this code
the system leaks some of the hugepages.

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
HugePages_Rsvd:     
0 Hugepagesize:     2048 kB
----------------------------------------------------------

The problem occurs durring a fork, in copy_hugetlb_page_range(). It 
locates the dst_pte using
huge_pte_alloc().  Since huge_pte_alloc() calls huge_pmd_share() it will 
share the pmd page
if can, yet the main loop in copy_hugetlb_page_range() does a get_page() 
on every hugepage.
This is a violation of the shared hugepmd pagetable protocol and creates 
additional referenced
to the hugepages causing a leak when the unmap of the VMA occurs.   We 
can skip the entire
replication of the ptes when the hugepage pagetables are shared.
The attached patch skips copying the ptes and the get_page() calls if 
the hugetlbpage pagetable
is shared.

Signed-off-by: Larry Woodman <lwoodman@redhat.com>

--------------080803000409090203020307
Content-Type: text/plain;
 name="linux-shared.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-shared.patch"

--- linux-2.6.23/mm/hugetlb.c.orig	2008-01-16 12:05:41.496448000 -0500
+++ linux-2.6.23/mm/hugetlb.c	2008-01-17 10:27:21.740353000 -0500
@@ -377,6 +377,11 @@ int copy_hugetlb_page_range(struct mm_st
 		dst_pte = huge_pte_alloc(dst, addr);
 		if (!dst_pte)
 			goto nomem;
+
+		/* if the pagetables are shared dont copy or take references */
+		if(dst_pte == src_pte)
+			continue;
+
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
 		if (!pte_none(*src_pte)) {

--------------080803000409090203020307--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
