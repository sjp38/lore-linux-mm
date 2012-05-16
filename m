Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id EBA026B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 11:38:42 -0400 (EDT)
Date: Wed, 16 May 2012 10:38:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 1/9] [slob] define page struct fields
 used in mm_types.h
In-Reply-To: <alpine.DEB.2.00.1205160925410.25603@router.home>
Message-ID: <alpine.DEB.2.00.1205161034400.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201609.418025254@linux.com> <4FB357C9.8080308@parallels.com> <alpine.DEB.2.00.1205160925410.25603@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Christoph Lameter wrote:

> On Wed, 16 May 2012, Glauber Costa wrote:
>
> > It is of course ok to reuse the field, but what about we make it a union
> > between "list" and "lru" ?
>
> That is what this patch does. You are commenting on code that was
> removed.

Argh. No it doesnt..... It will be easy to add though. But then you have
two list_head definitions in page struct that just differ in name.

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-16 04:36:42.531867096 -0500
+++ linux-2.6/mm/slob.c	2012-05-16 04:36:13.611867636 -0500
@@ -142,13 +142,13 @@ static inline int slob_page_free(struct

 static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->lru, list);
+	list_add(&sp->list, list);
 	__SetPageSlobFree(sp);
 }

 static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->lru);
+	list_del(&sp->list);
 	__ClearPageSlobFree(sp);
 }

@@ -314,7 +314,7 @@ static void *slob_alloc(size_t size, gfp

 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, lru) {
+	list_for_each_entry(sp, slob_list, list) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -328,7 +328,7 @@ static void *slob_alloc(size_t size, gfp
 			continue;

 		/* Attempt to alloc */
-		prev = sp->lru.prev;
+		prev = sp->list.prev;
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
@@ -354,7 +354,7 @@ static void *slob_alloc(size_t size, gfp
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->lru);
+		INIT_LIST_HEAD(&sp->list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2012-05-16 04:36:42.535867105 -0500
+++ linux-2.6/include/linux/mm_types.h	2012-05-16 04:35:37.963868439 -0500
@@ -97,6 +97,7 @@ struct page {
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
+		struct list_head list;	/* slobs list of pages */
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
 #ifdef CONFIG_64BIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
