Date: Thu, 30 Mar 2000 12:11:02 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: page fault in cli / sti safe or not
Message-ID: <20000330121102.A1159@fred.muc.de>
References: <CA2568B2.001A16BB.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568B2.001A16BB.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Thu, Mar 30, 2000 at 06:49:27AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 30, 2000 at 06:49:27AM +0200, pnilesh@in.ibm.com wrote:
>      I tried to page fault in cli () / sti() , but there was no deadlock. I
> had perception that a deadlock would occur. However what might have I now
> believe is that age fault always ocuur in any processes context , they will
> panic in interrupt handler. So when a page fault occurs the page fault
> handler is called and if the page is not found in the memory then a disk
> read is scheduled the faulting process is put to sleep and  schedule() is
> called to run new process. The schedule () implicitly calls sti() and hence
> there is no deadlock.

You are right. It does not make much sense though, because the locking
guarantee you wanted from cli() is broken. Also there is a bug in most
linux kernels that they do turn on the interrupts only after the 
scheduler task queue has run. Some programs do a lot of work in
the scheduler tq (isdn4linux, reiserfs, in some cases the serial driver),
which can cause bad interrupt latencies (often leading the SMP TLB IPI
timed out messages on faster SMP boxes) 

-Andi

-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
