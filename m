Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 010E86B005C
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 02:48:53 -0400 (EDT)
Date: Tue, 13 Aug 2013 23:46:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
Message-Id: <20130813234629.4ce2ec70.akpm@linux-foundation.org>
In-Reply-To: <520AC215.4050803@tilera.com>
References: <520AAF9C.1050702@tilera.com>
	<201308132307.r7DN74M5029053@farm-0021.internal.tilera.com>
	<20130813232904.GJ28996@mtj.dyndns.org>
	<520AC215.4050803@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Tue, 13 Aug 2013 19:32:37 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:

> On 8/13/2013 7:29 PM, Tejun Heo wrote:
> > Hello,
> >
> > On Tue, Aug 13, 2013 at 06:53:32PM -0400, Chris Metcalf wrote:
> >>  int lru_add_drain_all(void)
> >>  {
> >> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
> >> +	return schedule_on_each_cpu_cond(lru_add_drain_per_cpu,
> >> +					 lru_add_drain_cond, NULL);

This version looks nice to me.  It's missing the conversion of
schedule_on_each_cpu(), but I suppose that will be pretty simple.

> > It won't nest and doing it simultaneously won't buy anything, right?
> 
> Correct on both counts, I think.

I'm glad you understood the question :(

What does "nest" mean?  lru_add_drain_all() calls itself recursively,
presumably via some ghastly alloc_percpu()->alloc_pages(GFP_KERNEL)
route?  If that ever happens then we'd certainly want to know about it.
Hopefully PF_MEMALLOC would prevent infinite recursion.

If "nest" means something else then please enlighten me!

As for "doing it simultaneously", I assume we're referring to
concurrent execution from separate threads.  If so, why would that "buy
us anything"?  Confused.  As long as each thread sees "all pages which
were in pagevecs at the time I called lru_add_drain_all() get spilled
onto the LRU" then we're good.  afaict the implementation will do this.

> > Wouldn't it be better to protect it with a mutex and define all
> > necessary resources statically (yeah, cpumask is pain in the ass and I
> > think we should un-deprecate cpumask_t for static use cases)?  Then,
> > there'd be no allocation to worry about on the path.
> 
> If allocation is a real problem on this path, I think this is probably

Well as you pointed out, alloc_percpu() can already do a GFP_KERNEL
allocation, so adding another GFP_KERNEL allocation won't cause great
problems.  But the patchset demonstrates that the additional allocation
isn't needed.

> OK, though I don't want to speak for Andrew.  You could just guard it
> with a trylock and any caller that tried to start it while it was
> locked could just return happy that it was going on.
> 
> I'll put out a version that does that and see how that looks
> for comparison's sake.

That one's no good.  If thread A is holding the mutex, thread B will
bale out and we broke lru_add_drain_all()'s contract, "all pages which
...", above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
