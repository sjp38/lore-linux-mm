Date: Tue, 20 Aug 2002 10:55:04 -0400 (EDT)
From: Hai Huang <haih@eecs.umich.edu>
Subject: Re: active_mm and mm
In-Reply-To: <20020820101950.A2645@redhat.com>
Message-ID: <Pine.LNX.4.33.0208201031570.18993-100000@wildwood.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok, I see why we're differentiating between mm and active_mm, but is this
actually giving us a lot of benefits considering the number of context switches
that would actually take advantage of this feature is probably small
(well, it depends on the workload).  Also, is the tlb flush operation that
expensive?

-
Hai

> Hi,
>
> On Mon, Aug 19, 2002 at 10:09:50PM -0400, Hai Huang wrote:
> > In struct task_struct, what's the difference between active_mm and mm?  I
> > vaguely remembers it's used for reducing cache overhead during context
> > switch, is this right
>
> Yep.  Many context switches don't require us to switch to the mm of
> the newly running process.  All processes share exactly the same
> kernel address space, so as long as we are only accessing kernel
> memory and not per-process memory, we don't need to do the mm switch.
>
> So, for operations such as waiting on an IO event, a process might get
> woken up, check some kernel space data structures, and go back to
> sleep, all in side a system call and never touching user space.  It's
> a waste to switch to the process's mm just for that --- we'd end up
> throwing out the tlb cache of the old process for nothing.
>
> So, Linux has a "LAZY_TLB" mode which tasks such as the idle task
> (which never touch user space) all have set, and which tasks can enter
> if they are spinning in kernel space for a while.  When we switch to a
> LAZY_TLB task, we don't get a new mm, so the new task's active_mm
> is set to whatever the old task's active_mm was.  For non-LAZY_TLB
> running tasks, active_mm and mm should be the same.
>
> --Stephen
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
