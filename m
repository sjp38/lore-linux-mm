From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906282111.OAA54637@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
Date: Mon, 28 Jun 1999 14:11:18 -0700 (PDT)
In-Reply-To: <14199.56793.520615.700914@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 28, 99 09:40:57 pm
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
> On Mon, 28 Jun 1999 10:25:45 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> >> But it can atomic_inc(&mm->count) to pin the mm, drop the task lock and
> >> take the mm semaphore, and mmput() once it has finished.
> 
> > Hmm, hadn't thought about that one. Of course, as soon as you drop 
> > the task_lock, in theory, you have to resume your search from the
> > beginning of the task list, since the list might have changed while
> > you dropped the task_lock (assume for a moment that the vm code does
> > not know how the task list is managed). That prevents any forward
> > progress by swapoff. 
> 
> Then keep a fencepost of the highest pid you have completed so far,
> and with the lock held, look for the lowest pid greater than that
> one.  If you don't make any progress on the mm, bump up the fencepost
> pid by one.

If I understand right, here is an example. Lets say I believe I 
have scanned uptil pid 10. You are suggesting, after having scanned
pid 10, hold on to task_lock, and look for the min pid > 10. Say
that is pid 12. Problem is, while I was scanning pid 10, maybe
pid 5 got reallocated, and pid 5 is a new process (probably a 
child of pid 20). Note that I mention that it is good design for
the vm code not to assume how the task list is managed or pids
allocated (yes, I have thought of having a swapoff generation 
number stored in each task structure too ...)

> 
> It will work.  It's a little extra overhead, but it confines all of
> the cost to the swapoff path.  The pid scan isn't going to be nearly
> as expensive as the rest of the vm scanning we are already forced to
> do in swapoff.

I would love to confine the complexity in the swapoff path, except
I can't come up with a solution. In any case, I think I was not 
clear about what the cost is in my fix. It is adding 2 chain fields
in the mm structure, adding and deleting to this chain at mm alloc/free
time, and the up/down cost on the mutex. Note that the up/down cost
is minimal (one atomic inc/dec) when no swapoff is going on, since the
kernel_lock also protects the chain. The mutex only becomes contended
when there is a swapoff in progress. 

Thanks.

Kanoj
kanoj@engr.sgi.com

Ps - All this discussion does not seem to be making it on to the
linux-mm web page ...

> 
> --Stephen
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
