Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA32596
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 20:12:49 -0500
Date: Thu, 28 Jan 1999 02:02:38 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <199901272138.VAA12114@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990128001800.399A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.cobaltmicro.com>, gandalf@szene.ch, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.com, djf-lists@ic.net, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 1999, Stephen C. Tweedie wrote:

> > + * Fixed a race between mmget() and mmput(): added the mm_lock spinlock
> > + * to serialize accesses to the tsk->mm field.
> 
> I don't buy it, because we've seen these on UP machines too.  Besides,

Yes the comment/credits are completly bogus. Excuse me, I was too tired to
understand this last night (and btw I thought it was not sure if it was
happening also on UP).

> in all of the fork/exit/procfs code paths which look to be relevant to
> the reported oopses, we already hold the global kernel lock by the time
> we start fiddling with the mm references.  Adding yet another spinlock
> should make no difference at all to the locking.

I think this too. My new code made tons of sense to me and since when I
finished all my work everything become rock solid, I posted the thing to
the list. I don't like lock_kernel(), but yes I noticed too that
lock_kernel() should be enough (I noticed it today, last night I had too
much lack of sleep to think more about it).

> 	get_status() {
> 		tsk = grab_task(pid);
> 		task_mem() {
> 			down(&mm->mmap_sem);

My reason to reinsert the memcpy() was different than your one. It's
because sys_wait4 don't hold the kernel lock and does _only_ a
spin_lock_irq(tasklist_lock) and then remove the process from the
tasklist, so if we don't want to read_lock(tasklist_lock)  all the time in
array.c we must do the copy of the tsk, to be sure that the task_struct we
are playing with, still exists. But holding the tasklist_lock all the time
looked not safe to me due the down() in the array.c code...

Maybe I've thought stupid/wrong things but with my whole patch applyed the
kernel become rock solid and race-free. I'm sure of this. Otherwise I
would have not posted so sure of myself ;).

Can somebody tell me _exactly_ what the mmap_sem stays for? The kernel is
~always doing a down on the mmap_sem of the process itself.  It's
_useless_ that way. The only place the kernel is doing a down on another
task seems ptrace.c and fs/proc/array.c, so does we have the mmap_sem only
for handling correctly such two cases? 

And is true as I think that doing a down(current->mm->mmap_sem) is
_useless_ if every other place on the kernel only does only the same?

And finally I reask your question: can we at any time play with the ->mm,
mm->vma, pgd, pmd, pte, of a process without helding any semaphore, only
having the big kernel lock held?

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
