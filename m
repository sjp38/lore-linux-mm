Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 71FC78D0041
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 19:16:40 -0400 (EDT)
Date: Fri, 18 Mar 2011 00:16:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: PageBuddy and mapcount underflows robustness
Message-ID: <20110317231635.GC10696@random.random>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
 <20110314155232.GB10696@random.random>
 <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
 <20110314165922.GE10696@random.random>
 <AANLkTikWh5tFUZuALYRP3Dx2Zcs33u0UVdjf4d_7KhPJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikWh5tFUZuALYRP3Dx2Zcs33u0UVdjf4d_7KhPJ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2011 at 10:30:11AM -0700, Linus Torvalds wrote:
> On Mon, Mar 14, 2011 at 9:59 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > +#define PAGE_BUDDY_MAPCOUNT_VALUE (-1024*1024)
> 
> I realize that this is a nitpick, but from a code generation
> standpoint, large random constants like these are just nasty.
> 
> I would suggest aiming for constants that are easy to generate and/or
> fit better in the code stream. In many encoding schemes (eg x86), -128
> is much easier to generate, since it fits in a signed byte and allows
> small instructions etc. And in most RISC encodings, 8- or 16-bit
> constants can be encoded much more easily than something like your
> current one, and bigger ones often end up resulting in a load from
> memory or at least several immediate-building instructions.

-128 sure is ok with me. It's extremely unlikely to be off by 127
times, if we're off by more than 127 times we're still going to detect
the error.

> Also, this is just disgusting. It adds no safety here to have that
> VM_BUG_ON(), so it's just unnecessary code generation to do this.
> Also, we don't even WANT to do that stupid "__ClearPageBuddy()" in the
> first place! What those two code-sites actually want are just a simple
> 
>     reset_page_mapcount(page);
> 
> which does the right thing in _general_, and not just for the buddy
> case - we want to reset the mapcount for other reasons than just
> pagebuddy (ie the underflow/overflow case).

Agreed.

> And it avoids the VM_BUG_ON() too, making the crazy conditionals be not needed.

Well using reset_page_mapcount in the two error sites, didn't require
me to remove the VM_BUG_ON from __ClearPageBuddy so I left it
there...

===
Subject: mm: PageBuddy and mapcount robustness

From: Andrea Arcangeli <aarcange@redhat.com>

Change the _mapcount value indicating PageBuddy from -2 to -128 for
more robusteness against page_mapcount() undeflows.

Use reset_page_mapcount instead of __ClearPageBuddy in bad_page to
ignore the previous retval of PageBuddy().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h |   11 +++++++++--
 mm/page_alloc.c    |    4 ++--
 2 files changed, 11 insertions(+), 4 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -402,16 +402,23 @@ static inline void init_page_count(struc
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
