Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA17164
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 03:17:30 -0500
Date: Fri, 29 Jan 1999 02:47:41 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.95.990128144808.956H-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990129015657.8557A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 1999, Linus Torvalds wrote:

> If you want to touch some _other_ process mm pointer, that's when it gets
> interesting. Buyer beware.

Infact this is the point. I really think you are missing something. I read
your explanation of why we only need atomic_t but it was not touching some
point I instead thought about.

Ok, I assume you are right. Please take this example: I am writing a nice
kernel module that will collect some nice stats from the kernel.

I don't have the big kernel lock held, I consider that also __exit_mm()
won't have the big kernel lock held.

To collect such stats I need to touch all mm_struct pointed by all tsk->mm
in the kernel.

How can do that without racing? (see below)

> You're missing the fact that whenever we own the mm, we know that NOBODY

Sure, once we have owned an mm with mmget() we are safe, but my __only__
point is: how can I run a mmget() being sure that I am _getting_ an mm
that is not just been deallocated from the process that was owning such mm
(and it was the _only_ onwer) that get killed in the meantime on the other
CPU? Now I am sure because __exit_mm() is running with the kernel lock
held.

Another way to tell the same: "how can I be sure that I am doing an
atomic_inc(&mm->count) on a mm->count that was just > 0, and more
important on an mm that is still allocated? "

Now everything is fine of course, because I only need to get the big
kernel lock (and for this reason atomic_t _right_now_ is not needed) but
as you pointed out, some time in the future we could kill the big kernel
lock to scale better in SMP. OK? At that time according to you we'll
_need_ (and we'll _only_ need) the mm->count atomic_t to play with the mm
of other process without risk of races. 

I return to the kernel module stat colletctor example:

To be sure that the kernel stack of the process will not go away under me
I need to held the tasklist_lock. Ok? So i'll do:

	read_lock(&tasklist_lock);
	tsk = find_task_by_pid(pid);
	if (tsk)
	{
		struct page * page = mem_map + MAP_NR(tsk);
		atomic_inc(&page->count);
	}
	read_unlock(&tasklist_lock);
	mdelay(10000000000000);

So now I can wait all time I want and nobody can free and reuse my task
struct and replace it with garbage under my eyes. OK?

Now I want to play with the tsk->mm of the tsk. OK?

I'll do:

	unlock_kernel();
	^^
	if (tsk->mm && tsk->mm != &init_mm)
	{
		mdelay(2000000000000000000);
		mmget();
	}

but between the check `tsk->mm != &init_mm' and mmget() in the other CPU
the task `tsk' could have run __exit_mm()!!! (you remeber, we don't have
the big kernel lock held in __exit_mm() anymore). So mmget() will reput
the mm->count to 1, but there won't be any kind of mm_struct there!!! We
are increasing a random kernel space doing atomic_inc(&mm->count)!!
The mm_sruct is gone away between tsk->mm != &init_mm and mmget(). 

This is the race I seen two night ago. I seen it because I seen some
report on the list that was Oopsing in kmem_cache_free() called by
mmput(). So I didn't thought two times before adding the mm_lock. Do you
see why now?  Obviously I didn't seen the lock_kernel() (or better I seen
it too late and I am been too lazy to remove the mm_lock and since it was
not harming I left it there, as an advance for the future). 

An Oops in mmput() could be explained very well by the race I am trying to
point out to you:

	task 1				task 2
	-----------			---------------
					mm->count == 1
	if (tsk->mm != &init_mm)
	{
		/* interrupt */
					__do_exit()
					{
						tsk->mm = &init_mm
						mmput(); (mm->count == 0)
					}
		mmget() (mm->count == 1 but there' isn't a mm_struct there!!!)
	}

I can't see how _only_ with the mm->count atomic_t we can avoid this
scenario (you said that in the last emails!!!!). Maybe I only need a
loooong sleep.

Excuse me if I am still here (not gone away yet) but such mmget()/mmput() 
race sound not fixable to me without using a mm_lock spinlock (I am
considering to not have the lock_kernel() in __exit_mm() of course).

Do you see the future race now? Do you see why I tell you that we can't be
race free in looking the mm of _another_ task without a spinlock if
__exit_mm() won't own the big kernel lock?

Obviously if we'll serialize mmput/mmget and the setting of the tsk->mm
using a spinlock, we won't need mm->count atomic_t (as now btw).

Do you agree with me now?

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
