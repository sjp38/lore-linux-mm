Date: Thu, 29 May 2008 04:29:19 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] hugetlb: fix lockdep error
Message-ID: <20080529022919.GD3258@wotan.suse.de>
References: <20080529015956.GC3258@wotan.suse.de> <20080528191657.ba5f283c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080528191657.ba5f283c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: agl@us.ibm.com, nacc@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Can you merge this up please? It is helpful in testing to avoid lockdep
tripping over. I have it at the start of the multiple hugepage size
patchset, but it doesn't strictly belong there...

--
hugetlb: fix lockdep error

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -785,7 +785,7 @@ int copy_hugetlb_page_range(struct mm_st
 			continue;
 
 		spin_lock(&dst->page_table_lock);
-		spin_lock(&src->page_table_lock);
+		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
 		if (!huge_pte_none(huge_ptep_get(src_pte))) {
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
