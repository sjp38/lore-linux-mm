Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8JlJYp028841
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:19 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JlCKR067814
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:13 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JlCOB010769
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:12 -0700
Date: Thu, 8 Nov 2007 12:47:11 -0700
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 00/09] VM File Tails
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is the latest version of my "VM File Tails" work.  The idea is to
store tails of files that are smaller than the base page size in kmalloc'ed
memory, allowing more efficient use of memory.  This is especially important
when the base page size is large, such as 64 KB on powerpc.

So far, my testing hasn't resulted in any performance gains.  The workloads
prompting this work are more involved, so more testing is needed.  Right
now, I don't have a case for inclusion of these patches, but there was
interest in the community, so here they are.

These patches are built against 2.6.24-rc2.

I had posted some patches earlier that were much more complex, and
introduced dummy pages into the page cache to account for the tails.  I
have abandoned that approach, and have arrived at a much simpler patch set.

The idea is to attach a buffer to the address space (page->mapping) to hold
the tail.  Whenever the page corresponding to the tail is requested, a new
page is allocated and the tail is unpacked to that page.  At some point,
pages that are eligible to be packed are copied into kmalloced buffers and
attached to the address space.  The eligible pages must be up-to-date, clean,
unmapped, not waiting for I/O, etc.

Since the last time I posted:
- I optimized generic_file_aio_read to copy data directly from the tail,
  rather than unpacking the tail and copying from the page cache
- Luiz Capitulino contributed a patch to add statistics in
  /sys/kernel/debug/vm_tail/

My To-Do list includes:
- Investigate more aggressive places to pack tails.  It's currently only
  being done in shrink_active_list()
- benchmark!

Comments are appreciated.

The patches can also be downloaded from:
ftp://kernel.org/pub/linux/kernel/people/shaggy/vm_file_tails/

Thanks,
Shaggy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
