Subject: Re: mmap/munmap semantics
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Feb 2000 21:49:13 -0600
In-Reply-To: Richard Guenther's message of "Tue, 22 Feb 2000 18:46:02 +0100 (MET)"
Message-ID: <m1hff0fuiu.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Richard Guenther <richard.guenther@student.uni-tuebingen.de> writes:

> Hi!
> 
> With the ongoing development of GLAME there arise the following
> problems with the backing-store management, which is a mmaped
> file and does "userspace virtual memory management":

For this to be a productive discussion we need to know why 
you want this.  What advantage do your changes/proposals provide.

Most of this sounds like you want to zero memory quickly.
Does your code care that the memory is zero, or can you get away
with simply getting memory quickly?

> - I cannot see a way to mmap a part of the file but set the
>   contents initially to zero, i.e. I want to setup an initially
>   dirty zero-mapping which is assigned to a part of the file.
Why dirty?
>   Currently I'm just mmaping the part and do the zeroing by
>   reading from /dev/zero (which does as I understand from the
>   kernel code just create this zero mappings) - is there a more
>   portable way to achieve this?
memset...

> - I need to "drop" a mapping sometimes without writing the contents
>   back to disk - 

You do know that with a shared mapping the kernel can write
the contents back to disk whenever it feels like it.
What is the benefit of not writing things to disk?

>   I cannot see a way to do this with linux currently.
>   Ideally a hole could be created in the mmapped file on drop time -
>   is this possible at all with the VFS/ext2 at the moment (creating
>   a hole in a file by dropping parts of it)?
Again why do you want this?

> 
> So for the first case we could add a flag to mmap like MAP_ZERO to
> indicate a zero-map (dirty).

Possibly. madavise(MADV_WILLNEED)  sounds probably like what you
want. (After using ftruncate to zero everything quickly).

> 
> For the second case either the munmap call needs to be extended or
> some sort of madvise with a MADV_CLEAN flag? 
Poking holes is probably not what you want.  The zeroing cost
will be paid somewhere.

> Or we can just adjust
> mprotect(PROT_NONE) and subsequent munmap() to do the dropping?

This is definetly not right. mprotect(PROT_NONE) has very clear
semantics, as does munmap, and this suggestion would break them.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
