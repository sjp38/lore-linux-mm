Date: Mon, 7 Aug 2000 16:55:32 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Reply-To: chucklever@bigfoot.com
Subject: Re: RFC: design for new VM 
In-Reply-To: <200008071740.KAA25895@eng2.sequent.com>
Message-ID: <Pine.BSO.4.20.0008071641300.2595-100000@naughty.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit.Huizenga@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

hi gerrit-

good to see you on the list.

On Mon, 7 Aug 2000 Gerrit.Huizenga@us.ibm.com wrote:
> Another fundamental flaw I see with both the current page aging mechanism
> and the proposed mechanism is that workloads which exhaust memory pay
> no penalty at all until memory is full.  Then there is a sharp spike
> in the amount of (slow) IO as pages are flushed, processes are swapped,
> etc.  There is no apparent smoothing of spikes, such as increasing the
> rate of IO as the rate of memory pressure increases.  With the exception
> of laptops, most machines can sustain a small amount of background
> asynchronous IO without affecting performance (laptops may want IO
> batched to maximize battery life).  I would propose that as memory
> pressure increases, paging/swapping IO should increase somewhat
> proportionally.  This provides some smoothing for the bursty nature of
> most single user or small ISP workloads.  I believe databases style
> loads on larger machines would also benefit.

2 comments here.

1.  kswapd runs in the background and wakes up every so often to handle
the corner cases that smooth bursty memory request workloads.  it executes
the same code that is invoked from the kernel's memory allocator to
reclaim pages.

2.  i agree with you that when the system exhausts memory, it hits a hard
knee; it would be better to soften this.  however, the VM system is
designed to optimize the case where the system has enough memory.  in
other words, it is designed to avoid unnecessary work when there is no
need to reclaim memory.  this design was optimized for a desktop workload,
like the scheduler or ext2 "async" mode.  if i can paraphrase other
comments i've heard on these lists, it epitomizes a basic design
philosophy: "to optimize the common case gains the most performance
advantage."

can a soft-knee swapping algorithm be demonstrated that doesn't impact the
performance of applications running on a system that hasn't exhausted its
memory?

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@bigfoot.com>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
