Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA01585
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 14:42:22 -0500
Date: Sun, 31 Jan 1999 20:16:03 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <m1r9sbvnxi.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990131200828.1971E-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 31 Jan 1999, Eric W. Biederman wrote:

> The check may be needed if someone is decrementing the count while you are
> incrementing.   To remove the need for the check would require a lock

No. When you are incrementing it you _must_ be sure that mm->count was
just >= 1 and that it will remains >=1 while you are incrementing it.

> on the task struct.  (So a new pointer isn't written, and subsequently

No you can't lock on the task struct. Other processes won't share your
lock otherwise. If other processes doesn't share your lock the lock is
useless.

> Furthermore I am perfectly aware, the race existed in my code, and that

Which code? ;)

> it relied on fast code paths (not the best).  But since it cleared
> the interrupts I could if need be garantee on a given machine the code would
> always work.

You usually don't release a mm inside an irq (so __cli() can't help you to
avoid the race). And it's _only_ a SMP race issue. UP is safe because
do_exit() run outside irq handlers.

I hope to have understood well your email (I had some problem with my
not very good English ;). If not let me know.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
