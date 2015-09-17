Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8877A6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 19:57:19 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so7029702igb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 16:57:19 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id x75si4491674ioi.11.2015.09.17.16.57.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 17 Sep 2015 16:57:18 -0700 (PDT)
Date: Thu, 17 Sep 2015 18:57:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Experiences with slub bulk use-case for network stack
In-Reply-To: <20150917221702.734a42dc@redhat.com>
Message-ID: <alpine.DEB.2.11.1509171854480.5696@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <20150916120230.4ca75217@redhat.com> <alpine.DEB.2.11.1509161009420.21859@east.gentwo.org> <20150917221702.734a42dc@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org, Alexander Duyck <alexander.duyck@gmail.com>, iamjoonsoo.kim@lge.com

On Thu, 17 Sep 2015, Jesper Dangaard Brouer wrote:

> What I'm proposing is keeping interrupts on, and then simply cmpxchg
> e.g 2 slab-pages out of the SLUB allocator (which the SLUB code calls
> freelist's). The bulk call now owns these freelists, and returns them
> to the caller.  The API caller gets some helpers/macros to access
> objects, to shield him from the details (of SLUB freelist's).
>
> The pitfall with this API is we don't know how many objects are on a
> SLUB freelist.  And we cannot walk the freelist and count them, because
> then we hit the problem of memory/cache stalls (that we are trying so
> hard to avoid).

If you get a fresh page from the page allocator then you know how many
objects are available in a slab page.

There is also a counter in each slab page for the objects allocated. The
number of free object is page->objects - page->inuse.

This is only true for a lockec cmpxchg. The unlocked cmpxchg used for the
per cpu freelist does not use the counters in the page struct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
