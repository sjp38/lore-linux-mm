Received: from noc.nyx.net (mail@noc.nyx.net [206.124.29.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA13416
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 07:52:57 -0500
Received: from nyx10.nyx.net (colin@nyx10.nyx.net [206.124.29.2])
	by noc.nyx.net (8.9.1a+3.1W/8.9.1/esr) with ESMTP id FAA01230
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 05:51:59 -0700 (MST)
Received: (from colin@localhost)
	by nyx10.nyx.net (8.8.8/8.8.8/esr) id FAA15706
	for linux-mm@kvack.org; Tue, 5 Jan 1999 05:51:52 -0700 (MST)
Date: Tue, 5 Jan 1999 05:51:52 -0700 (MST)
From: Colin Plumb <colin@nyx.net>
Message-Id: <199901051251.FAA15706@nyx10.nyx.net>
Subject: Why don't shared anonymous mappings work?
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I was trying to explain to Paul R. Wilson why shared anonymous mappings
don't work and started having problems provinf that it couldn't
work without significant software changes.  Could someone check me
on the following logic which purports to explain how it could be done?

Shared anonymous mappings are easy as long as the page never leaves
memory.

In any given PTE, a page is either "in" or "out".  If "out", the PTE
is marked invalid but holds a swap offset where the page can be found.

A page may be both in memory and in swap.  In this case, the page cache
(indexed on inode and offset) is used to implement a swap cache, using
a special swapper_inode and the swap offset.  Once a page is in the
swap cache, mappings in both directions are efficient.  In memory, the
struct page contains the swap offset, and given the swap offset, the
page cache hash table will efficiently find the struct page (if any).

When a page is put into the swap cache, it is marked read-only.
Since there is only one PTE referencing it, all attempts to modify the
page will be trapped, and the swap cache entry invalidated.
(The call is in do_wp_page in mm/memory.c.)

But why can't we allow writeable swap-cached pages?  Which engender
dirty swap-cached pages, of course.  If a swap-cached page is dirty,
its disk data is invalid, but the address is still kept because
it may be in some PTEs.  (At least until the swap_map reaches 0.)

It seems that the handling would be just like mapped files as long
as you maintained a swap file entry for the page.  There are differences,
such as the fact that when mapping a not-present page, the inode is
implicit in the fact that it's an anonymous vma range and the offset
is taken from the PTE, rather than being derived from the VMA
offset.

There is some hairy magic relating to closing off all of the writeable
mappings of a page before it can be written to disk and marked clean,
but I presume those are handled for file mappings.

Basically, a dirty swap-cached page would only be written when it
was removed from the *last* process's PTE.  A less-efficient way would
be to write it out each time a dirty mapping is removed.  (This seems
to be what happens to dirty pages in filemap_swapout.  Ideally,
as long as there are writeable mappings, it should just copy the
reference's dirty bit to the page and then write the page if needed
when the last writeable mapping is removed.)

The only significant difference is that in do_wp_page, you don't
remove the page from the swap cache if there are other references to it
in swap_map.

Okay, now... I'm sure this is not some brilliant insight that everyone
else has missed.  Sould someone tell methe part *I* missed about  why it
won't work?
-- 
	-Colin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
