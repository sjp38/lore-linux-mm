Date: Sat, 12 May 2001 11:28:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping 
In-Reply-To: <200105090018.f490IGR87881@earth.backplane.com>
Message-ID: <Pine.LNX.4.21.0105121124110.5468-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Kirk McKusick <mckusick@mckusick.com>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2001, Matt Dillon wrote:

> :I know that FreeBSD will swap out sleeping processes, but will it
> :ever swap out running processes? The old BSD VM system would do so
> :(we called it hard swapping). It is possible to get a set of running
> :processes that simply do not all fit in memory, and the only way
> :for them to make forward progress is to cycle them through memory.
> 
>     I looked at the code fairly carefully last night... it doesn't
>     swap out running processes and it also does not appear to swap
>     out processes blocked in a page-fault (on I/O).  Now, of course
>     we can't swap a process out right then (it might be holding locks),
>     but I think it would be beneficial to be able to mark the process
>     as 'requesting a swapout on return to user mode' or something
>     like that.

In the (still very rough) swapping code for Linux I simply do
this as "swapout on next pagefault". The idea behind that is:

1) it's easy, at a page fault we know we can suspend the process

2) if we're thrashing, we want every process to make as much
   progress as possible before it's suspended (swapped out),
   letting the process run until the next page fault means we
   will never suspend a process while it's still able to make
   progress

3) thrashing should be a rare situation, so you don't want to
   complicate fast-path code like "return to userspace"; instead
   we make sure to have as little impact on the rest of the
   kernel code as possible

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
