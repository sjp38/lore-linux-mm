Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 4BC3E6B0044
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:39:08 -0400 (EDT)
Date: Tue, 23 Oct 2012 20:39:06 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [08/15] slab: Use common kmalloc_index/kmalloc_size
 functions
In-Reply-To: <CAAmzW4Pmb5uFGC=qaC0WfM_pZ1s+x4Knz0QJogZZ8vesnkF6qw@mail.gmail.com>
Message-ID: <0000013a8f59a08d-c08e9180-a368-4edd-b9ac-d512e2a3ce19-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com> <0000013a797cda39-907d3721-264e-4d75-8d4d-4122eb0a981c-000000@email.amazonses.com> <CAAmzW4Pmb5uFGC=qaC0WfM_pZ1s+x4Knz0QJogZZ8vesnkF6qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Sun, 21 Oct 2012, JoonSoo Kim wrote:

> 2012/10/19 Christoph Lameter <cl@linux.com>:
>
> > @@ -693,20 +657,19 @@ static inline struct array_cache *cpu_ca
> >  static inline struct kmem_cache *__find_general_cachep(size_t size,
> >                                                         gfp_t gfpflags)
> >  {
> > -       struct cache_sizes *csizep = malloc_sizes;
> > +       int i;
> >
> >  #if DEBUG
> >         /* This happens if someone tries to call
> >          * kmem_cache_create(), or __kmalloc(), before
> >          * the generic caches are initialized.
> >          */
> > -       BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
> > +       BUG_ON(kmalloc_caches[INDEX_AC] == NULL);
> >  #endif
> >         if (!size)
> >                 return ZERO_SIZE_PTR;
> >
> > -       while (size > csizep->cs_size)
> > -               csizep++;
> > +       i = kmalloc_index(size);
>
> Above kmalloc_index(size) is called with arbitrary size, therefore it
> cannot be folded.

The size is passed into an inline function that is folded and therefore
the kmalloc_index function can also be folded if the size passed into
__find_general_cachep was constant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
