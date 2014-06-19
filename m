Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BE74A6B003C
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:37:25 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so3482980wiv.8
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:37:25 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id f1si4132119wjw.158.2014.06.19.13.37.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:37:24 -0700 (PDT)
Date: Thu, 19 Jun 2014 22:37:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <20140619202928.GG4904@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1406192230390.5170@nanos>
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos> <20140619202928.GG4904@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> On Thu, Jun 19, 2014 at 09:29:08PM +0200, Thomas Gleixner wrote:
> > On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> > Well, no. Look at the callchain:
> > 
> > __call_rcu
> >     debug_object_activate
> >        rcuhead_fixup_activate
> >           debug_object_init
> >               kmem_cache_alloc
> > 
> > So call rcu activates the object, but the object has no reference in
> > the debug objects code so the fixup code is called which inits the
> > object and allocates a reference ....
> 
> OK, got it.  And you are right, call_rcu() has done this for a very
> long time, so not sure what changed.  But it seems like the right
> approach is to provide a debug-object-free call_rcu_alloc() for use
> by the memory allocators.
> 
> Seem reasonable?  If so, please see the following patch.

Not really, you're torpedoing the whole purpose of debugobjects :)

So, why can't we just init the rcu head when the stuff is created?

If that's impossible due to other memory allocator constraints, then
instead of inventing a whole new API we can simply flag the relevent
data in the memory allocator as we do with the debug objects mem cache
itself (SLAB_DEBUG_OBJECTS).

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
