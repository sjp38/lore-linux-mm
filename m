Date: Tue, 10 Oct 2006 12:35:55 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
Message-Id: <20061010123555.21996034.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610101001480.927@schroedinger.engr.sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
	<20061009111203.5dba9cbe.akpm@osdl.org>
	<20061009150259.d5b87469.pj@sgi.com>
	<20061009215125.619655b2.pj@sgi.com>
	<Pine.LNX.4.64N.0610092331120.17087@attu3.cs.washington.edu>
	<20061010000331.bcc10007.pj@sgi.com>
	<Pine.LNX.4.64.0610101001480.927@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: rientjes@cs.washington.edu, akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Could it be worth to investigate more radical ideas? This gets way too 
> complicated for me. Maybe drop the whole zone list generation idea and 
> iterate over nodes in another way?

Worth some thought.

I'll be surprised if this eliminates the usefulness of something
like this zonelist caching patch, however.

Sooner or later, regardless of what shape data structures we have,
we end up having to examine a bunch of nodes when allocating for
workloads or numa emulated configurations that make heavy use of
off-node allocations.

And when that happens, we end up with an N-squared information
flow problem, needing to get information or at least hints as to
which nodes have free pages to the tasks trying to allocate those
pages.

But we really would rather not pay the price of even a linear
scan over N nodes, in either the tasks freeing pages, nor in the
tasks allocating them.

The best I've been able to do, in this patch, is:
 1) compact the information, to minimize the cache line footprint, and
 2) have the allocators get by on incomplete information, essentially
    doing the first scan based on remembering which nodes were
    recently noticed to be full.

I predict that regardless of the shape (zonelists, nodemasks or
whatever) of the placement information coming into the core
routine of our allocator, we will still need some sort of caching
like this, bolted onto the side, for the cases making heavy use
of off-node allocations.

So I would not use disgust at the added complexity of this zonelist
caching patch to justify changing the fundamental zonelist structures
used to drive the kernel allocator.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
