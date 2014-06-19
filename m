Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 58FA46B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:28:27 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so2764441wgg.1
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:28:26 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id u5si8592557wjf.58.2014.06.19.13.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:28:26 -0700 (PDT)
Date: Thu, 19 Jun 2014 22:28:14 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
Message-ID: <alpine.DEB.2.10.1406192226470.5170@nanos>
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos> <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Christoph Lameter wrote:
> On Thu, 19 Jun 2014, Thomas Gleixner wrote:
> 
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
> So we need to init the object in the page struct before the __call_rcu?
 
Looks like RCU is lazily relying on the state callback to initialize
the objects.

There is an unused debug_init_rcu_head() inline in kernel/rcu/update.c

Paul????


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
