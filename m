From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Proof of concept: sorting per-cpu-page lists to reduce memory fragmentation
Date: Tue, 13 May 2008 22:22:20 +1000
References: <480BD01D.4000201@linux.intel.com>
In-Reply-To: <480BD01D.4000201@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200805132222.20538.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Monday 21 April 2008 09:22, Arjan van de Ven wrote:
> Hi,
>
> Right now, the per-cpu page lists are interfering somewhat with the buddy
> allocator in terms of keeping the free memory pool unfragmented. This
> proof-of-concept patch (just to show the idea) tries to improve that
> situation by sorting the per-cpu page lists by physical address, with the
> idea that when the pcp list gives a chunk of itself back to the global
> pool, the chunk it gives back isn't random but actually very localized, if
> not already containing contiguous parts.. as opposed to pure random
> ordering.
>
> Now, there's some issues I need to resolve before I can really propose this
> for merging: 1) Measuring success. Measuring fragmentation is a *hard*
> problem. Measurements I've done so far tend to show a little improvement,
> but that's very subjective since it's basically impossible to get
> reproducable results. Ideas on how to measure this are VERY welcome 2)
> Cache locality; the head of the pcp list in theory is cache hot; the
> current code doesn't take that into account. It's easy to not sort the,
> say, first 5 pages though; not done in the current implementation
>
> The patch below implements this, and has a hacky sysreq to print cpu 0's
> pcp list out (I use this to verify that the sort works).

I really hate the idea of doing stuff in the idle thread. It just
destroys your predictability and reproduceability.

I'll kick myself for saying this because I dislike the using any CPU
cycles are on anti-fragmentation heuristics ;) But one idea I had
that you might want to look into if you're looking into this area is
to instead check whether a given page is on a pcp list when checking
for buddies. If it is, then you can perhaps flush anything from all
pages out of all pcp lists, to just that single page from a given pcp
list.

For now you could probably use page_count == 0 (&&!PageBuddy) as an
heuristic. I actually have a patch that I want to merge, which allows
page allocations without messing with page_count to avoid some atomic
allocations in things like slab.... so you may eventually need a new
page flag there if the idea is a success.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
