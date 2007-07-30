Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070729053516.5d85738a.pj@sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070729053516.5d85738a.pj@sgi.com>
Content-Type: text/plain
Date: Mon, 30 Jul 2007 12:07:08 -0400
Message-Id: <1185811629.5492.73.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, nacc@us.ibm.com, kxr@sgi.com, clameter@sgi.com, mel@skynet.ie, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sun, 2007-07-29 at 05:35 -0700, Paul Jackson wrote:
> Lee,
> 
> What is the motivation for memoryless nodes?  I'm not sure what I
> mean by that question -- perhaps the answer involves describing a
> piece of hardware, perhaps a somewhat hypothetical piece of hardware
> if the real hardware is proprietary.  But usually adding new mechanisms
> to the kernel should involve explaining why it is needed.

Hi, Paul.

My motivation for working on the memoryless nodes patches is to properly
support all configurations of our hardware.  We can configure our
platforms with from 0% to 100% "cell local memory" [CLM].  We also call
0% CLM "fully interleaved", as it the hardware interleaves the memory on
a cache line granularity.  Our AMD-based x86_64 platforms have a similar
feature, altho' it's "all or nothing" on these platforms.  I believe the
Fujitsu ia64 platform supports a similar feature.

One could reasonably ask why we have this feature.  My understanding is
that certain OSes supported on this hardware were not very "NUMA-aware"
when the hardware was released--Linux, included.  Hardware interleaving
smoothed out the "hot spots" and made it possible to run reasonably well
on the platform.  This did leave some performance "on the table", as
Linux has demonstrated in recent releases.  Linux now performs better
for some workloads, like AIM7, in 100% CLM mode.  This was not the case
a year or two ago.

A couple of other details for completeness:  Like SGI platforms, on our
platforms, cell local memory shows up at some ridiculously high physical
address, altho' maybe not so ridiculous as the Altix ;-).  Interleaved
memory shows up at physical address 0.  I understand that the
architecture requires some memory at phys addr 0.  For this reason, even
when we configure 100% CLM, we still get a "small" amount of interleaved
memory--512M on my 4-node test system

I should also mention that when the HP-UX group runs the TPC-C benchmark
for reporting, they find that a mixture of cell local and interleaved
memory provides the best performance.  I don't know the details of how
they lay out the benchmark on this config, but I need to find out for
Linux testing...

Anyway, in 0% CLM/fully-interleaved mode, our platform looks like this:

available: 5 nodes (0-4)
node 0 size: 0 MB
node 0 free: 0 MB
node 1 size: 0 MB
node 1 free: 0 MB
node 2 size: 0 MB
node 2 free: 0 MB
node 3 size: 0 MB
node 3 free: 0 MB
node 4 size: 8191 MB <= interleaved at phys addr 0
node 4 free: 105 MB  <= was running a test...

If I configure for 100% CLM and boot with mem=16G [on a 32G platform], I
get:

available: 5 nodes (0-4)
node 0 size: 7600 MB
node 0 free: 6647 MB
node 1 size: 8127 MB
node 1 free: 7675 MB
node 2 size: 144 MB
node 2 free: 94 MB
node 3 size: 0 MB
node 3 free: 0 MB
node 4 size: 511 MB <= interleaved @ phys addr 0
node 4 free: 494 MB

both configs include memoryless nodes.

> In this case, it might further involve explaining why we need memoryless
> nodes, as opposed to say a hack for the above (hypothetical?) hardware
> in question that pretends that any CPUs on such memoryNo, wless nodes are on
> the nearest memory equipped node -- and then entirely drops the idea of
> memoryless nodes.  Most likely you have good reason not to go this way.
> Good chance even you've already explained this, and I missed it.

No, I haven't explained it.  Christoph posted the original memoryless
nodes patch set in response to prompting from Andrew.  He considered
failure to support memoryless nodes a bug.  The system "sort of" worked
because for most allocations, the zonelists allow the memoryless nodes
immediately "fall back" to a node with memory.  There were a few corner
cases that Christoph's series address.

I believe that the x86_64 kernel works as you suggest in fully
interleaved mode.  All memory shows up on node zero in the SRAT, and all
cpus are attached to this node.

For my part, given that our platforms can be configured in a couple of
ways, I would prefer that cpus not change their node association based
on the configuration.  But, that's just me...  I know one shouldn't make
any assumptions about cpu-to-node association.  Rather, we have the
libnuma APIs to query this information.  Still... why go there?

And then there's the fact that on some platforms, ours included, all
nodes with memory are not equal.  See my recent patch to allow selected
nodes to be excluded from interleave policy.  I don't want to exclude
these nodes from cpusets to achieve this, because there are cases [like
the TPC-C benchmark mentioned above] where we want the application to be
able to use the funky, interleaved memory, but only when requested
explicitly.  IMO, Christoph's generic nodemask mechanism makes it easy
to handle nodes with special characteristics--no memory, excluded from
interleave, ...--in a generic way.

> 
> ===
> 
> I have user level code that scans the 'cpu%d' entries below the
> /sys/devices/system/node%d directories, and then inverts the resulting
> <node, cpu> map, in order to provide, for any given cpu the nearest
> node.  This code is a simple form of node and cpu topology for user
> code that wants to setup cpusets with cpus and nodes 'near' each other.

Sounds useful for an administrator partitioning the machine.  I can see
why you might need it with the size of your systems ;-).  And, for our
platform in fully interleaved mode--even tho' there is only one node
with memory to choose from.  Is this part of the SGI ProPack?

> 
> Could you post the results, from such a (possibly hypothetical) machine,
> of the following two commands:
> 
>   find /sys/devices/system/node* -name cpu[0-9]\*
>   ls /sys/devices/system/cpu
> 
> And if the 'ls' shows cpus that the 'find' doesn't show, then can you
> recommend how user code should be written that would return, for any
> specified cpu (even one on a memoryless node) the number of the
> 'nearest' node that does have memory (for some plausible definition,
> your choice pretty much, of 'nearest')?

I verified that I see all cpus [16 on the 4-node, 16 cpu ia64 platform
I'm testing on], either way:  find or ls [w/ and w/o cell local
memory].  

> 
> Granted, this is not a pressing issue ... not much chance that my user
> code will be running on your (hypothetical?) hardware anytime soon,
> unless there is some deal in the works I don't know about for hp to
> buy sgi ;).
> 
> In short, how should user code find 'nearby' memory nodes for cpus that
> are on memoryless nodes?

Again, on the fully interleaved config, there is only one node with
memory, so it's not hard.  And in the 100% CLM, with mem=<less that 100%
of existing memory> [2nd config above], the SLIT says that the
interleaved pseudo-node is closer to any real node than any other real
node--based on the average latency.  The interleaved node is always the
highest numbered node.  Mileage may vary on other platforms...

Lee






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
