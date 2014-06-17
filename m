Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1F65F6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:45:15 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so6683265iec.23
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:45:14 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id dr7si27746897icb.101.2014.06.17.14.45.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 14:45:14 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so7043099iec.28
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:45:14 -0700 (PDT)
Date: Tue, 17 Jun 2014 14:45:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slab common: Add functions for kmem_cache_node
 access
In-Reply-To: <20140617141713.08e290145d24ca95c487c330@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1406171444310.27899@chino.kir.corp.google.com>
References: <20140611191510.082006044@linux.com> <20140611191518.964245135@linux.com> <20140617141713.08e290145d24ca95c487c330@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 17 Jun 2014, Andrew Morton wrote:

> On Wed, 11 Jun 2014 14:15:11 -0500 Christoph Lameter <cl@linux.com> wrote:
> 
> > These functions allow to eliminate repeatedly used code in both
> > SLAB and SLUB and also allow for the insertion of debugging code
> > that may be needed in the development process.
> > 
> > ...
> >
> > --- linux.orig/mm/slab.h	2014-06-10 14:18:11.506956436 -0500
> > +++ linux/mm/slab.h	2014-06-10 14:21:51.279893231 -0500
> > @@ -294,5 +294,18 @@ struct kmem_cache_node {
> >  
> >  };
> >  
> > +static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
> > +{
> > +	return s->node[node];
> > +}
> > +
> > +/*
> > + * Iterator over all nodes. The body will be executed for each node that has
> > + * a kmem_cache_node structure allocated (which is true for all online nodes)
> > + */
> > +#define for_each_kmem_cache_node(__s, __node, __n) \
> > +	for (__node = 0; __n = get_node(__s, __node), __node < nr_node_ids; __node++) \
> > +		 if (__n)
> 
> Clueless newbs would be aided if this comment were to describe the
> iterator's locking requirements.
> 

There are no locking requirements, if the nodelist is initialized then we 
are good to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
