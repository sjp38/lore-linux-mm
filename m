Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA14789
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 16:53:03 -0500
Date: Sat, 9 Jan 1999 13:50:14 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.95.990109134233.3478A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Savochkin Andrey Vladimirovich <saw@msu.ru>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sat, 9 Jan 1999, Linus Torvalds wrote:
> 
> The cleanest solution I can think of is actually to allow semaphores to be
> recursive. I can do that with minimal overhead (just one extra instruction
> in the non-contention case), so it's not too bad, and I've wanted to do it
> for certain other things, but it's still a nasty piece of code to mess
> around with. 
> 
> Oh, well. I don't think I have much choice.

Does anybody know semaphores by heart? I've got code that may well work,
but the race conditions for semaphores are nasty. As mentioned, this only
adds a single instruction to the common non-contended case, and I really
do believe it should be correct, but it is completely untested (so it
might not work at all), and it would be good to have somebody with some
theory go through this.. 

Basically, these simple changes should make it ok to do recursive
semaphore grabs, so

	down(&sem);
	down(&sem);
	up(&sem);
	up(&sem);

should work and leave the semaphore unlocked.

Anybody? Semaphore theory used to be really popular at Universities, so
there must be somebody who has some automated proving program somewhere..

		Linus

-----
diff -u --recursive --new-file penguin/linux/include/asm-i386/semaphore.h linux/include/asm-i386/semaphore.h
--- penguin/linux/include/asm-i386/semaphore.h	Fri Jan  1 11:56:20 1999
+++ linux/include/asm-i386/semaphore.h	Sat Jan  9 13:37:29 1999
@@ -25,12 +25,23 @@
 
 struct semaphore {
 	atomic_t count;
+	unsigned long owner;
 	int waking;
 	struct wait_queue * wait;
 };
 
-#define MUTEX ((struct semaphore) { ATOMIC_INIT(1), 0, NULL })
-#define MUTEX_LOCKED ((struct semaphore) { ATOMIC_INIT(0), 0, NULL })
+/*
+ * Because we want the non-contention case to be
+ * fast, we save the stack pointer into the "owner"
+ * field, and to get the true task pointer we have
+ * to do the bit masking. That moves the masking
+ * operation into the slow path.
+ */
+#define semaphore_owner(sem) \
+	((struct task_struct *)((2*PAGE_MASK) & (sem)->owner))
+
+#define MUTEX ((struct semaphore) { ATOMIC_INIT(1), 0, 0, NULL })
+#define MUTEX_LOCKED ((struct semaphore) { ATOMIC_INIT(0), 0, 0, NULL })
 
 asmlinkage void __down_failed(void /* special register calling convention */);
 asmlinkage int  __down_failed_interruptible(void  /* params in registers */);
@@ -64,13 +75,14 @@
 	spin_unlock_irqrestore(&semaphore_wake_lock, flags);
 }
 
-static inline int waking_non_zero(struct semaphore *sem)
+static inline int waking_non_zero(struct semaphore *sem, struct task_struct *tsk)
 {
 	unsigned long flags;
 	int ret = 0;
 
 	spin_lock_irqsave(&semaphore_wake_lock, flags);
-	if (sem->waking > 0) {
+	if (sem->waking > 0 || semaphore_owner(sem) == tsk) {
+		sem->owner = (unsigned long) tsk;
 		sem->waking--;
 		ret = 1;
 	}
@@ -91,7 +103,8 @@
 		"lock ; "
 #endif
 		"decl 0(%0)\n\t"
-		"js 2f\n"
+		"js 2f\n\t"
+		"movl %%esp,4(%0)\n"
 		"1:\n"
 		".section .text.lock,\"ax\"\n"
 		"2:\tpushl $1b\n\t"
@@ -113,6 +126,7 @@
 #endif
 		"decl 0(%1)\n\t"
 		"js 2f\n\t"
+		"movl %%esp,4(%1)\n\t"
 		"xorl %0,%0\n"
 		"1:\n"
 		".section .text.lock,\"ax\"\n"
diff -u --recursive --new-file penguin/linux/kernel/sched.c linux/kernel/sched.c
--- penguin/linux/kernel/sched.c	Mon Jan  4 23:15:49 1999
+++ linux/kernel/sched.c	Sat Jan  9 13:37:16 1999
@@ -883,7 +883,7 @@
 	 * who gets to gate through and who has to wait some more.	 \
 	 */								 \
 	for (;;) {							 \
-		if (waking_non_zero(sem))	/* are we waking up?  */ \
+		if (waking_non_zero(sem, tsk))	/* are we waking up?  */ \
 			break;			/* yes, exit loop */
 
 #define DOWN_TAIL(task_state)			\


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
