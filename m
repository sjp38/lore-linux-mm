Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA03404
	for <linux-mm@kvack.org>; Fri, 8 Jan 1999 05:53:29 -0500
Date: Fri, 8 Jan 1999 11:45:51 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107171547.397A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990108113255.202A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 1999, Linus Torvalds wrote:

> Ok, here it is.. Stable.

Yesterday after your email I tried and I been able to reproduce the
deadlock here too. It's trivial, simply alloc a shared mapping of 160Mbyte
and start dirtifying it and msync it in loop. So I applyed your patch and
the machine still deadlocked after some second. I thought "argg
update_shared_mappings is faulting noooooo"!! So I removed
updated_shared_mappings() and I tried again and it still deadlocked... I
thought "oh, cool, I still have something to fix ;)". 

So I developed this debugging code (that I post here because I guess it
could be useful also to many others) to know which was the still pending
bug:

Index: sched.c
===================================================================
RCS file: /var/cvs/linux/kernel/sched.c,v
retrieving revision 1.1.1.1.2.37
diff -u -r1.1.1.1.2.37 sched.c
--- sched.c	1999/01/07 11:57:23	1.1.1.1.2.37
+++ sched.c	1999/01/08 10:41:53
@@ -22,6 +22,10 @@
  * current-task
  */
 
+/*
+ * Debug down() code. Copyright (C) 1999  Andrea Arcangeli
+ */
+
 #include <linux/mm.h>
 #include <linux/kernel_stat.h>
 #include <linux/fdreg.h>
@@ -893,12 +897,27 @@
 	tsk->state = TASK_RUNNING;		\
 	remove_wait_queue(&sem->wait, &wait);
 
+void generate_oops (struct semaphore *sem)
+{
+	sema_init(sem, 9876);
+	wake_up(&sem->wait);
+}
+
 void __down(struct semaphore * sem)
 {
 	DOWN_VAR
+	struct timer_list timer;
+	init_timer (&timer);
+	timer.expires = jiffies + HZ*20;
+	timer.data = (unsigned long) sem;
+	timer.function = (void (*)(unsigned long)) generate_oops;
+	add_timer(&timer);
 	DOWN_HEAD(TASK_UNINTERRUPTIBLE)
 	schedule();
+	if (atomic_read(&sem->count) == 9876)
+		*(int *) 0 = 0;
 	DOWN_TAIL(TASK_UNINTERRUPTIBLE)
+	del_timer(&timer);
 }
 
 int __down_interruptible(struct semaphore * sem)


Then recompiled, rebooted, return to run the deadlocking proggy, deadlocked
again after some seconds and after 20 second I had a
nice Oops on the screen. SysRQ-K helped me to restore some functionality
in another console. Then I run dmesg | ksymoops.... and I had this:

Using `/usr/src/linux/System.map' to map addresses to symbols.

>>EIP: c0111646 <__down+b2/160>
Trace: c0111574 <generate_oops>
Trace: c0189f58 <__down_failed+8/10>
Trace: c010ef1a <do_page_fault+56/340>
Trace: c0108c0d <error_code+2d/40>
Trace: c0111646 <__down+b2/160>
Trace: c0111574 <generate_oops>
Trace: c0189f58 <__down_failed+8/10>
Trace: c011dc59 <filemap_write_page+9d/138>
Trace: c011dd59 <filemap_swapout+65/7c>
Trace: c0121864 <try_to_swap_out+118/1c4>
Trace: c0121a18 <swap_out_vma+108/164>
Trace: c0121ad4 <swap_out_process+60/88>
Trace: c0121bdb <swap_out+df/fc>
Trace: c011cbb7 <shrink_mmap+11b/138>
Trace: c0121d1a <free_user_and_cache+1e/34>
Trace: c0121d76 <try_to_free_pages+46/a4>
Trace: c0122615 <__get_free_pages+d5/220>
Trace: c0126af2 <get_hash_table+52/64>
Trace: c0127bcf <grow_buffers+3b/ec>
Trace: c0126ca8 <refill_freelist+c/34>
Trace: c0126f3a <getblk+202/228>
Trace: c013af6c <ext2_alloc_block+68/13c>
Trace: c013b5c4 <block_getblk+15c/2b0>
Trace: c013b887 <ext2_getblk+16f/20c>
Trace: c0139d2b <ext2_file_write+40b/554>
Trace: c011dcc0 <filemap_write_page+104/138>
Trace: c011e0fe <filemap_sync+256/30c>
Trace: c011e297 <msync_interval+2f/7c>
Trace: c011e3d2 <sys_msync+ee/14c>
Trace: c0108ad4 <system_call+34/40>
Code: c0111646 <__down+b2/160> 
Code: c0111646 <__down+b2/160>  c7 05 00 00 00 	movl   $0x0,0x0
Code: c011164b <__down+b7/160>  00 00 00 00 00 
Code: c0111656 <__down+c2/160>  8b 75 d8       	movl   0xffffffd8(%ebp),%esi
Code: c0111659 <__down+c5/160>  c7 06 02 00 00 	movl   $0x2,(%esi)
Code: c011165f <__down+cb/160>  31 00          	xorl   %eax,(%eax)
Code: c0111667 <__down+d3/160>  90             	nop    
Code: c0111668 <__down+d4/160>  90             	nop    
Code: c0111669 <__down+d5/160>  90             	nop    

So I looked at buffer.c ;)

Index: buffer.c
===================================================================
RCS file: /var/cvs/linux/fs/buffer.c,v
retrieving revision 1.1.1.1.2.8
diff -u -r1.1.1.1.2.8 buffer.c
--- buffer.c	1999/01/07 11:57:21	1.1.1.1.2.8
+++ linux/fs/buffer.c	1999/01/08 10:27:09
@@ -689,7 +689,7 @@
  */
 static void refill_freelist(int size)
 {
-	if (!grow_buffers(GFP_KERNEL, size)) {
+	if (!grow_buffers(GFP_BUFFER, size)) {
 		wakeup_bdflush(1);
 		current->policy |= SCHED_YIELD;
 		schedule();


and now is really stable ;))

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
