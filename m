Date: Fri, 17 Dec 2004 03:50:28 +0100 (CET)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [patch] [RFC] make WANT_PAGE_VIRTUAL a config option
In-Reply-To: <1103246050.13614.2571.camel@localhost>
Message-ID: <Pine.LNX.4.61.0412170256500.793@scrub.home>
References: <E1Cf3bP-0002el-00@kernel.beaverton.ibm.com>
 <Pine.LNX.4.61.0412170133560.793@scrub.home>  <1103244171.13614.2525.camel@localhost>
  <Pine.LNX.4.61.0412170150080.793@scrub.home> <1103246050.13614.2571.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, geert@linux-m68k.org, ralf@linux-mips.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 16 Dec 2004, Dave Hansen wrote:

> > Could you explain a bit more, what exactly the problem is?
> 
> The symptom is that you'll add some new function to a header, say
> mmzone.h.  You get some kind of compile error that a structure that you
> need is not fully defined (usually because it is predeclared "struct
> foo;").  This happens when you do either a structure dereference on a
> pointer, or do some other kind of pointer arithmetic on it outside of a
> macro.

I know this problem and I hoped you would provide a complete header 
dependency example. Anyway, I'm not against fixing this, I think that 
you're starting somewhere in the middle.
We have the same problem with core data types, like atomic_t, spinlocks, 
semaphores... Preempt made this problem worse and was "fixed" by 
separating some stuff into thread_info.
I'd prefer to fix this problem at the core first, some time ago I posted a 
few patches to separate out core data structures from the functions. This 
allows further cleanups, I just did a quick check with linux/mm.h and 
easily reduced the dependencies by half. I need to update the patches 
soon, so there are ready once 2.6.10 is out.
If you change the header dependencies, there is a big risk you break some 
architecture, the current system is rather fragile. Moving a random 
structure into a new header file doesn't always fix the problem, this 
structure might still need some other definitions and so can pull in 
different headers on every arch. Splitting a header is easy, getting the 
whole thing working again in the end is the hard part.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
