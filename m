Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA12267
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 23:18:19 -0400
Subject: I've got some patches to integrate...
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 14 Apr 1998 22:22:26 -0500
Message-ID: <m11zuz4vm5.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently I have been working in two tracks.

1) Adding dirty page support to the page cache.
   I had some preliminary discussions with Stephen Tweedie
2) Creating a proof of concept filesystem that uses dirty pages in the
   page cache, resides in swap, and is should be good for usage a
   Posix shared memory.

I believe I have found the last of my bugs, and it is now time to
start integrating my work with the developmental kernel.  I have heard
that there is a feature freeze in place so my timing is horrible!

My patches are:
1. A patch to page_io.c that allows:
a) reading of swap pages directly into the page cache, with rw_swap_page_nocache
b) gives rw_swap_page_nocache a wait parameter.  So it can do asynchronous operations.
c) uses brw_page directly for reading both swap partitions, and swap files,
   making life more uniform, allowing async operations on swap file etc.

2. A patch to swapfile.c.
  The problem is that sys_swapoff assumes all swap pages are in mapped
  into processs.  This is not necessarily true now with SYSV shared
  memory.  And when my filesystem that resides in swap is mounted is
  very definentily not true.
  
  The solution I have implemented is a some registration functions that
  maintain a linked list, so other parts of the kernel that use swap
  through rw_swap_page_nocache can have a chance to remove their pages
  from swap when swapoff is called.

3. A patch to filemap.c to that pages marked with a special dirty bit 
   are written out in shrink_mmap.
   This doesn't perform too well with the new memory allocator, that
   trys to keep lots of contigous memory.  It pushes the swapping
   heavily case which is not yet handled very well.
   On linux-2.0.32 it blasts writes through the page cache quite well.

Anyhow I thought I'd bounce off what I had off this list and see what
people thought of my ideas.  I started checking with Stepen Tweedie to
see if he maintained the swap code and if I should send patches to
him, or Linus.  And he said it should bounce what I have off of this
list, and to start talks about integrating it.

This is the end of the semester for me so I really won't have much time
for at least two weeks :(  My patches exist but need breaking up.
Right now I just have one huge patch glob against 2.1.92 after I got
everything working.

Eric
