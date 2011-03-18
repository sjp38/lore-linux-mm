Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFF98D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 17:34:41 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p2ILYHFB005469
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:34:26 -0700
Received: from iyi12 (iyi12.prod.google.com [10.241.51.12])
	by kpbe20.cbf.corp.google.com with ESMTP id p2ILYFxI015475
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:34:16 -0700
Received: by iyi12 with SMTP id 12so5517034iyi.23
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:34:15 -0700 (PDT)
Date: Fri, 18 Mar 2011 14:34:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: PageBuddy and mapcount underflows robustness
In-Reply-To: <20110317231635.GC10696@random.random>
Message-ID: <alpine.LSU.2.00.1103181428100.1996@sister.anvils>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils> <20110314155232.GB10696@random.random> <alpine.LSU.2.00.1103140910570.2601@sister.anvils> <20110314165922.GE10696@random.random> <AANLkTikWh5tFUZuALYRP3Dx2Zcs33u0UVdjf4d_7KhPJ@mail.gmail.com>
 <20110317231635.GC10696@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Fri, 18 Mar 2011, Andrea Arcangeli wrote:
> On Mon, Mar 14, 2011 at 10:30:11AM -0700, Linus Torvalds wrote:
> Subject: mm: PageBuddy and mapcount robustness
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Change the _mapcount value indicating PageBuddy from -2 to -128 for
> more robusteness against page_mapcount() undeflows.
> 
> Use reset_page_mapcount instead of __ClearPageBuddy in bad_page to
> ignore the previous retval of PageBuddy().
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Hugh Dickins <hughd@google.com>

Yes, this version satisfies my objections too.
I'd say Acked-by but I see that it's already in, great.

I've Cc'ed stable@kernel.org: please can we have this in 2.6.38.1,
since 2.6.38 regressed the recovery from bad page states,
inadvertently changing them to a fatal error when CONFIG_DEBUG_VM.

Thanks,
Hugh

commit ef2b4b95a63a1d23958dcb99eb2c6898eddc87d0
Author: Andrea Arcangeli <aarcange@redhat.com>
Date:   Fri Mar 18 00:16:35 2011 +0100

    mm: PageBuddy and mapcount robustness
    
    Change the _mapcount value indicating PageBuddy from -2 to -128 for
    more robusteness against page_mapcount() undeflows.
    
    Use reset_page_mapcount instead of __ClearPageBuddy in bad_page to
    ignore the previous retval of PageBuddy().
    
    Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
    Reported-by: Hugh Dickins <hughd@google.com>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 679300c..ff83798 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -402,16 +402,23 @@ static inline void init_page_count(struct page *page)
 /*
  * PageBuddy() indicate that the page is free and in the buddy system
  * (see mm/page_alloc.c).
+ *
+ * PAGE_BUDDY_MAPCOUNT_VALUE must be <= -2 but better not too close to
+ * -2 so that an underflow of the page_mapcount() won't be mistaken
+ * for a genuine PAGE_BUDDY_MAPCOUNT_VALUE. -128 can be created very
+ * efficiently by most CPU architectures.
  */
+#define PAGE_BUDDY_MAPCOUNT_VALUE (-128)
+
 static inline int PageBuddy(struct page *page)
 {
-	return atomic_read(&page->_mapcount) == -2;
+	return atomic_read(&page->_mapcount) == PAGE_BUDDY_MAPCOUNT_VALUE;
 }
 
 static inline void __SetPageBuddy(struct page *page)
 {
 	VM_BUG_ON(atomic_read(&page->_mapcount) != -1);
-	atomic_set(&page->_mapcount, -2);
+	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
 }
 
 static inline void __ClearPageBuddy(struct page *page)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bd76256..7945247 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -286,7 +286,7 @@ static void bad_page(struct page *page)
 
 	/* Don't complain about poisoned pages */
 	if (PageHWPoison(page)) {
-		__ClearPageBuddy(page);
+		reset_page_mapcount(page); /* remove PageBuddy */
 		return;
 	}
 
@@ -317,7 +317,7 @@ static void bad_page(struct page *page)
 	dump_stack();
 out:
 	/* Leave bad fields for debug, except PageBuddy could make trouble */
-	__ClearPageBuddy(page);
+	reset_page_mapcount(page); /* remove PageBuddy */
 	add_taint(TAINT_BAD_PAGE);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
