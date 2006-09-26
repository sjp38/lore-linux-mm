Date: Tue, 26 Sep 2006 00:06:12 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20060926000612.9db145a9.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Thanks for reviewing this, David.

David wrote:
> If there's mangling on 'last_full_zap' in the scenario with multiple CPU's 
> on one node, that means that we might be clearing 'fullnodes' more often 
> than every 1*HZ, and that clear is always done by one CPU.  Since the only 
> purpose of the delay is to allow a certain period of time go by where 
> these hints will actually serve a purpose, this entire speed-up will 
> then be degraded.  I agree that adding locking for 'zonelist_faster' is 
> probably going too far in terms of performance hint data, but it seems 
> necessary with 'last_full_zap' if the goal is to preserve this 1*HZ 
> delay.

I doubt it.  An occassional extra clearing of fullnodes seems quite
harmless to me.  I doubt it matters whether we zap fullnodes once per
second, or once per two seconds, or twice a second.  We're just dealing
with a single 64 bit word (a jiffies value), and it's a word that just
the few CPUs local to a single node are contending over.  On real 64 bit
systems, it may not even be possible to mangle it

The goal is not to preserve a 1*HZ delay.  I just pulled that delay out
of some unspeakable place.

Roughly I wanted to throttle the rate of wasteful scans of already full
zones to some rate that was infrequent enough to solve our performance
problem, while still fast enough that no one would ever seriously
notice the subtle transient changes in memory placement behaviour.

> It seems like an immutable time interval embedded in the page alloc code 
> may not be the best way to measure when a full zap should occur.

Eh ... why not?  Sure, it's dirt simple.  But in this case, fancier
control of this interval seems like it risks spending more effort than
it would save, with almost no discernable advantage to the user.

If we already had the exact metric handy that we needed, so no more
code needed to be added to a hot path to maintain the metric (including
likely real locks, since most metrics don't like to be mangled by
code that takes a cavelier attitude to locking), then I might reconsider.

But I doubt that this use would justify adding a metric.

> This is a creative solution, 

thanks ..

> This definitely seems to be headed in the right direction because it works 
> in both the real NUMA case and the fake NUMA case.

I hope so.

> I would really like to 
> run benchmarks on this implementation as I have done for the others but I 
> no longer have access to a 64-bit machine. 

Odd ...  Do you expect that situation to be remedied anytime soon?

I'd like to see the results of your rerunning your benchmark.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
