Received: from mail.ccr.net (ccr@alogconduit1at.ccr.net [208.130.159.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA03541
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 16:42:10 -0500
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
References: <Pine.LNX.3.96.990130163352.4720A-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Jan 1999 14:32:06 -0600
In-Reply-To: Andrea Arcangeli's message of "Sat, 30 Jan 1999 16:42:40 +0100 (CET)"
Message-ID: <m1yamkv6wp.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On 29 Jan 1999, Eric W. Biederman wrote:
AA> unlock_kernel();
AA> ^^
AA> if (tsk->mm && tsk->mm != &init_mm)
AA> {
AA> mdelay(2000000000000000000);
AA> mmget();
AA> }
>> 
>> This would need to say.
>> mm = tsk->mm;
>> mmget(mm);
>> if (mm != &init_mm) {
>> /* xyz */
>> }

AA> This is not enough to avoid races. I supposed to _not_ have the big kernel
AA> lock held. The point is _where_ you do mmget() and so _where_ you do
AA> mm-> count++. If current!=tsk and you don't have the big kernel lock held,
AA> you can risk to do a mm->count++ on a random kernel memory because mmput()
AA> run from __exit_mm() from the tsk context in the meantime on the other
AA> CPU.

I have a count incremented on the task so the task_struct won't go away.
tsk->mm at any point in time _always_ points to a valid mm.
(A new mm is assigned before the old mm is put)/

That does appear to leave a small race in my code.  That of having a pointer
to a valid mm, which is reallocated before the count can be incremented.

Probably a piece of code like:

mm_struct *fetch_tsk_mm(task_struct *tsk)
{
	unsinged long flags;
	mm_struct *mm;
	save_flags(flags);
	cli();
	do {	
		mm = tsk->mm;
	} while (!atomic_inc_and_test(&mm->count);
	restore_flags(flags);
	return mm;
}
is needed to make sure the count goes up before the mm can be reallocated.

I'm not an expert on locks, so there may be an even cheaper way of implementing
it.


The point is that:
a) An atomic count is sufficient if you know the mm will be valid while you hold it.
b) Making sure the time you CPU spends between getting the valid mm reference
   and incrementing the count on that reference, is smaller than time it takes
   for another CPU to put another mm in the task_struct, decrement the mm count, ensure
   the caches will see the memory writes in the approrpiate order and then reallocate
   the memory.  
   Is sufficient to say the mm will be valid when the count is incremented.

AA> Tell me if I am misunderstood your email.

In part, and in part I misunderstood the problem.

As far as I can tell the race is so unlikely it should never happen in practice.
But also it is so small there should be ample room for small for a large variety of
solutions.  It is an interesting problem, and worth solving well for 2.3.

I am quite certain however that your get_mm_and_lock routine would help not
at all in this case.


Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
