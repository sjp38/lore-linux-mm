Message-ID: <20000406173056.08616@colin.muc.de>
From: Andi Kleen <ak@muc.de>
Subject: Re: Query on memory management
References: <OF65849FAF.07536636-ON862568B9.004B90AB@hso.link.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF65849FAF.07536636-ON862568B9.004B90AB@hso.link.com>; from Mark_H_Johnson@Raytheon.com on Thu, Apr 06, 2000 at 04:18:24PM +0200
Date: Thu, 6 Apr 2000 17:30:56 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 06, 2000 at 04:18:24PM +0200, Mark_H_Johnson@Raytheon.com wrote:
> Questions -
> (1) What hard limits are there on how much memory can be mlock'd? I see
> checks [in mm/mlock.c] related to num_physpages/2, but can't tell if that
> is a system wide limit or a limit per process.

system wide
You can probably change it if you know what you're doing. 

> 
> (2) I've seen traffic related to "out of memory" problems. How close are we
> to a permanent solution & do you need suggestions? For example, I can't
> seem to find any per-process limits to the "working set or virtual size"
> (could refer to either the number of physical or virtual pages a process
> can use). If that was implemented, some of the problems you have seen with
> rogue processes could be prevented.

There are per process limits, settable using ulimit
When you set suitable process limits and limit the number of processes you
should never run out of swap. 

> 
> (3) Re: out of memory. I also saw code in 2.2.14 [arch/i386/mm/fault.c]

> prevents the init task (pid==1) from getting killed. Why can't that
> solution be applied to all tasks & let kswapd (or something else) keep
> moving pages to the swap file (or memory mapped files) & kill tasks if and
> only if the backing store on disk is gone?

Tasks are supposed to be only killed when you ran out of swap, or it ran out of
free pages that it cannot swap anymore. Some services like networking
may run out of memory earlier becaue they cannot swap and rely on a free
GFP_ATOMIC pool of pages.
> 
> (4) Is there a "hook" for user defined page replacement or page fault
> handling? I could not find one.

Just mprotect() the data in user space and set a signal handler for SIGSEGV
The fault address can be read from the sigcontext_struct passed to the
signal handler.



-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
