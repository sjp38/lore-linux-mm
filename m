Date: Tue, 22 Feb 2000 18:46:02 +0100 (MET)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: mmap/munmap semantics
Message-ID: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel List <linux-kernel@vger.rutgers.edu>
Cc: glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

With the ongoing development of GLAME there arise the following
problems with the backing-store management, which is a mmaped
file and does "userspace virtual memory management":
- I cannot see a way to mmap a part of the file but set the
  contents initially to zero, i.e. I want to setup an initially
  dirty zero-mapping which is assigned to a part of the file.
  Currently I'm just mmaping the part and do the zeroing by
  reading from /dev/zero (which does as I understand from the
  kernel code just create this zero mappings) - is there a more
  portable way to achieve this?
- I need to "drop" a mapping sometimes without writing the contents
  back to disk - I cannot see a way to do this with linux currently.
  Ideally a hole could be created in the mmapped file on drop time -
  is this possible at all with the VFS/ext2 at the moment (creating
  a hole in a file by dropping parts of it)?

So for the first case we could add a flag to mmap like MAP_ZERO to
indicate a zero-map (dirty).

For the second case either the munmap call needs to be extended or
some sort of madvise with a MADV_CLEAN flag? Or we can just adjust
mprotect(PROT_NONE) and subsequent munmap() to do the dropping?

Richard.

--
The GLAME Project: http://www.glame.de/
Hosted by SourceForge: http://glame.sourceforge.net/
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
