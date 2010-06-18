Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EA9D76B01B2
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 17:44:30 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o5ILiQiv010029
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 14:44:26 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by wpaz33.hot.corp.google.com with ESMTP id o5ILiOQq028645
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 14:44:25 -0700
Received: by pva18 with SMTP id 18so401245pva.37
        for <linux-mm@kvack.org>; Fri, 18 Jun 2010 14:44:24 -0700 (PDT)
Date: Fri, 18 Jun 2010 14:44:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: discard_slab_unlock
In-Reply-To: <alpine.DEB.2.00.1006151405020.10865@router.home>
Message-ID: <alpine.DEB.2.00.1006181438020.16115@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006151405020.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010, Christoph Lameter wrote:

> Subject: slub: discard_slab_unlock
> 
> The sequence of unlocking a slab and freeing occurs multiple times.
> Put the common into a single function.
> 

I personally don't see the benefit in this patch, it simply makes it 
harder for me to find if there are unmatched slab_lock() -> slab_unlock().  
There's no compelling reason to have it and, if done in a generic 
subsystem, we'd have an infinite number of these unlocking functions to 
enforce an order that should otherwise be pretty clear.

That said, I think something like the following would be better if 
nothing more than to annotate the code (we tend to read code better than 
comments :) about the rules:

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1233,6 +1233,7 @@ static void free_slab(struct kmem_cache *s, struct page *page)
 
 static void discard_slab(struct kmem_cache *s, struct page *page)
 {
+	BUG_ON(bit_spin_is_locked(PG_locked, &page->flags));
 	dec_slabs_node(s, page_to_nid(page), page->objects);
 	free_slab(s, page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
