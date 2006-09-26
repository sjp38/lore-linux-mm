Date: Mon, 25 Sep 2006 23:08:17 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20060925091452.14277.9236.sendpatchset@v0>
Message-ID: <Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Paul Jackson wrote:

>  - Some per-node data in the struct zonelist is now modified frequently,
>    with no locking.  Multiple CPU cores on a node could hit and mangle
>    this data.  The theory is that this is just performance hint data,
>    and the memory allocator will work just fine despite any such mangling.
>    The fields at risk are the struct 'zonelist_faster' fields 'fullnodes'
>    (a nodemask_t) and 'last_full_zap' (unsigned long jiffies).  It should
>    all be self correcting after at most a one second delay.
>  

If there's mangling on 'last_full_zap' in the scenario with multiple CPU's 
on one node, that means that we might be clearing 'fullnodes' more often 
than every 1*HZ, and that clear is always done by one CPU.  Since the only 
purpose of the delay is to allow a certain period of time go by where 
these hints will actually serve a purpose, this entire speed-up will 
then be degraded.  I agree that adding locking for 'zonelist_faster' is 
probably going too far in terms of performance hint data, but it seems 
necessary with 'last_full_zap' if the goal is to preserve this 1*HZ 
delay.

>  - I pay no attention to the various watermarks and such in this performance
>    hint.  A node could be marked full for one watermark, and then skipped
>    over when searching for a page using a different watermark.  I think
>    that's actually quite ok, as it will tend to slightly increase the
>    spreading of memory over other nodes, away from a memory stressed node.
> 

Since we currently lack support for dynamically allocating nodes with a 
node hotplug API, it actually seems advantageous to have a memory stressed 
node in a pool or cpuset of 'mems'.  Now when another cpuset is facing 
memory pressure I can cherry-pick an untouched node from a less bogged 
down cpuset for my own use.

It seems like an immutable time interval embedded in the page alloc code 
may not be the best way to measure when a full zap should occur.  A more 
appropriate metric might be to do a full zap after a certain threshold of 
pages have been freed.  If it's done that way, the zap would occur in a 
more appropriate place (when pages are freed) as opposed to when pages are 
allocated.  The overhead that we incur of zapping the nodemask every 
second and then being forced to recheck all the nodes again would then be 
eliminated in the case where there's been no change.  Based on the 
benchmarks I ran earlier, that's a popular case.  It's more appropriate 
when we're freeing pages and we know for sure that we're getting memory 
somewhere.

Note to self: in 2.6.18-rc7-mm1, NUMA_BUILD is just a synonym for 
CONFIG_NUMA.  And since this and CONFIG_NUMA_EMU is defined by default on 
x64_64, we're going to have overhead on a single processor system.  In my 
earlier patch I started extracting a macro that could be tested against 
in generic kernel code to determine at least whether NUMA emulation was 
being _used_.  This might need to make a comeback if this type of 
implementation is considered later.

This is a creative solution, especially considering the use of a 
statically-sized zlfast_ptr to find zlfast hidden away in struct zonelist.  
This definitely seems to be headed in the right direction because it works 
in both the real NUMA case and the fake NUMA case.  I would really like to 
run benchmarks on this implementation as I have done for the others but I 
no longer have access to a 64-bit machine.  I don't see how it could cause 
a performance degredation in the non-NUMA case.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
