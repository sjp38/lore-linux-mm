Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA966B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 11:13:28 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so221835327ykd.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 08:13:28 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id p32si22294847qge.61.2015.09.16.08.13.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 16 Sep 2015 08:13:27 -0700 (PDT)
Date: Wed, 16 Sep 2015 10:13:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Experiences with slub bulk use-case for network stack
In-Reply-To: <20150916120230.4ca75217@redhat.com>
Message-ID: <alpine.DEB.2.11.1509161009420.21859@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <20150916120230.4ca75217@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org, Alexander Duyck <alexander.duyck@gmail.com>, iamjoonsoo.kim@lge.com

On Wed, 16 Sep 2015, Jesper Dangaard Brouer wrote:

>
> Hint, this leads up to discussing if current bulk *ALLOC* API need to
> be changed...
>
> Alex and I have been working hard on practical use-case for SLAB
> bulking (mostly slUb), in the network stack.  Here is a summary of
> what we have learned so far.

SLAB refers to the SLAB allocator which is one slab allocator and SLUB is
another slab allocator.

Please keep that consistent otherwise things get confusing

> Bulk free'ing SKBs during TX completion is a big and easy win.
>
> Specifically for slUb, normal path for freeing these objects (which
> are not on c->freelist) require a locked double_cmpxchg per object.
> The bulk free (via detached freelist patch) allow to free all objects
> belonging to the same slab-page, to be free'ed with a single locked
> double_cmpxchg. Thus, the bulk free speedup is quite an improvement.

Yep.

> Alex and I had the idea of bulk alloc returns an "allocator specific
> cache" data-structure (and we add some helpers to access this).

Maybe add some Macros to handle this?

> In the slUb case, the freelist is a single linked pointer list.  In
> the network stack the skb objects have a skb->next pointer, which is
> located at the same position as freelist pointer.  Thus, simply
> returning the freelist directly, could be interpreted as a skb-list.
> The helper API would then do the prefetching, when pulling out
> objects.

The problem with the SLUB case is that the objects must be on the same
slab page.

> For the slUb case, we would simply cmpxchg either c->freelist or
> page->freelist with a NULL ptr, and then own all objects on the
> freelist. This also reduce the time we keep IRQs disabled.

You dont need to disable interrupts for the cmpxchges. There is additional
state in the page struct though so the updates must be done carefully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
