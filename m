Date: Fri, 28 Apr 2000 08:50:15 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] 2.3.99-pre6-3 VM fixed
In-Reply-To: <Pine.LNX.4.21.0004271647461.3919-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10004280832530.1834-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 27 Apr 2000, Rik van Riel wrote:
> 
> After half a day of heavy abuse, I've gotten my machine into
> a state where it's hanging in stext_lock and swap_out...
> 
> Both cpus are spinning in a very tight loop, suggesting a
> deadlock. (/me points finger at other code, I didn't change
> any locking stuff :))
> 
> This suggests a locking issue. Is there any place in the kernel
> where we take a write lock on tasklist_lock and do a lock_kernel()
> afterwards?

Note that if you have an EIP, debugging these kinds of things is usually
quite easy. You should not be discouraged at all by the fact that it is
"somewhere in stext_lock" - with the EIP it is very easy to figure out
exactly which lock it is, and which caller to the lock routine it is that
failed.

For example, if I knew that I had a lock-up, and the EIP I got was
0xc024b5f9 on my machine, I'd do:

	gdb vmlinux
	(gdb) x/5i 0xc024b5f9
	0xc024b5f9 <stext_lock+1833>:   jle    0xc024b5f0 <stext_lock+1824>
	0xc024b5fb <stext_lock+1835>:   jmp    0xc0119164 <schedule+296>
	0xc024b600 <stext_lock+1840>:   cmpb   $0x0,0xc02c46c0
	0xc024b607 <stext_lock+1847>:   repz nop 
	0xc024b609 <stext_lock+1849>:   jle    0xc024b600 <stext_lock+1840>

which tells me that yes, it seems to be in the stext_lock region, but more
than that it also tells me that the lock stuff will exit to 0xc0119164, or
in the middle of schedule. So then just disassemble that area:

	(gdb) x/5i 0xc0119164
	0xc0119164 <schedule+296>:      lock decb 0xc02c46c0
	0xc011916b <schedule+303>:      js     0xc024b5f0 <stext_lock+1824>
	0xc0119171 <schedule+309>:      mov    0xffffffc8(%ebp),%ebx
	0xc0119174 <schedule+312>:      cmpl   $0x2,0x28(%ebx)
	0xc0119178 <schedule+316>:      je     0xc0119b00 <schedule+2756>

which tells us that it's a spinlock at address 0xc02c46c0, and the
out-of-line code for the contention case starts at 0xc024b5f0 (which was
roughly where we were: the whole sequence was

	(gdb) x/4i 0xc024b5f0
	0xc024b5f0 <stext_lock+1824>:   cmpb   $0x0,0xc02c46c0
	0xc024b5f7 <stext_lock+1831>:   repz nop 
	0xc024b5f9 <stext_lock+1833>:   jle    0xc024b5f0 <stext_lock+1824>
	0xc024b5fb <stext_lock+1835>:   jmp    0xc0119164 <schedule+296>

which includes the EIP that we were found looping at.

More than that, you can then look at the spinlock (this only works for
static spinlocks, but 99% of all spinlocks are of that kind):

	(gdb) x/x 0xc02c46c0
	0xc02c46c0 <runqueue_lock>:     0x00000001

which shows us that the spinlock in question was the runqueue_lock in
thismade up example. So this told us that somebody got stuck in schedule()
waiting for the runqueue lock, and we know which lock it is that has
problems. We do NOT know how that lock came to be locked forever, but by
this time we have much better information... It is often useful to look at
where the other CPU seems to be spinning at this point, because that will
often show what lock _that_ CPU is waiting for, and that in turn often
gives the deadlock sequence at which point you go "DUH!" and fix it.

Now, this gets a bit more complex if you have semaphore trouble, because
when a semaphore blocks forever you will just find the machine idle with
processes blocked in "D" state, and it looks worse as a debugging issue
because you have so little to go on. But semaphores can very easily be
turned into "debugging semaphores" with this trivial change to __down() in
arch/i386/kernel/semaphore.c:

	-		schedule();
	+		if (!schedule_timeout(20*HZ)) BUG();

which is not actually 100% correct in the general case (having a semaphore
that sleeps for more than 20 seconds is possible in theory, but in 99.9%
of all cases it is indicative of a kernel bug and a deadlock on the
semaphore).

Now you'll get a nice Oops when the lockup happens (or rather, 20seconds
after the lockup happened), with full stack-trace etc. Again, this way you
can see exactly which semaphore and where it was that it blocked on.

(Btw - careful here. You want to make sure you only check the first oops.
Quite often you can get secondary oopses due to killing a process in the
middle of a critical region, so it's usually the first oops that tells you
the most. But sometimes the secondary oopses can give you more deadlock
information - like who was the other process involved in the deadlock if
it wasn't simply a recursive one)..

Thus endeth this lesson on debugging deadlocks. I've done it often
enough..

		Linus

PS. If the deadlock occurs with interrupts disabled, you won't get the EIP
with the "alt+scroll-lock" method, so they used to be quite horrible to
debug. These days those are the trivial cases, because the automatic irq
deadlock detector will kick in and give you a nice oops when they happen
without you having to do anything extra.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
