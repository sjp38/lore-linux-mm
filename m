Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1QGjjri008290
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 11:45:45 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1QGkDEc178240
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 09:46:13 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1QGkC7u014109
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 09:46:12 -0700
Subject: Re: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1203981109.11846.22.camel@nimitz.home.sr71.net>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220129.23627.5152.stgit@kernel>
	 <1203978363.11846.10.camel@nimitz.home.sr71.net>
	 <1203980580.3837.30.camel@localhost.localdomain>
	 <1203981109.11846.22.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Tue, 26 Feb 2008 10:53:35 -0600
Message-Id: <1204044815.3837.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-25 at 15:11 -0800, Dave Hansen wrote:
<snip>
> I wonder if it might get simpler if you just make the pages on the
> freelists "virgin buddy pages".  Basically don't touch pages much until
> after they're dequeued.  Flip flop (a la John Kerry) the order around a
> bit:
> 
> 1. alloc from the buddy list
> 2. enqueue_huge_page()
> 3. somebody does dequeue_huge_page() and before it returns, we:
> 4. initialize to set ->dtor, page->_count, etc...
> 
> This has the disadvantage of shifting some work from a "once per alloc
> from the buddy list" to "once per en/dequeue".  Basically, just try and
> re-think when you turn pages from plain buddy pages into
> hugetlb-flavored pages.  

This is an interesting idea and I will think about it some more.
However, switching this around will introduce more of the churn that
makes people nervous.  So I would appeal that we put forth my original
idea (with your suggested modification) because it is a simple and
verifiable bug fix.  Amended patch follows:

commit 635ff936930f5c56be23feffd06764554f88f8ad
Author: Adam Litke <agl@us.ibm.com>
Date:   Tue Feb 26 08:42:33 2008 -0800

    hugetlb: Correct page count for surplus huge pages
    
    Free pages in the hugetlb pool are free and as such have a reference
    count of zero.  Regular allocations into the pool from the buddy are
    "freed" into the pool which results in their page_count dropping to zero.
    However, surplus pages are directly utilized by the caller without first
    being freed so an explicit reset of the reference count is needed.
    
    This hasn't effected end users because the bad page count is reset before
    the page is handed off.  However, under CONFIG_DEBUG_VM this triggers a BUG
    when the page count is validated.
    
    Thanks go to Mel for first spotting this issue and providing an initial
    fix.
    
    Signed-off-by: Adam Litke <agl@us.ibm.com>
    Cc: Mel Gorman <mel@csn.ul.ie>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index db861d8..5afcacb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -267,6 +267,11 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
+		/*
+		 * This page is now managed by the hugetlb allocator and has
+		 * no current users -- reset its reference count.
+		 */
+		BUG_ON(!put_page_testzero(page));
 		nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
 		/*
@@ -345,13 +350,14 @@ free:
 			enqueue_huge_page(page);
 		else {
 			/*
-			 * Decrement the refcount and free the page using its
-			 * destructor.  This must be done with hugetlb_lock
+			 * The page has a reference count of zero already, so
+			 * call free_huge_page directly instead of using
+			 * put_page.  This must be done with hugetlb_lock
 			 * unlocked which is safe because free_huge_page takes
 			 * hugetlb_lock before deciding how to free the page.
 			 */
 			spin_unlock(&hugetlb_lock);
-			put_page(page);
+			free_huge_page(page);
 			spin_lock(&hugetlb_lock);
 		}
 	}


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
