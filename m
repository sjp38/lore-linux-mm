Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id WAA11237
	for <linux-mm@kvack.org>; Sun, 8 Jul 2001 22:44:52 -0400
Date: Thu, 5 Jul 2001 17:45:51 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107042247230.21720-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0107051737340.1577-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0107082243310.30164@toomuch.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus,

Ben's mail on multipage PAGE_CACHE_SIZE support prompts me to let you
know now what I've been doing, and ask your opinion on this direction.

Congratulations to Ben for working out multipage PAGE_CACHE_SIZE.
I couldn't see where it was headed, and PAGE_CACHE_SIZE has been
PAGE_SIZE for so long that I assumed everyone had given up on it.

I'm interested in larger pages, but wary of multipage PAGE_CACHE_SIZE:
partly because it relies on non-0-order page allocations, partly because
it seems a shame then to break I/O into smaller units below the cache.

So instead I'm using a larger PAGE_SIZE throughout the kernel: here's an
extract from include/asm-i386/page.h (currently edited not configured):

/*
 * One subpage is represented by one Page Table Entry at the MMU level,
 * and corresponds to one page at the user process level: its size is
 * the same as param.h EXEC_PAGESIZE (for getpagesize(2) and mmap(2)).
 */
#define SUBPAGE_SHIFT	12
#define SUBPAGE_SIZE	(1UL << SUBPAGE_SHIFT)
#define SUBPAGE_MASK	(~(SUBPAGE_SIZE-1))

/*
 * 2**N adjacent subpages may be clustered to make up one kernel page.
 * Reasonable and tested values for PAGE_SUBSHIFT are 0 (4k page),
 * 1 (8k page), 2 (16k page), 3 (32k page).  Higher values will not
 * work without further changes e.g. to unsigned short b_size.
 */
#define PAGE_SUBSHIFT	0
#define PAGE_SUBCOUNT	(1UL << PAGE_SUBSHIFT)

/*
 * One kernel page is represented by one struct page (see mm.h),
 * and is the kernel's principal unit of memory allocation.
 */
#define PAGE_SHIFT	(PAGE_SUBSHIFT + SUBPAGE_SHIFT)
#define PAGE_SIZE	(1UL << PAGE_SHIFT)
#define PAGE_MASK	(~(PAGE_SIZE-1))

The kernel patch which applies these definitions is, of course, much
larger than Ben's multipage PAGE_CACHE_SIZE patch.   Currently against
2.4.4 (I'm rebasing to 2.4.6 in the next week) plus some other patches
we're using inhouse, it's about 350KB touching 160 files.  Not quite
complete yet (trivial macros still to be added to non-i386 arches; md
readahead size not yet resolved; num_physpages in tuning to be checked;
vmscan algorithms probably misscaled) and certainly undertested, but
both 2GB SMP machine and 256MB laptop run stably with 32k pages (though
4k pages are better on the laptop, to keep kernel source tree in cache).

Most of the patch is simple and straightforward, replacing PAGE_SIZE
by SUBPAGE_SIZE where appropriate (in drivers that's usually only when
handling vm_pgoff).  Though I'm happy with the "SUB" naming, others may
not be, and a more vivid naming might make driver maintenance easier.

Some of the patch is rather tangential: seemed right to implement proper
flush_tlb_range() and flush_tlb_range_k() for flushing subpages togther;
hard to resist tidyups like changing zap_page_range() arg from size to
end when it's always sandwiched between start,end functions.  Unless
PAGE_CACHE_SIZE definition were to be removed too, no change at all
to most filesystems (cramfs, ncpfs, proc being exceptions).

Kernel physical and virtual address space mostly in PAGE_SIZE units:
__get_free_page(), vmalloc(), ioremap(), kmap_atomic(), kmap() pages;
but early alloc_bootmem_pages() and fixmap.h slots in SUBPAGE_SIZE.

User address space has to be in SUBPAGE_SIZE units (unless I want to
rebuild all my userspace): so the difficult part of the patch is the
mm/memory.c fault handlers, and preventing the anonymous SUBPAGE_SIZE
pieces from degenerating into needing a PAGE_SIZE physical page each,
and how to translate exclusive_swap_page().

These page fault handlers now prepare and operate upon a
pte_t *folio[PAGE_SUBCOUNT], different parts of the same large page
expected at respective virtual offsets (yes, mremap() can spoil that,
but it's exceptional).  Anon mappings may have non-0 vm_pgoff, to share
page with adjacent private mappings e.g. bss share large page with data,
so KIO across data-bss boundary works (KIO page granularity troublesome,
but would have been a shame to revert to the easier SUBPAGE_SIZE there).
Hard to get the macros right, to melt away to efficient code in the
PAGE_SUBSHIFT 0 case: I've done the best I can for now,
you'll probably find them clunky and suggest better.

Performance?  Not yet determined, we're just getting around to that.
Unless it performs significantly better than multipage PAGE_CACHE_SIZE,
it should be forgotten: no point in extensive change for no gain.

I've said enough for now: either you're already disgusted, and will
reply "Never!", or you'll sometime want to cast an eye over the patch
itself (or nominate someone else to do so), to get the measure of it.
If the latter, please give me a few days to put it together against
2.4.6, minus our other inhouse pieces, then I can put the result on
an ftp site for you.

I would have preferred to wait a little longer before unveiling this,
but it's appropriate to consider it with multipage PAGE_CACHE_SIZE.

Thanks for your time!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
