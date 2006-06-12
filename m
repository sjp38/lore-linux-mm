Subject: Re: [PATCH]: Adding a counter in vma to indicate the number
	of	physical pages backing it
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <448A762F.7000105@yahoo.com.au>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
	 <448A762F.7000105@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 12 Jun 2006 10:36:34 -0700
Message-Id: <1150133795.9576.19.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2006-06-10 at 17:35 +1000, Nick Piggin wrote:
> Rohit Seth wrote:
> > Below is a patch that adds number of physical pages that each vma is
> > using in a process.  Exporting this information to user space
> > using /proc/<pid>/maps interface.
> > 
> > There is currently /proc/<pid>/smaps that prints the detailed
> > information about the usage of physical pages but that is a very
> > expensive operation as it traverses all the PTs (for some one who is
> > just interested in getting that data for each vma).
> 
> Yet more cacheline footprint in the page fault and unmap paths...
> 

Not necessarily.  If I'm doing calculation right then vm_struct is
currently 176 bytes (without the addition of nphys) on my x86_64 box. So
in this case addition would not result in bigger cache foot print of
page fulats. Also currently two adjacent vmas share a cache line.  So
there is already that much of cache line ping pong going on. 

Though I agree that we should try to not extend this size beyond
absolutely necessary.

> What is this used for and why do we want it? Could you do some
> smaps-like interface that can work on ranges of memory, and
> continue to walk pagetables instead?
> 

It is just the price of those walks that makes smaps not an attractive
solution for monitoring purposes.

I'm thinking if it is possible to extend current interfaces (possibly
having a new system call) in such a way that a user land process can
give some hints/preferences to kernel in terms of <pid, virtual_range>
to remove/inactivate.  This can help in keeping the current kernel
behavior for vmscans but at the same time provide little bit of
non-symmetry for user land applications.  Thoughts?

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
