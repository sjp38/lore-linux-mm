Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA07330
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 10:06:19 -0500
Date: Thu, 28 Jan 1999 15:05:41 GMT
Message-Id: <199901281505.PAA02861@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990128001800.399A-100000@laser.bogus>
References: <199901272138.VAA12114@dax.scot.redhat.com>
	<Pine.LNX.3.96.990128001800.399A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 28 Jan 1999 02:02:38 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> I think this too. My new code made tons of sense to me and since when I
> finished all my work everything become rock solid, 

Luck!  Fwiw, I was unable to reproduce the problem at all even on 2.2.0
with your test script.

>> get_status() {
>> tsk = grab_task(pid);
>> task_mem() {
>> down(&mm->mmap_sem);

No spinlock change will fix this race (although the memcpy will).

> My reason to reinsert the memcpy() was different than your one. It's
> because sys_wait4 don't hold the kernel lock and does _only_ a
> spin_lock_irq(tasklist_lock) and then remove the process from the
> tasklist, 

OK.

> Maybe I've thought stupid/wrong things but with my whole patch applyed the
> kernel become rock solid and race-free. I'm sure of this. Otherwise I
> would have not posted so sure of myself ;).

No, because the fork/exec race is still obviously present in get_stat,
and because SMP-only synchronisation fixes cannot fix a problem seen on
UP machines.

> Can somebody tell me _exactly_ what the mmap_sem stays for? 

Any modifications or blocking lookups to the mmap structures, and all
places where we add a new page into the process page tables.  That
includes mmap operations and page faults.

> The kernel is ~always doing a down on the mmap_sem of the process
> itself.  It's _useless_ that way.  The only place the kernel is doing
> a down on another task seems ptrace.c and fs/proc/array.c, so does we
> have the mmap_sem only for handling correctly such two cases?

Not at all.  The whole point of the semaphore is to protect the shared
mm when we have multiple threads all mmaping and page faulting
independently within the same mm_struct.  That's why the semaphore is in
the mm_struct, not in the task_struct.

> And finally I reask your question: can we at any time play with the ->mm,
> mm-> vma, pgd, pmd, pte, of a process without helding any semaphore, only
> having the big kernel lock held?

Yes.  Basically, changing an existing pte needs the kernel lock.  Adding
or modifying (but not removing) a new pte or modifying the vma tree
needs the mm semaphore.  We can unmap ptes in swap_out() without the
semaphore but with only the kernel lock.  We can map new anonymous pages
without the kernel lock but with only the semaphore.  Everything else
needs both.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
