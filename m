Date: Fri, 13 Aug 1999 10:49:45 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Strange  memory allocation error in 2.2.11
In-Reply-To: <37B42F56.FBAB01A4@geocities.com>
Message-ID: <Pine.LNX.3.96.990813104056.25480B-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Levenstein <romix@geocities.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Aug 1999, Roman Levenstein wrote:

> > > I'm writing a program , which actively uses garbage collection,
> > > implemented in
> > > a separate library(it scans stack, heap, etc. and relies on the system,
> > > when trying to determine start and end addresses of these memory areas ,
> > > but doesn't contain any assembler low-level code).
> > 
> > Hrmm, how exactly are you extracting this information from the kernel?
> 
>  I use this piece of code , to find out the end and start of the heap
> and  
>  static data area ( and it doesn't use kernel info directly ):
> 
> #if defined(linux) || (defined(sparc) && ! defined(__SVR4))
> #  define GC_ALIGNMENT           8   // use 8-byte alignment for our
> heap
> extern int etext;
> extern int end;
> #  define GC_DATA_START  (void*)(((unsigned long)(&etext) + 0xfff) &
> ~0xfff)
> #  define GC_DATA_END    (void*)(&end)
> #include <stdlib.h>
> #include <unistd.h>
> extern "C" void * sbrk(int);
> #  define GC_GET_HEAP_BOTTOM sbrk(0)
> #  define GC_GET_HEAP_TOP    sbrk(0)
> #  define GC_CONFIGURED
> #endif

This is definately wrong -- the bottom and top of heap are definately not
equal, and if you're using any sort of recent malloc implementation, it
will make use of mmap/munmap, which 2.2.11 can possibly change the
allocation patterns of.

>  Unforunately , I've no such a small program. The GC-library is very
> complex and
>  the program , where I use it , is also very big. I've never had any
> problems  with GC-library before 2.2.11 , though I use this library
> since February.

Well, try comparing the results of strace under different kernels.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
