Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B6912900001
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:03:36 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p4BK3YrP027067
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:34 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by hpaq11.eem.corp.google.com with ESMTP id p4BK3VQe022566
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:33 -0700
Received: by pvg3 with SMTP id 3so522798pvg.18
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:31 -0700 (PDT)
Date: Wed, 11 May 2011 13:03:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup6 4/5] slub: Move node determination out of
 hotpath
In-Reply-To: <20110415194831.991653328@linux.com>
Message-ID: <alpine.DEB.2.00.1105111255130.9346@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194831.991653328@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Fri, 15 Apr 2011, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-04-15 12:52:17.000000000 -0500
> +++ linux-2.6/mm/slub.c	2011-04-15 12:54:15.000000000 -0500
> @@ -1828,7 +1828,6 @@ load_freelist:
>  	c->freelist = get_freepointer(s, object);
>  	page->inuse = page->objects;
>  	page->freelist = NULL;
> -	c->node = page_to_nid(page);
>  
>  unlock_out:
>  	slab_unlock(page);
> @@ -1845,8 +1844,10 @@ another_slab:
>  new_slab:
>  	page = get_partial(s, gfpflags, node);
>  	if (page) {
> -		c->page = page;
>  		stat(s, ALLOC_FROM_PARTIAL);
> +load_from_page:
> +		c->node = page_to_nid(page);
> +		c->page = page;
>  		goto load_freelist;
>  	}
>  

I don't like this because it's using a label within a conditional in an 
already very cluttered __slab_alloc().  This function could benefit from 
some serious cleanup instead of adding even more code that resembles 
spaghetti code from BASIC just to avoid two lines of duplicate code.

> @@ -1867,8 +1868,8 @@ new_slab:
>  
>  		slab_lock(page);
>  		__SetPageSlubFrozen(page);
> -		c->page = page;
> -		goto load_freelist;
> +
> +		goto load_from_page;

I'd much prefer to just add a

	c->node = page_to_nid(page);

rather than the new label and goto into a conditional.

>  	}
>  	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
>  		slab_out_of_memory(s, gfpflags, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
