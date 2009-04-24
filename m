Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B65FF6B00A5
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 20:33:23 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3O0XqXK018374
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Apr 2009 09:33:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 77C0B45DE56
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:33:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ECD345DE52
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:33:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D1711DB8043
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:33:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B81781DB8038
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:33:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 15/22] Do not disable interrupts in free_page_mlock()
In-Reply-To: <20090423155951.6778bdd3.akpm@linux-foundation.org>
References: <1240408407-21848-16-git-send-email-mel@csn.ul.ie> <20090423155951.6778bdd3.akpm@linux-foundation.org>
Message-Id: <20090424090721.1047.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Apr 2009 09:33:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > @@ -157,14 +157,9 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
> >   */
> >  static inline void free_page_mlock(struct page *page)
> >  {
> > -	if (unlikely(TestClearPageMlocked(page))) {
> > -		unsigned long flags;
> > -
> > -		local_irq_save(flags);
> > -		__dec_zone_page_state(page, NR_MLOCK);
> > -		__count_vm_event(UNEVICTABLE_MLOCKFREED);
> > -		local_irq_restore(flags);
> > -	}
> > +	__ClearPageMlocked(page);
> > +	__dec_zone_page_state(page, NR_MLOCK);
> > +	__count_vm_event(UNEVICTABLE_MLOCKFREED);
> >  }
> 
> The conscientuous reviewer runs around and checks for free_page_mlock()
> callers in other .c files which might be affected.
> 
> Only there are no such callers.
> 
> The reviewer's job would be reduced if free_page_mlock() wasn't
> needlessly placed in a header file!

very sorry.

How about this?

=============================================
Subject: [PATCH] move free_page_mlock() to page_alloc.c

Currently, free_page_mlock() is only called from page_alloc.c.
Thus, we can move it to page_alloc.c.

Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/internal.h   |   18 ------------------
 mm/page_alloc.c |   21 +++++++++++++++++++++
 2 files changed, 21 insertions(+), 18 deletions(-)

Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2009-04-24 09:12:03.000000000 +0900
+++ b/mm/internal.h	2009-04-24 09:12:10.000000000 +0900
@@ -150,23 +150,6 @@ static inline void mlock_migrate_page(st
 	}
 }
 
-/*
- * free_page_mlock() -- clean up attempts to free and mlocked() page.
- * Page should not be on lru, so no need to fix that up.
- * free_pages_check() will verify...
- */
-static inline void free_page_mlock(struct page *page)
-{
-	if (unlikely(TestClearPageMlocked(page))) {
-		unsigned long flags;
-
-		local_irq_save(flags);
-		__dec_zone_page_state(page, NR_MLOCK);
-		__count_vm_event(UNEVICTABLE_MLOCKFREED);
-		local_irq_restore(flags);
-	}
-}
-
 #else /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
 static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
 {
@@ -175,7 +158,6 @@ static inline int is_mlocked_vma(struct 
 static inline void clear_page_mlock(struct page *page) { }
 static inline void mlock_vma_page(struct page *page) { }
 static inline void mlock_migrate_page(struct page *new, struct page *old) { }
-static inline void free_page_mlock(struct page *page) { }
 
 #endif /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
 
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2009-04-24 09:12:03.000000000 +0900
+++ b/mm/page_alloc.c	2009-04-24 09:13:25.000000000 +0900
@@ -491,6 +491,27 @@ static inline void __free_one_page(struc
 	zone->free_area[order].nr_free++;
 }
 
+#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+/*
+ * free_page_mlock() -- clean up attempts to free and mlocked() page.
+ * Page should not be on lru, so no need to fix that up.
+ * free_pages_check() will verify...
+ */
+static void free_page_mlock(struct page *page)
+{
+	if (unlikely(TestClearPageMlocked(page))) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		__dec_zone_page_state(page, NR_MLOCK);
+		__count_vm_event(UNEVICTABLE_MLOCKFREED);
+		local_irq_restore(flags);
+	}
+}
+#else
+static void free_page_mlock(struct page *page) { }
+#endif
+
 static inline int free_pages_check(struct page *page)
 {
 	free_page_mlock(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
