Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA30490
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 16:39:27 -0500
Date: Wed, 27 Jan 1999 21:38:58 GMT
Message-Id: <199901272138.VAA12114@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990127131315.19147A-100000@laser.bogus>
References: <Pine.LNX.3.96.990127123207.15486A-100000@laser.bogus>
	<Pine.LNX.3.96.990127131315.19147A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.cobaltmicro.com>, gandalf@szene.ch, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.com, djf-lists@ic.net, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 27 Jan 1999 13:15:25 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> - * Fixed a race between mmget() and mmput(): added the mm_lock spinlock in
> - * the task_struct to serialize accesses to the tsk->mm field.
> + * Fixed a race between mmget() and mmput(): added the mm_lock spinlock
> + * to serialize accesses to the tsk->mm field.

I don't buy it, because we've seen these on UP machines too.  Besides,
in all of the fork/exit/procfs code paths which look to be relevant to
the reported oopses, we already hold the global kernel lock by the time
we start fiddling with the mm references.  Adding yet another spinlock
should make no difference at all to the locking.

I think the real problem is in the new procfs code in fs/proc/array.c
calling mmget()/mmput() the way it does.  The get_mm_and_lock() function
tries to be safe, but in a couple of places we do not use it, instead
doing something like:

	get_status() {
		tsk = grab_task(pid);
		task_mem() {
			down(&mm->mmap_sem);
			/* Walk the vma tree */
			up(&mm->mmap_sem);
		}
		release_task(tsk);
	}

grab_task() includes

	if (tsk && tsk->mm && tsk->mm != &init_mm)
		mmget(tsk->mm);

and release_task does

	if (tsk != current && tsk->mm && tsk->mm != &init_mm)
		mmput(tsk->mm);

In other words, we are grabbing a task, pinning the mm_struct, blocking
for the mm semaphore and releasing the task's *current* mm_struct, which
is not necessarily the same as it was before we blocked.  In particular,
if we catch the process during a fork+exec, then it is perfectly
possible for tsk->mm to change here.

Note that this was not a problem in the original version of this patch
which just copied the task_struct in grab_task(), because that way we
would always be releasing the same mm that we grabbed.

Can anybody give a good reason why we need to block in array.c at all?
I don't see why we need the down/up(&mm->mmap_sem) code, since we should
already hold the global kernel lock and the vma tree should remain
intact while we inspect it as long as we do not drop that lock.  If we
do keep that lock intact from beginning to end then we cannot run the
risk of tsk->mm changing out from under our feet.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
