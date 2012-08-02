Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 2092D6B0099
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:37:13 -0400 (EDT)
Received: by ggm4 with SMTP id 4so10959379ggm.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 13:37:12 -0700 (PDT)
Date: Thu, 2 Aug 2012 13:37:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common [01/19] slub: Add debugging to verify correct cache use
 on kmem_cache_free()
In-Reply-To: <20120802201530.921218259@linux.com>
Message-ID: <alpine.DEB.2.00.1208021334350.5454@chino.kir.corp.google.com>
References: <20120802201506.266817615@linux.com> <20120802201530.921218259@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> Add additional debugging to check that the objects is actually from the cache
> the caller claims. Doing so currently trips up some other debugging code. It
> takes a lot to infer from that what was happening.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2012-08-02 13:52:35.314898373 -0500
> +++ linux-2.6/mm/slub.c	2012-08-02 13:52:38.662958767 -0500
> @@ -2607,6 +2607,13 @@
>  
>  	page = virt_to_head_page(x);
>  
> +	if (kmem_cache_debug(s) && page->slab != s) {
> +		printk("kmem_cache_free: Wrong slab cache. %s but object"
> +			" is from  %s\n", page->slab->name, s->name);
> +		WARN_ON(1);
> +		return;
> +	}
> +

This could quickly spam the kernel log depending on how frequently objects 
are being freed from the buggy callsite, should we disable further 
debugging for the cache in situations like this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
