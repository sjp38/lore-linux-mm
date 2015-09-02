Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id AAC736B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 14:51:07 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so19980827pad.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 11:51:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id oh5si36855496pbb.168.2015.09.02.11.51.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 11:51:07 -0700 (PDT)
Date: Wed, 2 Sep 2015 20:51:01 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] slub: Avoid irqoff/on in bulk allocation
Message-ID: <20150902205101.4dfbb7a9@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1509021300460.14827@east.gentwo.org>
References: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org>
	<20150902110950.4d407c0f@redhat.com>
	<alpine.DEB.2.11.1509021300460.14827@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, brouer@redhat.com

On Wed, 2 Sep 2015 13:04:08 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Wed, 2 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > > +error:
> > > +	__kmem_cache_free_bulk(s, i, p);
> >
> > Don't we need to update "tid" here, like:
> >
> >   c->tid = next_tid(c->tid);
> >
> > Consider a call to the ordinary kmem_cache_alloc/slab_alloc_node was
> > in-progress, which get PREEMPT'ed just before it's call to
> > this_cpu_cmpxchg_double().
> >  Now, this function gets called and we modify c->freelist, but cannot
> > get all objects and then fail (goto error).  Although we put-back
> > objects (via __kmem_cache_free_bulk) don't we want to update c->tid
> > in-order to make sure the call to this_cpu_cmpxchg_double() retry?
> 
> Hmm... I thought that __kmem_cache_free_bulk is run with interrupts
> disabled and will invoke the __slab_free which will increment tid if any
> objects are freed from the local page.

Ah, yes.  Fallback __kmem_cache_free_bulk() will invoke slab_free(),
which will have updated c->tid.  The patch is correct.

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
