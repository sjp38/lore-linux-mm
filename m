Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9036B00A5
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:47:52 -0400 (EDT)
Date: Sat, 30 May 2009 09:55:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: More thoughts about hwpoison and pageflags compression
Message-ID: <20090530075516.GM1065@one.firstfloor.org>
References: <200905291135.124267638@firstfloor.org> <20090529225202.0c61a4b3@lxorguk.ukuu.org.uk> <20090530063710.GI1065@one.firstfloor.org> <20090529235302.ccf58d88.akpm@linux-foundation.org> <20090530072758.GL1065@one.firstfloor.org> <20090530002930.2481164f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090530002930.2481164f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Sat, May 30, 2009 at 12:29:30AM -0700, Andrew Morton wrote:
> On Sat, 30 May 2009 09:27:58 +0200 Andi Kleen <andi@firstfloor.org> wrote:
> 
> > On Fri, May 29, 2009 at 11:53:02PM -0700, Andrew Morton wrote:
> > > On Sat, 30 May 2009 08:37:10 +0200 Andi Kleen <andi@firstfloor.org> wrote:
> > > 
> > > > So using a separate bit is a sensible choice imho.
> > > 
> > > Could you make the feature 64-bit-only and use one of bits 32-63?
> > 
> > We could, but these systems can run 32bit kernels too (although
> > it's probably not a good idea). Ok it would be probably possible
> > to make it 64bit only, but I would prefer to not do that.
> > 
> > Also even 32bit has still flags free and even if we run out there's an easy 
> > path to free more (see my earlier writeup)
> 
> hm.  Maybe that should be proven sooner rather than later.

The SPARSEMEM code already has some fallback. I don't know if it works, but 
at least the code looks to be there.

 * There are three possibilities for how page->flags get
 * laid out.  The first is for the normal case, without
 * sparsemem.  The second is for sparsemem when there is
 * plenty of space for node and section.  The last is when
 * we have run out of space and have to fall back to an
 * alternate (slower) way of determining the node.
 *
 * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE | ... | FLAGS |
 * classic sparse with space for node:| SECTION | NODE | ZONE | ... | FLAGS |
 * classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |


/*
 * If we did not store the node number in the page then we have to
 * do a lookup in the section_to_node_table in order to find which
 * node the page belongs to.
 */
#if MAX_NUMNODES <= 256
static u8 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
#else
static u16 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
#endif

The other part that could be added is to use a separate hash to go from
page to SECTION (that would be very similar to the old discontig perfect hash
I did to go from pfn to node), then the "SECTION" part would be free for reuse too.

Then you could use the full 32bits. On 32bit we're right now at 22,
hwpoison would be 23. There's still some room.

> Plus we haven't looked into the complexity of the external flags yet.

It would be dumb to do external flags before you actually run out.
After all what good are free bits?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
