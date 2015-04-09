Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0B95F6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 10:03:27 -0400 (EDT)
Received: by qku63 with SMTP id 63so125326850qku.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 07:03:26 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id 15si14428941qga.22.2015.04.09.07.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 07:03:25 -0700 (PDT)
Date: Thu, 9 Apr 2015 09:03:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub bulk alloc: Extract objects from the per cpu slab
In-Reply-To: <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1504090859560.19278@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org> <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: brouer@redhat.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Wed, 8 Apr 2015, Andrew Morton wrote:

> On Wed, 8 Apr 2015 13:13:29 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
>
> > First piece: accelleration of retrieval of per cpu objects
> >
> >
> > If we are allocating lots of objects then it is advantageous to
> > disable interrupts and avoid the this_cpu_cmpxchg() operation to
> > get these objects faster. Note that we cannot do the fast operation
> > if debugging is enabled.
>
> Why can't we do it if debugging is enabled?

We would have to add extra code to do all the debugging checks. And it
would not be fast anyways.

> > Allocate as many objects as possible in the fast way and then fall
> > back to the generic implementation for the rest of the objects.
>
> Seems sane.  What's the expected success rate of the initial bulk
> allocation attempt?

This is going to increase as we add more capabilities. I have a second
patch here that extends the fast allocation to the per cpu partial pages.

> > +		c->tid = next_tid(c->tid);
> > +
> > +		local_irq_enable();
> > +	}
> > +
> > +	return __kmem_cache_alloc_bulk(s, flags, size, p);
>
> This kmem_cache_cpu.tid logic is a bit opaque.  The low-level
> operations seem reasonably well documented but I couldn't find anywhere
> which tells me how it all actually works - what is "disambiguation
> during cmpxchg" and how do we achieve it?

This is used to force a retry in slab_alloc_node() if preemption occurs
there. We are modifying the per cpu state thus a retry must be forced.

> I'm in two minds about putting
> slab-infrastructure-for-bulk-object-allocation-and-freeing-v3.patch and
> slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch into 4.1.
> They're standalone (ie: no in-kernel callers!) hence harmless, and
> merging them will make Jesper's life a bit easier.  But otoh they are
> unproven and have no in-kernel callers, so formally they shouldn't be
> merged yet.  I suppose we can throw them away again if things don't
> work out.

Can we keep them in -next and I will add patches as we go forward? There
was already a lot of discussion before and I would like to go
incrementally adding methods to do bulk extraction from the various
control structures that we have holding objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
