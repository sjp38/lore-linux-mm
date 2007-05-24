Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCBW05001091
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCBU10474288
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:32 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCBUU8024508
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:30 -0400
Date: Thu, 24 May 2007 08:11:30 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 000/012] VM Page Tails
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I wanted to get some feedback on this as it is, before it undergoes some
major re-writing.  These patches are against linux-2.6.22-rc2.

These patches implement what I'm calling "VM File Tails" to
differentiate this code from a file system's method of storing file
tails on disk, such as reiserfs does.  I've struggled a bit on the
naming of the config option and symbols.  I changed the PageTail()
to PageFileTail() to avoid confusion with the tails of a compound page,
and I've changed the config option from CONFIG_FILE_TAILS to
CONFIG_VM_FILE_TAILS to make it clear that this is not really a
filesystem thing.

The object is to store smaller files more effiently on kernels that use
a large base page size.  In particular I'm targeting Series P kernels
compiled with CONFIG_64K_PAGES.

Buffers for the tails are kmalloc'ed and aligned to the file system's
block size.  A fake page struct is allocated and assigned to the file
tail, and used in the page cache (radix tree), file system code, and
even passed to the device drivers in order to perform I/O.

If a file is grown, or an mmapped tail is touched, the tail is unpacked
into a normal page.

I've tried getting rid of the new page flag PG_filetail, by defining
a function:

static inline int page_is_file_tail(struct page *page) {
	return (page->mapping && page == page->mapping->tail_page);
}

where tail_page is a new field in the mapping, but this gets complicated
when the page is removed from the page cache.  zeroing page->mapping would
cause us to lose track of the fact that this is not a real page struct.
I believe I can make it work, but the patch gets much more intrusive, so
I've left it as a page flag for the time being.

The current implementation only enables the new code for jfs and ext4 in
order to minimize any possible file system corruption until the code
becomes more stable.  The code currently is NOT stable, so review it all
you want, but be warned that it may crash or lockup your machine if you
try to run it.

These patches completely conflict with Nick Piggin's Lockless Page Cache
patches, so keep in mind that all of the locking in mm/page_tail.c is going
to have to be re-worked.

I also think I can build on top of Christoph Lameter's Variable Order Page
Cache patches, which deals with some of the same concepts, but from a
different direction.  He's looking at larger than PAGE_SIZE pages, where
I'm looking at pages that are smaller than PAGE_SIZE.

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
