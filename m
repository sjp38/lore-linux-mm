Subject: Re: maximum memory limit
References: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 08 Feb 2000 10:25:46 -0600
In-Reply-To: Rik van Riel's message of "Tue, 8 Feb 2000 15:08:49 +0100 (CET)"
Message-ID: <m166vzr791.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Lee Chin <leechin@mail.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@nl.linux.org> writes:

> On Tue, 8 Feb 2000, Lee Chin wrote:
> 
> > Sorry if this is the wrong list, but what is the maximum virtual
> > memory an application can malloc in the latest kernel?
> > 
> > Just doing a (for example) "malloc(1024)" in a loop will max out
> > close to 1GB even though I have 4 GB ram on my system.
> 
> The kernel supports up to 3GB of address space per process.
> The first 900MB can be allocated by brk() and the rest can
> be allocated by mmap().
> 
> Problem is that libc malloc() appears to use brk() only, so
> it is limited to 900MB. You can fix that by doing the brk()
> and malloc() yourself, but I think that in the long run the
> glibc people may want to change their malloc implementation
> so that it automatically supports the full 3GB...

Clarification: The problem is the brk interface, which ignores
fragmentation.  The brk interface assumes all memory is
continuous. When brk runs into any mapping it fails. And since ld.so
is mapped at 1GB the brk cannot allocate any more memory.  This
is agravated by the fact that ELF programs appear to be intially
mapped at 128M+288K. 0x08048000. (Someone allocated 900MB??? wow!)

It would certainly be a good option if libc could allocate
new chunks of memory with mmap, or a combination of mmap and mremap.
mremap is functionally a good as brk but will let you work with
arbitrary areas of memory. 

A good option is to compile programs that need huge amounts
of memory through brk statically.  If they do not use mmap, or shmat
they should be fine until they hit the stack, which is growing
in the other direction from 3GB.  Because the program is static it's
code size is reduced the linker will only pull in needed objects,
and performance is also enhanced as you don't need to deal with PIC,
and register starvation.  So it looks good for compute intensive code.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
