Date: Fri, 25 Jun 1999 00:23:26 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906212344.QAA93017@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9906250014490.20322-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 1999, Kanoj Sarcar wrote:

>And continuing on with the problems with swapoff ...

I have not thought yet at the races you are talking about in the thread.

But I think I seen another potential problem related to swapoff in the
last days. Think if you run swapoff -a while there is a program that is
faulting in a swapin exception. The process is sleeping into
read_swap_cache_async() after having increased the swap-count (this is the
only problem). While the task is sleeping swapoff will swapin the page and
will map the swapped-in page in the pte of the process while the process
is sleeping. Then swapoff continue and see that the swap-count is still >
0 (1 in the example) even if the page is been swapped-in for all tasks in
the system. Swapoff get confused and set the swap count to 0 by hand (and
doing that it corrupts a bit the state of the VM). I think I reproduced
the above scenario stress testing 2.3.8 + my VM changes (finally "stable"
except the buffer beyond end of the device problem) but it the problem
I seen is real then it will apply to 2.2.x as well.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
