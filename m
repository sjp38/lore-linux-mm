From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906211846.LAA91751@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Mon, 21 Jun 1999 11:46:27 -0700 (PDT)
In-Reply-To: <14190.31543.461985.372712@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 21, 99 06:49:43 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi, 
> 
> On Mon, 21 Jun 1999 10:36:37 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > But doesn't my previous logic work in this case too? Namely
> > that kernel_lock is held when any code looks at or changes
> > a pte, so if swapoff holds the kernel_lock and never goes to 
> > sleep, things should work?
> 
> No, because the swapoff could still take place while a normal swapin is
> already in progress.
> 
> > Maybe if you can jot down a quick scenario where a problem occurs when
> > swapoff does not take mmap_sem, it would be easier for me to spot
> > which concurrency issue I am missing ...
> 
> Look no further than swap_in(), which knows that there is no pte (so
> swapout concurrency is not a problem) and it holds the mmap lock (so
> there are no concurrent swap_ins on the page).  It reads in the page adn
> unconditionally sets up the pte to point to it, assuming that nobody
> else can conceivably set the pte while we do the swap outselves.
> 
> --Stephen
> 

Hmm, am I being fooled by the comment in swap_in?

/*
 * The tests may look silly, but it essentially makes sure that
 * no other process did a swap-in on us just as we were waiting.
 *

Also, swap_in seems to be revalidating the pte if it goes to
sleep:

        if (pte_val(*page_table) != entry) {
                if (page_map)
                        free_page_and_swap_cache(page_address(page_map));
                return;
        }

All this while holding kernel_lock ...

So, I am still mystified about why swapoff would need the mmap_sem.

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
