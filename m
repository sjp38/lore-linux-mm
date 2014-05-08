Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9F86B00EC
	for <linux-mm@kvack.org>; Thu,  8 May 2014 09:51:44 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so2548350qap.20
        for <linux-mm@kvack.org>; Thu, 08 May 2014 06:51:44 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id 68si452169qgk.162.2014.05.08.06.51.43
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 06:51:43 -0700 (PDT)
Date: Thu, 8 May 2014 08:51:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in
 free_block()
In-Reply-To: <alpine.DEB.2.02.1405071429310.8454@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1405080850420.22626@gentwo.org>
References: <20140507212224.9085.qmail@ns.horizon.com> <alpine.DEB.2.02.1405071429310.8454@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: George Spelvin <linux@horizon.com>, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014, David Rientjes wrote:

> > @@ -3362,17 +3359,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
> >  		       int node)
> >  {
> >  	int i;
> > -	struct kmem_cache_node *n;
> > +	struct kmem_cache_node *n = cachep->node[node];
> >
> >  	for (i = 0; i < nr_objects; i++) {
> > -		void *objp;
> > -		struct page *page;
> > -
> > -		clear_obj_pfmemalloc(&objpp[i]);
> > -		objp = objpp[i];
> > +		void *objp = clear_obj_pfmemalloc(&objpp[i]);
> > +		struct page *page = virt_to_head_page(objp);
> >
> > -		page = virt_to_head_page(objp);
> > -		n = cachep->node[node];
> >  		list_del(&page->lru);
> >  		check_spinlock_acquired_node(cachep, node);
> >  		slab_put_obj(cachep, page, objp, node);
>
> I think this unnecessarily obfuscates the code.

It takes the lookup out of the loop. What does the obfuscation?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
