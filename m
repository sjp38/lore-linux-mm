Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA01589
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 14:42:28 -0500
Date: Sun, 31 Jan 1999 02:00:55 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <m1yamkv6wp.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990131015437.303F-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 30 Jan 1999, Eric W. Biederman wrote:

> I have a count incremented on the task so the task_struct won't go away.
> tsk->mm at any point in time _always_ points to a valid mm.

You must think this:

	CPU0				CPU1
	/proc				task1
	------------			----------------
	is task1->mm valid?
	answer -> yes!!
	mm = task1->mm
	IRQ14 (disk I/O completed)
	...
					__exit_mm()
					_dealloc_ task1->mm kmem_cache_free(mm)
					task1->mm = &init_mm
	...
	mm->count++
	^^^^^^^^^^^ you are writing data on random kernel space

Right now this can't happen because both /proc and __exit_mm() are
synchronized by the big kernel lock.

> 	do {	
> 		mm = tsk->mm;
> 	} while (!atomic_inc_and_test(&mm->count);

The point is that you can't increment and test a mm->count if you are not
sure that the mm exists on such piece of memory. And if you are sure that
such piece of memory exists you don't need to check it and you can only
increment it ;). Do you see my point now?

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
