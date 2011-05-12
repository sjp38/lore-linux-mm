Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4048A900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 16:11:16 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p4CKB5Vh031208
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:11:05 -0700
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by kpbe12.cbf.corp.google.com with ESMTP id p4CKAwXI005306
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:10:59 -0700
Received: by pzk10 with SMTP id 10so1251468pzk.35
        for <linux-mm@kvack.org>; Thu, 12 May 2011 13:10:50 -0700 (PDT)
Date: Thu, 12 May 2011 13:10:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] slub: avoid label inside conditional
In-Reply-To: <alpine.DEB.2.00.1105121142370.27324@router.home>
Message-ID: <alpine.DEB.2.00.1105121304090.2407@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194831.991653328@linux.com> <alpine.DEB.2.00.1105111255130.9346@chino.kir.corp.google.com> <alpine.DEB.2.00.1105121142370.27324@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org

On Thu, 12 May 2011, Christoph Lameter wrote:

> > I'd much prefer to just add a
> >
> > 	c->node = page_to_nid(page);
> >
> > rather than the new label and goto into a conditional.
> >
> > >  	}
> > >  	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
> > >  		slab_out_of_memory(s, gfpflags, node);
> >
> 
> Hmmm... Looks like we also missed to use the label.
> 

It was used in the same patch it was introduced:

@@ -1828,7 +1828,6 @@ load_freelist:
 	c->freelist = get_freepointer(s, object);
 	page->inuse = page->objects;
 	page->freelist = NULL;
-	c->node = page_to_nid(page);
 
 unlock_out:
 	slab_unlock(page);
@@ -1845,8 +1844,10 @@ another_slab:
 new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
-		c->page = page;
 		stat(s, ALLOC_FROM_PARTIAL);
+load_from_page:
+		c->node = page_to_nid(page);
+		c->page = page;
 		goto load_freelist;
 	}
 
@@ -1867,8 +1868,8 @@ new_slab:
 
 		slab_lock(page);
 		__SetPageSlubFrozen(page);
-		c->page = page;
-		goto load_freelist;
+
+		goto load_from_page;
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);

> 
> Subject: slub: Fix control flow in slab_alloc
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-05-12 11:41:44.000000000 -0500
> +++ linux-2.6/mm/slub.c	2011-05-12 11:42:25.000000000 -0500
> @@ -1833,7 +1833,6 @@ new_slab:
>  	page = get_partial(s, gfpflags, node);
>  	if (page) {
>  		stat(s, ALLOC_FROM_PARTIAL);
> -load_from_page:
>  		c->node = page_to_nid(page);
>  		c->page = page;
>  		goto load_freelist;
> @@ -1856,6 +1855,7 @@ load_from_page:
> 
>  		slab_lock(page);
>  		__SetPageSlubFrozen(page);
> +		c->node = page_to_nid(page);
>  		c->page = page;
>  		goto load_freelist;
>  	}
> 

So this doesn't apply on top of the stack.


slub: avoid label inside conditional

Jumping to a label inside a conditional is considered poor style, 
especially considering the current organization of __slab_alloc().

This removes the 'load_from_page' label and just duplicates the three 
lines of code that it uses:

	c->node = page_to_nid(page);
	c->page = page;
	goto load_freelist;

since it's probably not worth making this a separate helper function.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1845,7 +1845,6 @@ new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
-load_from_page:
 		c->node = page_to_nid(page);
 		c->page = page;
 		goto load_freelist;
@@ -1868,8 +1867,9 @@ load_from_page:
 
 		slab_lock(page);
 		__SetPageSlubFrozen(page);
-
-		goto load_from_page;
+		c->node = page_to_nid(page);
+		c->page = page;
+		goto load_freelist;
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
