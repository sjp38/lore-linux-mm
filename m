Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id EE1236B0038
	for <linux-mm@kvack.org>; Sat,  5 Sep 2015 07:18:33 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so48689421ioi.2
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 04:18:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q2si9494027pdi.59.2015.09.05.04.18.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Sep 2015 04:18:33 -0700 (PDT)
Date: Sat, 5 Sep 2015 13:18:25 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Message-ID: <20150905131825.6c04837d@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost>
	<20150904165944.4312.32435.stgit@devil>
	<55E9DE51.7090109@gmail.com>
	<alpine.DEB.2.11.1509041354560.993@east.gentwo.org>
	<55EA0172.2040505@gmail.com>
	<alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com, brouer@redhat.com

On Fri, 4 Sep 2015 18:45:13 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 4 Sep 2015, Alexander Duyck wrote:
> > Right, but one of the reasons for Jesper to implement the bulk alloc/free is
> > to avoid the cmpxchg that is being used to get stuff into or off of the per
> > cpu lists.
> 
> There is no full cmpxchg used for the per cpu lists. Its a cmpxchg without
> lock semantics which is very cheap.

The double_cmpxchg without lock prefix still cost 9 cycles, which is
very fast but still a cost (add approx 19 cycles for a lock prefix).

It is slower than local_irq_disable + local_irq_enable that only cost
7 cycles, which the bulking call uses.  (That is the reason bulk calls
with 1 object can almost compete with fastpath).


> > In the case of network drivers they are running in softirq context almost
> > exclusively.  As such it is useful to have a set of buffers that can be
> > acquired or freed from this context without the need to use any
> > synchronization primitives.  Then once the softirq context ends then we can
> > free up some or all of the resources back to the slab allocator.
> 
> That is the case in the slab allocators.

There is a potential for taking advantage of this softirq context,
which is basically what my qmempool implementation did.

But we have now optimized the slub allocator to an extend that (in case
of slab-tuning or slab_nomerge) is faster than my qmempool implementation.

Thus, I would like a smaller/slimmer layer than qmempool.  We do need
some per CPU cache for allocations, like Alex suggests, but I'm not
sure we need that for the free side.  For now I'm returning
objects/skbs directly to slub, and is hoping enough objects can be
merged in a detached freelist, which allow me to return several objects
with a single locked double_cmpxchg.

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
