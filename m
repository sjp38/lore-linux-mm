Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C069C6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 23:56:53 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so5652876pdj.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 20:56:53 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id p2si6944743pda.257.2015.06.08.20.56.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 20:56:52 -0700 (PDT)
Received: by pdjm12 with SMTP id m12so5652481pdj.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 20:56:52 -0700 (PDT)
Date: Tue, 9 Jun 2015 12:57:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix a null pointer dereference in
 destroy_handle_cache()
Message-ID: <20150609035717.GB3297@swordfish>
References: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150608135532.ac913746b6394217e92a229a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150608135532.ac913746b6394217e92a229a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On (06/08/15 13:55), Andrew Morton wrote:
[..]
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

Oh, sorry I first received "+ zsmalloc-fix-a-null-pointer-dereference-in-
destroy_handle_cache.patch added to -mm tree" message, so I replied
there. fetchmail works somewhat confusing over the last weeks.

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

Yes, I thought about this.

A naive grepping gave me 563 occurrences

 git grep kmem_cache_destroy | wc -l
 563

So I decided to hold this activity. Well, I think I can create this
patch bomb, it's trivial.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
