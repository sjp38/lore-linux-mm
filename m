Date: Tue, 22 Feb 2000 13:41:27 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: mmap/munmap semantics
In-Reply-To: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
Message-ID: <Pine.LNX.3.96.1000222133019.4098B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Feb 2000, Richard Guenther wrote:

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

Do you mean that you want to go above and beyond what ftruncate does?  If
that's the case, reading from /dev/zero is probably the easiest thing,
although I suspect doing a sendfile from /dev/zero to the file will
ultimately end up being more efficient.

If you are managed to do a read from /dev/zero into a shared file mapping
beyond the end of file without getting a SIGBUS, then that's a bug.

> - I need to "drop" a mapping sometimes without writing the contents
>   back to disk - I cannot see a way to do this with linux currently.
>   Ideally a hole could be created in the mmapped file on drop time -
>   is this possible at all with the VFS/ext2 at the moment (creating
>   a hole in a file by dropping parts of it)?

No, this is insanity.  Creating holes in the middle of files actually cam
up when talking about ext2 changes, and frankly it doesn't make sense. 
For example: on a filesystem that uses extents, creating a hole in the
middle of a file means that you might have to allocate more disk space in
order to free the disk space.

> So for the first case we could add a flag to mmap like MAP_ZERO to
> indicate a zero-map (dirty).

Or teach truncate about preallocation.

> For the second case either the munmap call needs to be extended or
> some sort of madvise with a MADV_CLEAN flag? Or we can just adjust
> mprotect(PROT_NONE) and subsequent munmap() to do the dropping?

Remember that madvise is only giving the system hints about what you want
it to do.  If madvise allows you to mark a dirty page as clean without
doing a writeback, that could result in stale data residing in the page
cache for other users to come along and read without that data going to
disk -- not behaviour I want to see.  If read returns it, it should be on
disk.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
