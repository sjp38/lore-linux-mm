From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.41900.732658.354175@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 17:32:44 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
In-Reply-To: <199906280148.SAA94463@google.engr.sgi.com>
References: <Pine.LNX.4.10.9906250203110.22024-100000@laser.random>
	<199906280148.SAA94463@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 27 Jun 1999 18:48:47 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Linus/Andrea/Stephen,
> This is the patch that tries to cure the swapoff races with processes
> forking, exiting, and (readahead) swapping by faulting. 

> Basically, all these operations are synchronized by the process
> mmap_sem. Unfortunately, swapoff has to visit all processes, during
> which it must hold tasklist_lock, a spinlock. Hence, it can not take
> the mmap_sem, a sleeping mutex. 

But it can atomic_inc(&mm->count) to pin the mm, drop the task lock and
take the mm semaphore, and mmput() once it has finished.

> So, the patch links up all active mm's in a list that swapoff can
> visit

There shouldn't be need for a new data structure.  A bit of extra work
in swapoff should be all that is needed, and that avoids adding any
extra code at all on the hot paths.

Adding extra locks is the sort of thing other unixes do to solve
problems like this: we don't want to fall into that trap on Linux. :)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
