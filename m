Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4446B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 20:36:48 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so2649899pdj.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 17:36:47 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id hy8si6339763pab.227.2015.06.08.17.36.46
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 17:36:47 -0700 (PDT)
Date: Tue, 9 Jun 2015 09:38:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] zsmalloc: fix a null pointer dereference in
 destroy_handle_cache()
Message-ID: <20150609003827.GD9687@js1304-P5Q-DELUXE>
References: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150608135532.ac913746b6394217e92a229a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150608135532.ac913746b6394217e92a229a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Mon, Jun 08, 2015 at 01:55:32PM -0700, Andrew Morton wrote:
> On Fri,  5 Jun 2015 20:11:30 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:
> 
> > zs_destroy_pool()->destroy_handle_cache() invoked from
> > zs_create_pool() can pass a NULL ->handle_cachep pointer
> > to kmem_cache_destroy(), which will dereference it.
> >
> 
> That's slightly lacking in details (under what circumstances will it
> crash) so I changed it to
> 
> : If zs_create_pool()->create_handle_cache()->kmem_cache_create() fails,
> : zs_create_pool()->destroy_handle_cache() will dereference the NULL
> : pool->handle_cachep.
> :
> : Modify destroy_handle_cache() to avoid this.
> 
> 
> > ...
> >
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -285,7 +285,8 @@ static int create_handle_cache(struct zs_pool *pool)
> >  
> >  static void destroy_handle_cache(struct zs_pool *pool)
> >  {
> > -	kmem_cache_destroy(pool->handle_cachep);
> > +	if (pool->handle_cachep)
> > +		kmem_cache_destroy(pool->handle_cachep);
> >  }
> >  
> >  static unsigned long alloc_handle(struct zs_pool *pool)
> 
> I'll apply this, but...  from a bit of grepping I'm estimating that we
> have approximately 200 instances of
> 
> 	if (foo)
> 		kmem_cache_destroy(foo);
> 
> so obviously kmem_cache_destroy() should be doing the check.

Hello, Andrew.

I'm not sure if doing the check in kmem_cache_destroy() is better.
My quick grep for other pool based allocators(ex. mempool, zpool) also
says that they don't check whether passed pool pointer is NULL or not
in destroy function. I think that it's general convention that proper
pool pointer should be passed to pool based function APIs.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
