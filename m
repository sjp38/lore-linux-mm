From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14186.31507.833263.846717@dukat.scot.redhat.com>
Date: Fri, 18 Jun 1999 18:00:03 +0100 (BST)
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906180020.RAA02498@google.engr.sgi.com>
References: <14185.34250.163041.796165@dukat.scot.redhat.com>
	<199906180020.RAA02498@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 17 Jun 1999 17:20:10 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Interesting scenario ... unfortunately, I am getting confused.
> I am trying to lay out the steps in your example here:
 
> Step 1:  P1 and P2 sharing a page which is not in core, is out on
> swap at swap handle X, swap_count(X) = 2 (P1 + P2)

> Step 2: P1 writes to page.

>         Step 2a: swap_in reads in the page into core into page A, 
> page_count(A) = 2 (swapcache + P1), A.offset = X,  
> swap_count (X)= 2 (P2 + swapcache)

Yes.  Exactly.

> So, what am I missing, since your example does not end up with 
> page_count = 1 and swap_count(page offset/swaphandle) = 1?

> I did give an alternative scenario involving an exitting process,
> do you believe that one?

Yes --- I'd missed the fact that you wanted swap_count to be one as well
as page count.

> While I have your attention, I think I found a bug in the
> sys_swapoff algorithm ... basically, it needs to also look 
> at swap_lockmap. Say an exitting process fired off some async
> swap ins just before it exitted, and a bunch of these are in
> flight (swap_lockmaps are set, as are swap_map, from swapcache).
> The swap device gets deleted (with a printk warning message due
> to non zero swap_map count). Finally, the old async swap in's 
> start terminating, invoking swap_after_unlock_page. Interesting
> things could happen, depending on whether the swap id has been
> reallocated or not ... Is there any protection against this
> scenario?

Yes --- try_to_unuse calls read_swap_cache() with wait==1, so we always
wait for the IO to complete before swapoff can complete.  At least,
that's the theory. :)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
