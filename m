Date: Wed, 23 Feb 2000 08:48:29 +1100
Message-Id: <200002222148.IAA03610@mobilix.atnf.CSIRO.AU>
From: Richard Gooch <rgooch@atnf.csiro.au>
Subject: Re: mmap/munmap semantics
In-Reply-To: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Richard Guenther writes:
> Hi!
> 
> With the ongoing development of GLAME there arise the following
> problems with the backing-store management, which is a mmaped
> file and does "userspace virtual memory management":
> - I cannot see a way to mmap a part of the file but set the
>   contents initially to zero, i.e. I want to setup an initially
>   dirty zero-mapping which is assigned to a part of the file.
>   Currently I'm just mmaping the part and do the zeroing by
>   reading from /dev/zero (which does as I understand from the
>   kernel code just create this zero mappings) - is there a more
>   portable way to achieve this?
> - I need to "drop" a mapping sometimes without writing the contents
>   back to disk - I cannot see a way to do this with linux currently.
>   Ideally a hole could be created in the mmapped file on drop time -
>   is this possible at all with the VFS/ext2 at the moment (creating
>   a hole in a file by dropping parts of it)?
> 
> So for the first case we could add a flag to mmap like MAP_ZERO to
> indicate a zero-map (dirty).
> 
> For the second case either the munmap call needs to be extended or
> some sort of madvise with a MADV_CLEAN flag? Or we can just adjust
> mprotect(PROT_NONE) and subsequent munmap() to do the dropping?

Maybe you can make use of the same driver that I'd like to use:

- a processes opens the driver device file, and passes the FD to
  another "daemon" process (a child or whatever)

- one process mmap(2)s the FD and does reads and writes to the VMA

- the "daemon" does an ioctl(2) waiting for page fault events, and
  proceeds to read(2)/write(2) to satisfy the page faults

- the driver passes page fault and free memory request events to the
  daemon.

This allows you to set up a user-space virtual memory system. This is
useful for me, it may be useful for you.

All I need to do is find a victim to volunteer to write this ;-)

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
