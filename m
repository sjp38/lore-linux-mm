Message-ID: <37B42F56.FBAB01A4@geocities.com>
Date: Fri, 13 Aug 1999 14:44:38 +0000
From: Roman Levenstein <romix@geocities.com>
MIME-Version: 1.0
Subject: Re: Strange  memory allocation error in 2.2.11
References: <Pine.LNX.3.96.990813080203.24615A-100000@mole.spellcast.com>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> > I'm writing a program , which actively uses garbage collection,
> > implemented in
> > a separate library(it scans stack, heap, etc. and relies on the system,
> > when trying to determine start and end addresses of these memory areas ,
> > but doesn't contain any assembler low-level code).
> 
> Hrmm, how exactly are you extracting this information from the kernel?

 I use this piece of code , to find out the end and start of the heap
and  
 static data area ( and it doesn't use kernel info directly ):

#if defined(linux) || (defined(sparc) && ! defined(__SVR4))
#  define GC_ALIGNMENT           8   // use 8-byte alignment for our
heap
extern int etext;
extern int end;
#  define GC_DATA_START  (void*)(((unsigned long)(&etext) + 0xfff) &
~0xfff)
#  define GC_DATA_END    (void*)(&end)
#include <stdlib.h>
#include <unistd.h>
extern "C" void * sbrk(int);
#  define GC_GET_HEAP_BOTTOM sbrk(0)
#  define GC_GET_HEAP_TOP    sbrk(0)
#  define GC_CONFIGURED
#endif
> 
> > Are there any changes in MM for 2.2.11 , which require recompilation of
> > user programs?
> 
> The only changes in 2.2.11 related to mm that could cause this have to do
> with zeromapping ranges, but it should be a non-change for x86.  Also,
> allocation patterns might be slightly different now as mmap is now allows
> to wrap around once it reached the top of the address space.  Also, a bug
> in mremap was fixed.
> 
> > What other reasons can lead to such effect?
> 
> Depends on your code =)  Do you have a test program that demonstrates the
> but that we could look at?
 
 Unforunately , I've no such a small program. The GC-library is very
complex and
 the program , where I use it , is also very big. I've never had any
problems  with GC-library before 2.2.11 , though I use this library
since February.

 The latest run of the program , for example, hasn't crashed , but it
took 2.50 minutes instead of normal 10 secs. It's definetly something
with MM in 2.2.11 ...

 Roman Levenstein
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
