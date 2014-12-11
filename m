Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id B11B26B0032
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 05:19:16 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so3330952qae.31
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 02:19:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d108si773821qgf.1.2014.12.11.02.19.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 02:19:15 -0800 (PST)
Date: Thu, 11 Dec 2014 11:18:59 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
 (backed by alf_queue)
Message-ID: <20141211111859.21e23e90@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1412101339480.22982@gentwo.org>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
	<20141210141332.31779.56391.stgit@dragon>
	<alpine.DEB.2.11.1412101339480.22982@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>, brouer@redhat.com

On Wed, 10 Dec 2014 13:51:32 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Wed, 10 Dec 2014, Jesper Dangaard Brouer wrote:
> 
> > One of the building blocks for achieving this speedup is a cmpxchg
> > based Lock-Free queue that supports bulking, named alf_queue for
> > Array-based Lock-Free queue.  By bulking elements (pointers) from the
> > queue, the cost of the cmpxchg (approx 8 ns) is amortized over several
> > elements.
> 
> This is a bit of an issue since the design of the SLUB allocator is such
> that you should pick up an object, apply some processing and then take the
> next one. The fetching of an object warms up the first cacheline and this
> is tied into the way free objects are linked in SLUB.
> 
> So a bulk fetch from SLUB will not that effective and cause the touching
> of many cachelines if we are dealing with just a few objects. If we are
> looking at whole slab pages with all objects then SLUB can be effective
> since we do not have to build up the linked pointer structure in each
> page. SLAB has a different architecture there and a bulk fetch there is
> possible without touching objects even for small sets since the freelist
> management is separate from the objects.
> 
> If you do this bulking then you will later access cache cold objects?
> Doesnt that negate the benefit that you gain? Or are these objects written
> to by hardware and therefore by necessity cache cold?

Cache warmup is a concern, but perhaps it's the callers responsibility
to prefetch for their use-case.  For qmempool I do have patches that
prefetch elems when going from the sharedq to the localq (per CPU), but
I didn't see much gain, and I could prove my point (of being faster than
slab) without it.  And I would use/need the slab bulk interface to add
elems to sharedq which I consider semi-cache cold.


> We could provide a faster bulk alloc/free function.
> 
> 	int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags,
> 		size_t objects, void **array)

I like it :-)

> and this could be optimized by each slab allocator to provide fast
> population of objects in that array. We then assume that the number of
> objects is in the hundreds or so right?

I'm already seeing a benefit with 16 packets alloc/free "bulking".

On RX we have a "budget" of 64 packets/descriptors (taken from the NIC
RX ring) that need SKBs.

On TX packets are put into the TX ring, and later at TX completion the
TX ring is cleaned up, as many as 256 (as e.g. in the ixgbe driver).

Scientific articles on userspace networking (like netmap) report that
they need at least 8 packet bulking to see wirespeed 10G at 64 bytes.


> The corresponding free function
> 
> 	void kmem_cache_free_array(struct kmem_cache *s,
> 		size_t objects, void **array)
> 
> 
> I think the queue management of the array can be improved by using a
> similar technique as used the SLUB allocator using the cmpxchg_local.
> cmpxchg_local is much faster than a full cmpxchg and we are operating on
> per cpu structures anyways. So the overhead could still be reduced.

I think you missed that the per cpu localq is already not using cmpxchg
(it is a SPSC queue).  The sharedq (MPMC queue) does need and use the
locked cmpxchg.

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
