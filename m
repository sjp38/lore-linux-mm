Date: Wed, 18 Jul 2007 16:05:14 +0100
Subject: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070718150514.GA21823@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de, hugh@veritas.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

At the nudging of Andrew, I was checking to see if the architecture-specific
implementations of alloc_zeroed_user_highpage() can be removed or not.
With the exception of barriers, the differences are negligible and the main
memory barrier is in clear_user_highpage(). However, it's unclear why it's
needed. Do you mind looking at the following patch and telling me if it's
wrong and if so, why?

Thanks a lot.

===

    This patch removes an unnecessary write barrier from clear_user_highpage().
    
    clear_user_highpage() is called from alloc_zeroed_user_highpage() on a
    number of architectures and from clear_huge_page(). However, these callers
    are already protected by the necessary memory barriers due to spinlocks
    in the fault path and the page should not be visible on other CPUs anyway
    making the barrier unnecessary. A hint of lack of necessity is that there
    does not appear to be a read barrier anywhere for this zeroed page.
    
    The sequence for the first use of alloc_zeroed_user_highpage()
    looks like;
    
    pte_unmap_unlock()
    alloc_zeroed_user_highpage()
    pte_offset_map_lock()
    
    The second is
    
    pte_unmap()	(usually nothing but sometimes a barrier()
    alloc_zeroed_user_highpage()
    pte_offset_map_lock()
    
    The two sequences with the use of locking should already have sufficient
    barriers.
    
    By removing this write barrier, IA64 could use the default implementation
    of alloc_zeroed_user_highpage() instead of a custom version which appears
    to do nothing but avoid calling smp_wmb(). Once that is done, there is
    little reason to have architecture-specific alloc_zeroed_user_highpage()
    helpers as it would be redundant.

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 12c5e4e..ace5a32 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -68,8 +68,6 @@ static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
 	void *addr = kmap_atomic(page, KM_USER0);
 	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
-	/* Make sure this page is cleared on other CPU's too before using it */
-	smp_wmb();
 }
 
 #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
