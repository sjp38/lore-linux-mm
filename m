Date: Wed, 19 Jun 2002 08:58:48 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] (2/2) reverse mappings for current 2.5.23 VM
In-Reply-To: <Pine.LNX.4.44.0206190231520.3637-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.44L.0206190853190.2598-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Craig Kulesa wrote:

> Where: 	   http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/

Thank you. I take it as a big compliment that people are
not only interested in rmap on other kernel versions but
able to read and understand the rmap code well enough to
be able to do so ;)

> 2.5.22 vanilla:
> Total kernel swapouts during test = 29068 kB
> Total kernel swapins during test  = 16480 kB
> Elapsed time for test: 141 seconds
>
> 2.5.23-rmap (this patch -- "rmap-minimal"):
> Total kernel swapouts during test = 24068 kB
> Total kernel swapins during test  =  6480 kB
> Elapsed time for test: 133 seconds
>
> 2.5.23-rmap13b (Rik's "rmap-13b complete") :
> Total kernel swapouts during test = 40696 kB
> Total kernel swapins during test  =   380 kB
> Elapsed time for test: 133 seconds

Interesting to see that both rmap versions have the same
performance, it would seem that swapouts are much cheaper
than waiting for a pagefault to swap something in ...

> [Gotta tone down page_launder() a bit...]

... though I definately agree with your analysis here.
I hadn't expected to give a quick rmap port without any
of the VM balancing changes to give a performance edge
over the virtual scanning VM and am surprised by your
results.


> Modifications:
>
> 	- in vmscan.c: dropped swap_out_add_to_swap_cache(), integrated
> 	  its contents to rmap's add_to_swap() in swap_state.c.  This is a
> 	  more reasonable place for it anyway.
>
> 	- Dropped try_to_swap_out(), swap_out(), and all its brethren from
> 	  vmscan.c.  What a great feeling! :)
>
> 	- In vmscan.c's shrink_cache():
> 	  If a page is actively referenced and page mapping in use, move
> 	  the inactive page to the active list; alloc some swap space for
> 	  anon pages, then if we must, fall to rmap's try_to_unmap() to
> 	  swap.  Drop the max_mapped logic, since swap_out() is gone and
> 	  we don't need it.  If try_to_unmap() fails, put the page on the
> 	  active list.  These are all pieces of Rik's page_launder()
> 	  logic in his integrated rmap scheme.
>
> 	- use page_referenced() instead of TestClearPageReferenced() in
> 	  refill_inactive()

This changelog seems small enough for the code to be mergeable,
if it weren't for one last TODO item:

- pte_highmem support for -rmap


> Okay it's quick and dirty, but it seems to work pretty well in initial
> (and not yet rigorous) tests.  Like the full rmap patch for 2.5, I'll try
> to keep this patch up to date with the 2.5 and rmap trees until VM
> development switches to 2.5.

Thank you. I'm leaving for two meetings and a conference
in Canada later today, but I'll be back to work on rmap
for 2.5 from july 3rd.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
