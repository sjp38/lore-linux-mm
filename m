From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906242355.QAA92976@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Thu, 24 Jun 1999 16:55:28 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9906250014490.20322-100000@laser.random> from "Andrea Arcangeli" at Jun 25, 99 00:23:26 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Mon, 21 Jun 1999, Kanoj Sarcar wrote:
> 
> >And continuing on with the problems with swapoff ...
> 
> I have not thought yet at the races you are talking about in the thread.
> 
> But I think I seen another potential problem related to swapoff in the
> last days. Think if you run swapoff -a while there is a program that is
> faulting in a swapin exception. The process is sleeping into
> read_swap_cache_async() after having increased the swap-count (this is the
> only problem). While the task is sleeping swapoff will swapin the page and
> will map the swapped-in page in the pte of the process while the process
> is sleeping. Then swapoff continue and see that the swap-count is still >
> 0 (1 in the example) even if the page is been swapped-in for all tasks in
> the system. Swapoff get confused and set the swap count to 0 by hand (and
> doing that it corrupts a bit the state of the VM). I think I reproduced
> the above scenario stress testing 2.3.8 + my VM changes (finally "stable"
> except the buffer beyond end of the device problem) but it the problem
> I seen is real then it will apply to 2.2.x as well.
> 
> Andrea Arcangeli
> 

Andrea, 

The scenario that you lay out is not possible, as both Stephen and I
pointed out earlier in this thread. swapoff uses read_swap_cache,
so if a process has started a swapin, swapoff will wait for that io
to complete. Note that swapoff can not proceed until the read-in is
complete (at which point the swapcount is decremented by 
PG_swap_unlock_after logic). So, it is not possible for swapoff
to see swap count > 0. At least in theory ...

As to why you might be seeing the problem, this might be due
to fork/exit races with swapoff (which I pointed out in this thread), 
which I hope to have a fix for sometime soon (although it looks ugly). 
Also, see below.

Linus,

The swap lockmap deletion in 2.3.8 is not complete. I hope you will
be taking in Andrea's "shm pages in swapcache" changes (although I
haven't reviewed it, so I can't attest to its goodness). One problem
in 2.3.8 is that a shm page could be getting swapped out, and a swapoff
could actually read the contents of the swaphandle into a new page,
*before* the swapout completed (this was prevented in 2.3.7 in
rw_swap_page_base() by swap lockmap checking), since shm pages are 
not in the swap cache (thus swapoff would have no way of synchronizing
with the swapout completing). This could lead to shm data getting
corrupted. And also lead to swapoff manually setting swapcount to 0,
with shm swapout termination also decrementing swapcount.

Or maybe I am just confused ....

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
