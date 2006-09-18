Date: Mon, 18 Sep 2006 09:34:34 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060918093434.e66b8887.pj@sgi.com>
In-Reply-To: <20060917192010.cc360ece.pj@sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
	<Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
	<20060917041707.28171868.pj@sgi.com>
	<Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
	<20060917060358.ac16babf.pj@sgi.com>
	<Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
	<20060917152723.5bb69b82.pj@sgi.com>
	<Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
	<20060917192010.cc360ece.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@google.com, clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pj wrote:
>     Do you have any plans to build a hybrid system with both real and
>     emulated NUMA present?  That could complicate things.

This might be the crux of the matter.

We currently have a large SMP (aka multi-core) wave washing over the
upper end of the large volume markets, as we deal with the fact
that a single core's compute power (and electric power ;) can't
continue to grow as fast we need.

Inevitably, in a few years, a NUMA wave will follow, as we deal with
an overloaded shared memory bus, and begin to distribute the memory
bandwidth across multiple buses.

We should architect consistently with this anticipated evolution.

Eventually, a memory container mechanism that doesn't work on real
NUMA boxes would be useless.

I'm inclined to think that this means node_distance between two fake
nodes on the same real node should be 10, the value always used to
indicate that two node numbers refer to one and the same physical
hardware.

For now, it could be that we can't handle hybrid systems, and that fake
numa systems simply have a distance table of all 10's, driven by the
kernel boot command "numa=fake=N".  But that apparatus will have to be
extended at some point, to support hybrid fake and real NUMA combined.
And this will have to mature from being an arch=x86_64 only thing to
being generically available.  And it will have to become a mechanism
that can be applied on a running system, creating (and removing) fake
nodes on the fly, without a reboot, so long as the required physical
memory is free and available.

A comment above arch/x86_64/mm/srat.c slit_valid() raises concerns
about a SLIT table with all 10's.  I suspect we will just have to find
out the hard way what that problem is.  Change the table to all 10's
on these fake numa systems and see what hurts.

The generic kernel code should deal with this, and in particular, the
get_page_from_freelist() loop that provoked this discussion should be
coded so that it caches the last used node iff that node is distance
10 from the node at the front of the zonelist.

The only way to make this kind of stuff hold up over the long term
is to get a good conceptual model, and stick with it.  This fake
numa provides for multiple logical nodes on a single physical node.

The modal approach I recommended yesterday, where a system either
supported fake NUMA or real NUMA, but not both, had the stench of
an intermediate solution that would not hold over the long run.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
