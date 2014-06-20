Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5D17D6B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 04:17:54 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so345986wib.11
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 01:17:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id qi1si10186962wjc.18.2014.06.20.01.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 01:17:52 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:17:32 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <20140619220449.GT4904@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1406201015440.5170@nanos>
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos> <20140619202928.GG4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192230390.5170@nanos>
 <20140619205307.GL4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192331250.5170@nanos> <20140619220449.GT4904@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> On Thu, Jun 19, 2014 at 11:32:41PM +0200, Thomas Gleixner wrote:
> > 
> > 
> > On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> > 
> > > On Thu, Jun 19, 2014 at 10:37:17PM +0200, Thomas Gleixner wrote:
> > > > On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> > > > > On Thu, Jun 19, 2014 at 09:29:08PM +0200, Thomas Gleixner wrote:
> > > > > > On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> > > > > > Well, no. Look at the callchain:
> > > > > > 
> > > > > > __call_rcu
> > > > > >     debug_object_activate
> > > > > >        rcuhead_fixup_activate
> > > > > >           debug_object_init
> > > > > >               kmem_cache_alloc
> > > > > > 
> > > > > > So call rcu activates the object, but the object has no reference in
> > > > > > the debug objects code so the fixup code is called which inits the
> > > > > > object and allocates a reference ....
> > > > > 
> > > > > OK, got it.  And you are right, call_rcu() has done this for a very
> > > > > long time, so not sure what changed.  But it seems like the right
> > > > > approach is to provide a debug-object-free call_rcu_alloc() for use
> > > > > by the memory allocators.
> > > > > 
> > > > > Seem reasonable?  If so, please see the following patch.
> > > > 
> > > > Not really, you're torpedoing the whole purpose of debugobjects :)
> > > > 
> > > > So, why can't we just init the rcu head when the stuff is created?
> > > 
> > > That would allow me to keep my code unchanged, so I am in favor.  ;-)
> > 
> > Almost unchanged. You need to provide a function to do so, i.e. make
> > use of
> > 
> >     debug_init_rcu_head()
> 
> You mean like this?

I'd rather name it init_rcu_head() and free_rcu_head() w/o the debug_
prefix, so it's consistent with init_rcu_head_on_stack /
destroy_rcu_head_on_stack. But either way works for me.

Acked-by: Thomas Gleixner <tglx@linutronix.de>

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
