Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id F28A46B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 06:44:37 -0400 (EDT)
Received: by yken206 with SMTP id n206so20813727yke.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:44:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id px19si15377745vdb.93.2015.06.10.03.44.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 03:44:36 -0700 (PDT)
Date: Wed, 10 Jun 2015 12:44:26 +0200
From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: Corruption with MMOTS
 slub-bulk-allocation-from-per-cpu-partial-pages.patch
Message-ID: <20150610124426.231e1a5e@redhat.com>
In-Reply-To: <20150609002258.GA9687@js1304-P5Q-DELUXE>
References: <20150608121639.3d9ce2aa@redhat.com>
	<20150609002258.GA9687@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>


To Andrew/Christoph, can we drop this patch?  Then, I'll base my work
on top of the previous patch.  Which also need some bug fixes, as
pointed out by Joonsoo.

(p.s. iif then also drop
slub-bulk-allocation-from-per-cpu-partial-pages-fix.patch)


On Tue, 9 Jun 2015 09:22:59 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Mon, Jun 08, 2015 at 12:16:39PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > It seems the patch from (inserted below):
> >  http://ozlabs.org/~akpm/mmots/broken-out/slub-bulk-allocation-from-per-cpu-partial-pages.patch
> > 
> > Is not protecting access to c->partial "enough" (section is under
> > local_irq_disable/enable).  When exercising bulk API I can make it
> > crash/corrupt memory when compiled with CONFIG_SLUB_CPU_PARTIAL=y
> > 
> > First I suspected:
> >  object = get_freelist(s, c->page); 
> > But the problem goes way with CONFIG_SLUB_CPU_PARTIAL=n
> > 
> > 
> > From: Christoph Lameter <cl@linux.com>
> > Subject: slub: bulk allocation from per cpu partial pages
> > 
> > Cover all of the per cpu objects available.
> > 
> > Expand the bulk allocation support to drain the per cpu partial pages
> > while interrupts are off.
> > 
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > Cc: Pekka Enberg <penberg@kernel.org>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  mm/slub.c |   36 +++++++++++++++++++++++++++++++++---
> >  1 file changed, 33 insertions(+), 3 deletions(-)
> > 
> > diff -puN mm/slub.c~slub-bulk-allocation-from-per-cpu-partial-pages mm/slub.c
> > --- a/mm/slub.c~slub-bulk-allocation-from-per-cpu-partial-pages
> > +++ a/mm/slub.c
> > @@ -2769,15 +2769,45 @@ bool kmem_cache_alloc_bulk(struct kmem_c
> >  		while (size) {
> >  			void *object = c->freelist;
> >  
> > -			if (!object)
> > -				break;
> > +			if (unlikely(!object)) {
> > +				/*
> > +				 * Check if there remotely freed objects
> > +				 * availalbe in the page.
> > +				 */
> > +				object = get_freelist(s, c->page);
> > +
> > +				if (!object) {
> > +					/*
> > +					 * All objects in use lets check if
> > +					 * we have other per cpu partial
> > +					 * pages that have available
> > +					 * objects.
> > +					 */
> > +					c->page = c->partial;
> > +					if (!c->page) {
> > +						/* No per cpu objects left */
> > +						c->freelist = NULL;
> > +						break;
> > +					}
> > +
> > +					/* Next per cpu partial page */
> > +					c->partial = c->page->next;
> > +					c->freelist = get_freelist(s,
> > +							c->page);
> > +					continue;
> > +				}
> > +
> > +			}
> > +
> >  
> > -			c->freelist = get_freepointer(s, object);
> >  			*p++ = object;
> >  			size--;
> >  
> >  			if (unlikely(flags & __GFP_ZERO))
> >  				memset(object, 0, s->object_size);
> > +
> > +			c->freelist = get_freepointer(s, object);
> > +
> 
> Hello,
> 
> get_freepointer() should be called before zeroing object.
> It may help your problem.

That is a bug, but I'm not invoking with __GFP_ZERO...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
