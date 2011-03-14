Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 853018D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:59:26 -0400 (EDT)
Date: Mon, 14 Mar 2011 17:59:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: PageBuddy and mapcount underflows robustness
Message-ID: <20110314165922.GE10696@random.random>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
 <20110314155232.GB10696@random.random>
 <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Mon, Mar 14, 2011 at 09:37:43AM -0700, Hugh Dickins wrote:
> version - which Linus has now taken.

That was fast, so that solves all merging order rejects in the first
place as we'll all rebase on upstraem.

> I was certainly tempted to remove all the non-NUMA cases, but as you
> say, now is not the right time for that since we needed a quick bugfix.

Correct. Too much risk in making the not-NUMA case as the NUMA case.

> I do appreciate why you did it that way, it is nicer to be allocating

BTW, one reason it was done this way is also because the not-NUMA case
was the original code, and when I added the NUMA awareness to
khugepaged I didn't want to risk regressions to the existing case that
I knew worked fine.

> on the outside, though unsuitable in the NUMA case.  But given how this
> bug has passed unnoticed for so long, it seems like nobody has been
> testing non-NUMA, so yes, best to simplify and make non-NUMA do the
> same as NUMA in 2.6.39.

These days clearly the NUMA case gets more testing than the not-NUMA
case. Especially for features like memcg that are mostly needed on
NUMA systems and not so much on small laptops or something not
NUMA.

I'm unsure if it's so urgent to remove it, maybe a little benchmarking
with khugepaged at 100% load may be worth trying first, but if there's
no real change in the frequency increase of khugepaged/pages_collapsed
counter, I'm surely ok if it gets removed later.

> Since Linus has taken my version that you didn't like, perhaps you can

I'm ok with your version... no problem.

> get even by sending him your "mm: PageBuddy cleanups" patch, the version
> I didn't like (for its silly branches) so was reluctant to push myself.

Ok that slipped even my own aa.git tree as it was more a RFC when I
posted it and it didn't fix a real bug but just made the code more
robust at runtime in case of hardware memory corruption or software
bugs.

> I'd really like to see that fix in, since it's a little hard to argue
> for in -stable, being all about a system which is already unstable.
>
> But I think it needs a stronger title than "PageBuddy cleanups" -
> "fix BUG in bad_page()"?

I think this can comfortably wait 2.6.39-rc. I think it's best if
Andrew merges it so it gets digested through -mm for a while. But let
me know if you prefer something else. So here it is with slightly
updated header.

===
Subject: mm: PageBuddy and mapcount underflows robustness

From: Andrea Arcangeli <aarcange@redhat.com>

bad_page could VM_BUG_ON(!PageBuddy(page)) inside __ClearPageBuddy(). I prefer
to keep the VM_BUG_ON for safety and to add a if to solve it.

Change the _mapcount value indicating PageBuddy from -2 to -1024*1024 for more
robusteness against page_mapcount() underflows.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Hugh Dickins <hughd@google.com>
---

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6385fc..fa16ba0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -402,16 +402,22 @@ static inline void init_page_count(struct page *page)
 /*
  * PageBuddy() indicate that the page is free and in the buddy system
  * (see mm/page_alloc.c).
+ *
+ * PAGE_BUDDY_MAPCOUNT_VALUE must be <= -2 but better not too close to
+ * -2 so that an underflow of the page_mapcount() won't be mistaken
+ * for a genuine PAGE_BUDDY_MAPCOUNT_VALUE.
  */
+#define PAGE_BUDDY_MAPCOUNT_VALUE (-1024*1024)
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
index a873e61..8aac134 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -286,7 +286,9 @@ static void bad_page(struct page *page)
 
 	/* Don't complain about poisoned pages */
 	if (PageHWPoison(page)) {
-		__ClearPageBuddy(page);
+		/* __ClearPageBuddy VM_BUG_ON(!PageBuddy(page)) */
+		if (PageBuddy(page))
+			__ClearPageBuddy(page);
 		return;
 	}
 
@@ -317,7 +319,8 @@ static void bad_page(struct page *page)
 	dump_stack();
 out:
 	/* Leave bad fields for debug, except PageBuddy could make trouble */
-	__ClearPageBuddy(page);
+	if (PageBuddy(page)) /* __ClearPageBuddy VM_BUG_ON(!PageBuddy(page)) */
+		__ClearPageBuddy(page);
 	add_taint(TAINT_BAD_PAGE);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
