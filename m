From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906180020.RAA02498@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Thu, 17 Jun 1999 17:20:10 -0700 (PDT)
In-Reply-To: <14185.34250.163041.796165@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 18, 99 00:33:30 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Tue, 15 Jun 1999 09:32:19 +0200 (CEST), Rik van Riel
> <riel@nl.linux.org> said:
> 
> >> How will it be possible for a page to be in the swapcache, for its
> >> reference count to be 1 (which has been checked just before), and for
> >> its swap_count(page->offset) to also be 1? I can see this being
> >> possible only if an unmap/exit path might lazily leave a anonymous
> >> page in the swap cache, but I don't believe that happens.
> 
> > It does happen. We use a 'two-stage' reclamation process instead
> > of page aging. It seems to work wonderfully -- nice page aging
> > properties without the overhead. 
> 
> Much more than that: if we take a write fault to a page which is shared
> on swap by two processes, then we bring it into cache and take a
> copy-on-write, leaving one copy in the swap cache (reference one: it is
> _only_ in use by the swap cache now), and the other copy being reference
> by the faulting process.
> 
> --Stephen
> --

Interesting scenario ... unfortunately, I am getting confused.
I am trying to lay out the steps in your example here:
 
Step 1:  P1 and P2 sharing a page which is not in core, is out on
swap at swap handle X, swap_count(X) = 2 (P1 + P2)

Step 2: P1 writes to page.

        Step 2a: swap_in reads in the page into core into page A, 
page_count(A) = 2 (swapcache + P1), A.offset = X,  
swap_count (X)= 2 (P2 + swapcache)

        Step 2b: P1 incurs do_wp_page on the page, gets a new page. 
The old page A ends up with a page_count = 1 (swapcache), and
swap_count (X) stays at 2. 

So, what am I missing, since your example does not end up with 
page_count = 1 and swap_count(page offset/swaphandle) = 1?

I did give an alternative scenario involving an exitting process,
do you believe that one?

While I have your attention, I think I found a bug in the
sys_swapoff algorithm ... basically, it needs to also look 
at swap_lockmap. Say an exitting process fired off some async
swap ins just before it exitted, and a bunch of these are in
flight (swap_lockmaps are set, as are swap_map, from swapcache).
The swap device gets deleted (with a printk warning message due
to non zero swap_map count). Finally, the old async swap in's 
start terminating, invoking swap_after_unlock_page. Interesting
things could happen, depending on whether the swap id has been
reallocated or not ... Is there any protection against this
scenario?

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
