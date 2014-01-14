Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 657376B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:01:02 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so3654577pab.33
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:01:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id g5si1156007pav.317.2014.01.14.10.00.57
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 10:00:57 -0800 (PST)
Subject: [RFC][PATCH 1/9] mm: slab/slub: use page->list consistently instead of page->lru
From: Dave Hansen <dave@sr71.net>
Date: Tue, 14 Jan 2014 10:00:44 -0800
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
In-Reply-To: <20140114180042.C1C33F78@viggo.jf.intel.com>
Message-Id: <20140114180044.1E401C47@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


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
---

 b/include/linux/mm_types.h |    3 ++-
 b/mm/slab.c                |    4 ++--
 b/mm/slob.c                |   10 +++++-----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff -puN include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently include/linux/mm_types.h
--- a/include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently	2014-01-14 09:57:56.099621967 -0800
+++ b/include/linux/mm_types.h	2014-01-14 09:57:56.106622281 -0800
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
--- a/mm/slab.c~make-slab-use-page-lru-vs-list-consistently	2014-01-14 09:57:56.101622056 -0800
+++ b/mm/slab.c	2014-01-14 09:57:56.108622370 -0800
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
--- a/mm/slob.c~make-slab-use-page-lru-vs-list-consistently	2014-01-14 09:57:56.103622146 -0800
+++ b/mm/slob.c	2014-01-14 09:57:56.109622415 -0800
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
