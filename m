From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.57040.245837.447659@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 21:45:04 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.BSO.4.10.9906281530400.24888-100000@funky.monkey.org>
References: <199906280148.SAA94463@google.engr.sgi.com>
	<Pine.BSO.4.10.9906281530400.24888-100000@funky.monkey.org>
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.3.96.990629092942.7614C@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 15:39:43 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> i'm already working on a patch that will allow kswapd to grab the
> mmap_sem for the task that is about to be swapped.  this takes a
> slightly different approach, since i'm focusing on kswapd and not on
> swapoff.  

Don't, it will create a whole pile of new deadlock conditions.  Think
carefully about what happens when you take a page fault, lock the mm,
and then need to allocate a new page in memory to satisfy the fault.
You end up recursively calling try_to_free_page, and if that needs to
reacquire the mm semaphore then you are in major trouble.  The same
mechanism can also block kswapd from making progress.

We've looked at this before: the reason swapout doesn't take the
semaphore is because the deadlock cases are worse than just living
with the current unlocked behaviour.  There's also the fact that
swapping can deal with multiple mms at the same time: if you fork, you
can get two mms which share the same COW page in memory or on swap.
As a result, mm locking doesn't actually buy you enough extra
protection for data pages to be worth it.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
