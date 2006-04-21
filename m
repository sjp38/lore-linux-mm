Date: Fri, 21 Apr 2006 15:49:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] split zonelist and use nodemask for page allocation [1/4]
Message-Id: <20060421154916.f1c436d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060420231751.f1068112.pj@sgi.com>
References: <20060421131147.81477c93.kamezawa.hiroyu@jp.fujitsu.com>
	<20060420231751.f1068112.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Apr 2006 23:17:51 -0700
Paul Jackson <pj@sgi.com> wrote:

> Interesting ... maybe ?
> 
> Doesn't this change the semantics of the kernel page allocator?
> 
> If I read correctly:
> 
>     The existing code scans the entire systems zonelists multiple times.
>     First, it looks on all nodes in the system for easy memory, and if that
>     fails, tries again, looking for less easy (lower threshold) memory.
> 
>     Your code takes one node at a time, in the alloc_pages_nodemask() loop,
>     and calls __alloc_pages() for that node, which will exhaust that node
>     before giving up.
> 

Ah....okay, get_page_from_freelist()  scans several times in alloc_pages()....
I should consider again and rewrite the whole patch.
Thank you for pointing it out.
Maybe what I should do is not to add a function which encapsulate alloc_pages()
but to modify get_pge_from_freelist() to take nodemask.


> In particular, the low memory failure cases, such as when the system
> starts to swap on a node, or a task is forced to sleep waiting for memory,
> or the out-of-memory killer called, would seem to be quite different with
> your patch.  This could cause some serious problems, I suspect.
> 
Yes, serious.

> Some of your other advantages from this change look nice, but I suspect
> it would take a radical rewrite of __alloc_pages(), moving the multiple
> scans at increasingly aggressive free memory settings up into your
> __alloc_pages_nodemask() routine, and  moving the cpuset_zone_allowed()
> check from get_page_from_freelist() up as well.
> 
Yes, I think so too.

> This would be a major rewrite of mm/page_alloc.c, perhaps a very
> interesting one, but I don't think it would be an easy one.
> 

> Or, just perhaps, the above change in semantics is a -good- one.  I'll
> wager that my colleague Christoph will consider it such (I see he has
> already heartily endorsed your patch.)  Essentially your patch would
> seem to increase the locality of allocations -- beating one node to
> death before considering the next.  Sometimes this will be a good
> improvement.
> 
> And sometimes not.  In my ideal world, there would be a per-cpuset
> option, perhaps just a boolean, choosing between the two choices of:
>   1) look on all allowed nodes for easy memory, before reconsidering
>        each allowed node for the one of the last free pages, or
>   2) beat all zones on one node hard, before going off-node.
> 
> I believe that the existing code does (1), and your patch does (2).
> 
> In any event, the layering of yet another control loop on top of the
> nested conditional fallback loops of loops we have now is a concern.
> It is getting harder and harder for mere mortals to understand this.
> 
> Perhaps there are opportunities here for much more cleanup, though
> that would not be easy.
> 
yes, not easy.

> My apologies for wasting your time if I misread this.
> 
I think you are right.
Thank you. 

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
