Subject: Re: speeding up swapoff
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1188394172.22156.67.camel@localhost>
References: <1188394172.22156.67.camel@localhost>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 12:08:31 -0400
Message-Id: <1188403712.5121.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juergen Beisert <juergen127@kreuzholzen.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 09:29 -0400, Daniel Drake wrote:
> Hi,
> 
> I've spent some time trying to understand why swapoff is such a slow
> operation.
> 
> My experiments show that when there is not much free physical memory,
> swapoff moves pages out of swap at a rate of approximately 5mb/sec. When
> there is a lot of free physical memory, it is faster but still a slow
> CPU-intensive operation, purging swap at about 20mb/sec.
> 
> I've read into the swap code and I have some understanding that this is
> an expensive operation (and has to be). This page was very helpful and
> also agrees:
> http://kernel.org/doc/gorman/html/understand/understand014.html
> 
> After reading that, I have an idea for a possible optimization. If we
> were to create a system call to disable ALL swap partitions (or modify
> the existing one to accept NULL for that purpose), could this process be
> signficantly less complex?
> 
> I'm thinking we could do something like this:
>  1. Prevent any more pages from being swapped out from this point
>  2. Iterate through all process page tables, paging all swapped
>     pages back into physical memory and updating PTEs
>  3. Clear all swap tables and caches
> 
> Due to only iterating through process page tables once, does this sound
> like it would increase performance non-trivially? Is it feasible?
> 
> I'm happy to spend a few more hours looking into implementing this but
> would greatly appreciate any advice from those in-the-know on if my
> ideas are broken to start with...

Daniel:  

in a response, Juergen Beisert asked if you'd tried mlock()  [mlockall()
would probably be a better choice] to lock your application into memory.
That would require modifying the application.  Don't know if you want to
do that.

Back in Feb'07, I posted an RFC regarding [optionally] inheriting
mlockall() semantics across fork and exec.  The original posting is
here:

	http://marc.info/?l=linux-mm&m=117217855508612&w=4

The patch is quite stale now [against 20-rc<something>], but shouldn't
be too much work to rebase to something more recent.  The patch
description points to an ad hoc mlock "prefix command" that would allow
you to:

	mlock <some application>

and run the application as if it had called "mlockall(MCL_CURRENT|
MCL_FUTURE)", without having to modify the application--if that's
something you can't or don't want to do.

Maybe this would help?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
