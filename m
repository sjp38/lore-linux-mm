Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCA56B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 06:02:37 -0400 (EDT)
Received: by qgt47 with SMTP id 47so166283858qgt.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 03:02:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h185si21167561qhc.83.2015.09.16.03.02.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 03:02:36 -0700 (PDT)
Date: Wed, 16 Sep 2015 12:02:30 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Experiences with slub bulk use-case for network stack
Message-ID: <20150916120230.4ca75217@redhat.com>
In-Reply-To: <20150904165944.4312.32435.stgit@devil>
References: <20150824005727.2947.36065.stgit@localhost>
	<20150904165944.4312.32435.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, Alexander Duyck <alexander.duyck@gmail.com>, iamjoonsoo.kim@lge.com


Hint, this leads up to discussing if current bulk *ALLOC* API need to
be changed...

Alex and I have been working hard on practical use-case for SLAB
bulking (mostly slUb), in the network stack.  Here is a summary of
what we have learned so far.

Bulk free'ing SKBs during TX completion is a big and easy win.

Specifically for slUb, normal path for freeing these objects (which
are not on c->freelist) require a locked double_cmpxchg per object.
The bulk free (via detached freelist patch) allow to free all objects
belonging to the same slab-page, to be free'ed with a single locked
double_cmpxchg. Thus, the bulk free speedup is quite an improvement.

The slUb alloc is hard to beat on speed:
 * accessing c->freelist, local cmpxchg 9 cycles (38% of cost)
 * c->freelist is refilled with single locked cmpxchg

In micro benchmarking it looks like we can beat alloc, because we do a
local_irq_{disable,enable} (cost 7 cycles).  And then pull out all
objects in c->freelist.  Thus, saving 9 cycles per object (counting
from the 2nd object).

However, in practical use-cases we are seeing the single object alloc
win over bulk alloc, we believe this to be due to prefetching.  When
c->freelist get (semi) cache-cold, then it gets more expensive to walk
the freelist (which is a basic single linked list to next free object).

For bulk alloc the full freelist is walked (right-way) and objects
pulled out into the array.  For normal single object alloc only a
single object is returned, but it does a prefetch on the next object
pointer.  Thus, next time single alloc is called the object will have
been prefetched.  Doing prefetch in bulk alloc only helps a little, as
it does not have enough "time" between accessing/walking the freelist
for objects.

So, how can we solve this and make bulk alloc faster?


Alex and I had the idea of bulk alloc returns an "allocator specific
cache" data-structure (and we add some helpers to access this).

In the slUb case, the freelist is a single linked pointer list.  In
the network stack the skb objects have a skb->next pointer, which is
located at the same position as freelist pointer.  Thus, simply
returning the freelist directly, could be interpreted as a skb-list.
The helper API would then do the prefetching, when pulling out
objects.

For the slUb case, we would simply cmpxchg either c->freelist or
page->freelist with a NULL ptr, and then own all objects on the
freelist. This also reduce the time we keep IRQs disabled.

API wise, we don't (necessary) know how many objects are on the
freelist (without first walking the list, which would cause stalls on
data, which we are trying to avoid).

Thus, the API of always returning the exact number of requested
objects will not work...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

(related to http://thread.gmane.org/gmane.linux.kernel.mm/137469)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
