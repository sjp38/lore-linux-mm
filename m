Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0B34A6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 18:18:07 -0400 (EDT)
Date: Tue, 13 Aug 2013 15:18:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
Message-Id: <20130813151805.b1177b60cba5b127b2aa6aee@linux-foundation.org>
In-Reply-To: <20130813220700.GC28996@mtj.dyndns.org>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
	<201308072335.r77NZZwl022494@farm-0012.internal.tilera.com>
	<20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
	<52099187.80301@tilera.com>
	<20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org>
	<20130813201958.GA28996@mtj.dyndns.org>
	<20130813133135.3b580af557d1457e4ee8331a@linux-foundation.org>
	<20130813210719.GB28996@mtj.dyndns.org>
	<20130813141621.3f1c3415901d4236942ee736@linux-foundation.org>
	<20130813220700.GC28996@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Tue, 13 Aug 2013 18:07:00 -0400 Tejun Heo <tj@kernel.org> wrote:

> Hello,
> 
> On Tue, Aug 13, 2013 at 02:16:21PM -0700, Andrew Morton wrote:
> > I've yet to see any evidence that callback APIs have been abused and
> > I've yet to see any reasoning which makes me believe that this one will
> > be abused.
> 
> Well, off the top of my head.
> 
> * In general, it's clunkier.  Callbacks become artificial boundaries
>   across which context has to be carried over explicitly.  It often
>   involves packing data into a temporary struct.  The artificial
>   barrier also generally makes the logic more difficult to follow.
>   This is pretty general problem with callback based interface and why
>   many programming languages / conventions prefer iterator style
>   interface over callback based ones.  It makes the code a lot easier
>   to organize around the looping construct.  Here, it isn't as
>   pronounced because the thing naturally requires a callback anyway.
> 
> * From the API itself, it often isn't clear what restrictions the
>   context the callback is called under would have.  It sure is partly
>   documentation problem but is pretty easy to get wrong inadvertantly
>   as the code evolves and can be difficult to spot as the context
>   isn't apparent.
> 
> Moving away from callbacks started with higher level languages but the
> kernel sure is on the boat too where possible.  This one is muddier as
> the interface is async in nature but still it's at least partially
> applicable.

I don't buy it.  The callback simply determines whether "we need to
schuedule work on this cpu".  It's utterly simple.  Nobody will have
trouble understanding or using such a thing.

> > >  It feels a bit silly to me to push the API
> > > that way when doing so doesn't even solve the allocation problem.
> > 
> > It removes the need to perform a cpumask allocation in
> > lru_add_drain_all().
> 
> But that doesn't really solve anything, does it?

It removes one memory allocation and initialisation per call.  It
removes an entire for_each_online_cpu() loop.

> > >  It doesn't really buy us much while making the interface more complex.
> > 
> > It's a superior interface.
> 
> It is more flexible but at the same time clunkier.

The callback predicate is a quite natural thing in this case.

>  I wouldn't call it
> superior and the flexibility doesn't buy us much here.

It buys quite a lot and demonstrates why a callback interface is better.


I really don't understand what's going on here.  You're advocating for
a weaker kernel interface and for inferior kernel runtime behaviour. 
Forcing callers to communicate their needs via a large,
dynamically-allocated temporary rather than directly.  And what do we
get in return for all this?  Some stuff about callbacks which frankly
has me scratching my head.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
