Date: Sun, 15 Dec 2002 16:51:03 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: freemaps
Message-ID: <20021216005103.GF2690@holomorphy.com>
References: <3DFBF26B.47C04A6@digeo.com> <Pine.LNX.4.44.0212150926130.1831-100000@localhost.localdomain> <3DFC455E.1FD92CBC@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DFC455E.1FD92CBC@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ingo Molnar <mingo@elte.hu>, "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Dec 15, 2002 at 01:03:26AM -0800, Andrew Morton wrote:
> I expect this could be solved with two trees:
> - For searching, a radix-tree indexed by hole size.  A list
>   of same-sized holes at each leaf.
> - For insertion (where we must perform merging) an rbtree.

It's not quite that easy, because what this appears to suggest
would result in best fit, not address-ordered first fit.

My first thought is a length-constrained address minimization on a 2-d
tree, quadtree, or 2D k-d-b tree keyed on address and length; the
duelling tree solutions aren't really capable of providing O(lg(n))
guarantees for address-ordered first fit (or implementing address-
ordered first fit at all). I have no clue how to do this both
nonrecursively and without frequently-dirtied temporary node linkage,
though, as it appears to require a work stack (or potentially even a
queue for prioritized searches) like many other graph searches. Also,
I don't have a proof in hand that this is really O(lg(n)) worst-case,
though there are relatively obvious intuitive reasons to suspect so.


On Sun, Dec 15, 2002 at 01:03:26AM -0800, Andrew Morton wrote:
> But:
> - Do we need to keep the lists of same-sized holes sorted by
>   virtual address, to avoid fragmentation?

Well, not so much to avoid fragmentation, but avoid worst cases.


On Sun, Dec 15, 2002 at 01:03:26AM -0800, Andrew Morton wrote:
> - Do all mm's incur all this stuff, or do we build it all when
>   some threshold is crossed?

Not all incur these kinds of problems; but it is probably expensive
to build non-incrementally once the threshold is crossed.


On Sun, Dec 15, 2002 at 01:03:26AM -0800, Andrew Morton wrote:
> - How does it play with non-linear mappings?

It doesn't care; they're just vma's parked on a virtual address range
like the rest of them.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
