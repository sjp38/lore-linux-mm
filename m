Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D417D6B02C3
	for <linux-mm@kvack.org>; Mon, 22 May 2017 16:56:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c10so141458419pfg.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:56:23 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id d14si18503814pln.57.2017.05.22.13.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 13:56:23 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id e193so93190233pfh.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:56:22 -0700 (PDT)
Date: Mon, 22 May 2017 13:56:21 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
Message-ID: <20170522205621.GL141096@google.com>
References: <20170519210036.146880-1-mka@chromium.org>
 <20170519210036.146880-2-mka@chromium.org>
 <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

El Mon, May 22, 2017 at 01:39:26PM -0700 David Rientjes ha dit:

> On Fri, 19 May 2017, Matthias Kaehlcke wrote:
> 
> > The function is only used when CONFIG_NUMA=y. Placing it in an #ifdef
> > block fixes the following warning when building with clang:
> > 
> > mm/slub.c:1246:20: error: unused function 'kmalloc_large_node_hook'
> >     [-Werror,-Wunused-function]
> > 
> 
> Is clang not inlining kmalloc_large_node_hook() for some reason?  I don't 
> think this should ever warn on gcc.

clang warns about unused static inline functions outside of header
files, in difference to gcc.

> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> > ---
> >  mm/slub.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 57e5156f02be..66e1046435b7 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1313,11 +1313,14 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
> >   * Hooks for other subsystems that check memory allocations. In a typical
> >   * production configuration these hooks all should produce no code at all.
> >   */
> > +
> > +#ifdef CONFIG_NUMA
> >  static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
> >  {
> >  	kmemleak_alloc(ptr, size, 1, flags);
> >  	kasan_kmalloc_large(ptr, size, flags);
> >  }
> > +#endif
> >  
> >  static inline void kfree_hook(const void *x)
> >  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
