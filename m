Date: Mon, 7 Aug 2000 18:59:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RFC: design for new VM 
In-Reply-To: <Pine.BSO.4.20.0008071641300.2595-100000@naughty.monkey.org>
Message-ID: <Pine.LNX.4.21.0008071844100.25008-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chucklever@bigfoot.com
Cc: Gerrit.Huizenga@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Aug 2000, Chuck Lever wrote:
> On Mon, 7 Aug 2000 Gerrit.Huizenga@us.ibm.com wrote:
> > Another fundamental flaw I see with both the current page aging mechanism
> > and the proposed mechanism is that workloads which exhaust memory pay
> > no penalty at all until memory is full.  Then there is a sharp spike
> > in the amount of (slow) IO as pages are flushed, processes are swapped,
> > etc.  There is no apparent smoothing of spikes, such as increasing the
> > rate of IO as the rate of memory pressure increases.  With the exception
> > of laptops, most machines can sustain a small amount of background
> > asynchronous IO without affecting performance (laptops may want IO
> > batched to maximize battery life).  I would propose that as memory
> > pressure increases, paging/swapping IO should increase somewhat
> > proportionally.  This provides some smoothing for the bursty nature of
> > most single user or small ISP workloads.  I believe databases style
> > loads on larger machines would also benefit.
> 
> 2 comments here.
> 
> 1.  kswapd runs in the background and wakes up every so often to handle
> the corner cases that smooth bursty memory request workloads.  it executes
> the same code that is invoked from the kernel's memory allocator to
> reclaim pages.

*nod*

The idea is that the memory_pressure variable indicates how
much page stealing is going on (on average) so every time
kswapd wakes up it knows how much pages to steal. That way
it should (if we're "lucky") free enough pages to get us
along until the next time kswapd wakes up.

> 2.  i agree with you that when the system exhausts memory, it
> hits a hard knee; it would be better to soften this.

The memory_pressure variable is there to ease this. If the load
is more or less bursty, but constant on a somewhat longer timescale
(say one minute), then we'll average the inactive_target to
somewhere between one and two seconds worth of page steals.

> can a soft-knee swapping algorithm be demonstrated that doesn't
> impact the performance of applications running on a system that
> hasn't exhausted its memory?

The algorithm we're using (dynamic inactive target w/
agressively trying to meet that target) will eat disk
bandwidth in the case of one application filling memory
really fast but not swapping, but since the data is
kept in memory, it shouldn't be a very big performance
penalty in most cases.


About NUMA scalability: we'll have different memory pools
per NUMA node. So if you have a 32-node, 64GB NUMA machine,
it'll partly function like 32 independant 2GB machines.

We'll have to find a solution for the pagecache_lock (how do
we make this more scalable?), but the pagecache_lru_lock, the
memory queues/lists and kswapd will be per _node_.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
