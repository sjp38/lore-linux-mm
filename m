From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14190.31543.461985.372712@dukat.scot.redhat.com>
Date: Mon, 21 Jun 1999 18:49:43 +0100 (BST)
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906211736.KAA17592@google.engr.sgi.com>
References: <14190.28416.483360.862142@dukat.scot.redhat.com>
	<199906211736.KAA17592@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

On Mon, 21 Jun 1999 10:36:37 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> But doesn't my previous logic work in this case too? Namely
> that kernel_lock is held when any code looks at or changes
> a pte, so if swapoff holds the kernel_lock and never goes to 
> sleep, things should work?

No, because the swapoff could still take place while a normal swapin is
already in progress.

> Maybe if you can jot down a quick scenario where a problem occurs when
> swapoff does not take mmap_sem, it would be easier for me to spot
> which concurrency issue I am missing ...

Look no further than swap_in(), which knows that there is no pte (so
swapout concurrency is not a problem) and it holds the mmap lock (so
there are no concurrent swap_ins on the page).  It reads in the page adn
unconditionally sets up the pte to point to it, assuming that nobody
else can conceivably set the pte while we do the swap outselves.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
