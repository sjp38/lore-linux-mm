Received: from mail.ccr.net (ccr@alogconduit1at.ccr.net [208.130.159.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA03528
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 16:42:02 -0500
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
References: <Pine.LNX.3.96.990131200828.1971E-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 31 Jan 1999 15:56:57 -0600
In-Reply-To: Andrea Arcangeli's message of "Sun, 31 Jan 1999 20:16:03 +0100 (CET)"
Message-ID: <m1btjft8ba.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On 31 Jan 1999, Eric W. Biederman wrote:
>> The check may be needed if someone is decrementing the count while you are
>> incrementing.   To remove the need for the check would require a lock

AA> No. When you are incrementing it you _must_ be sure that mm->count was
AA> just >= 1 and that it will remains >=1 while you are incrementing it.

It's possible to do without this.  Not smart terribly smart or portable, but possible.

>> on the task struct.  (So a new pointer isn't written, and subsequently

AA> No you can't lock on the task struct. Other processes won't share your
AA> lock otherwise. If other processes doesn't share your lock the lock is
AA> useless.

You must lock on the task whose mm you are incrementing, or aquire a more general lock.
What you want to keep is the valid pointer from the tsk struct, valid
until you release the count.

>> Furthermore I am perfectly aware, the race existed in my code, and that

AA> Which code? ;)

The snippet for just using the atomic count, several emails ago in this
thread.  I believe I called the sketched subroutine fetch_mm.

>> it relied on fast code paths (not the best).  But since it cleared
>> the interrupts I could if need be garantee on a given machine the code would
>> always work.

AA> You usually don't release a mm inside an irq (so __cli() can't help you to
AA> avoid the race). And it's _only_ a SMP race issue. UP is safe because
AA> do_exit() run outside irq handlers.

But cli() will allow you to have a bounded execution time on a single CPU,
so you can know that another cpu won't have time to deallocate the memory.

AA> I hope to have understood well your email (I had some problem with my
AA> not very good English ;). If not let me know.

Go back and read through the thread slowly.  The trouble seems more
to do with missed points then miscomprehension of english.

I believe my last message was quite clear, though the ones before
it may have been a little muddled.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
