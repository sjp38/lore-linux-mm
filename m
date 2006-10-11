Date: Tue, 10 Oct 2006 20:42:36 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061010204236.64bcd0b4.pj@sgi.com>
In-Reply-To: <20061004192714.20412e08.pj@sgi.com>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
	<20061001234858.fe91109e.pj@sgi.com>
	<Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
	<20061002014121.28b759da.pj@sgi.com>
	<20061003111517.a5cc30ea.pj@sgi.com>
	<Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
	<20061004084552.a07025d7.pj@sgi.com>
	<Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
	<20061004192714.20412e08.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@cs.washington.edu, linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

A week ago, I wrote, of my zonelist caching patch:
>
> Downside - it's still a linear zonelist scan

Actually, not quite so, in the terms that matter on real NUMA hardware.

On real NUMA hardware, there are two memory costs of interest:

 1) the usual cost to hit main (node local) memory, also known as a
    cache line miss, and

 2) the higher cost to hit some other nodes memory, for something the
    other node just updated, so you really have to go across the NUMA
    fabric to get it.

My zonelist caching shrinks (1) to just a few cache lines, but more
importantly (for real NUMA hardware) reduces (2) to essentially a
constant, that no longer grows linearly with the number of nodes.

When one node is looking for free memory on a list of other nodes, the
page allocator no longer relies on -any- live information from the
nodes it skips over.  It is usually able to get a page from the very
first node that it tries.  It is able to skip over likely full nodes
using only locally stored and available information from the node local
zonelist cache.

So in the unit of measure that matters most to NUMA systems, (2) above,
this zonelist caching -is- very close to constant time, for workloads
presenting sufficiently high page allocation request rates.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
