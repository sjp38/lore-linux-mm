Date: Tue, 10 Oct 2000 17:53:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Updated 2.4 TODO List
In-Reply-To: <200010090419.e994JQT09775@trampoline.thunk.org>
Message-ID: <Pine.LNX.4.21.0010101738110.11122-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tytso@mit.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000 tytso@mit.edu wrote:

> 2. Capable Of Corrupting Your FS/data
> 
>      * Non-atomic page-map operations can cause loss of dirty bit on
>        pages (sct, alan)

Is anybody looking into fixing this bug ?

> 9. To Do
> 
>      * mm->rss is modified in some places without holding the
>        page_table_lock (sct)

Probably not a show-stopper, but we're looking for
volunteers to fix this one anyway ;)

>      * VM: Out of Memory handling {CRITICAL}

Seems to work now, except for the fact that it is possible
to end up with a heavily thrashing system that /just/ didn't
run out of memory and doesn't get anything killed.

Then again, you can end up with a heavily thrashing system
where you can't get anything done without running out of swap
anyway ... the proper fix for this is probably some form of
thrashing control...

>      * VM: Fix the highmem deadlock, where the swapper cannot create low
>        memory bounce buffers OR swap out low memory because it has
>        consumed all resources {CRITICAL} (old bug, already reported in
>        2.4.0test6)

Haven't been able to reproduce it on my 1GB test machine,
but it might still be there. Can anyone confirm if this
bug is still present ?

>      * VM: page->mapping->flush() callback in page_lauder() for easier
>        integration with journaling filesystem and maybe the network
>        filesystems

Possibly a 2.5 issue, or something to merge later in 2.4,
since we don't have journaling filesystems in the kernel
anyway. I guess we'll want it for the network filesystems
though.

But this is a fairly simple thing to integrate:
1) have an appropriate function in the filesystems
2) insert function pointer in the right struct
3) call the function from vmscan.c::page_launder()

>      * VM: maybe rebalance the swapper a bit... we do page aging now so
>        maybe refill_inactive_scan() / shm_swap() and swap_out() need to
>        be rebalanced a bit

I'll try to look into this (3 days to go before I have to
leave for Miami) and see how things can be improved here.

> 11. To Check
> 
>      * VFS?VM - mmap/write deadlock (demo code seems to show lock is
>        there)

Does anyone have the demo code at hand so we can verify if this
still happens ?

>      * Stressing the VM (IOPS SPEC SFS) with HIGHMEM turned on can hang
>        system (linux-2.4.0test5, Ying Chen, Rik van Riel)

Ditto. Can this still be reproduced with the latest VM or was
it simply a side effect of something else in the VM that got
fixed recently ?

(the highmem code itself looks ok so the bug might well have
been caused by a side effect of something else)

> 12. Probably Post 2.4
> 
>      * addres_space needs a VM pressure/flush callback (Ingo)

[duplicate item?]

We may want this to better support the journaling filesystems
in 2.4 .... but I agree that it should probably be post 2.4.0.

>      * VM: physical->virtual reverse mapping, so we can do much better
>        page aging with less CPU usage spikes
>      * VM: better IO clustering for swap (and filesystem) IO
>      * VM: move all the global VM variables, lists, etc. into the pgdat
>        struct for better NUMA scalability
>      * VM: (maybe) some QoS things, as far as they are major improvements
>        with minor intrusion

These 4 seem /definate/ 2.5 issues, though I hope to have them
(except maybe QoS?) ready in an patch before 2.5.0 is split off.

>      * VM: thrashing control, maybe process suspension with some forced
>        swapping ?
>      * VM: include Ben LaHaise's code, which moves readahead to the VMA
>        level, this way we can do streaming swap IO, complete with
>        drop_behind()

These two are fairly simple and may well be done in the next
few weeks. If no bug reports about the current 2.4 VM pop up,
I'll probably look into some of the issues above...


FYI, my personal VM TODO list:
- see if refill_inactive_scan(), swapout_shm(), swap_out(), etc...
  need rebalancing
- anti-thrashing code  (if no hidden nasties are present)
- better IO clustering + readahead at VMA level

AFAIK Juan Quintela is already looking into the ->flush()
callback for journaling filesystems.

And one more TODO item:

* pinned page reservation system for journaling filesystems


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
