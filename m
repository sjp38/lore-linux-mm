Date: Fri, 25 Jun 1999 02:26:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906242355.QAA92976@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9906250203110.22024-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jun 1999, Kanoj Sarcar wrote:

>The scenario that you lay out is not possible, as both Stephen and I
>pointed out earlier in this thread. swapoff uses read_swap_cache,
>so if a process has started a swapin, swapoff will wait for that io
>to complete. Note that swapoff can not proceed until the read-in is

Sorry, I forgot to specify where the the faulting-task was sleeping.

I wasn't talking about the case where the faulting-task was sleeping on
I/O with the swap-cache page just alloced and hashed in the page cache. If
the task is sleeping waiting for I/O then I completly agree with you that
swapoff will block in lookup_swap_cache because it will see the swap-cache
page locked down from the faulting-task.

In my case the faulting-task was sleeping in _GFP_ (maybe swapping out
some stuff in sync mode). And if you look at rw_swap_cache_async you'll
notice that the task can go to sleep in GFP while holding an additional
reference into the swap space (see swap_duplicate). While the task was
sleeping swapoff was allowed to alloc a new page in the meantime, then was
allowed to add such new page to the swap cache and to start I/O on it, and
finally to remap the pte with the new page. Then swapoff continued
noticing that there was an additional reference in the swap cache even if
nobody was mapping such swapped-out page anymore (the additional reference
was of the proggy sleeping in GFP).

>The swap lockmap deletion in 2.3.8 is not complete. I hope you will
>be taking in Andrea's "shm pages in swapcache" changes (although I

I'll send the shm patch to Linus in the next days (but I bet nobody will
trigger the race in the meantime, also considering that database people
have the shm memory not swappable).

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
