Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9D66B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 16:17:08 -0400 (EDT)
Received: by qgev79 with SMTP id v79so22800005qge.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 13:17:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p21si4333976qki.114.2015.09.17.13.17.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 13:17:07 -0700 (PDT)
Date: Thu, 17 Sep 2015 22:17:02 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Experiences with slub bulk use-case for network stack
Message-ID: <20150917221702.734a42dc@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1509161009420.21859@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost>
	<20150904165944.4312.32435.stgit@devil>
	<20150916120230.4ca75217@redhat.com>
	<alpine.DEB.2.11.1509161009420.21859@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org, Alexander Duyck <alexander.duyck@gmail.com>, iamjoonsoo.kim@lge.com, brouer@redhat.com

On Wed, 16 Sep 2015 10:13:25 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Wed, 16 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> >
> > Hint, this leads up to discussing if current bulk *ALLOC* API need to
> > be changed...
> >
> > Alex and I have been working hard on practical use-case for SLAB
> > bulking (mostly slUb), in the network stack.  Here is a summary of
> > what we have learned so far.
> 
> SLAB refers to the SLAB allocator which is one slab allocator and SLUB is
> another slab allocator.
> 
> Please keep that consistent otherwise things get confusing

This naming scheme is really confusing.  I'll try to be more
consistent.  So, you want capital letters SLAB and SLUB when talking
about a specific slab allocator implementation.


> > Bulk free'ing SKBs during TX completion is a big and easy win.
> >
> > Specifically for slUb, normal path for freeing these objects (which
> > are not on c->freelist) require a locked double_cmpxchg per object.
> > The bulk free (via detached freelist patch) allow to free all objects
> > belonging to the same slab-page, to be free'ed with a single locked
> > double_cmpxchg. Thus, the bulk free speedup is quite an improvement.
> 
> Yep.
> 
> > Alex and I had the idea of bulk alloc returns an "allocator specific
> > cache" data-structure (and we add some helpers to access this).
> 
> Maybe add some Macros to handle this?

Yes, helpers will likely turn out to be macros.


> > In the slUb case, the freelist is a single linked pointer list.  In
> > the network stack the skb objects have a skb->next pointer, which is
> > located at the same position as freelist pointer.  Thus, simply
> > returning the freelist directly, could be interpreted as a skb-list.
> > The helper API would then do the prefetching, when pulling out
> > objects.
> 
> The problem with the SLUB case is that the objects must be on the same
> slab page.

Yes, I'm aware that, that is what we are trying to take advantage of.


> > For the slUb case, we would simply cmpxchg either c->freelist or
> > page->freelist with a NULL ptr, and then own all objects on the
> > freelist. This also reduce the time we keep IRQs disabled.
> 
> You dont need to disable interrupts for the cmpxchges. There is
> additional state in the page struct though so the updates must be
> done carefully.

Yes, I'm aware of cmpxchg does not need to disable interrupts.  And I
plan to take advantage of this, in this new approach for bulk alloc.

Our current bulk alloc disables interrupts for the full period (of
collecting the number requested objects).

What I'm proposing is keeping interrupts on, and then simply cmpxchg
e.g 2 slab-pages out of the SLUB allocator (which the SLUB code calls
freelist's). The bulk call now owns these freelists, and returns them
to the caller.  The API caller gets some helpers/macros to access
objects, to shield him from the details (of SLUB freelist's).

The pitfall with this API is we don't know how many objects are on a
SLUB freelist.  And we cannot walk the freelist and count them, because
then we hit the problem of memory/cache stalls (that we are trying so
hard to avoid).

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
