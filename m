Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA00421
	for <linux-mm@kvack.org>; Sat, 30 Jan 1999 10:42:35 -0500
Date: Sat, 30 Jan 1999 16:42:40 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <m17lu6xj4e.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990130163352.4720A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 29 Jan 1999, Eric W. Biederman wrote:

> AA> 	unlock_kernel();
> AA> 	^^
> AA> 	if (tsk->mm && tsk->mm != &init_mm)
> AA> 	{
> AA> 		mdelay(2000000000000000000);
> AA> 		mmget();
> AA> 	}
> 
> This would need to say.
> 	mm = tsk->mm;
> 	mmget(mm);
> 	if (mm != &init_mm) {
> 	/* xyz */
> 	}

This is not enough to avoid races. I supposed to _not_ have the big kernel
lock held. The point is _where_ you do mmget() and so _where_ you do
mm->count++. If current!=tsk and you don't have the big kernel lock held,
you can risk to do a mm->count++ on a random kernel memory because mmput()
run from __exit_mm() from the tsk context in the meantime on the other
CPU.

When tsk == current instead you implicit know that you _can't_ race yes,
but this was _not_ the case I was complaining about. 

Tell me if I am misunderstood your email.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
