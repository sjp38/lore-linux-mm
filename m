Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1F186B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 20:38:14 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o8T0cCbC000364
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:12 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe14.cbf.corp.google.com with ESMTP id o8T0bcDq023415
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:10 -0700
Received: by pvh1 with SMTP id 1so68166pvh.9
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:10 -0700 (PDT)
Date: Tue, 28 Sep 2010 17:38:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup5 2/3] SLUB: Pass active and inactive redzone flags
 instead of boolean to debug functions
In-Reply-To: <20100928131057.084357922@linux.com>
Message-ID: <alpine.DEB.2.00.1009281733430.9704@chino.kir.corp.google.com>
References: <20100928131025.319846721@linux.com> <20100928131057.084357922@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Christoph Lameter wrote:

> @@ -1075,8 +1071,9 @@ static inline int free_debug_processing(
>  static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
>  			{ return 1; }
>  static inline int check_object(struct kmem_cache *s, struct page *page,
> -			void *object, int active) { return 1; }
> -static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
> +			void *object, u8 val) { return 1; }
> +static inline void add_full(struct kmem_cache *s,
> +		struct kmem_cache_node *n, struct page *page) {}
>  static inline unsigned long kmem_cache_flags(unsigned long objsize,
>  	unsigned long flags, const char *name,
>  	void (*ctor)(void *))

Looks like add_full() got changed there for CONFIG_SLUB_DEBUG=n 
unintentionally.

I'm wondering if we should make that option configurable regardless of 
CONFIG_EMBEDDED, it's a large savings if you're never going to be doing 
any debugging on Pekka's for-next:

   text	   data	    bss	    dec	    hex	filename
  25817	   1473	    288	  27578	   6bba	slub.o.debug
  10742	    232	    256	  11230	   2bde	slub.o.nodebug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
