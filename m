Date: Sat, 8 Apr 2000 15:20:25 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004080037.RAA32924@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004081514470.559-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Kanoj Sarcar wrote:

>Okay, I think I found at least one reason why the lockpage was being done
>in lookup_swap_cache(). It was effectively to check the PageSwapCache bit,
>since shrink_mmap:__delete_from_swap_cache could race with a 
>lookup_swap_cache.

shrink_mmap can't race with a find_get_cache. find_get_page increments the
reference count within the critical section and shrink_mmap checks the
page count and drop the page in one whole transaction within a mutually
exclusive critical section.

>Yes, I did notice the recent shrink_mmap SMP race fixes that you posted,

They weren't relative to the cache, but only to the LRU list
inserction/deletion. There wasn't races between shrink_mmap and
find_get_page and friends.

>now it _*might*_ be unneccesary to do a find_lock_page() in 
>lookup_swap_cache() (just for this race). I will have to look at the 

It isn't. Checking PageSwapCache while the page is locked is not
necessary. The only thing which can drop the page from the swap cache is
swapoff that will do that as soon as you do the unlock before returning
from lookup_swap_cache anyway.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
