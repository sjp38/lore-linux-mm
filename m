Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA17956
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 17:10:50 -0800 (PST)
Date: Wed, 29 Jan 2003 17:27:43 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129172743.1e11d566.akpm@digeo.com>
In-Reply-To: <20030129.163034.130834202.davem@redhat.com>
References: <20030129022617.62800a6e.akpm@digeo.com>
	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	<20030129151206.269290ff.akpm@digeo.com>
	<20030129.163034.130834202.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> wrote:
>
>    From: Andrew Morton <akpm@digeo.com>
>    Date: Wed, 29 Jan 2003 15:12:06 -0800
>    
>    But that would be a separate patch.  _all_ we are doing here is fixing and
>    optimising the xtime_lock problems.  We should seek to do that with
>    "equivalent transformations".
> 
> I agree, do this and arch people can tweak later.

Stephen has already tweaked.  Hopefully Andi and David can review this
sometime:



This is an optimisation to the ia64, ia32 and x86_64 do_gettimeofday() code
above and beyond the base frlock work.

Patch from Stephen Hemminger <shemminger@osdl.org>

* Don't need to disable interrupts on ia64, x86_64 or ia32 with TSC
  getttimeofday.  Disabling interrupts is noticeably slower ~3% so
  would really like to only do it if necessary.

* Some more cleanup of frlock.h in the macro's that aren't being used yet.




 arch/i386/kernel/time.c             |    7 +++----
 arch/i386/kernel/timers/timer_pit.c |    7 +++----
 arch/ia64/kernel/time.c             |    5 ++---
 include/linux/frlock.h              |    8 ++++++--
 i386/kernel/apm.c                   |    0 
 5 files changed, 14 insertions(+), 13 deletions(-)

diff -puN arch/i386/kernel/apm.c~do_gettimeofday-speedup arch/i386/kernel/apm.c
diff -puN arch/i386/kernel/time.c~do_gettimeofday-speedup arch/i386/kernel/time.c
--- 25/arch/i386/kernel/time.c~do_gettimeofday-speedup	Wed Jan 29 16:39:41 2003
+++ 25-akpm/arch/i386/kernel/time.c	Wed Jan 29 16:39:41 2003
@@ -86,22 +86,21 @@ struct timer_opts* timer = &timer_none;
  */
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned long flags;
 	unsigned long seq;
 	unsigned long usec, sec;
 
 	do {
-		seq = fr_read_begin_irqsave(&xtime_lock, flags);
+		seq = fr_read_begin(&xtime_lock);
 
 		usec = timer->get_offset();
 		{
 			unsigned long lost = jiffies - wall_jiffies;
-			if (lost)
+			if (unlikely(lost != 0))
 				usec += lost * (1000000 / HZ);
 		}
 		sec = xtime.tv_sec;
 		usec += (xtime.tv_nsec / 1000);
-	} while (unlikely(seq != fr_read_end_irqrestore(&xtime_lock, flags)));
+	} while (unlikely(seq != fr_read_end(&xtime_lock)));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
diff -puN arch/i386/kernel/timers/timer_pit.c~do_gettimeofday-speedup arch/i386/kernel/timers/timer_pit.c
--- 25/arch/i386/kernel/timers/timer_pit.c~do_gettimeofday-speedup	Wed Jan 29 16:39:41 2003
+++ 25-akpm/arch/i386/kernel/timers/timer_pit.c	Wed Jan 29 16:39:41 2003
@@ -76,7 +76,7 @@ static void delay_pit(unsigned long loop
 static unsigned long get_offset_pit(void)
 {
 	int count;
-
+	unsigned long flags;
 	static int count_p = LATCH;    /* for the first call after boot */
 	static unsigned long jiffies_p = 0;
 
@@ -85,8 +85,7 @@ static unsigned long get_offset_pit(void
 	 */
 	unsigned long jiffies_t;
 
-	/* gets recalled with irq locally disabled */
-	spin_lock(&i8253_lock);
+	spin_lock_irqsave(&i8253_lock, flags);
 	/* timer count may underflow right here */
 	outb_p(0x00, 0x43);	/* latch the count ASAP */
 
@@ -108,7 +107,7 @@ static unsigned long get_offset_pit(void
                 count = LATCH - 1;
         }
 	
-	spin_unlock(&i8253_lock);
+	spin_unlock_irqrestore(&i8253_lock, flags);
 
 	/*
 	 * avoiding timer inconsistencies (they are rare, but they happen)...
diff -puN arch/ia64/kernel/time.c~do_gettimeofday-speedup arch/ia64/kernel/time.c
--- 25/arch/ia64/kernel/time.c~do_gettimeofday-speedup	Wed Jan 29 16:39:41 2003
+++ 25-akpm/arch/ia64/kernel/time.c	Wed Jan 29 16:39:41 2003
@@ -117,11 +117,10 @@ do_settimeofday (struct timeval *tv)
 void
 do_gettimeofday (struct timeval *tv)
 {
-	unsigned long flags;
 	unsigned long seq, usec, sec, old;
 
 	do {
-		seq = fr_read_begin_irqsave(&xtime_lock, flags);
+		seq = fr_read_begin(&xtime_lock);
 		usec = gettimeoffset();
 
 		/*
@@ -138,7 +137,7 @@ do_gettimeofday (struct timeval *tv)
 
 		sec = xtime.tv_sec;
 		usec += xtime.tv_nsec / 1000;
-	} while (seq != fr_read_end_irqrestore(&xtime_lock, flags));
+	} while (seq != fr_read_end(&xtime_lock));
 
 
 	while (usec >= 1000000) {
diff -puN include/linux/frlock.h~do_gettimeofday-speedup include/linux/frlock.h
--- 25/include/linux/frlock.h~do_gettimeofday-speedup	Wed Jan 29 16:39:41 2003
+++ 25-akpm/include/linux/frlock.h	Wed Jan 29 16:42:15 2003
@@ -64,6 +64,9 @@ static inline void fr_write_end(frlock_t
 	preempt_enable();
 }
 
+/* Lock out other writers and update the count.
+ * Acts like a normal spin_lock/unlock.
+ */
 static inline void fr_write_lock(frlock_t *rw)
 {
 	spin_lock(&rw->lock);
@@ -82,11 +85,12 @@ static inline int fr_write_trylock(frloc
 
 	if (ret) {
 		++rw->pre_sequence;
-		wmb();
+		mb();
 	}
 	return ret;
 }
 
+/* Start of read calculation -- fetch last complete writer token */
 static inline unsigned fr_read_begin(const frlock_t *rw) 
 {
 	unsigned ret = rw->post_sequence;
@@ -95,6 +99,7 @@ static inline unsigned fr_read_begin(con
 	
 }
 
+/* End of reader calculation -- fetch last writer start token */
 static inline unsigned fr_read_end(const frlock_t *rw)
 {
 	rmb();
@@ -128,4 +133,3 @@ static inline unsigned fr_read_end(const
 	})
 
 #endif /* __LINUX_FRLOCK_H */
-

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
