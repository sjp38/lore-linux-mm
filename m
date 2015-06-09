Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4061D6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 20:40:08 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so2728464pdb.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 17:40:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s7si6426745pdl.14.2015.06.08.17.40.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 17:40:07 -0700 (PDT)
Date: Mon, 8 Jun 2015 17:43:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zsmalloc: fix a null pointer dereference in
 destroy_handle_cache()
Message-Id: <20150608174306.92652579.akpm@linux-foundation.org>
In-Reply-To: <20150609003827.GD9687@js1304-P5Q-DELUXE>
References: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
	<20150608135532.ac913746b6394217e92a229a@linux-foundation.org>
	<20150609003827.GD9687@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Tue, 9 Jun 2015 09:38:27 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > > ...
> > >
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -285,7 +285,8 @@ static int create_handle_cache(struct zs_pool *pool)
> > >  
> > >  static void destroy_handle_cache(struct zs_pool *pool)
> > >  {
> > > -	kmem_cache_destroy(pool->handle_cachep);
> > > +	if (pool->handle_cachep)
> > > +		kmem_cache_destroy(pool->handle_cachep);
> > >  }
> > >  
> > >  static unsigned long alloc_handle(struct zs_pool *pool)
> > 
> > I'll apply this, but...  from a bit of grepping I'm estimating that we
> > have approximately 200 instances of
> > 
> > 	if (foo)
> > 		kmem_cache_destroy(foo);
> > 
> > so obviously kmem_cache_destroy() should be doing the check.
> 
> Hello, Andrew.
> 
> I'm not sure if doing the check in kmem_cache_destroy() is better.

Of course it's better - we have *hundreds* of sites doing something
which could be done at a single site.  Where's the advantage in that?

> My quick grep for other pool based allocators(ex. mempool, zpool) also
> says that they don't check whether passed pool pointer is NULL or not
> in destroy function.

Maybe some of those should be converted as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
