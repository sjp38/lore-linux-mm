From: andrea@suse.de
Date: Mon, 10 Apr 2000 10:55:32 +0200 (CEST)
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004090040.RAA49059@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004092326460.293-100000@vaio.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000, Kanoj Sarcar wrote:

>Btw, I am looking at your patch with message id
><Pine.LNX.4.21.0004081924010.317-100000@alpha.random>, that does not
>seem to be holding vmlist/pagetable lock in the swapdelete code (at
>least at first blush). That was partly why I wanted to know what fixes 
>are in your patch ...

The patch was against the earlier swapentry patch that was also fixing the
vma/pte locking in swapoff. All the three patches I posted were
incremental.

>Note: I prefer being able to hold mmap_sem in the swapdelete path, that
>will provide protection against fork/exit races too. I will try to port

With my approch swapoff is serialized w.r.t. to fork/exit the same way as
swap_out(). However I see the potential future problem in exit_mmap() that
makes the entries not reachable before swapoff starts and that does the
swap_free() after swapoff completed and after the swapdevice gone away (==
too late). That's not an issue right now though, since both swapoff and
do_exit() are holding the big kernel lock but it will become an issue
eventually. Probably exit_mmap() should unlink and unmap the vmas bit by
bit using locking to unlink and lefting them visible if they are not yet
released. That should get rid of that future race.

About grabbing the mmap semaphore in unuse_process: we don't need to do
that because we aren't changing vmas from swapoff. Swapoff only browses
and changes pagetables so it only needs the vmalist-access read-spinlock
that avoids vma to go away, and the pagtable exclusive spinlock because
we'll change the pagetables (and the latter one is implied in the
vmlist_access_lock as we know from the vmlist_access_lock implementation).

swap_out() can't grab the mmap_sem for obvious reasons, so if you only
grab the mmap_sem you'll have to rely only on the big kernel lock to avoid
swap_out() to race with your swapoff, right? It doesn't look like a right
long term solution.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
