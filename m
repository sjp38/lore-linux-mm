Date: Mon, 19 Apr 2004 21:54:47 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: numa api comments
Message-ID: <20040419195447.GA5900@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.d
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(based on the code in 2.6.6-rc1-mm1)

 - the

	if (unlikely(order >= MAX_ORDER))
	       return NULL;

   in alloc_pages_node and your new alloc_pages should probably move
   into __alloc_pages, thus making alloc_pages_current as an entinity
   of it's own superflous.  It's naming is rather strange anyway.

 - you add an extern for __alloc_page_vma but it doesn't seem to be
   implemented at all

 - alloc_page_vma arguments seems backwards.  We usually have gfp_flags
   arguments last which is kinda natural.  Can we change the prototype to

	alloc_page_vma(struct vm_area_struct *vma, unsigned long addr,
			unsigned gfp_mask);

   ?  Dito for sched.h, that one is used even more..

 - could you please move the struct vm_area_struct forward delcaration
   somewhere near the top of gfp.h (I usually prefer just below the
   includes) ?  In the middle of the prototypes it looks rather distracting.

 - does mm.h as a widely-used header really need to include mempolicy.h?
   AFAICS a forward-declaration of struct mempolicy would do it.

 - can we please have a for_each_node() instead of mess like

	for (nd = find_first_bit(nodes, MAX_NUMNODES);
             nd < MAX_NUMNODES;
             nd = find_next_bit(nodes, MAX_NUMNODES, 1+nd)) {

   ?

 - swapin_readahead() seems to be used only in mm/memory.c, what about
   making it static?

 - alloc_page_interleave should probably reuse te existing
   alloc_pages_node, ala:

static struct page *alloc_page_interleave(unsigned gfp, unsigned nid)
{
	struct page *page = alloc_pages_node(nid, gfp_mask, 0);

	if (page && page_zone(page) == zl->zones[0]) {
		zl->zones[0]->pageset[get_cpu()].interleave_hit++;
		put_cpu();
	}

	return page;
}

 - the addition of mpol_set_vma_default() to gazillions of vma
   initializations looking almost the same says we really want some
   helper for it finally..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
