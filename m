Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE896B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:20:40 -0400 (EDT)
Received: by qgf75 with SMTP id 75so2872604qgf.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 02:20:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si346898qks.30.2015.06.16.02.20.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 02:20:39 -0700 (PDT)
Date: Tue, 16 Jun 2015 11:20:33 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Message-ID: <20150616112033.0b8bafb8@redhat.com>
In-Reply-To: <20150616072328.GB13125@js1304-P5Q-DELUXE>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<20150616072328.GB13125@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com

On Tue, 16 Jun 2015 16:23:28 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Mon, Jun 15, 2015 at 05:52:56PM +0200, Jesper Dangaard Brouer wrote:
> > This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
> > now both have bulk alloc and free implemented.
> > 
> > Play nice and reenable local IRQs while calling slowpath.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >  mm/slub.c |   32 +++++++++++++++++++++++++++++++-
> >  1 file changed, 31 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 98d0e6f73ec1..cc4f870677bb 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
> >  
> >  void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> >  {
> > -	__kmem_cache_free_bulk(s, size, p);
> > +	struct kmem_cache_cpu *c;
> > +	struct page *page;
> > +	int i;
> > +
> > +	local_irq_disable();
> > +	c = this_cpu_ptr(s->cpu_slab);
> > +
> > +	for (i = 0; i < size; i++) {
> > +		void *object = p[i];
> > +
> > +		if (unlikely(!object))
> > +			continue; // HOW ABOUT BUG_ON()???
> > +
> > +		page = virt_to_head_page(object);
> > +		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
> 
> You need to use cache_from_objt() to support kmemcg accounting.
> And, slab_free_hook() should be called before free.

Okay, but Christoph choose to not support kmem_cache_debug() in patch2/7.

Should we/I try to add kmem cache debugging support?

If adding these, then I would also need to add those on alloc path...

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
