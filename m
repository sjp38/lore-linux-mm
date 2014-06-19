Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 868C66B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 15:29:21 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so2843950wes.12
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 12:29:21 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id t2si8406051wjw.106.2014.06.19.12.29.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 12:29:19 -0700 (PDT)
Date: Thu, 19 Jun 2014 21:29:08 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <20140619165247.GA4904@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1406192127100.5170@nanos>
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Paul E. McKenney wrote:

> On Thu, Jun 19, 2014 at 10:03:04AM -0500, Christoph Lameter wrote:
> > On Thu, 19 Jun 2014, Sasha Levin wrote:
> > 
> > > [  690.770137] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> > > [  690.770137] __slab_alloc (mm/slub.c:1732 mm/slub.c:2205 mm/slub.c:2369)
> > > [  690.770137] ? __lock_acquire (kernel/locking/lockdep.c:3189)
> > > [  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> > > [  690.770137] kmem_cache_alloc (mm/slub.c:2442 mm/slub.c:2484 mm/slub.c:2489)
> > > [  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> > > [  690.770137] ? debug_object_activate (lib/debugobjects.c:439)
> > > [  690.770137] __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> > > [  690.770137] debug_object_init (lib/debugobjects.c:365)
> > > [  690.770137] rcuhead_fixup_activate (kernel/rcu/update.c:231)
> > > [  690.770137] debug_object_activate (lib/debugobjects.c:280 lib/debugobjects.c:439)
> > > [  690.770137] ? discard_slab (mm/slub.c:1486)
> > > [  690.770137] __call_rcu (kernel/rcu/rcu.h:76 (discriminator 2) kernel/rcu/tree.c:2585 (discriminator 2))
> > 
> > __call_rcu does a slab allocation? This means __call_rcu can no longer be
> > used in slab allocators? What happened?
> 
> My guess is that the root cause is a double call_rcu(), call_rcu_sched(),
> call_rcu_bh(), or call_srcu().
> 
> Perhaps the DEBUG_OBJECTS code now allocates memory to report errors?
> That would be unfortunate...

Well, no. Look at the callchain:

__call_rcu
    debug_object_activate
       rcuhead_fixup_activate
          debug_object_init
              kmem_cache_alloc

So call rcu activates the object, but the object has no reference in
the debug objects code so the fixup code is called which inits the
object and allocates a reference ....

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
