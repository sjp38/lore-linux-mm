Date: Fri, 15 Sep 2006 01:28:10 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060915012810.81d9b0e3.akpm@osdl.org>
In-Reply-To: <20060915002325.bffe27d1.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, clameter@sgi.com, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006 00:23:25 -0700
Andrew Morton <akpm@osdl.org> wrote:

> 
> There are two problems:
> 
> a) the linear search across nodes which are not in the cpuset
> 
> b) the linear search across nodes which _are_ in the cpuset, but which
>    are used up.
> 
> I'm thinking a) is easily solved by adding an array of the zones inside the
> `struct cpuset', and change get_page_from_freelist() to only look at those
> zones.
> 
> And b) can, I think, be solved by caching the most-recently-allocated-from
> zone* inside the cpuset as well.  This might alter page allocation
> behaviour a bit.  And we'd need to do an exhaustive search at some point in
> there.

err, if we cache the most-recently-allocated-from zone in the cpuset then
we don't need the array-of-zones, do we?  We'll only need to do a zone
waddle when switching from one zone to the next, which is super-rare.

That's much simpler.

> The nasty part is locking that array of zones, and its length, and the
> cached zone*.  I guess it'd need to be RCUed.

And locking becomes simpler too.  It's just a check of
cpuset_zone_allowed(current->cpuset->current_allocation_zone), in
get_page_from_freelist(), isn't it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
