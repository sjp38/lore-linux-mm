Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA08246
	for <linux-mm@kvack.org>; Sat, 23 Jan 1999 15:57:36 -0500
Date: Sat, 23 Jan 1999 21:56:20 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-final
In-Reply-To: <Pine.LNX.3.95.990120224340.23558G-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990123210422.2856A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 1999, Linus Torvalds wrote:

> In short, before you post a bug-report about 2.2.0-final, I'd like you to

There are three things from me I think should go in before 2.2.0 real
(maybe a normal user would be not too much worried by these two races, it
depends also about the definition on `normal user' ;).

The first is a fix for a potential swapout deadlock I discovered and fixed
some day ago. See my email about the topic with the patch:

On Mon, 18 Jan 1999, Andrea Arcangeli wrote:
> 
> Date: Mon, 18 Jan 1999 21:26:05 +0100 (CET)
> From: Andrea Arcangeli <andrea@e-mind.com>
> To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>,
>     "Stephen C. Tweedie" <sct@redhat.com>,
>     Linus Torvalds <torvalds@transmeta.com>
> Cc: Linux-MM List <linux-mm@kvack.org>,
>     Linux Kernel List <linux-kernel@vger.rutgers.edu>
> Subject: Re: Removing swap lockmap...
> 
> On 18 Jan 1999, Zlatko Calusic wrote:
> 
> > I removed swap lockmap all together and, to my surprise, I can't
> > produce any ill behaviour on my system, not even under very heavy
> > swapping (in low memory condition).
> 
> Looking at your patch (and so looking at the swap_lockmap code) I found a
> potential deadlock in the current swap_lockmap handling: 
> 
> 	task A				task B
> 	----------			-------------
> 	rw_swap_page_base()
> 	
> 	...if (test_and_set_bit(lockmap))
> 		... run_task_queue()
> 					swap_after_unlock_page()
> 						... clear_bit(lockmap)
> 						.... wakeup(&lock_queue)
> 		...sleep_on(&lock_queue);
> 		deadlocked
> 
> I think it will not harm too much because the window is not too big (but
> not small) and because usually one of the process not yet deadlocked will
> generate IO and will wakeup also the deadlocked process at I/O
> completation time. A very lazy ;) but at the same time obviosly right
> (that should not harm performances at all) fix could be to replace the
> sleep_on() with a sleep_on_timeout(..., 1).
> 
 * patch snipped *
> 
> I think we need the swap_lockmap in the shm case because without swap
> cache a swapin could happen at the same time of the swapout because
> find_in_swap_cache() won't work there. 
> 
> Andrea Arcangeli

Here the fix:

Index: page_io.c
===================================================================
RCS file: /var/cvs/linux/mm/page_io.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 page_io.c
--- page_io.c	1999/01/18 01:32:53	1.1.2.1
+++ linux/mm/page_io.c	1999/01/18 20:21:41
@@ -88,7 +88,7 @@
 		/* Make sure we are the only process doing I/O with this swap page. */
 		while (test_and_set_bit(offset,p->swap_lockmap)) {
 			run_task_queue(&tq_disk);
-			sleep_on(&lock_queue);
+			sleep_on_timeout(&lock_queue, 1);
 		}
 
 		/* 


----------------------------------------------------------------------

The second thing is the complete race fix for the disable/enable_bh(). 
It's obviously right. Here it is (against 2.2.0-pre8intestingforalan but
should apply clean to your tree too): 

Index: linux/include/asm-i386/softirq.h
diff -u linux/include/asm-i386/softirq.h:1.1.1.1 linux/include/asm-i386/softirq.h:1.1.2.2
--- linux/include/asm-i386/softirq.h:1.1.1.1	Mon Jan 18 02:27:17 1999
+++ linux/include/asm-i386/softirq.h	Wed Jan 20 07:41:42 1999
@@ -9,24 +9,6 @@
 #define get_active_bhs()	(bh_mask & bh_active)
 #define clear_active_bhs(x)	atomic_clear_mask((x),&bh_active)
 
-extern inline void init_bh(int nr, void (*routine)(void))
-{
-	bh_base[nr] = routine;
-	atomic_set(&bh_mask_count[nr], 0);
-	bh_mask |= 1 << nr;
-}
-
-extern inline void remove_bh(int nr)
-{
-	bh_base[nr] = NULL;
-	bh_mask &= ~(1 << nr);
-}
-
-extern inline void mark_bh(int nr)
-{
-	set_bit(nr, &bh_active);
-}
-
 #ifdef __SMP__
 
 /*
@@ -90,21 +72,49 @@
 
 #endif	/* SMP */
 
+extern inline void init_bh(int nr, void (*routine)(void))
+{
+	bh_base[nr] = routine;
+	bh_mask_count[nr] = 0;
+	wmb();
+	bh_mask |= 1 << nr;
+}
+
+extern inline void remove_bh(int nr)
+{
+	bh_mask &= ~(1 << nr);
+	synchronize_bh();
+	bh_base[nr] = NULL;
+}
+
+extern inline void mark_bh(int nr)
+{
+	set_bit(nr, &bh_active);
+}
+
 /*
  * These use a mask count to correctly handle
  * nested disable/enable calls
  */
 extern inline void disable_bh(int nr)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&bh_lock, flags);
 	bh_mask &= ~(1 << nr);
-	atomic_inc(&bh_mask_count[nr]);
+	bh_mask_count[nr]++;
+	spin_unlock_irqrestore(&bh_lock, flags);
 	synchronize_bh();
 }
 
 extern inline void enable_bh(int nr)
 {
-	if (atomic_dec_and_test(&bh_mask_count[nr]))
+	unsigned long flags;
+
+	spin_lock_irqsave(&bh_lock, flags);
+	if (!--bh_mask_count[nr])
 		bh_mask |= 1 << nr;
+	spin_unlock_irqrestore(&bh_lock, flags);
 }
 
 #endif	/* __ASM_SOFTIRQ_H */
Index: linux/include/linux/interrupt.h
diff -u linux/include/linux/interrupt.h:1.1.1.1 linux/include/linux/interrupt.h:1.1.2.1
--- linux/include/linux/interrupt.h:1.1.1.1	Mon Jan 18 02:27:09 1999
+++ linux/include/linux/interrupt.h	Mon Jan 18 02:32:58 1999
@@ -17,7 +17,8 @@
 
 extern volatile unsigned char bh_running;
 
-extern atomic_t bh_mask_count[32];
+extern spinlock_t bh_lock;
+extern int bh_mask_count[32];
 extern unsigned long bh_active;
 extern unsigned long bh_mask;
 extern void (*bh_base[32])(void);
Index: linux/kernel/softirq.c
diff -u linux/kernel/softirq.c:1.1.1.1 linux/kernel/softirq.c:1.1.2.1
--- linux/kernel/softirq.c:1.1.1.1	Mon Jan 18 02:27:00 1999
+++ linux/kernel/softirq.c	Mon Jan 18 02:32:52 1999
@@ -20,7 +20,8 @@
 
 /* intr_count died a painless death... -DaveM */
 
-atomic_t bh_mask_count[32];
+spinlock_t bh_lock = SPIN_LOCK_UNLOCKED;
+int bh_mask_count[32];
 unsigned long bh_active = 0;
 unsigned long bh_mask = 0;
 void (*bh_base[32])(void);


----------------------------------------------------------------------

The third thing I disagree is to swapout in cluster when shrink_mmap() 
fails at priority == 6 (or whatever). shrink_mmap() that fails tell
nothing about the state of the VM. We could be with 0 phys RAM but with
some freeable cache but shrink_mmap could still fail at that stage. This
has no trivial fix (I think my new nr_freeable pages balance level will
fix it though) and luckily is mostly a performances issue (even if I
think it's the cause of the VM slowdown after some day of usage).

>From a stableness point of view instead I think that the current
try_to_free_pages() algorithm is not good because we should do only _one_
(and not count-- until swapout fail)  swapout(), if nr_free_pages <
freepages.min.  This because low memory system SWAP_CLUSTER_MAX (aka 32) 
is very major than 10 (minimum of freepages.min). Here a patch: 

Index: vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 vmscan.c
--- vmscan.c	1999/01/23 18:52:32	1.1.1.3
+++ linux/mm/vmscan.c	1999/01/23 20:53:11
@@ -487,6 +487,8 @@
 		while (swap_out(priority, gfp_mask)) {
 			if (!--count)
 				goto done;
+			if (nr_free_pages < freepages.min)
+				break;
 		}
 
 		shrink_dcache_memory(priority, gfp_mask);


But NOTE, I _never_ tried this patch (nor tried compiled it), because I am
testing my VM algorithm instead of 2.2.0 ones. Maybe it will harm a bit
performances (not too much though) but looks to me strictly _needed_ to me
for low memory machines. If somebody would try out the system w and w/o
this patch after setting echo 10 >/proc/sys/vm/freepages it would be
interesting. 

------------ Busy-Linus can stop reading here (now ;) ----------------

BTW, I am running now with my new vm that take stable the number of
freeable pages. This VM works greatly here. But I had to change all
bh->b_count++ with bget(bh) and implementing bget() this way: 

extern inline unsigned int bget(struct buffer_head * bh)
{
        buffer_get(bh);
        return ++bh->b_count;
}

where buffer_get() is this:

extern inline void buffer_get(struct buffer_head *bh)
{
        struct page * page = mem_map + MAP_NR(bh->b_data);

        switch (atomic_read(&page->count))
        {
        case 1:
                atomic_inc(&page->count);
                nr_freeable_pages--;
                break;
#if 1 /* PARANOID */
        case 0:
                printk(KERN_ERR "buffer_get: page was unused!\n");
#endif
        }
}

And for b_count-- exists a bput().

Taking uptodate the file cache instead is been very easier (some line
changed and nothing more). Lukily the only b_count++ or b_count-- are in
buffer.c and in ext2fs, other fs has one or two b_count only.

Seeems to works fine and stable here but I still need to do some test
before release it. The only reason I developed nr_freeable_pages is
because I want stable numbers. And to get stable numbers under swapout
shrink_mmap retval is not enough because I could go sometime in the wrong
direction doing the wrong work.  But I can't trust the size of the cache
or of the buffers as a balance factor because they could be all busy or
all freeable... (as pointed out by Stephen).  BTW, Stephen, having b_count
== 0 (as I done) is a good approximation that the buffer is ready to be
freed? I seen in buffer.c that it should be also unlocked, unprotected and
clean to be freeable, but b_count looks like to be the most important
thing, can a driver take locked/dirty/protected for an infinite time a
buffer? 

If I rember well (not sure if we was talking about the same thing) also
Rik suggested to have a nr_freeable_pages, I don't know if the reason he
wanted it is my same one though. 

Comments from MM guys?

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
