Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKrQNU030063
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:26 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKrQEp678812
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:26 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKrQa9010692
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:26 -0400
Date: Wed, 29 Aug 2007 16:53:25 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 00/07] VM File Tails
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a rewrite of my "VM File Tails" work.  The idea is to store tails
of files that are smaller than the base page size in kmalloc'ed memory,
allowing more efficient use of memory.  This is especially important when
the base page size is large, such as 64 KB on powerpc.

I had posted some patches earlier that were much more complex, and
introduced dummy pages into the page cache to account for the tails.  I
have abandoned that approach, and have arrived at a much simpler patch set.

The idea is to attach a buffer to the address space (page->mapping) to hold
the tail.  Whenever the page corresponding to the tail is requested, a new
page is allocated and the tail is unpacked to that page.  At some point,
pages that are eligible to be packed are copied into kmalloced buffers and
attached to the address space.  The eligible pages must be up-to-date, clean,
unmapped, not waiting for I/O, etc.

This is still pretty preliminary, and has passed basic unit testing.  i.e.
building a kernel.  :-)

My To-Do list includes:
- adding some statistics
- optimizing generic_file_aio_read to copy data directly from the tail,
  rather than unpacking the tail and copying from the page cache
- Investigate more aggressive places to pack tails.  It's currently only
  being done in shrink_active_list()
- benchmark!

Comments are appreciated.

The patches can also be downloaded from:
ftp://kernel.org/pub/linux/kernel/people/shaggy/vm_file_tails/vm_file_tails.2007-08-29.tar.gz

Thanks,
Shaggy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
