Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 078BB6B003B
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:37:14 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so2448863qac.11
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:37:14 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id r64si7914262qga.37.2014.06.19.13.37.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:37:14 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 14:37:13 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6DD261FF001C
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:37:00 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5JKZveS43319434
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:35:57 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s5JKeu0K022150
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:40:56 -0600
Date: Thu, 19 Jun 2014 13:36:59 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: slub/debugobjects: lockup when freeing memory
Message-ID: <20140619203659.GH4904@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <53A2F406.4010109@oracle.com>
 <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
 <20140619165247.GA4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192127100.5170@nanos>
 <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 19, 2014 at 03:19:39PM -0500, Christoph Lameter wrote:
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

Good point.  The patch I just sent will complain at callback-invocation
time because the debug-object information won't be present.

One way to handle this would be for rcu_do_batch() to avoid complaining
if it gets a callback that has not been through call_rcu()'s
debug_rcu_head_queue().  One way to do that would be to have an
alternative to debug_object_deactivate() that does not complain
if it is handed an unactivated object.

Another way to handle this would be for me to put the definition of
debug_rcu_head_queue() somewhere where the sl*b allocator could get
at it, and have the sl*b allocators invoke it some at initialization
and within the RCU callback.

Other thoughts?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
