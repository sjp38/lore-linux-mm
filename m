Date: Tue, 22 Apr 2003 07:38:37 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <171790000.1051022316@[10.10.2.4]>
In-Reply-To: <20030422132013.GF8931@holomorphy.com>
References: <20030405143138.27003289.akpm@digeo.com>
 <Pine.LNX.4.44.0304220618190.24063-100000@devserv.devel.redhat.com>
 <20030422123719.GH23320@dualathlon.random>
 <20030422132013.GF8931@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Well, AFAICT the question wrt. sys_remap_file_pages() is not speed, but
> space. Speeding up mmap() is of course worthy of merging given the
> usual mergeability criteria.
> 
> On this point I must make a concession: k-d trees as formulated by
> Bentley et al have space consumption issues that may well render them
> inappropriate for kernel usage. I still believe it's worth an empirical
> investigation once descriptions of on-line algorithms for their
> maintenance are recovered, as well as other 2D+ spatial algorithms, esp.
> those with better space behavior.
> 
> Specifically, k-d trees require internal nodes to partition spaces that
> are not related to leaf nodes (i.e. data points), and not all
> rebalancing policies are guaranteed to recover space.

We can still do the simple sorted list of lists thing (I have preliminary
non-functional code). But I don't see that it's really worth the overhead
in the common case to fix a corner case that has already been fixed in a
different way.

/*
 * s = address_space, r = address_range, v = vma
 *
 * s - r - r - r - r - r
 *     |   |   |   |   |
 *     v   v   v   v   v
 *     |   |           |
 *     v   v           v
 *         |
 *         v
 */

struct address_range {
       unsigned long           start;
       unsigned long           end;
       struct list_head        ranges;
       struct list_head        vmas;
};

where the list of address_ranges is sorted by start address. This is
intended to make use of the real-world case that many things (like shared
libs) map the same exact address ranges over and over again (ie something
like 3 ranges, but hundreds or thousands of mappings).

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
