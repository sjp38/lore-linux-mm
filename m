Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA11034
	for <linux-mm@kvack.org>; Thu, 18 Jun 1998 04:31:07 -0400
Date: Thu, 18 Jun 1998 09:25:55 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: PTE chaining, kswapd and swapin readahead
In-Reply-To: <m1k96fxsil.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.96.980618091641.2911D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 17 Jun 1998, Eric W. Biederman wrote:
> >>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> RR> True LRU swapping might actually be a disadvantage. The way
> RR> we do things now (walking process address space) can result
> RR> in a much larger I/O bandwidth to/from the swapping device.
> 
> The goal should be to reduce disk I/O as disk bandwidth is way below
> memory bandwidth.  Using ``unused'' disk bandwidth in prepaging may
> also be a help.  

For normal disks, most I/O is so completely dominated by
_seeks_, that transfer time can be almost completely ignored.
This is why we should focus on reducing the number of disk
I/Os, not the number of blocks transferred.

> Note: much of the write I/O performance we achieve is because
> get_swap_page() is very efficient at returning adjacent swap pages.
> I don't see where location is memory makes a difference.

It makes a difference because:
- programs usually use larger area's in one piece
- swapout clustering saves a lot of I/O (like you just said)
- when pages from a process are adjacant on disk, we can
  save the same amount of I/O on _swapin_ too.
- this will result in a _much_ improved bandwidth

> We could probably add a few more likely cases to the vm system.  The
> only simple special cases I can think to add are reverse sequential
> access, and stack access where pages 1 2 3 4 are accesed and then 4 3
> 2 1 are accessed in reverse order.

Maybe that's why stacks grow down :-) Looking at the addresses
of a shrinking stack, you'll notice that linear forward readahead
still is the best algorithm.

> >> Also for swapin readahead the only effective strategy I know is to
> >> implement a kernel system call, that says I'm going to be accessing
> 
> The point I was hoping to make is that for programs that find
> themselves swapping frequently a non blocking read (for mmapped areas)
> can be quite effective.

Agreed. And combined with your other (snipped) call, it might
give a _huge_ advantage for large simulations and other
processes which implement it.

> RR> There are more possibilities. One of them is to use the
> RR> same readahead tactic that is being used for mmap()
> RR> readahead. 
> 
> Actually that sounds like a decent idea.  But I doubt it will help
> much. I will start on the vnodes fairly soon, after I get a kernel
> pgflush deamon working.

It _does_ help very much. A lot of the perceived slowness
of Linux is the 'task switching' in X. By this I mean new
people selecting another window as their foreground window,
causing X and the programs to read in huge amounts of
graphics data, while simultaneously swapping out other data.

By implementing the same readahead tactic as we use for
mmap()ed files, we could cut the number of I/Os by more
than one 3rd and probably even more.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
