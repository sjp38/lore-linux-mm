From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004080015.RAA04351@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Fri, 7 Apr 2000 17:15:21 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004080142340.2121-100000@alpha.random> from "Andrea Arcangeli" at Apr 08, 2000 01:54:02 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Fri, 7 Apr 2000, Kanoj Sarcar wrote:
> 
> >[..] A bigger problem might
> >be that you are violating lock orders when you grab the vmlist_lock
> >from inside code that already has tasklist_lock in readmode [..]
> 
> Conceptually it's the obviously right locking order. The mm exists in
> function of a task struct. So first grabbing the tasklist lock, finding
> the task_struct and then locking its mm before playing with it looks the
> natural ordering of things and how things should be done.
> 
> BTW, swap_out() always used the same locking order that I added to swapoff
> so if my patch is wrong, swap_out() is always been wrong as well ;).

Not sure what you mean ... swap_out never grabbed the mmap_sem/page_table_lock
before (in 2.2. too).

> 
> I had a fast look and it seems nobody is going to harm swap_out and
> swapoff but if somebody is using the inverse lock I'd much prefer to fix
> that path because the locking design of swapoff and swap_out looks the
> obviously right one to me.

Okay, give it a shot, but I think changing the places which hold
tasklist_lock might be a bigger effort. In any case, for vm activity
like swap space deletion, holding of the tasklist_lock is the worst
possible alternative, and should be done only if other alternatives
are too intrusive. I know, it has been like this for a while now ...

Oh, btw, before we start discussing this, you should run that stress
test to make sure whether a lock order violation actually exists
or not ...

Kanoj
> 
> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
