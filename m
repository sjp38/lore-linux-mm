Date: Tue, 26 Sep 2006 14:48:12 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20060926144812.3ebbd7e6.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0609261242170.22108@attu2.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
	<20060926000612.9db145a9.pj@sgi.com>
	<Pine.LNX.4.64N.0609261049260.11233@attu4.cs.washington.edu>
	<20060926122445.717c7c11.pj@sgi.com>
	<Pine.LNX.4.64N.0609261242170.22108@attu2.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> Why is it arbitrary, though?

I was just trying to throttle the rate of futile zonelist scans.

In my implementation, the choice of 1*HZ for the zap time is obviously
an arbitrarily chosen time, within some acceptable range - right?

If you are asking why I didn't pick the non-arbitrary variant
implementation you suggested, wherein we clear individual node bits in
the nodemask of full nodes, anytime we free memory on that node, then I
did not do this because it was more code, and because it required a
lock to safely clear the bit, and because I had no particular reason to
think it would provide measurable improvement anyway.

I am quite happy coding stupid, simple, short and racey code, if it
looks to me like it will perform just as well, and be just as robust,
if not more so, than the more exact, longer, lock protected code.

> If that's the case, then the entire speed-up is broken. 

Are we looking at the same patch ;)?  My patch enables us to only have
to look closely at each full node once per second, instead of once per
page allocation.  That's the speedup.  That and the more rapid
application of the cpuset constraint in most cases.  The unallowed and
recently full nodes are skipped over on the first scan at the per-zone
cost of loading just a single unsigned short, from a compact array, plus
modest constant overhead per __alloc_pages call.

(My unit of cost here is 'cache line misses'.)

> And since the node bit is only turned 
> on when it has been passed by and deemed too full to allocate on, I don't 
> see where the race exists.

If two cpus on the same node each go to clear a (different) bit in the
nodemask at the same time, you could have each cpu load the mask, each
cpu compute a new mask, with its bit cleared, and each cpu store the
mask, all in that order.  Notice that the second cpu to store just
clobbered the bit clear done by the first cpu.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
