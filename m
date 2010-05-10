Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C78236B0234
	for <linux-mm@kvack.org>; Mon, 10 May 2010 02:04:01 -0400 (EDT)
Date: Mon, 10 May 2010 15:03:16 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: numa aware lmb and sparc stuff
Message-ID: <20100510060316.GA12250@linux-sh.org>
References: <1273466126.23699.23.camel@pasglop> <20100510050158.GA24592@linux-sh.org> <1273469363.23699.26.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273469363.23699.26.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 03:29:23PM +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2010-05-10 at 14:01 +0900, Paul Mundt wrote:
> > On Mon, May 10, 2010 at 02:35:26PM +1000, Benjamin Herrenschmidt wrote:
> > > So unless i'm missing something, I should be able to completely remove
> > > lmb's reliance on that nid_range() callback and instead have lmb itself
> > > use the various early_node_map[] accessors such as
> > > for_each_active_range_index_in_nid() or similar.
> > > 
> > If you do this then you will also be coupling LMB with
> > ARCH_POPULATES_NODE_MAP, which the nid_range() callback offers an
> > alternative for (although since there aren't any architectures presently
> > using LMB that don't also set ARCH_POPULATES_NODE_MAP perhaps this is
> > ok). The nobootmem stuff also has a reliance on the early node map
> > already.
> 
> Right, my tentative implementation indeed requires
> ARCH_POPULATES_NODE_MAP for lmb_alloc_nid() to be available (I even
> documented it). Do you see that as a limitation in the long run ?
> 
I wouldn't call it a limitation so much as a subtle dependency. All of
the current platforms that are supporting NUMA are doing so along with
ARCH_POPULATES_NODE_MAP, so in those cases making the early_node_map
dependence explicit and generic will permit the killing off of
architecture-private data structures and accounting for region sizes and
node mappings.

The NUMA platforms that do not currently follow the
ARCH_POPULATES_NODE_MAP semantics seem to already be in various states of
disarray (generically broken, bitrotted, etc.). To that extent, perhaps
it's also useful to have NUMA imply ARCH_POPULATES_NODE_MAP? New
architectures that are going to opt for sparsemem or NUMA are likely
going to end up down the ARCH_POPULATES_NODE_MAP path anyways I would
imagine.

> > I've just started sorting out some of the LMB/NUMA bits on SH now as
> > well, so I'd certainly be interested in any changes on top of Yinghai's
> > work you're planning on doing.
> 
> I'm not sure I plan to change things on -top- of Yinghai work. I'm still
> maintaining a patch series that is rooted before Yinghai current one, as
> I very very much dislike pretty much everything in there. Though I plan
> to provide all the functionality he needs for his x86 port and
> NO_BOOTMEM implementation.
> 
That sounds fine, too. I'll certainly give it a go once the patches show
up.

On a somewhat related note, is your intention with powerpc that sparsemem
sections are always encapsulated within a single LMB region (assuming
that the sparsemem and LMB section sizes are different)? Do you simply
never permit node sizes smaller than the sparsemem section size (ie, in
the fake NUMA case)? I've been playing with this with both sparsemem and
ARCH_HAS_HOLES_MEMORYMODEL where those sorts of combinations will be
quite common. It would be good to have some LMB guidelines hammered out
before people get too carried away with building infrastructure on top of
it at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
