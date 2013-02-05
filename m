Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DF6F66B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:16:52 -0500 (EST)
Message-ID: <1360073811.27007.13.camel@gandalf.local.home>
Subject: Re: [PATCH] slob: Check for NULL pointer before calling ctor()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 05 Feb 2013 09:16:51 -0500
In-Reply-To: <1358442826.23211.18.camel@gandalf.local.home>
References: <1358442826.23211.18.camel@gandalf.local.home>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Ping?

-- Steve


On Thu, 2013-01-17 at 12:13 -0500, Steven Rostedt wrote:
> [ Sorry for the duplicate email, it's linux-mm@kvack.org not linux-mm@vger.kernel.org ] 
> 
> While doing some code inspection, I noticed that the slob constructor
> method can be called with a NULL pointer. If memory is tight and slob
> fails to allocate with slob_alloc() or slob_new_pages() it still calls
> the ctor() method with a NULL pointer. Looking at the first ctor()
> method I found, I noticed that it can not handle a NULL pointer (I'm
> sure others probably can't either):
> 
> static void sighand_ctor(void *data)
> {
>         struct sighand_struct *sighand = data;
> 
>         spin_lock_init(&sighand->siglock);
>         init_waitqueue_head(&sighand->signalfd_wqh);
> }
> 
> The solution is to only call the ctor() method if allocation succeeded.
> 
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> 
> diff --git a/mm/slob.c b/mm/slob.c
> index a99fdf7..48fcb90 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -554,7 +554,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
>  					    flags, node);
>  	}
>  
> -	if (c->ctor)
> +	if (b && c->ctor)
>  		c->ctor(b);
>  
>  	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
