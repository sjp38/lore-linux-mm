Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id DF99C6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:53:20 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id a41so2146525yho.39
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:53:20 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id g26si9956701yhl.210.2014.06.19.13.53.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:53:20 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 14:53:19 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3EB423E40066
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:53:09 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5JIneMX59179116
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 20:49:40 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s5JKv5a4005332
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:57:05 -0600
Date: Thu, 19 Jun 2014 13:53:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: slub/debugobjects: lockup when freeing memory
Message-ID: <20140619205307.GL4904@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <53A2F406.4010109@oracle.com>
 <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
 <20140619165247.GA4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192127100.5170@nanos>
 <20140619202928.GG4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192230390.5170@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406192230390.5170@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 19, 2014 at 10:37:17PM +0200, Thomas Gleixner wrote:
> On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> > On Thu, Jun 19, 2014 at 09:29:08PM +0200, Thomas Gleixner wrote:
> > > On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> > > Well, no. Look at the callchain:
> > > 
> > > __call_rcu
> > >     debug_object_activate
> > >        rcuhead_fixup_activate
> > >           debug_object_init
> > >               kmem_cache_alloc
> > > 
> > > So call rcu activates the object, but the object has no reference in
> > > the debug objects code so the fixup code is called which inits the
> > > object and allocates a reference ....
> > 
> > OK, got it.  And you are right, call_rcu() has done this for a very
> > long time, so not sure what changed.  But it seems like the right
> > approach is to provide a debug-object-free call_rcu_alloc() for use
> > by the memory allocators.
> > 
> > Seem reasonable?  If so, please see the following patch.
> 
> Not really, you're torpedoing the whole purpose of debugobjects :)
> 
> So, why can't we just init the rcu head when the stuff is created?

That would allow me to keep my code unchanged, so I am in favor.  ;-)

							Thanx, Paul

> If that's impossible due to other memory allocator constraints, then
> instead of inventing a whole new API we can simply flag the relevent
> data in the memory allocator as we do with the debug objects mem cache
> itself (SLAB_DEBUG_OBJECTS).
> 
> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
