Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 70A9D6B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 15:29:48 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so801917pab.17
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 12:29:48 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ek3si30301774pbd.115.2014.02.05.12.29.45
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 12:29:46 -0800 (PST)
Subject: [PATCH] mm: slab/slub: use page->list consistently instead of page->lru
From: Dave Hansen <dave@sr71.net>
Date: Wed, 05 Feb 2014 12:29:45 -0800
Message-Id: <20140205202945.4C31B693@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, cl@linux.com, rientjes@google.com


Andrew, I sent this out along with a bunch of other slab stuff,
but I think it stands alone and should get pulled in by itself.

--

From: Dave Hansen <dave.hansen@linux.intel.com>

'struct page' has two list_head fields: 'lru' and 'list'.
Conveniently, they are unioned together.  This means that code
can use them interchangably, which gets horribly confusing like
with this nugget from slab.c:

>	list_del(&page->lru);
>	if (page->active == cachep->num)
>		list_add(&page->list, &n->slabs_full);

This patch makes the slab and slub code use page->lru
universally instead of mixing ->list and ->lru.

So, the new rule is: page->lru is what the you use if you want to
keep your page on a list.  Don't like the fact that it's not
called ->list?  Too bad.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>
---

 b/include/linux/mm_types.h |    3 ++-
 b/mm/slab.c                |    4 ++--
 b/mm/slob.c                |   10 +++++-----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff -puN include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently include/linux/mm_types.h
--- a/include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently	2014-02-05 12:28:13.655176289 -0800
+++ b/include/linux/mm_types.h	2014-02-05 12:28:13.662176603 -0800
@@ -124,6 +124,8 @@ struct page {
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
+					 * Can be used as a generic list
+					 * by the page owner.
 					 */
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
@@ -136,7 +138,6 @@ struct page {
 #endif
 		};
 
-		struct list_head list;	/* slobs list of pages */
 		struct slab *slab_page; /* slab fields */
 		struct rcu_head rcu_head;	/* Used by SLAB
 						 * when destroying via RCU
diff -puN mm/slab.c~make-slab-use-page-lru-vs-list-consistently mm/slab.c
--- a/mm/slab.c~make-slab-use-page-lru-vs-list-consistently	2014-02-05 12:28:13.657176378 -0800
+++ b/mm/slab.c	2014-02-05 12:28:13.664176693 -0800
@@ -2886,9 +2886,9 @@ retry:
 		/* move slabp to correct slabp list: */
 		list_del(&page->lru);
 		if (page->active == cachep->num)
-			list_add(&page->list, &n->slabs_full);
+			list_add(&page->lru, &n->slabs_full);
 		else
-			list_add(&page->list, &n->slabs_partial);
+			list_add(&page->lru, &n->slabs_partial);
 	}
 
 must_grow:
diff -puN mm/slob.c~make-slab-use-page-lru-vs-list-consistently mm/slob.c
--- a/mm/slob.c~make-slab-use-page-lru-vs-list-consistently	2014-02-05 12:28:13.659176468 -0800
+++ b/mm/slob.c	2014-02-05 12:28:13.664176693 -0800
@@ -111,13 +111,13 @@ static inline int slob_page_free(struct
 
 static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->list, list);
+	list_add(&sp->lru, list);
 	__SetPageSlobFree(sp);
 }
 
 static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->list);
+	list_del(&sp->lru);
 	__ClearPageSlobFree(sp);
 }
 
@@ -282,7 +282,7 @@ static void *slob_alloc(size_t size, gfp
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, list) {
+	list_for_each_entry(sp, slob_list, lru) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -296,7 +296,7 @@ static void *slob_alloc(size_t size, gfp
 			continue;
 
 		/* Attempt to alloc */
-		prev = sp->list.prev;
+		prev = sp->lru.prev;
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
@@ -322,7 +322,7 @@ static void *slob_alloc(size_t size, gfp
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->list);
+		INIT_LIST_HEAD(&sp->lru);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
