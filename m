Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA22567
	for <linux-mm@kvack.org>; Fri, 29 Jan 1999 13:43:03 -0500
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
References: <Pine.LNX.3.96.990129015657.8557A-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 29 Jan 1999 08:13:05 -0600
In-Reply-To: Andrea Arcangeli's message of "Fri, 29 Jan 1999 02:47:41 +0100 (CET)"
Message-ID: <m17lu6xj4e.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On Thu, 28 Jan 1999, Linus Torvalds wrote:

>> You're missing the fact that whenever we own the mm, we know that NOBODY

AA> I return to the kernel module stat colletctor example:

AA> To be sure that the kernel stack of the process will not go away under me
AA> I need to held the tasklist_lock. Ok? So i'll do:

AA> 	read_lock(&tasklist_lock);
AA> 	tsk = find_task_by_pid(pid);
AA> 	if (tsk)
AA> 	{
AA> 		struct page * page = mem_map + MAP_NR(tsk);
AA> 		atomic_inc(&page->count);

Actually in the future we should have something increment the task count or 
similiar.  But I suppose keeping a page count should be enough.

AA> 	}
AA> 	read_unlock(&tasklist_lock);
AA> 	mdelay(10000000000000);

AA> So now I can wait all time I want and nobody can free and reuse my task
AA> struct and replace it with garbage under my eyes. OK?

AA> Now I want to play with the tsk->mm of the tsk. OK?

AA> I'll do:

AA> 	unlock_kernel();
AA> 	^^
AA> 	if (tsk->mm && tsk->mm != &init_mm)
AA> 	{
AA> 		mdelay(2000000000000000000);
AA> 		mmget();
AA> 	}

This would need to say.
	mm = tsk->mm;
	mmget(mm);
	if (mm != &init_mm) {
	/* xyz */
	}

And do_exit & exec would need to say:
     old_mm = tsk->mm;
     tsk->mm = new_mm; /* probably init_mm */
     mmput(old_mm);

There does to be a memory barier there to sychronize reads/writes of cache
data.  I forget off had what kind that needs to be.

The fix is just to never let bad sit in the tsk struct while it is valid.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
