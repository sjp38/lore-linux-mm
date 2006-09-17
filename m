Message-ID: <450D1A94.7020100@yahoo.com.au>
Date: Sun, 17 Sep 2006 19:51:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>	<20060914220011.2be9100a.akpm@osdl.org>	<20060914234926.9b58fd77.pj@sgi.com>	<20060915002325.bffe27d1.akpm@osdl.org>	<20060915012810.81d9b0e3.akpm@osdl.org>	<20060915203816.fd260a0b.pj@sgi.com>	<20060915214822.1c15c2cb.akpm@osdl.org>	<20060916043036.72d47c90.pj@sgi.com>	<20060916081846.e77c0f89.akpm@osdl.org> <20060917022834.9d56468a.pj@sgi.com>
In-Reply-To: <20060917022834.9d56468a.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Andrew wrote:
> 
>>Could cache a zone* and the cpu number.  If the cpu number has changed
>>since last time, do another lookup.
> 
> 
> Hmmm ... getting closer.  This doesn't work as stated, because
> consecutive requests to allocate a page could use different zonelists,
> perhaps from MPOL_BIND, while still coming from the same cpu number.
> The cached zone* would be in the wrong zonelist in that case.
> 
> How about two struct zone pointers in the task struct?
> 
> One caching the zonelist pointer passed into get_page_from_freelist(),
> and the other caching the pointer you've been suggesting all along,
> to the zone where we found free memory last time we looked.
> 
> If that same task tries to allocate a page with a different zonelist
> then we fallback to a brute force lookup and reset the cached state.
> 
> (Note to self) The cpuset_update_task_memory_state() routine will
> have to zap these two cached zone pointers.  That's easy.
> 
> 
> Also, as you noticed earlier, we need a way to notice if a once full
> zone that we've been skipping over gets some more free memory.
> 
> One way to do that would be to add one more (a third) zone* to the
> task struct.  This third zone* would point to the next zone to retry
> for free memory.
> 
>   Once each time we call get_page_from_freelist(), we'd retry one
>   zone, to see if it had gained some free memory.
> 
>     If it still had no free memory, increment the retry pointer,
>     wrapping when it got up to the zone* we were currently getting
>     memory from.
> 
>     If we discovered some new free memory on the retried node, then
>     start using that zone* instead of the one we were using.
> 
> 
> Now we're up to three zone* pointers in the task struct:
>   base  -- the base zonelist pointer passed to get_page_from_freelist()
>   cur   -- the current zone we're getting memory from
>   retry -- the next zone to recheck for free memory
> 
> If we make the cur and retry pointers be 32 bit indices, instead of
> pointers, this saves 64 bits in the task struct on 64 bit arch's.
> 
> Calls to get_page_from_freelist() with GFP_HARDWALL -not- set, and
> those with ALLOC_CPUSET -not- set, must bypass this cached state.
> 
> The micro-optimizations I had in mind to the cpuset_zone_allowed()
> call from get_page_from_freelist() are probably still worth doing,
> as that code path, from a linear search of the zonelist, is still
> necessary in various situations.
> 
> How does this sound?
> 

Too complex? ;) Why not just start with caching the first allowed
zone and see how far that gets you?

With respect to a new design, there have been various noises about
using nodemask bits to specify the node to allocate from, I wonder
what happened with that? Your cpuset code would end up being
something like a bitwise and over a fairly small bit of memory
(even for hundreds of nodes/containers).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
