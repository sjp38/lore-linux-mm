Received: from sunsite.mff.cuni.cz (jj@sunsite.ms.mff.cuni.cz [195.113.19.66])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA24643
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 06:40:25 -0500
From: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>
Message-Id: <199901271135.MAA10589@sunsite.mff.cuni.cz>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Wed, 27 Jan 1999 12:35:29 +0100 (CET)
In-Reply-To: <Pine.LNX.3.96.990126145544.11981B-100000@chiara.csoma.elte.hu> from "MOLNAR Ingo" at Jan 26, 99 03:15:04 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Something like
> > 
> > Chop memory into 4Mb sized chunks that hold the perfectly normal and
> > existing pages and buddy memory allocator. Set a flag on 25-33% of them
> > to a max of say 10 and for <12Mb boxes simply say "tough".
> 
> this is conceptually 'boot-time allocation of big buffers' by splitting
> all available memory into two pieces:
> 
> 	size_kernel: generic memory
> 	size_user: only swappable
> 
> (size_kernel+size_user = ca. size_allmemory)
> 
> This still doesnt solve the 'what if we need more big buffers than
> size_user' and 'what if we need kernel memory more than size_kernel'
> questions, and both are valid.

It does not have to look like that.
I guess we need some size_user memory on some ports anyway (i386 above 1GB
physical, sun4d above 2GB physical, sparc64 memory hotplug mem_map), but the
rest should be general memory.
I bet forcing every single driver in the kernel which ever does some kmalloc
to write hooks for relocating that buffer is utopic - it would add too much
complexity everywhere. You often don't keep track where all you put pointers
to the kmalloced area. So we'll have to live with some unmovable objects.
But for the rest, the memory allocator can behave like this:
either have some chunks in which non-swappable memory is being allocated, or
have some rule, e.g. that non-swappable memory grows from the lowest
physical pages up.
Now, for a swappable get_free_pages you can allocate it from anywhere, but
it would be good to give precedence to the memory outside of the current
non-swappable region(s).
For non-swappable get_free_pages, you first try hard to allocate it from the
current non-swappable region(s) (first looking if there are free pages, then
look if there are swappable pages (and in the latter case either swap them
off, or just move them to swappable regions)). If all non-swappable
region(s) are full of non-swappable allocations, then you allocate another
non-swappable region and swap-off/move some pages from there.
As long as we keep most of the objects swappable/movable, this will work
well. If there are too many unmovable objects, it will lead to deadly
fragmentation and this won't work.
But most of the objects are swappable/movable: everything referenced
in user pages only, vmalloc regions, or can be easily flushed.

Cheers,
    Jakub
___________________________________________________________________
Jakub Jelinek | jj@sunsite.mff.cuni.cz | http://sunsite.mff.cuni.cz
Administrator of SunSITE Czech Republic, MFF, Charles University
___________________________________________________________________
UltraLinux  |  http://ultra.linux.cz/  |  http://ultra.penguin.cz/
Linux version 2.2.0 on a sparc64 machine (3958.37 BogoMips)
___________________________________________________________________
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
