Date: Sun, 9 Apr 2000 01:10:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004082147.OAA75650@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004090102560.342-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000, Kanoj Sarcar wrote:

>> 
>> On Fri, 7 Apr 2000, Kanoj Sarcar wrote:
>> 
>> >> BTW, swap_out() always used the same locking order that I added to swapoff
>> >> so if my patch is wrong, swap_out() is always been wrong as well ;).
>> >
>> >Not sure what you mean ... swap_out never grabbed the mmap_sem/page_table_lock
>> >before (in 2.2. too).
>> 
>> In 2.2.x page_table_lock wasn't necessary because we was holding the big
>> kernel lock.
>
>You have answered your own question in a later email. I quote you:
>"Are you using read_swap_cache from any
>swapin event? The problem is swapin can't use read_swap_cache because with
>read_swap_cache we would never know if we're doing I/O on an inactive swap
>entry"
>
>Grabbing lock_kernel in swap_in is not enough since it might get dropped
>if the swap_in code goes to sleep for some reason.

I wasn't talking about races between swapoff/swapin.

I was talking about the locking order issue you raised about the necessary
vmlist_*_lock I added in swapoff.

What I meant is that in 2.2.x there was no need of the
vmlist_*_lock/page_cache_lock in swapoff because we was relying on the big
kernel lock while playing with pagetables and vmas (same in swap_out()).

In 2.3.x both swap_out and swapoff needs to grab first the tasklist_lock
(as in 2.2.x) and then the vmlist_*_lock (otherwise as first the vma
browsing may happen during a vma list modification).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
