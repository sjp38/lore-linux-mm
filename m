From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906281725.KAA72836@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
Date: Mon, 28 Jun 1999 10:25:45 -0700 (PDT)
In-Reply-To: <14199.41900.732658.354175@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 28, 99 05:32:44 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Sun, 27 Jun 1999 18:48:47 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > Linus/Andrea/Stephen,
> > This is the patch that tries to cure the swapoff races with processes
> > forking, exiting, and (readahead) swapping by faulting. 
> 
> > Basically, all these operations are synchronized by the process
> > mmap_sem. Unfortunately, swapoff has to visit all processes, during
> > which it must hold tasklist_lock, a spinlock. Hence, it can not take
> > the mmap_sem, a sleeping mutex. 
> 
> But it can atomic_inc(&mm->count) to pin the mm, drop the task lock and
> take the mm semaphore, and mmput() once it has finished.
>

Hmm, hadn't thought about that one. Of course, as soon as you drop 
the task_lock, in theory, you have to resume your search from the
beginning of the task list, since the list might have changed while
you dropped the task_lock (assume for a moment that the vm code does
not know how the task list is managed). That prevents any forward
progress by swapoff. 

I did think of other ways to maintain a hold on the process,
preventing it from forking or exitting, but my judgement was they
were going to be more heavyweight than my current solution.

> > So, the patch links up all active mm's in a list that swapoff can
> > visit
> 
> There shouldn't be need for a new data structure.  A bit of extra work
> in swapoff should be all that is needed, and that avoids adding any
> extra code at all on the hot paths.
> 
> Adding extra locks is the sort of thing other unixes do to solve
> problems like this: we don't want to fall into that trap on Linux. :)
> 

Agreed ... if you can come up with a reasonably simple and lightweight
solution without using locks.

Thanks.

Kanoj
kanoj@engr.sgi.com
> --Stephen
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
