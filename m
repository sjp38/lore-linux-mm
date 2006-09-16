Date: Sat, 16 Sep 2006 16:10:31 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060916161031.4b7c2470.akpm@osdl.org>
In-Reply-To: <20060916145117.9b44786d.pj@sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060916044847.99802d21.pj@sgi.com>
	<20060916083825.ba88eee8.akpm@osdl.org>
	<20060916145117.9b44786d.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2006 14:51:17 -0700
Paul Jackson <pj@sgi.com> wrote:

> Andrew wrote:
> > Pretty much all loads?  If you haven't consumed most of the "container"'s
> > memory then you have overprovisioned its size.
> 
> Not so on real NUMA boxes.

I meant pretty much all loads when employing this trick of reusing the NUMA
code for containerisation.

>  If you configure your system so that
> you are having to go a long way off-node for much of your memory,
> then your performance is screwed.
> 
> No one in their right mind would run a memory hog that eats 40 nodes
> of memory and a kernel build both in the same 60 node, small CPU
> count cpuset on a real NUMA box.
> 
> The primary motivation for cpusets is to improve memory locality on
> NUMA boxes.  You're using fake numa and cpusets to simulate destroying
> memory locality.
> 
> On a real 64 node NUMA box, there would be 64 differently sorted
> zonelists, each one centered on a different node.  The kernel build
> would be running on different CPUs, associated with different nodes
> than the memory hog, and it would be using zonelists that had the
> unloaded (still has free memory) nodes at the front the list.
> 
> Aha - maybe this is the problem - the fake numa stuff is missing the
> properly sorted zone lists.

I don't see how any of this could help.  If one has a memory container
which is constructed from 50 zones, that linear search is just going to do
a lot of linear searching when the container approaches anything like
fullness.

It could well be a single CPU machine...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
