Subject: New version of frlock (now called seqlock)
From: Stephen Hemminger <shemminger@osdl.org>
Content-Type: multipart/mixed; boundary="=-FDAvaF2Vpnf5wZXjoFpb"
Message-Id: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 30 Jan 2003 15:30:17 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-FDAvaF2Vpnf5wZXjoFpb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is an update to the earlier frlock.

Changes:
	- name change frlock to seqlock
	- separate the locking and counter only data types
	- use one counter instead of two to keep track of changes.
	
For barriers, keep to the same basic original strategy.  One change is
to use mb() (instead of wmb()) for the counter only, since it is
possible to for some future use to make mistakes there.  Despite all
the discussion, there has been no good argument that original x86_64
code was incorrect in the way it used wmb and rmb.

Left for future work:

  * move do_gettimeofday to common code, rather than across N arch
	  and have a do_gettimeoffset for the tick offset.
  * replace vxtime_lock on x86_64 since same data now in xtime_lock

  * move data that is used for time stuff together, right now
	xtime, xtime_lock, jiffies, wall_jiffies are all spread over
	memory and in different cache lines.
 
Compiles and runs on i386, will do ia64 soon. Others, I edited based on
Andrew's last code.

--=-FDAvaF2Vpnf5wZXjoFpb
Content-Disposition: attachment; filename=xtime-seqlock-generic.diff
Content-Type: text/x-patch; name=xtime-seqlock-generic.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN -X dontdiff linux-2.5.59/include/linux/seqlock.h linux-2.5-seqlock/include/linux/seqlock.h
--- linux-2.5.59/include/linux/seqlock.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.5-seqlock/include/linux/seqlock.h	2003-01-30 14:57:05.000000000 -0800
@@ -0,0 +1,145 @@
+#ifndef __LINUX_SEQLOCK_H
+#define __LINUX_SEQLOCK_H
+/*
+ * Reader/writer consistent mechanism without starving writers. This type of
+ * lock for data where the reader wants a consitent set of information
+ * and is willing to retry if the information changes.  Readers never
+ * block but they may have to retry if a writer is in
+ * progress. Writers do not wait for readers. 
+ *
+ * This is not as cache friendly as brlock. Also, this will not work
+ * for data that contains pointers, because any writer could
+ * invalidate a pointer that a reader was following.
+ *
+ * Expected reader usage:
+ * 	do {
+ *	    seq = seq_read_begin(&foo);
+ * 	...
+ *      } while (seq_read_end(&foo, seq));
+ *
+ *
+ * Based on x86_64 vsyscall gettimeofday 
+ * by Keith Owens and Andrea Arcangeli
+ */
+
+#include <linux/config.h>
+#include <linux/spinlock.h>
+#include <linux/preempt.h>
+
+typedef struct {
+	volatile unsigned counter;
+} seqcounter_t;
+
+#define SEQ_INIT	(seqcounter_t) { 0 }
+#define seq_init(x)	do { *(x) = SEQ_INIT; } while (0)
+
+/* Update sequence count only
+ * Assumes caller is doing own mutual exclusion with other lock
+ * or semaphore.
+ */
+static inline void seq_write_begin(seqcounter_t *s)
+{
+	preempt_disable();
+	++s->counter;
+	wmb();			
+}
+
+static inline void seq_write_end(seqcounter_t *s)
+{
+	wmb();
+	s->counter++;
+	preempt_enable();
+}
+
+
+/* Start of read calculation -- fetch last complete writer token */
+static inline unsigned seq_read_begin(const seqcounter_t *s)
+{
+	unsigned ret = s->counter;
+	mb();
+	return ret;
+}
+
+/* End of read calculation -- check if sequence matches */
+static inline int seq_read_end(const seqcounter_t *s, unsigned iv)
+{
+	mb();
+	return (s->counter != iv) || (iv & 1);
+}
+
+/* Combination of spinlock for writing and sequence update for readers */
+typedef struct {
+	seqcounter_t seq;
+	spinlock_t lock;
+} seqlock_t;
+
+/*
+ * These macros triggered gcc-3.x compile-time problems.  We think these are
+ * OK now.  Be cautious.
+ */
+#define SEQ_LOCK_UNLOCKED { SEQ_INIT, SPIN_LOCK_UNLOCKED }
+#define seqlock_init(x)	do { *(x) = (seqlock_t) SEQ_LOCK_UNLOCKED; } while (0)
+
+/* Lock out other writers and update the count.
+ * Acts like a normal spin_lock/unlock.
+ * Don't need preempt_disable() because that is in the spin_lock already.
+ */
+static inline void seq_write_lock(seqlock_t *rw)
+{
+	spin_lock(&rw->lock);
+	++rw->seq.counter;
+	wmb();			
+}	
+
+static inline void seq_write_unlock(seqlock_t *rw) 
+{
+	wmb();
+	rw->seq.counter++;
+	spin_unlock(&rw->lock);
+}
+
+static inline int seq_write_trylock(seqlock_t *rw)
+{
+	int ret = spin_trylock(&rw->lock);
+
+	if (ret) {
+		++rw->seq.counter;
+		wmb();			
+	}
+	return ret;
+}
+
+/* Version of seq_read_begin/end for use with seqlock */
+#define seq_read_lock(slock)						\
+	seq_read_begin(&(slock)->seq)
+#define seq_read_unlock(slock,iv)					\
+	unlikely(seq_read_end(&(slock)->seq, iv))
+
+
+/*
+ * Possible sw/hw IRQ protected versions of the interfaces.
+ */
+#define seq_write_lock_irqsave(lock, flags)				\
+	do { local_irq_save(flags);	seq_write_lock(lock); } while (0)
+#define seq_write_lock_irq(lock)						\
+	do { local_irq_disable();	seq_write_lock(lock); } while (0)
+#define seq_write_lock_bh(lock)						\
+        do { local_bh_disable();	seq_write_lock(lock); } while (0)
+
+#define seq_write_unlock_irqrestore(lock, flags)				\
+	do { seq_write_unlock(lock); local_irq_restore(flags); } while(0)
+#define seq_write_unlock_irq(lock)					\
+	do { seq_write_unlock(lock); local_irq_enable(); } while(0)
+#define seq_write_unlock_bh(lock)					\
+	do { seq_write_unlock(lock); local_bh_enable(); } while(0)
+
+#define seq_read_lock_irqsave(lock, flags)				\
+	({ local_irq_save(flags);	seqlock_read_begin(lock); })
+
+#define seq_read_lock_irqrestore(lock, iv, flags)			\
+	unlikely({int ret = seq_read_end(&(lock)->seq, iv);		\
+		local_irq_save(flags);					\
+		ret;							\
+	})
+
+#endif /* __LINUX_SEQLOCK_H */
diff -urN -X dontdiff linux-2.5.59/include/linux/time.h linux-2.5-seqlock/include/linux/time.h
--- linux-2.5.59/include/linux/time.h	2003-01-16 18:22:20.000000000 -0800
+++ linux-2.5-seqlock/include/linux/time.h	2003-01-30 11:02:49.000000000 -0800
@@ -25,6 +25,7 @@
 #ifdef __KERNEL__
 
 #include <linux/spinlock.h>
+#include <linux/seqlock.h>
 
 /*
  * Change timeval to jiffies, trying to avoid the
@@ -120,7 +121,7 @@
 }
 
 extern struct timespec xtime;
-extern rwlock_t xtime_lock;
+extern seqlock_t xtime_lock;
 
 static inline unsigned long get_seconds(void)
 { 
diff -urN -X dontdiff linux-2.5.59/kernel/time.c linux-2.5-seqlock/kernel/time.c
--- linux-2.5.59/kernel/time.c	2003-01-16 18:21:45.000000000 -0800
+++ linux-2.5-seqlock/kernel/time.c	2003-01-30 11:29:29.000000000 -0800
@@ -27,7 +27,6 @@
 #include <linux/timex.h>
 #include <linux/errno.h>
 #include <linux/smp_lock.h>
-
 #include <asm/uaccess.h>
 
 /* 
@@ -38,7 +37,6 @@
 
 /* The xtime_lock is not only serializing the xtime read/writes but it's also
    serializing all accesses to the global NTP variables now. */
-extern rwlock_t xtime_lock;
 extern unsigned long last_time_offset;
 
 #if !defined(__alpha__) && !defined(__ia64__)
@@ -80,7 +78,7 @@
 		return -EPERM;
 	if (get_user(value, tptr))
 		return -EFAULT;
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	xtime.tv_sec = value;
 	xtime.tv_nsec = 0;
 	last_time_offset = 0;
@@ -88,7 +86,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 	return 0;
 }
 
@@ -96,13 +94,13 @@
 
 asmlinkage long sys_gettimeofday(struct timeval *tv, struct timezone *tz)
 {
-	if (tv) {
+	if (likely(tv != NULL)) {
 		struct timeval ktv;
 		do_gettimeofday(&ktv);
 		if (copy_to_user(tv, &ktv, sizeof(ktv)))
 			return -EFAULT;
 	}
-	if (tz) {
+	if (unlikely(tz != NULL)) {
 		if (copy_to_user(tz, &sys_tz, sizeof(sys_tz)))
 			return -EFAULT;
 	}
@@ -127,10 +125,10 @@
  */
 inline static void warp_clock(void)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	xtime.tv_sec += sys_tz.tz_minuteswest * 60;
 	last_time_offset = 0;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /*
@@ -235,7 +233,7 @@
 		    txc->tick > 1100000/USER_HZ)
 			return -EINVAL;
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	result = time_state;	/* mostly `TIME_OK' */
 
 	/* Save for later - semantics of adjtime is to return old value */
@@ -386,7 +384,7 @@
 	txc->errcnt	   = pps_errcnt;
 	txc->stbcnt	   = pps_stbcnt;
 	last_time_offset = 0;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 	do_gettimeofday(&txc->time);
 	return(result);
 }
@@ -409,9 +407,12 @@
 struct timespec current_kernel_time(void)
 {
         struct timespec now;
-        unsigned long flags;
-        read_lock_irqsave(&xtime_lock,flags);
-	now = xtime;
-        read_unlock_irqrestore(&xtime_lock,flags);
+        unsigned long seq;
+
+	do {
+		seq = seq_read_lock(&xtime_lock);
+		now = xtime;
+	} while (seq_read_unlock(&xtime_lock, seq));
+
 	return now; 
 }
diff -urN -X dontdiff linux-2.5.59/kernel/timer.c linux-2.5-seqlock/kernel/timer.c
--- linux-2.5.59/kernel/timer.c	2003-01-16 18:21:49.000000000 -0800
+++ linux-2.5-seqlock/kernel/timer.c	2003-01-30 11:13:22.000000000 -0800
@@ -754,11 +754,8 @@
 /* jiffies at the most recent update of wall time */
 unsigned long wall_jiffies;
 
-/*
- * This read-write spinlock protects us from races in SMP while
- * playing with xtime and avenrun.
- */
-rwlock_t xtime_lock __cacheline_aligned_in_smp = RW_LOCK_UNLOCKED;
+seqlock_t xtime_lock __cacheline_aligned_in_smp = SEQ_LOCK_UNLOCKED;
+
 unsigned long last_time_offset;
 
 /*
@@ -798,8 +795,7 @@
 }
   
 /*
- * The 64-bit jiffies value is not atomic - you MUST NOT read it
- * without holding read_lock_irq(&xtime_lock).
+ * The 64-bit jiffies value is not atomic 
  * jiffies is defined in the linker script...
  */
 
@@ -1087,18 +1083,21 @@
 	struct sysinfo val;
 	unsigned long mem_total, sav_total;
 	unsigned int mem_unit, bitcount;
+	unsigned long seq;
 
 	memset((char *)&val, 0, sizeof(struct sysinfo));
 
-	read_lock_irq(&xtime_lock);
-	val.uptime = jiffies / HZ;
+	do {
+		seq = seq_read_lock(&xtime_lock);
+
+		val.uptime = jiffies / HZ;
 
-	val.loads[0] = avenrun[0] << (SI_LOAD_SHIFT - FSHIFT);
-	val.loads[1] = avenrun[1] << (SI_LOAD_SHIFT - FSHIFT);
-	val.loads[2] = avenrun[2] << (SI_LOAD_SHIFT - FSHIFT);
+		val.loads[0] = avenrun[0] << (SI_LOAD_SHIFT - FSHIFT);
+		val.loads[1] = avenrun[1] << (SI_LOAD_SHIFT - FSHIFT);
+		val.loads[2] = avenrun[2] << (SI_LOAD_SHIFT - FSHIFT);
 
-	val.procs = nr_threads;
-	read_unlock_irq(&xtime_lock);
+		val.procs = nr_threads;
+	} while (unlikely(seq_read_unlock(&xtime_lock, seq)));
 
 	si_meminfo(&val);
 	si_swapinfo(&val);

--=-FDAvaF2Vpnf5wZXjoFpb
Content-Disposition: attachment; filename=xtime-seqlock-i386.diff
Content-Type: text/x-patch; name=xtime-seqlock-i386.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN -X dontdiff linux-2.5.59/arch/i386/kernel/apm.c linux-2.5-seqlock/arch/i386/kernel/apm.c
--- linux-2.5.59/arch/i386/kernel/apm.c	2003-01-16 18:21:37.000000000 -0800
+++ linux-2.5-seqlock/arch/i386/kernel/apm.c	2003-01-30 14:48:34.000000000 -0800
@@ -215,6 +215,7 @@
 #include <linux/miscdevice.h>
 #include <linux/apm_bios.h>
 #include <linux/init.h>
+#include <linux/time.h>
 #include <linux/sched.h>
 #include <linux/pm.h>
 #include <linux/kernel.h>
@@ -227,7 +228,6 @@
 
 #include <linux/sysrq.h>
 
-extern rwlock_t xtime_lock;
 extern spinlock_t i8253_lock;
 extern unsigned long get_cmos_time(void);
 extern void machine_real_restart(unsigned char *, int);
@@ -1250,6 +1250,7 @@
 {
 	int		err;
 	struct apm_user	*as;
+	unsigned long flags;
 
 	if (pm_send_all(PM_SUSPEND, (void *)3)) {
 		/* Vetoed */
@@ -1264,10 +1265,10 @@
 		printk(KERN_CRIT "apm: suspend was vetoed, but suspending anyway.\n");
 	}
 	/* serialize with the timer interrupt */
-	write_lock_irq(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 
 	/* protect against access to timer chip registers */
-	spin_lock(&i8253_lock);
+	spin_lock_irqsave(&i8253_lock, flags);
 
 	get_time_diff();
 	err = set_system_power_state(APM_STATE_SUSPEND);
@@ -1275,8 +1276,8 @@
 	set_time();
 	ignore_normal_resume = 1;
 
-	spin_unlock(&i8253_lock);
-	write_unlock_irq(&xtime_lock);
+	spin_unlock_irqrestore(&i8253_lock, flags);
+	seq_write_unlock(&xtime_lock);
 
 	if (err == APM_NO_ERROR)
 		err = APM_SUCCESS;
@@ -1301,10 +1302,10 @@
 	int	err;
 
 	/* serialize with the timer interrupt */
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/* If needed, notify drivers here */
 	get_time_diff();
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 
 	err = set_system_power_state(APM_STATE_STANDBY);
 	if ((err != APM_SUCCESS) && (err != APM_NO_ERROR))
@@ -1393,9 +1394,9 @@
 			ignore_bounce = 1;
 			if ((event != APM_NORMAL_RESUME)
 			    || (ignore_normal_resume == 0)) {
-				write_lock_irq(&xtime_lock);
+				seq_write_lock_irq(&xtime_lock);
 				set_time();
-				write_unlock_irq(&xtime_lock);
+				seq_write_unlock_irq(&xtime_lock);
 				pm_send_all(PM_RESUME, (void *)0);
 				queue_event(event, NULL);
 			}
@@ -1410,9 +1411,9 @@
 			break;
 
 		case APM_UPDATE_TIME:
-			write_lock_irq(&xtime_lock);
+			seq_write_lock_irq(&xtime_lock);
 			set_time();
-			write_unlock_irq(&xtime_lock);
+			seq_write_unlock_irq(&xtime_lock);
 			break;
 
 		case APM_CRITICAL_SUSPEND:
diff -urN -X dontdiff linux-2.5.59/arch/i386/kernel/time.c linux-2.5-seqlock/arch/i386/kernel/time.c
--- linux-2.5.59/arch/i386/kernel/time.c	2003-01-16 18:22:09.000000000 -0800
+++ linux-2.5-seqlock/arch/i386/kernel/time.c	2003-01-30 11:50:09.000000000 -0800
@@ -70,7 +70,6 @@
 
 unsigned long cpu_khz;	/* Detected as we calibrate the TSC */
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 
 spinlock_t rtc_lock = SPIN_LOCK_UNLOCKED;
@@ -87,19 +86,21 @@
  */
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned long flags;
+	unsigned seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = timer->get_offset();
-	{
-		unsigned long lost = jiffies - wall_jiffies;
-		if (lost)
-			usec += lost * (1000000 / HZ);
-	}
-	sec = xtime.tv_sec;
-	usec += (xtime.tv_nsec / 1000);
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock(&xtime_lock);
+
+		usec = timer->get_offset();
+		{
+			unsigned long lost = jiffies - wall_jiffies;
+			if (unlikely(lost != 0))
+				usec += lost * (1000000 / HZ);
+		}
+		sec = xtime.tv_sec;
+		usec += (xtime.tv_nsec / 1000);
+	} while (seq_read_unlock(&xtime_lock, seq));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -112,7 +113,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/*
 	 * This is revolting. We need to set "xtime" correctly. However, the
 	 * value in this location is the value at the most recent update of
@@ -133,7 +134,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /*
@@ -279,13 +280,13 @@
 	 * the irq version of write_lock because as just said we have irq
 	 * locally disabled. -arca
 	 */
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 
 	timer->mark_offset();
  
 	do_timer_interrupt(irq, NULL, regs);
 
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 
 }
 
diff -urN -X dontdiff linux-2.5.59/arch/i386/kernel/timers/timer_pit.c linux-2.5-seqlock/arch/i386/kernel/timers/timer_pit.c
--- linux-2.5.59/arch/i386/kernel/timers/timer_pit.c	2003-01-16 18:22:39.000000000 -0800
+++ linux-2.5-seqlock/arch/i386/kernel/timers/timer_pit.c	2003-01-29 15:17:08.000000000 -0800
@@ -76,7 +76,7 @@
 static unsigned long get_offset_pit(void)
 {
 	int count;
-
+	unsigned long flags;
 	static int count_p = LATCH;    /* for the first call after boot */
 	static unsigned long jiffies_p = 0;
 
@@ -85,8 +85,7 @@
 	 */
 	unsigned long jiffies_t;
 
-	/* gets recalled with irq locally disabled */
-	spin_lock(&i8253_lock);
+	spin_lock_irqsave(&i8253_lock, flags);
 	/* timer count may underflow right here */
 	outb_p(0x00, 0x43);	/* latch the count ASAP */
 
@@ -108,7 +107,7 @@
                 count = LATCH - 1;
         }
 	
-	spin_unlock(&i8253_lock);
+	spin_unlock_irqrestore(&i8253_lock, flags);
 
 	/*
 	 * avoiding timer inconsistencies (they are rare, but they happen)...

--=-FDAvaF2Vpnf5wZXjoFpb
Content-Disposition: attachment; filename=xtime-seqlock-ia64.diff
Content-Type: text/x-patch; name=xtime-seqlock-ia64.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN -X dontdiff linux-2.5.59/arch/ia64/kernel/time.c linux-2.5-seqlock/arch/ia64/kernel/time.c
--- linux-2.5.59/arch/ia64/kernel/time.c	2003-01-16 18:21:44.000000000 -0800
+++ linux-2.5-seqlock/arch/ia64/kernel/time.c	2003-01-30 12:03:10.000000000 -0800
@@ -24,7 +24,6 @@
 #include <asm/sal.h>
 #include <asm/system.h>
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 extern unsigned long last_time_offset;
 
@@ -89,7 +88,7 @@
 void
 do_settimeofday (struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	{
 		/*
 		 * This is revolting. We need to set "xtime" correctly. However, the value
@@ -112,21 +111,21 @@
 		time_maxerror = NTP_PHASE_LIMIT;
 		time_esterror = NTP_PHASE_LIMIT;
 	}
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 void
 do_gettimeofday (struct timeval *tv)
 {
-	unsigned long flags, usec, sec, old;
+	unsigned long seq, usec, sec, old;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	{
+	do {
+		seq = seq_read_lock(&xtime_lock);
 		usec = gettimeoffset();
 
 		/*
-		 * Ensure time never goes backwards, even when ITC on different CPUs are
-		 * not perfectly synchronized.
+		 * Ensure time never goes backwards, even when ITC on 
+		 * different CPUs are not perfectly synchronized.
 		 */
 		do {
 			old = last_time_offset;
@@ -138,8 +137,7 @@
 
 		sec = xtime.tv_sec;
 		usec += xtime.tv_nsec / 1000;
-	}
-	read_unlock_irqrestore(&xtime_lock, flags);
+	} while (seq_read_unlock(&xtime_lock, seq));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -182,10 +180,10 @@
 			 * another CPU. We need to avoid to SMP race by acquiring the
 			 * xtime_lock.
 			 */
-			write_lock(&xtime_lock);
+			seq_write_lock(&xtime_lock);
 			do_timer(regs);
 			local_cpu_data->itm_next = new_itm;
-			write_unlock(&xtime_lock);
+			seq_write_unlock(&xtime_lock);
 		} else
 			local_cpu_data->itm_next = new_itm;
 

--=-FDAvaF2Vpnf5wZXjoFpb
Content-Disposition: attachment; filename=xtime-seqlock-other.diff
Content-Type: text/x-patch; name=xtime-seqlock-other.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN -X dontdiff linux-2.5.59/arch/alpha/kernel/time.c linux-2.5-seqlock/arch/alpha/kernel/time.c
--- linux-2.5.59/arch/alpha/kernel/time.c	2003-01-16 18:22:13.000000000 -0800
+++ linux-2.5-seqlock/arch/alpha/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -44,6 +44,7 @@
 #include <asm/hwrpb.h>
 
 #include <linux/mc146818rtc.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 
 #include "proto.h"
@@ -51,7 +52,6 @@
 
 u64 jiffies_64;
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;	/* kernel/timer.c */
 
 static int set_rtc_mmss(unsigned long);
@@ -106,7 +106,7 @@
 		alpha_do_profile(regs->pc);
 #endif
 
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 
 	/*
 	 * Calculate how many ticks have passed since the last update,
@@ -138,7 +138,7 @@
 		state.last_rtc_update = xtime.tv_sec - (tmp ? 600 : 0);
 	}
 
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 void
@@ -410,18 +410,20 @@
 void
 do_gettimeofday(struct timeval *tv)
 {
-	unsigned long sec, usec, lost, flags;
+	unsigned long flags;
+	unsigned long sec, usec, lost, seq;
 	unsigned long delta_cycles, delta_usec, partial_tick;
 
-	read_lock_irqsave(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	delta_cycles = rpcc() - state.last_time;
-	sec = xtime.tv_sec;
-	usec = (xtime.tv_nsec / 1000);
-	partial_tick = state.partial_tick;
-	lost = jiffies - wall_jiffies;
+		delta_cycles = rpcc() - state.last_time;
+		sec = xtime.tv_sec;
+		usec = (xtime.tv_nsec / 1000);
+		partial_tick = state.partial_tick;
+		lost = jiffies - wall_jiffies;
 
-	read_unlock_irqrestore(&xtime_lock, flags);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 #ifdef CONFIG_SMP
 	/* Until and unless we figure out how to get cpu cycle counters
@@ -463,7 +465,7 @@
 	unsigned long delta_usec;
 	long sec, usec;
 	
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 
 	/* The offset that is added into time in do_gettimeofday above
 	   must be subtracted out here to keep a coherent view of the
@@ -494,7 +496,7 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 
diff -urN -X dontdiff linux-2.5.59/arch/arm/kernel/time.c linux-2.5-seqlock/arch/arm/kernel/time.c
--- linux-2.5.59/arch/arm/kernel/time.c	2003-01-16 18:22:24.000000000 -0800
+++ linux-2.5-seqlock/arch/arm/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -34,7 +34,6 @@
 
 u64 jiffies_64;
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 
 /* this needs a better home */
@@ -148,18 +147,20 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec, lost;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = gettimeoffset();
-
-	lost = jiffies - wall_jiffies;
-	if (lost)
-		usec += lost * USECS_PER_JIFFY;
-
-	sec = xtime.tv_sec;
-	usec += xtime.tv_nsec / 1000;
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		usec = gettimeoffset();
+
+		lost = jiffies - wall_jiffies;
+		if (lost)
+			usec += lost * USECS_PER_JIFFY;
+
+		sec = xtime.tv_sec;
+		usec += xtime.tv_nsec / 1000;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	/* usec may have gone up a lot: be safe */
 	while (usec >= 1000000) {
@@ -173,7 +174,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/*
 	 * This is revolting. We need to set "xtime" correctly. However, the
 	 * value in this location is the value at the most recent update of
@@ -194,7 +195,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 static struct irqaction timer_irq = {
diff -urN -X dontdiff linux-2.5.59/arch/m68k/kernel/time.c linux-2.5-seqlock/arch/m68k/kernel/time.c
--- linux-2.5.59/arch/m68k/kernel/time.c	2003-01-16 18:21:47.000000000 -0800
+++ linux-2.5-seqlock/arch/m68k/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -22,6 +22,7 @@
 #include <asm/machdep.h>
 #include <asm/io.h>
 
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/profile.h>
 
@@ -129,25 +130,27 @@
 	mach_sched_init(timer_interrupt);
 }
 
-extern rwlock_t xtime_lock;
-
 /*
  * This version of gettimeofday has near microsecond resolution.
  */
 void do_gettimeofday(struct timeval *tv)
 {
-	extern unsigned long wall_jiffies;
 	unsigned long flags;
+	extern unsigned long wall_jiffies;
+	unsigned long seq;
 	unsigned long usec, sec, lost;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = mach_gettimeoffset();
-	lost = jiffies - wall_jiffies;
-	if (lost)
-		usec += lost * (1000000/HZ);
-	sec = xtime.tv_sec;
-	usec += xtime.tv_nsec/1000;
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+
+		usec = mach_gettimeoffset();
+		lost = jiffies - wall_jiffies;
+		if (lost)
+			usec += lost * (1000000/HZ);
+		sec = xtime.tv_sec;
+		usec += xtime.tv_nsec/1000;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
+
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -162,7 +165,7 @@
 {
 	extern unsigned long wall_jiffies;
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/* This is revolting. We need to set the xtime.tv_nsec
 	 * correctly. However, the value in this location is
 	 * is value at the last tick.
@@ -183,5 +186,5 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/m68knommu/kernel/time.c linux-2.5-seqlock/arch/m68knommu/kernel/time.c
--- linux-2.5.59/arch/m68knommu/kernel/time.c	2003-01-16 18:22:22.000000000 -0800
+++ linux-2.5-seqlock/arch/m68knommu/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -18,6 +18,7 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/profile.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 
 #include <asm/machdep.h>
@@ -126,21 +127,23 @@
 	mach_sched_init(timer_interrupt);
 }
 
-extern rwlock_t xtime_lock;
-
 /*
  * This version of gettimeofday has near microsecond resolution.
  */
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = mach_gettimeoffset ? mach_gettimeoffset() : 0;
-	sec = xtime.tv_sec;
-	usec += (xtime.tv_nsec / 1000);
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+
+		usec = mach_gettimeoffset ? mach_gettimeoffset() : 0;
+		sec = xtime.tv_sec;
+		usec += (xtime.tv_nsec / 1000);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
+
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -153,7 +156,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/* This is revolting. We need to set the xtime.tv_usec
 	 * correctly. However, the value in this location is
 	 * is value at the last tick.
@@ -174,5 +177,5 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips/au1000/common/time.c linux-2.5-seqlock/arch/mips/au1000/common/time.c
--- linux-2.5.59/arch/mips/au1000/common/time.c	2003-01-16 18:22:01.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/au1000/common/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -27,6 +27,7 @@
 #include <linux/config.h>
 #include <linux/init.h>
 #include <linux/kernel_stat.h>
+#include <linux/time.h>
 #include <linux/sched.h>
 #include <linux/spinlock.h>
 
@@ -44,7 +45,6 @@
 
 static unsigned long r4k_offset; /* Amount to increment compare reg each time */
 static unsigned long r4k_cur;    /* What counter should be at next timer irq */
-extern rwlock_t xtime_lock;
 
 #define ALLINTS (IE_IRQ0 | IE_IRQ1 | IE_IRQ2 | IE_IRQ3 | IE_IRQ4 | IE_IRQ5)
 
@@ -150,10 +150,10 @@
 	set_cp0_status(ALLINTS);
 
 	/* Read time from the RTC chipset. */
-	write_lock_irqsave (&xtime_lock, flags);
+	seq_write_lock_irqsave (&xtime_lock, flags);
 	xtime.tv_sec = get_mips_time();
 	xtime.tv_usec = 0;
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 }
 
 /* This is for machines which generate the exact clock. */
@@ -229,20 +229,24 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned int flags;
+	unsigned long flags;
+	unsigned long seq;
 
-	read_lock_irqsave (&xtime_lock, flags);
-	*tv = xtime;
-	tv->tv_usec += do_fast_gettimeoffset();
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	/*
-	 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
-	 * is nonzero if the timer bottom half hasnt executed yet.
-	 */
-	if (jiffies - wall_jiffies)
-		tv->tv_usec += USECS_PER_JIFFY;
+		*tv = xtime;
+		tv->tv_usec += do_fast_gettimeoffset();
+
+		/*
+		 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
+		 * is nonzero if the timer bottom half hasnt executed yet.
+		 */
+		if (jiffies - wall_jiffies)
+			tv->tv_usec += USECS_PER_JIFFY;
+
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
-	read_unlock_irqrestore (&xtime_lock, flags);
 
 	if (tv->tv_usec >= 1000000) {
 		tv->tv_usec -= 1000000;
@@ -252,7 +256,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_usec correctly.
 	 * However, the value in this location is is value at the last tick.
@@ -272,7 +276,7 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
 
 /*
diff -urN -X dontdiff linux-2.5.59/arch/mips/baget/time.c linux-2.5-seqlock/arch/mips/baget/time.c
--- linux-2.5.59/arch/mips/baget/time.c	2003-01-16 18:21:34.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/baget/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -11,6 +11,7 @@
 #include <linux/param.h>
 #include <linux/string.h>
 #include <linux/mm.h>
+#include <linux/time.h>
 #include <linux/interrupt.h>
 #include <linux/timex.h>
 #include <linux/spinlock.h>
@@ -23,8 +24,6 @@
 
 #include <asm/baget/baget.h>
 
-extern rwlock_t xtime_lock;
-
 /* 
  *  To have precision clock, we need to fix available clock frequency
  */
@@ -79,20 +78,21 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned long flags;
+	unsigned long seq;
 
-	read_lock_irqsave (&xtime_lock, flags);
-	*tv = xtime;
-	read_unlock_irqrestore (&xtime_lock, flags);
+	do {
+		seq = seq_read_lock(&xtime_lock);
+		*tv = xtime;
+	} while (seq_read_unlock(&xtime_lock, seq));
 }
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 	xtime = *tv;
 	time_adjust = 0;		/* stop active adjtime() */
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips/dec/time.c linux-2.5-seqlock/arch/mips/dec/time.c
--- linux-2.5.59/arch/mips/dec/time.c	2003-01-16 18:22:29.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/dec/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -15,6 +15,7 @@
 #include <linux/param.h>
 #include <linux/string.h>
 #include <linux/mm.h>
+#include <linux/time.h>
 #include <linux/interrupt.h>
 #include <linux/bcd.h>
 
@@ -35,7 +36,6 @@
 extern void (*board_time_init)(struct irqaction *irq);
 
 extern volatile unsigned long wall_jiffies;
-extern rwlock_t xtime_lock;
 
 /*
  * Change this if you have some constant time drift
@@ -211,19 +211,22 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	*tv = xtime;
-	tv->tv_usec += do_gettimeoffset();
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		*tv = xtime;
+		tv->tv_usec += do_gettimeoffset();
 
-	/*
-	 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
-	 * is nonzero if the timer bottom half hasnt executed yet.
-	 */
-	if (jiffies - wall_jiffies)
-		tv->tv_usec += USECS_PER_JIFFY;
+		/*
+		 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
+		 * is nonzero if the timer bottom half hasnt executed yet.
+		 */
+		if (jiffies - wall_jiffies)
+			tv->tv_usec += USECS_PER_JIFFY;
+
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
-	read_unlock_irqrestore(&xtime_lock, flags);
 
 	if (tv->tv_usec >= 1000000) {
 		tv->tv_usec -= 1000000;
@@ -233,7 +236,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_usec
 	 * correctly. However, the value in this location is
@@ -254,7 +257,7 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /*
@@ -330,6 +333,7 @@
 timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	volatile unsigned char dummy;
+	unsigned long seq;
 
 	dummy = CMOS_READ(RTC_REG_C);	/* ACK RTC Interrupt */
 
@@ -357,23 +361,27 @@
 	 * CMOS clock accordingly every ~11 minutes. Set_rtc_mmss() has to be
 	 * called as close as possible to 500 ms before the new second starts.
 	 */
-	read_lock(&xtime_lock);
-	if ((time_status & STA_UNSYNC) == 0
-	    && xtime.tv_sec > last_rtc_update + 660
-	    && xtime.tv_usec >= 500000 - tick / 2
-	    && xtime.tv_usec <= 500000 + tick / 2) {
-		if (set_rtc_mmss(xtime.tv_sec) == 0)
-			last_rtc_update = xtime.tv_sec;
-		else
-			/* do it again in 60 s */
-			last_rtc_update = xtime.tv_sec - 600;
-	}
+	do {
+		seq = seq_read_lock(&xtime_lock);
+
+		if ((time_status & STA_UNSYNC) == 0
+		    && xtime.tv_sec > last_rtc_update + 660
+		    && xtime.tv_usec >= 500000 - tick / 2
+		    && xtime.tv_usec <= 500000 + tick / 2) {
+			if (set_rtc_mmss(xtime.tv_sec) == 0)
+				last_rtc_update = xtime.tv_sec;
+			else
+				/* do it again in 60 s */
+				last_rtc_update = xtime.tv_sec - 600;
+		}
+	} while (seq_read_unlock(&xtime_lock, seq));
+
 	/* As we return to user mode fire off the other CPU schedulers.. this is
 	   basically because we don't yet share IRQ's around. This message is
 	   rigged to be safe on the 386 - basically it's a hack, so don't look
 	   closely for now.. */
 	/*smp_message_pass(MSG_ALL_BUT_SELF, MSG_RESCHEDULE, 0L, 0); */
-	read_unlock(&xtime_lock);
+
 }
 
 static void r4k_timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
@@ -470,10 +478,10 @@
 	real_year = CMOS_READ(RTC_DEC_YEAR);
 	year += real_year - 72 + 2000;
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	xtime.tv_sec = mktime(year, mon, day, hour, min, sec);
 	xtime.tv_usec = 0;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 
 	if (mips_cpu.options & MIPS_CPU_COUNTER) {
 		write_32bit_cp0_register(CP0_COUNT, 0);
diff -urN -X dontdiff linux-2.5.59/arch/mips/ite-boards/generic/time.c linux-2.5-seqlock/arch/mips/ite-boards/generic/time.c
--- linux-2.5.59/arch/mips/ite-boards/generic/time.c	2003-01-16 18:22:04.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/ite-boards/generic/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -27,6 +27,7 @@
 #include <linux/init.h>
 #include <linux/kernel_stat.h>
 #include <linux/sched.h>
+#include <linux/time.h>
 #include <linux/spinlock.h>
 
 #include <asm/mipsregs.h>
@@ -38,7 +39,6 @@
 
 extern void enable_cpu_timer(void);
 extern volatile unsigned long wall_jiffies;
-extern rwlock_t xtime_lock;
 
 unsigned long missed_heart_beats = 0;
 static long last_rtc_update = 0;
@@ -119,6 +119,8 @@
  */
 void mips_timer_interrupt(struct pt_regs *regs)
 {
+	unsigned long seq;
+
 	if (r4k_offset == 0)
 		goto null;
 
@@ -133,18 +135,22 @@
  		 * within 500ms before the * next second starts, 
  		 * thus the following code.
  		 */
-		read_lock(&xtime_lock);
-		if ((time_status & STA_UNSYNC) == 0 
-		    && xtime.tv_sec > last_rtc_update + 660 
-		    && xtime.tv_usec >= 500000 - (tick >> 1) 
-		    && xtime.tv_usec <= 500000 + (tick >> 1))
-			if (set_rtc_mmss(xtime.tv_sec) == 0)
-				last_rtc_update = xtime.tv_sec;
-			else {
-				/* do it again in 60 s */
-	    			last_rtc_update = xtime.tv_sec - 600; 
-			}
-		read_unlock(&xtime_lock);
+		do {
+			seq = seq_read_lock(&xtime_lock);
+
+
+			if ((time_status & STA_UNSYNC) == 0 
+			    && xtime.tv_sec > last_rtc_update + 660 
+			    && xtime.tv_usec >= 500000 - (tick >> 1) 
+			    && xtime.tv_usec <= 500000 + (tick >> 1))
+				if (set_rtc_mmss(xtime.tv_sec) == 0)
+					last_rtc_update = xtime.tv_sec;
+				else {
+					/* do it again in 60 s */
+					last_rtc_update = xtime.tv_sec - 600; 
+				}
+			
+		} while (seq_read_unlock(&xtime_lock, seq));
 
 		r4k_cur += r4k_offset;
 		ack_r4ktimer(r4k_cur);
@@ -247,10 +253,10 @@
 	enable_cpu_timer();
 
 	/* Read time from the RTC chipset. */
-	write_lock_irqsave (&xtime_lock, flags);
+	seq_write_lock_irqsave (&xtime_lock, flags);
 	xtime.tv_sec = get_mips_time();
 	xtime.tv_usec = 0;
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 }
 
 /* This is for machines which generate the exact clock. */
@@ -332,20 +338,24 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned int flags;
+	unsigned long flags;
+	unsigned int seq;
 
-	read_lock_irqsave (&xtime_lock, flags);
-	*tv = xtime;
-	tv->tv_usec += do_fast_gettimeoffset();
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	/*
-	 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
-	 * is nonzero if the timer bottom half hasnt executed yet.
-	 */
-	if (jiffies - wall_jiffies)
-		tv->tv_usec += USECS_PER_JIFFY;
+		*tv = xtime;
+		tv->tv_usec += do_fast_gettimeoffset();
+
+		/*
+		 * xtime is atomically updated in timer_bh. 
+		 * jiffies - wall_jiffies
+		 * is nonzero if the timer bottom half hasnt executed yet.
+		 */
+		if (jiffies - wall_jiffies)
+			tv->tv_usec += USECS_PER_JIFFY;
 
-	read_unlock_irqrestore (&xtime_lock, flags);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	if (tv->tv_usec >= 1000000) {
 		tv->tv_usec -= 1000000;
@@ -355,7 +365,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_usec correctly.
 	 * However, the value in this location is is value at the last tick.
@@ -375,5 +385,5 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips/kernel/sysirix.c linux-2.5-seqlock/arch/mips/kernel/sysirix.c
--- linux-2.5.59/arch/mips/kernel/sysirix.c	2003-01-16 18:22:43.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/kernel/sysirix.c	2003-01-30 14:48:34.000000000 -0800
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/errno.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/times.h>
 #include <linux/elf.h>
@@ -615,19 +616,17 @@
 	return current->gid;
 }
 
-extern rwlock_t xtime_lock;
-
 asmlinkage int irix_stime(int value)
 {
 	if (!capable(CAP_SYS_TIME))
 		return -EPERM;
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	xtime.tv_sec = value;
 	xtime.tv_usec = 0;
 	time_maxerror = MAXPHASE;
 	time_esterror = MAXPHASE;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 
 	return 0;
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips/kernel/time.c linux-2.5-seqlock/arch/mips/kernel/time.c
--- linux-2.5.59/arch/mips/kernel/time.c	2003-01-16 18:22:05.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -37,7 +37,6 @@
 /*
  * forward reference
  */
-extern rwlock_t xtime_lock;
 extern volatile unsigned long wall_jiffies;
 
 /*
@@ -63,19 +62,23 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 
-	read_lock_irqsave (&xtime_lock, flags);
-	*tv = xtime;
-	tv->tv_usec += do_gettimeoffset();
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	/*
-	 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
-	 * is nonzero if the timer bottom half hasnt executed yet.
-	 */
-	if (jiffies - wall_jiffies)
-		tv->tv_usec += USECS_PER_JIFFY;
+		*tv = xtime;
+		tv->tv_usec += do_gettimeoffset();
+
+		/*
+		 * xtime is atomically updated in timer_bh. 
+		 * jiffies - wall_jiffies
+		 * is nonzero if the timer bottom half hasnt executed yet.
+		 */
+		if (jiffies - wall_jiffies)
+			tv->tv_usec += USECS_PER_JIFFY;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
-	read_unlock_irqrestore (&xtime_lock, flags);
 
 	if (tv->tv_usec >= 1000000) {
 		tv->tv_usec -= 1000000;
@@ -85,7 +88,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_usec
 	 * correctly. However, the value in this location is
@@ -105,7 +108,7 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
 
 
@@ -291,6 +294,8 @@
  */
 void timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
+	unsigned long seq;
+
 	if (mips_cpu.options & MIPS_CPU_COUNTER) {
 		unsigned int count;
 
@@ -340,19 +345,21 @@
 	 * CMOS clock accordingly every ~11 minutes. rtc_set_time() has to be
 	 * called as close as possible to 500 ms before the new second starts.
 	 */
-	read_lock (&xtime_lock);
-	if ((time_status & STA_UNSYNC) == 0 &&
-	    xtime.tv_sec > last_rtc_update + 660 &&
-	    xtime.tv_usec >= 500000 - ((unsigned) tick) / 2 &&
-	    xtime.tv_usec <= 500000 + ((unsigned) tick) / 2) {
-		if (rtc_set_time(xtime.tv_sec) == 0) {
-			last_rtc_update = xtime.tv_sec;
-		} else {
-			last_rtc_update = xtime.tv_sec - 600; 
-			/* do it again in 60 s */
+	do {
+		seq = seq_read_lock(&xtime_lock);
+	
+		if ((time_status & STA_UNSYNC) == 0 &&
+		    xtime.tv_sec > last_rtc_update + 660 &&
+		    xtime.tv_usec >= 500000 - ((unsigned) tick) / 2 &&
+		    xtime.tv_usec <= 500000 + ((unsigned) tick) / 2) {
+			if (rtc_set_time(xtime.tv_sec) == 0) {
+				last_rtc_update = xtime.tv_sec;
+			} else {
+				last_rtc_update = xtime.tv_sec - 600; 
+				/* do it again in 60 s */
+			}
 		}
-	}
-	read_unlock (&xtime_lock);
+	} while (seq_read_unlock(&xtime_lock, seq));
 
 	/*
 	 * If jiffies has overflowed in this timer_interrupt we must
diff -urN -X dontdiff linux-2.5.59/arch/mips/mips-boards/generic/time.c linux-2.5-seqlock/arch/mips/mips-boards/generic/time.c
--- linux-2.5.59/arch/mips/mips-boards/generic/time.c	2003-01-16 18:22:22.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/mips-boards/generic/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -34,6 +34,7 @@
 #include <asm/div64.h>
 
 #include <linux/mc146818rtc.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 
 #include <asm/mips-boards/generic.h>
@@ -45,7 +46,6 @@
 
 static unsigned long r4k_offset; /* Amount to increment compare reg each time */
 static unsigned long r4k_cur;    /* What counter should be at next timer irq */
-extern rwlock_t xtime_lock;
 
 #define ALLINTS (IE_IRQ0 | IE_IRQ1 | IE_IRQ2 | IE_IRQ3 | IE_IRQ4 | IE_IRQ5)
 
@@ -133,7 +133,9 @@
  */
 void mips_timer_interrupt(struct pt_regs *regs)
 {
+	unsigned long flags;
 	int irq = 7;
+	unsigned long seq;
 
 	if (r4k_offset == 0)
 		goto null;
@@ -149,18 +151,21 @@
  		 * within 500ms before the * next second starts, 
  		 * thus the following code.
  		 */
-		read_lock(&xtime_lock);
-		if ((time_status & STA_UNSYNC) == 0 
-		    && xtime.tv_sec > last_rtc_update + 660 
-		    && xtime.tv_usec >= 500000 - (tick >> 1) 
-		    && xtime.tv_usec <= 500000 + (tick >> 1))
-			if (set_rtc_mmss(xtime.tv_sec) == 0)
-				last_rtc_update = xtime.tv_sec;
-			else
-				/* do it again in 60 s */
-	    			last_rtc_update = xtime.tv_sec - 600; 
-		read_unlock(&xtime_lock);
 
+		do {
+			seq = seq_read_lock_irqsave(&xtime_lock, flags);
+
+			if ((time_status & STA_UNSYNC) == 0 
+			    && xtime.tv_sec > last_rtc_update + 660 
+			    && xtime.tv_usec >= 500000 - (tick >> 1) 
+			    && xtime.tv_usec <= 500000 + (tick >> 1))
+				if (set_rtc_mmss(xtime.tv_sec) == 0)
+					last_rtc_update = xtime.tv_sec;
+				else
+					/* do it again in 60 s */
+					last_rtc_update = xtime.tv_sec - 600; 
+		} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
+		
 		if ((timer_tick_count++ % HZ) == 0) {
 		    mips_display_message(&display_string[display_count++]);
 		    if (display_count == MAX_DISPLAY_COUNT)
@@ -267,10 +272,10 @@
 	change_cp0_status(ST0_IM, ALLINTS);
 
 	/* Read time from the RTC chipset. */
-	write_lock_irqsave (&xtime_lock, flags);
+	seq_write_lock_irqsave (&xtime_lock, flags);
 	xtime.tv_sec = get_mips_time();
 	xtime.tv_usec = 0;
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 }
 
 /* This is for machines which generate the exact clock. */
@@ -363,20 +368,24 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned int flags;
+	unsigned long flags;
+	unsigned long seq;
+
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	read_lock_irqsave (&xtime_lock, flags);
-	*tv = xtime;
-	tv->tv_usec += do_fast_gettimeoffset();
+		*tv = xtime;
+		tv->tv_usec += do_fast_gettimeoffset();
 
-	/*
-	 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
-	 * is nonzero if the timer bottom half hasnt executed yet.
-	 */
-	if (jiffies - wall_jiffies)
-		tv->tv_usec += USECS_PER_JIFFY;
+		/*
+		 * xtime is atomically updated in timer_bh. 
+		 * jiffies - wall_jiffies
+		 * is nonzero if the timer bottom half hasnt executed yet.
+		 */
+		if (jiffies - wall_jiffies)
+			tv->tv_usec += USECS_PER_JIFFY;
 
-	read_unlock_irqrestore (&xtime_lock, flags);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	if (tv->tv_usec >= 1000000) {
 		tv->tv_usec -= 1000000;
@@ -386,7 +395,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_usec correctly.
 	 * However, the value in this location is is value at the last tick.
@@ -406,5 +415,5 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips/philips/nino/time.c linux-2.5-seqlock/arch/mips/philips/nino/time.c
--- linux-2.5.59/arch/mips/philips/nino/time.c	2003-01-16 18:21:34.000000000 -0800
+++ linux-2.5-seqlock/arch/mips/philips/nino/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -19,12 +19,12 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/delay.h>
 #include <asm/tx3912.h>
 
 extern volatile unsigned long wall_jiffies;
-extern rwlock_t xtime_lock;
 
 static struct timeval xbase;
 
@@ -62,29 +62,31 @@
 void do_gettimeofday(struct timeval *tv)
 {
     unsigned long flags;
+    unsigned long seq;
     unsigned long high, low;
 
-    read_lock_irqsave(&xtime_lock, flags);
-    // 40 bit RTC, driven by 32khz source:
-    // +-----------+-----------------------------------------+
-    // | HHHH.HHHH | LLLL.LLLL.LLLL.LLLL.LMMM.MMMM.MMMM.MMMM |
-    // +-----------+-----------------------------------------+
-    readRTC(&high,&low);
-    tv->tv_sec  = (high << 17) | (low >> 15);
-    tv->tv_usec = (low % 32768) * 1953 / 64;
-    tv->tv_sec += xbase.tv_sec;
-    tv->tv_usec += xbase.tv_usec;
+    do {
+	    seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-    tv->tv_usec += do_gettimeoffset();
+	    // 40 bit RTC, driven by 32khz source:
+	    // +-----------+-----------------------------------------+
+	    // | HHHH.HHHH | LLLL.LLLL.LLLL.LLLL.LMMM.MMMM.MMMM.MMMM |
+	    // +-----------+-----------------------------------------+
+	    readRTC(&high,&low);
+	    tv->tv_sec  = (high << 17) | (low >> 15);
+	    tv->tv_usec = (low % 32768) * 1953 / 64;
+	    tv->tv_sec += xbase.tv_sec;
+	    tv->tv_usec += xbase.tv_usec;
 
-    /*
-     * xtime is atomically updated in timer_bh. lost_ticks is
-     * nonzero if the timer bottom half hasnt executed yet.
-     */
-    if (jiffies - wall_jiffies)
-	tv->tv_usec += USECS_PER_JIFFY;
+	    tv->tv_usec += do_gettimeoffset();
 
-    read_unlock_irqrestore(&xtime_lock, flags);
+	    /*
+	     * xtime is atomically updated in timer_bh. lost_ticks is
+	     * nonzero if the timer bottom half hasnt executed yet.
+	     */
+	    if (jiffies - wall_jiffies)
+		    tv->tv_usec += USECS_PER_JIFFY;
+    } while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
     if (tv->tv_usec >= 1000000) {
 	tv->tv_usec -= 1000000;
@@ -94,7 +96,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-    write_lock_irq(&xtime_lock);
+    seq_write_lock_irq(&xtime_lock);
     /* This is revolting. We need to set the xtime.tv_usec
      * correctly. However, the value in this location is
      * is value at the last tick.
@@ -118,7 +120,7 @@
     time_state = TIME_BAD;
     time_maxerror = MAXPHASE;
     time_esterror = MAXPHASE;
-    write_unlock_irq(&xtime_lock);
+    seq_write_unlock_irq(&xtime_lock);
 }
 
 static int set_rtc_mmss(unsigned long nowtime)
diff -urN -X dontdiff linux-2.5.59/arch/mips64/mips-boards/generic/time.c linux-2.5-seqlock/arch/mips64/mips-boards/generic/time.c
--- linux-2.5.59/arch/mips64/mips-boards/generic/time.c	2003-01-16 18:21:43.000000000 -0800
+++ linux-2.5-seqlock/arch/mips64/mips-boards/generic/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -27,6 +27,7 @@
 #include <linux/init.h>
 #include <linux/kernel_stat.h>
 #include <linux/sched.h>
+#include <linux/time.h>
 #include <linux/spinlock.h>
 
 #include <asm/mipsregs.h>
@@ -44,7 +45,6 @@
 
 static unsigned long r4k_offset; /* Amount to increment compare reg each time */
 static unsigned long r4k_cur;    /* What counter should be at next timer irq */
-extern rwlock_t xtime_lock;
 
 #define ALLINTS (IE_IRQ0 | IE_IRQ1 | IE_IRQ2 | IE_IRQ3 | IE_IRQ4 | IE_IRQ5)
 
@@ -132,6 +132,8 @@
  */
 void mips_timer_interrupt(struct pt_regs *regs)
 {
+	unsigned long flags;
+	unsigned long seq;
 	int irq = 7;
 
 	if (r4k_offset == 0)
@@ -148,17 +150,20 @@
  		 * within 500ms before the * next second starts, 
  		 * thus the following code.
  		 */
-		read_lock(&xtime_lock);
-		if ((time_status & STA_UNSYNC) == 0 
-		    && xtime.tv_sec > last_rtc_update + 660 
-		    && xtime.tv_usec >= 500000 - (tick >> 1) 
-		    && xtime.tv_usec <= 500000 + (tick >> 1))
-			if (set_rtc_mmss(xtime.tv_sec) == 0)
-				last_rtc_update = xtime.tv_sec;
-			else
-				/* do it again in 60 s */
-	    			last_rtc_update = xtime.tv_sec - 600; 
-		read_unlock(&xtime_lock);
+		do {
+			seq = seq_read_lock_irqsave(&xtime_lock, flags);
+			
+			if ((time_status & STA_UNSYNC) == 0 
+			    && xtime.tv_sec > last_rtc_update + 660 
+			    && xtime.tv_usec >= 500000 - (tick >> 1) 
+			    && xtime.tv_usec <= 500000 + (tick >> 1))
+				if (set_rtc_mmss(xtime.tv_sec) == 0)
+					last_rtc_update = xtime.tv_sec;
+				else
+					/* do it again in 60 s */
+					last_rtc_update = xtime.tv_sec - 600; 
+		} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
+
 
 		if ((timer_tick_count++ % HZ) == 0) {
 		    mips_display_message(&display_string[display_count++]);
@@ -266,10 +271,10 @@
 	set_cp0_status(ST0_IM, ALLINTS);
 
 	/* Read time from the RTC chipset. */
-	write_lock_irqsave (&xtime_lock, flags);
+	seq_write_lock_irqsave (&xtime_lock, flags);
 	xtime.tv_sec = get_mips_time();
 	xtime.tv_usec = 0;
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 }
 
 /* This is for machines which generate the exact clock. */
@@ -352,20 +357,25 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned int flags;
+	unsigned long flags;
+	unsigned long seq;
 
-	read_lock_irqsave (&xtime_lock, flags);
-	*tv = xtime;
-	tv->tv_usec += do_fast_gettimeoffset();
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	/*
-	 * xtime is atomically updated in timer_bh. jiffies - wall_jiffies
-	 * is nonzero if the timer bottom half hasnt executed yet.
-	 */
-	if (jiffies - wall_jiffies)
-		tv->tv_usec += USECS_PER_JIFFY;
+		*tv = xtime;
+		tv->tv_usec += do_fast_gettimeoffset();
+
+		/*
+		 * xtime is atomically updated in timer_bh. 
+		 * jiffies - wall_jiffies
+		 * is nonzero if the timer bottom half hasnt executed yet.
+		 */
+		if (jiffies - wall_jiffies)
+			tv->tv_usec += USECS_PER_JIFFY;
+
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
-	read_unlock_irqrestore (&xtime_lock, flags);
 
 	if (tv->tv_usec >= 1000000) {
 		tv->tv_usec -= 1000000;
@@ -375,7 +385,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_usec correctly.
 	 * However, the value in this location is is value at the last tick.
@@ -395,5 +405,5 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips64/sgi-ip22/ip22-timer.c linux-2.5-seqlock/arch/mips64/sgi-ip22/ip22-timer.c
--- linux-2.5.59/arch/mips64/sgi-ip22/ip22-timer.c	2003-01-16 18:22:13.000000000 -0800
+++ linux-2.5-seqlock/arch/mips64/sgi-ip22/ip22-timer.c	2003-01-30 14:48:34.000000000 -0800
@@ -11,6 +11,7 @@
 #include <linux/param.h>
 #include <linux/string.h>
 #include <linux/mm.h>
+#include <linux/time.h>
 #include <linux/interrupt.h>
 #include <linux/timex.h>
 #include <linux/kernel_stat.h>
@@ -32,8 +33,6 @@
 static unsigned long r4k_offset; /* Amount to increment compare reg each time */
 static unsigned long r4k_cur;    /* What counter should be at next timer irq */
 
-extern rwlock_t xtime_lock;
-
 static inline void ack_r4ktimer(unsigned long newval)
 {
 	write_32bit_cp0_register(CP0_COMPARE, newval);
@@ -86,7 +85,7 @@
 	unsigned long count;
 	int irq = 7;
 
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 	/* Ack timer and compute new compare. */
 	count = read_32bit_cp0_register(CP0_COUNT);
 	/* This has races.  */
@@ -116,7 +115,7 @@
 			/* do it again in 60s  */
 			last_rtc_update = xtime.tv_sec - 600;
 	}
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 static unsigned long dosample(volatile unsigned char *tcwp,
@@ -224,10 +223,10 @@
 	set_cp0_status(ST0_IM, ALLINTS);
 	sti();
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	xtime.tv_sec = get_indy_time();		/* Read time from RTC. */
 	xtime.tv_usec = 0;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 void indy_8254timer_irq(void)
@@ -243,20 +242,21 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned long flags;
+	unsigned long seq;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	*tv = xtime;
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock(&xtime_lock);
+		*tv = xtime;
+	} while (seq_read_unlock(&xtime_lock, seq));
 }
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	xtime = *tv;
 	time_adjust = 0;		/* stop active adjtime() */
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
diff -urN -X dontdiff linux-2.5.59/arch/mips64/sgi-ip27/ip27-timer.c linux-2.5-seqlock/arch/mips64/sgi-ip27/ip27-timer.c
--- linux-2.5.59/arch/mips64/sgi-ip27/ip27-timer.c	2003-01-16 18:22:02.000000000 -0800
+++ linux-2.5-seqlock/arch/mips64/sgi-ip27/ip27-timer.c	2003-01-30 14:48:34.000000000 -0800
@@ -9,6 +9,7 @@
 #include <linux/interrupt.h>
 #include <linux/kernel_stat.h>
 #include <linux/param.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/mm.h>		
 #include <linux/bcd.h>		
@@ -40,7 +41,6 @@
 static unsigned long ct_cur[NR_CPUS];	/* What counter should be at next timer irq */
 static long last_rtc_update;		/* Last time the rtc clock got updated */
 
-extern rwlock_t xtime_lock;
 extern volatile unsigned long wall_jiffies;
 
 
@@ -94,7 +94,7 @@
 	int cpuA = ((cputoslice(cpu)) == 0);
 	int irq = 7;				/* XXX Assign number */
 
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 
 again:
 	LOCAL_HUB_S(cpuA ? PI_RT_PEND_A : PI_RT_PEND_B, 0);	/* Ack  */
@@ -145,7 +145,7 @@
 		}
         }
 
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 
 	if (softirq_pending(cpu))
 		do_softirq();
@@ -162,17 +162,20 @@
 {
 	unsigned long flags;
 	unsigned long usec, sec;
+	unsigned long seq;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = do_gettimeoffset();
-	{
-		unsigned long lost = jiffies - wall_jiffies;
-		if (lost)
-			usec += lost * (1000000 / HZ);
-	}
-	sec = xtime.tv_sec;
-	usec += xtime.tv_usec;
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+
+		usec = do_gettimeoffset();
+		{
+			unsigned long lost = jiffies - wall_jiffies;
+			if (lost)
+				usec += lost * (1000000 / HZ);
+		}
+		sec = xtime.tv_sec;
+		usec += xtime.tv_usec;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -185,7 +188,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	tv->tv_usec -= do_gettimeoffset();
 	tv->tv_usec -= (jiffies - wall_jiffies) * (1000000 / HZ);
 
@@ -199,7 +202,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /* Includes for ioc3_init().  */
diff -urN -X dontdiff linux-2.5.59/arch/parisc/kernel/sys_parisc32.c linux-2.5-seqlock/arch/parisc/kernel/sys_parisc32.c
--- linux-2.5.59/arch/parisc/kernel/sys_parisc32.c	2003-01-16 18:22:00.000000000 -0800
+++ linux-2.5-seqlock/arch/parisc/kernel/sys_parisc32.c	2003-01-30 14:20:31.000000000 -0800
@@ -20,6 +20,7 @@
 #include <linux/resource.h>
 #include <linux/times.h>
 #include <linux/utsname.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
@@ -2427,23 +2428,26 @@
 
 asmlinkage int sys32_sysinfo(struct sysinfo32 *info)
 {
+	unsigned long flags;
+	unsigned long seq;
 	struct sysinfo val;
 	int err;
-	extern rwlock_t xtime_lock;
 
 	/* We don't need a memset here because we copy the
 	 * struct to userspace once element at a time.
 	 */
 
-	read_lock_irq(&xtime_lock);
-	val.uptime = jiffies / HZ;
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	val.loads[0] = avenrun[0] << (SI_LOAD_SHIFT - FSHIFT);
-	val.loads[1] = avenrun[1] << (SI_LOAD_SHIFT - FSHIFT);
-	val.loads[2] = avenrun[2] << (SI_LOAD_SHIFT - FSHIFT);
+		val.uptime = jiffies / HZ;
+		
+		val.loads[0] = avenrun[0] << (SI_LOAD_SHIFT - FSHIFT);
+		val.loads[1] = avenrun[1] << (SI_LOAD_SHIFT - FSHIFT);
+		val.loads[2] = avenrun[2] << (SI_LOAD_SHIFT - FSHIFT);
 
-	val.procs = nr_threads;
-	read_unlock_irq(&xtime_lock);
+		val.procs = nr_threads;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	si_meminfo(&val);
 	si_swapinfo(&val);
diff -urN -X dontdiff linux-2.5.59/arch/parisc/kernel/time.c linux-2.5-seqlock/arch/parisc/kernel/time.c
--- linux-2.5.59/arch/parisc/kernel/time.c	2003-01-16 18:22:03.000000000 -0800
+++ linux-2.5-seqlock/arch/parisc/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -36,7 +36,6 @@
 
 /* xtime and wall_jiffies keep wall-clock time */
 extern unsigned long wall_jiffies;
-extern rwlock_t xtime_lock;
 
 static long clocktick;	/* timer cycles per tick */
 static long halftick;
@@ -115,9 +114,9 @@
 		smp_do_timer(regs);
 #endif
 		if (cpu == 0) {
-			write_lock(&xtime_lock);
+			seq_write_lock(&xtime_lock);
 			do_timer(regs);
-			write_unlock(&xtime_lock);
+			seq_write_unlock(&xtime_lock);
 		}
 	}
     
@@ -172,16 +171,14 @@
 void
 do_gettimeofday (struct timeval *tv)
 {
-	unsigned long flags, usec, sec;
+	unsigned long flags, seq, usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	{
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 		usec = gettimeoffset();
-	
 		sec = xtime.tv_sec;
 		usec += (xtime.tv_nsec / 1000);
-	}
-	read_unlock_irqrestore(&xtime_lock, flags);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -195,7 +192,7 @@
 void
 do_settimeofday (struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	{
 		/*
 		 * This is revolting. We need to set "xtime"
@@ -219,7 +216,7 @@
 		time_maxerror = NTP_PHASE_LIMIT;
 		time_esterror = NTP_PHASE_LIMIT;
 	}
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 
@@ -241,10 +238,10 @@
 	mtctl(next_tick, 16);
 
 	if(pdc_tod_read(&tod_data) == 0) {
-		write_lock_irq(&xtime_lock);
+		seq_write_lock_irq(&xtime_lock);
 		xtime.tv_sec = tod_data.tod_sec;
 		xtime.tv_nsec = tod_data.tod_usec * 1000;
-		write_unlock_irq(&xtime_lock);
+		seq_write_unlock_irq(&xtime_lock);
 	} else {
 		printk(KERN_ERR "Error reading tod clock\n");
 	        xtime.tv_sec = 0;
diff -urN -X dontdiff linux-2.5.59/arch/ppc/kernel/time.c linux-2.5-seqlock/arch/ppc/kernel/time.c
--- linux-2.5.59/arch/ppc/kernel/time.c	2003-01-16 18:22:27.000000000 -0800
+++ linux-2.5-seqlock/arch/ppc/kernel/time.c	2003-01-30 14:48:34.000000000 -0800
@@ -76,7 +76,6 @@
 
 /* keep track of when we need to update the rtc */
 time_t last_rtc_update;
-extern rwlock_t xtime_lock;
 
 /* The decrementer counts down by 128 every 128ns on a 601. */
 #define DECREMENTER_COUNT_601	(1000000000 / HZ)
@@ -161,7 +160,7 @@
 			continue;
 
 		/* We are in an interrupt, no need to save/restore flags */
-		write_lock(&xtime_lock);
+		seq_write_lock(&xtime_lock);
 		tb_last_stamp = jiffy_stamp;
 		do_timer(regs);
 
@@ -191,7 +190,7 @@
 				/* Try again one minute later */
 				last_rtc_update += 60;
 		}
-		write_unlock(&xtime_lock);
+		seq_write_unlock(&xtime_lock);
 	}
 	if ( !disarm_decr[smp_processor_id()] )
 		set_dec(next_dec);
@@ -213,21 +212,23 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned delta, lost_ticks, usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	sec = xtime.tv_sec;
-	usec = (xtime.tv_nsec / 1000);
-	delta = tb_ticks_since(tb_last_stamp);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		sec = xtime.tv_sec;
+		usec = (xtime.tv_nsec / 1000);
+		delta = tb_ticks_since(tb_last_stamp);
 #ifdef CONFIG_SMP
-	/* As long as timebases are not in sync, gettimeofday can only
-	 * have jiffy resolution on SMP.
-	 */
-	if (!smp_tb_synchronized)
-		delta = 0;
+		/* As long as timebases are not in sync, gettimeofday can only
+		 * have jiffy resolution on SMP.
+		 */
+		if (!smp_tb_synchronized)
+			delta = 0;
 #endif /* CONFIG_SMP */
-	lost_ticks = jiffies - wall_jiffies;
-	read_unlock_irqrestore(&xtime_lock, flags);
+		lost_ticks = jiffies - wall_jiffies;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	usec += mulhwu(tb_to_us, tb_ticks_per_jiffy * lost_ticks + delta);
 	while (usec >= 1000000) {
@@ -243,7 +244,7 @@
 	unsigned long flags;
 	int tb_delta, new_usec, new_sec;
 
-	write_lock_irqsave(&xtime_lock, flags);
+	seq_write_lock_irqsave(&xtime_lock, flags);
 	/* Updating the RTC is not the job of this code. If the time is
 	 * stepped under NTP, the RTC will be update after STA_UNSYNC
 	 * is cleared. Tool like clock/hwclock either copy the RTC
@@ -283,7 +284,7 @@
 	time_state = TIME_ERROR;        /* p. 24, (a) */
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 }
 
 /* This function is only called on the boot processor */
diff -urN -X dontdiff linux-2.5.59/arch/ppc/platforms/pmac_time.c linux-2.5-seqlock/arch/ppc/platforms/pmac_time.c
--- linux-2.5.59/arch/ppc/platforms/pmac_time.c	2003-01-16 18:21:49.000000000 -0800
+++ linux-2.5-seqlock/arch/ppc/platforms/pmac_time.c	2003-01-30 14:48:34.000000000 -0800
@@ -15,6 +15,7 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/init.h>
+#include <linux/time.h>
 #include <linux/adb.h>
 #include <linux/cuda.h>
 #include <linux/pmu.h>
@@ -29,8 +30,6 @@
 #include <asm/time.h>
 #include <asm/nvram.h>
 
-extern rwlock_t xtime_lock;
-
 /* Apparently the RTC stores seconds since 1 Jan 1904 */
 #define RTC_OFFSET	2082844800
 
@@ -215,19 +214,21 @@
 {
 	static unsigned long time_diff;
 	unsigned long flags;
+	unsigned long seq;
 
 	switch (when) {
 	case PBOOK_SLEEP_NOW:
-		read_lock_irqsave(&xtime_lock, flags);
-		time_diff = xtime.tv_sec - pmac_get_rtc_time();
-		read_unlock_irqrestore(&xtime_lock, flags);
+		do {
+			seq = seq_read_lock_irqsave(&xtime_lock, flags);
+			time_diff = xtime.tv_sec - pmac_get_rtc_time();
+		} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 		break;
 	case PBOOK_WAKE:
-		write_lock_irqsave(&xtime_lock, flags);
+		seq_write_lock_irqsave(&xtime_lock, flags);
 		xtime.tv_sec = pmac_get_rtc_time() + time_diff;
 		xtime.tv_nsec = 0;
 		last_rtc_update = xtime.tv_sec;
-		write_unlock_irqrestore(&xtime_lock, flags);
+		seq_write_unlock_irqrestore(&xtime_lock, flags);
 		break;
 	}
 	return PBOOK_SLEEP_OK;
diff -urN -X dontdiff linux-2.5.59/arch/ppc64/kernel/time.c linux-2.5-seqlock/arch/ppc64/kernel/time.c
--- linux-2.5.59/arch/ppc64/kernel/time.c	2003-01-16 18:22:43.000000000 -0800
+++ linux-2.5-seqlock/arch/ppc64/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -69,7 +69,6 @@
 
 /* keep track of when we need to update the rtc */
 time_t last_rtc_update;
-extern rwlock_t xtime_lock;
 extern int piranha_simulator;
 #ifdef CONFIG_PPC_ISERIES
 unsigned long iSeries_recal_titan = 0;
@@ -284,12 +283,12 @@
 		smp_local_timer_interrupt(regs);
 #endif
 		if (cpu == boot_cpuid) {
-			write_lock(&xtime_lock);
+			seq_write_lock(&xtime_lock);
 			tb_last_stamp = lpaca->next_jiffy_update_tb;
 			do_timer(regs);
 			timer_sync_xtime( cur_tb );
 			timer_check_rtc();
-			write_unlock(&xtime_lock);
+			seq_write_unlock(&xtime_lock);
 			if ( adjusting_time && (time_adjust == 0) )
 				ppc_adjtimex();
 		}
@@ -348,7 +347,7 @@
 	long int tb_delta, new_usec, new_sec;
 	unsigned long new_xsec;
 
-	write_lock_irqsave(&xtime_lock, flags);
+	seq_write_lock_irqsave(&xtime_lock, flags);
 	/* Updating the RTC is not the job of this code. If the time is
 	 * stepped under NTP, the RTC will be update after STA_UNSYNC
 	 * is cleared. Tool like clock/hwclock either copy the RTC
@@ -399,7 +398,7 @@
 		do_gtod.tb_orig_stamp = tb_last_stamp;
 	}
 
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 }
 
 /*
@@ -465,7 +464,7 @@
 #endif
 		ppc_md.get_boot_time(&tm);
 
-	write_lock_irqsave(&xtime_lock, flags);
+	seq_write_lock_irqsave(&xtime_lock, flags);
 	xtime.tv_sec = mktime(tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
 			      tm.tm_hour, tm.tm_min, tm.tm_sec);
 	tb_last_stamp = get_tb();
@@ -484,7 +483,7 @@
 
 	xtime.tv_nsec = 0;
 	last_rtc_update = xtime.tv_sec;
-	write_unlock_irqrestore(&xtime_lock, flags);
+	seq_write_unlock_irqrestore(&xtime_lock, flags);
 
 	/* Not exact, but the timer interrupt takes care of this */
 	set_dec(tb_ticks_per_jiffy);
@@ -587,7 +586,7 @@
 	new_tb_to_xs = divres.result_low;
 	new_xsec = mulhdu( tb_ticks, new_tb_to_xs );
 
-	write_lock_irqsave( &xtime_lock, flags );
+	seq_write_lock_irqsave( &xtime_lock, flags );
 	old_xsec = mulhdu( tb_ticks, do_gtod.varp->tb_to_xs );
 	new_stamp_xsec = do_gtod.varp->stamp_xsec + old_xsec - new_xsec;
 
@@ -609,7 +608,7 @@
 	do_gtod.varp = temp_varp;
 	do_gtod.var_idx = temp_idx;
 
-	write_unlock_irqrestore( &xtime_lock, flags );
+	seq_write_unlock_irqrestore( &xtime_lock, flags );
 
 }
 
diff -urN -X dontdiff linux-2.5.59/arch/s390/kernel/time.c linux-2.5-seqlock/arch/s390/kernel/time.c
--- linux-2.5.59/arch/s390/kernel/time.c	2003-01-16 18:21:34.000000000 -0800
+++ linux-2.5-seqlock/arch/s390/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -52,7 +52,6 @@
 static uint64_t xtime_cc;
 static uint64_t init_timer_cc;
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 
 void tod_to_timeval(__u64 todval, struct timespec *xtime)
@@ -83,12 +82,15 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	sec = xtime.tv_sec;
-	usec = xtime.tv_nsec / 1000 + do_gettimeoffset();
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+
+		sec = xtime.tv_sec;
+		usec = xtime.tv_nsec / 1000 + do_gettimeoffset();
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -102,7 +104,7 @@
 void do_settimeofday(struct timeval *tv)
 {
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/* This is revolting. We need to set the xtime.tv_nsec
 	 * correctly. However, the value in this location is
 	 * is value at the last tick.
@@ -122,7 +124,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 static inline __u32 div64_32(__u64 dividend, __u32 divisor)
@@ -166,7 +168,7 @@
 	 * Do not rely on the boot cpu to do the calls to do_timer.
 	 * Spread it over all cpus instead.
 	 */
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 	if (S390_lowcore.jiffy_timer > xtime_cc) {
 		__u32 xticks;
 
@@ -181,7 +183,7 @@
 		while (xticks--)
 			do_timer(regs);
 	}
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 	while (ticks--)
 		update_process_times(user_mode(regs));
 #else
diff -urN -X dontdiff linux-2.5.59/arch/s390x/kernel/time.c linux-2.5-seqlock/arch/s390x/kernel/time.c
--- linux-2.5.59/arch/s390x/kernel/time.c	2003-01-16 18:22:30.000000000 -0800
+++ linux-2.5-seqlock/arch/s390x/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -51,7 +51,6 @@
 static uint64_t xtime_cc;
 static uint64_t init_timer_cc;
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 
 void tod_to_timeval(__u64 todval, struct timespec *xtime)
@@ -78,12 +77,14 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	sec = xtime.tv_sec;
-	usec = xtime.tv_nsec + do_gettimeoffset();
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		sec = xtime.tv_sec;
+		usec = xtime.tv_nsec + do_gettimeoffset();
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -97,7 +98,7 @@
 void do_settimeofday(struct timeval *tv)
 {
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/* This is revolting. We need to set the xtime.tv_usec
 	 * correctly. However, the value in this location is
 	 * is value at the last tick.
@@ -117,7 +118,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /*
@@ -152,7 +153,7 @@
 	 * Do not rely on the boot cpu to do the calls to do_timer.
 	 * Spread it over all cpus instead.
 	 */
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 	if (S390_lowcore.jiffy_timer > xtime_cc) {
 		__u32 xticks;
 
@@ -167,7 +168,7 @@
 		while (xticks--)
 			do_timer(regs);
 	}
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 	while (ticks--)
 		update_process_times(user_mode(regs));
 #else
diff -urN -X dontdiff linux-2.5.59/arch/sh/kernel/time.c linux-2.5-seqlock/arch/sh/kernel/time.c
--- linux-2.5.59/arch/sh/kernel/time.c	2003-01-16 18:21:34.000000000 -0800
+++ linux-2.5-seqlock/arch/sh/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -72,7 +72,6 @@
 
 u64 jiffies_64;
 
-extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 #define TICK_SIZE tick
 
@@ -128,18 +127,20 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = do_gettimeoffset();
-	{
-		unsigned long lost = jiffies - wall_jiffies;
-		if (lost)
-			usec += lost * (1000000 / HZ);
-	}
-	sec = xtime.tv_sec;
-	usec += xtime.tv_usec;
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		usec = do_gettimeoffset();
+		{
+			unsigned long lost = jiffies - wall_jiffies;
+			if (lost)
+				usec += lost * (1000000 / HZ);
+		}
+		sec = xtime.tv_sec;
+		usec += xtime.tv_usec;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -152,7 +153,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/*
 	 * This is revolting. We need to set "xtime" correctly. However, the
 	 * value in this location is the value at the most recent update of
@@ -172,7 +173,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /* last time the RTC clock got updated */
@@ -231,9 +232,9 @@
 	 * the irq version of write_lock because as just said we have irq
 	 * locally disabled. -arca
 	 */
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 	do_timer_interrupt(irq, NULL, regs);
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 static unsigned int __init get_timer_frequency(void)
diff -urN -X dontdiff linux-2.5.59/arch/sparc/kernel/pcic.c linux-2.5-seqlock/arch/sparc/kernel/pcic.c
--- linux-2.5.59/arch/sparc/kernel/pcic.c	2003-01-16 18:22:14.000000000 -0800
+++ linux-2.5-seqlock/arch/sparc/kernel/pcic.c	2003-01-30 14:48:35.000000000 -0800
@@ -25,6 +25,7 @@
 
 #include <linux/ctype.h>
 #include <linux/pci.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/interrupt.h>
 
@@ -34,8 +35,6 @@
 #include <asm/timer.h>
 #include <asm/uaccess.h>
 
-extern rwlock_t xtime_lock;
-
 #ifndef CONFIG_PCI
 
 asmlinkage int sys_pciconfig_read(unsigned long bus,
@@ -739,10 +738,10 @@
 
 static void pcic_timer_handler (int irq, void *h, struct pt_regs *regs)
 {
-	write_lock(&xtime_lock);	/* Dummy, to show that we remember */
+	seq_write_lock(&xtime_lock);	/* Dummy, to show that we remember */
 	pcic_clear_clock_irq();
 	do_timer(regs);
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 #define USECS_PER_JIFFY  10000  /* We have 100HZ "standard" timer for sparc */
@@ -795,18 +794,20 @@
 static void pci_do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = do_gettimeoffset();
-	{
-		unsigned long lost = jiffies - wall_jiffies;
-		if (lost)
-			usec += lost * (1000000 / HZ);
-	}
-	sec = xtime.tv_sec;
-	usec += (xtime.tv_nsec / 1000);
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		usec = do_gettimeoffset();
+		{
+			unsigned long lost = jiffies - wall_jiffies;
+			if (lost)
+				usec += lost * (1000000 / HZ);
+		}
+		sec = xtime.tv_sec;
+		usec += (xtime.tv_nsec / 1000);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
diff -urN -X dontdiff linux-2.5.59/arch/sparc/kernel/time.c linux-2.5-seqlock/arch/sparc/kernel/time.c
--- linux-2.5.59/arch/sparc/kernel/time.c	2003-01-16 18:22:17.000000000 -0800
+++ linux-2.5-seqlock/arch/sparc/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -23,6 +23,7 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/init.h>
 #include <linux/pci.h>
@@ -42,8 +43,6 @@
 #include <asm/page.h>
 #include <asm/pcic.h>
 
-extern rwlock_t xtime_lock;
-
 extern unsigned long wall_jiffies;
 
 u64 jiffies_64;
@@ -131,7 +130,7 @@
 #endif
 
 	/* Protect counter clear so that do_gettimeoffset works */
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 #ifdef CONFIG_SUN4
 	if((idprom->id_machtype == (SM_SUN4 | SM_4_260)) ||
 	   (idprom->id_machtype == (SM_SUN4 | SM_4_110))) {
@@ -155,7 +154,7 @@
 	  else
 	    last_rtc_update = xtime.tv_sec - 600; /* do it again in 60 s */
 	}
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 /* Kick start a stopped clock (procedure from the Sun NVRAM/hostid FAQ). */
@@ -470,18 +469,20 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = do_gettimeoffset();
-	{
-		unsigned long lost = jiffies - wall_jiffies;
-		if (lost)
-			usec += lost * (1000000 / HZ);
-	}
-	sec = xtime.tv_sec;
-	usec += (xtime.tv_nsec / 1000);
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		usec = do_gettimeoffset();
+		{
+			unsigned long lost = jiffies - wall_jiffies;
+			if (lost)
+				usec += lost * (1000000 / HZ);
+		}
+		sec = xtime.tv_sec;
+		usec += (xtime.tv_nsec / 1000);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -494,9 +495,9 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	bus_do_settimeofday(tv);
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 static void sbus_do_settimeofday(struct timeval *tv)
diff -urN -X dontdiff linux-2.5.59/arch/sparc64/kernel/time.c linux-2.5-seqlock/arch/sparc64/kernel/time.c
--- linux-2.5.59/arch/sparc64/kernel/time.c	2003-01-16 18:22:09.000000000 -0800
+++ linux-2.5-seqlock/arch/sparc64/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -17,6 +17,7 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
@@ -37,8 +38,6 @@
 #include <asm/isa.h>
 #include <asm/starfire.h>
 
-extern rwlock_t xtime_lock;
-
 spinlock_t mostek_lock = SPIN_LOCK_UNLOCKED;
 spinlock_t rtc_lock = SPIN_LOCK_UNLOCKED;
 unsigned long mstk48t02_regs = 0UL;
@@ -134,7 +133,7 @@
 {
 	unsigned long ticks, pstate;
 
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 
 	do {
 #ifndef CONFIG_SMP
@@ -196,13 +195,13 @@
 
 	timer_check_rtc();
 
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 #ifdef CONFIG_SMP
 void timer_tick_interrupt(struct pt_regs *regs)
 {
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 
 	do_timer(regs);
 
@@ -225,7 +224,7 @@
 
 	timer_check_rtc();
 
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 #endif
 
@@ -665,7 +664,7 @@
 	if (this_is_starfire)
 		return;
 
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	/*
 	 * This is revolting. We need to set "xtime" correctly. However, the
 	 * value in this location is the value at the most recent update of
@@ -686,7 +685,7 @@
 	time_status |= STA_UNSYNC;
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /* Ok, my cute asm atomicity trick doesn't work anymore.
@@ -696,18 +695,20 @@
 void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long flags;
+	unsigned long seq;
 	unsigned long usec, sec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	usec = do_gettimeoffset();
-	{
-		unsigned long lost = jiffies - wall_jiffies;
-		if (lost)
-			usec += lost * (1000000 / HZ);
-	}
-	sec = xtime.tv_sec;
-	usec += (xtime.tv_nsec / 1000);
-	read_unlock_irqrestore(&xtime_lock, flags);
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
+		usec = do_gettimeoffset();
+		{
+			unsigned long lost = jiffies - wall_jiffies;
+			if (lost)
+				usec += lost * (1000000 / HZ);
+		}
+		sec = xtime.tv_sec;
+		usec += (xtime.tv_nsec / 1000);
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
diff -urN -X dontdiff linux-2.5.59/arch/um/kernel/time_kern.c linux-2.5-seqlock/arch/um/kernel/time_kern.c
--- linux-2.5.59/arch/um/kernel/time_kern.c	2003-01-16 18:22:20.000000000 -0800
+++ linux-2.5-seqlock/arch/um/kernel/time_kern.c	2003-01-30 14:48:35.000000000 -0800
@@ -7,6 +7,7 @@
 #include "linux/unistd.h"
 #include "linux/stddef.h"
 #include "linux/spinlock.h"
+#include "linux/time.h"
 #include "linux/sched.h"
 #include "linux/interrupt.h"
 #include "linux/init.h"
@@ -21,8 +22,6 @@
 
 u64 jiffies_64;
 
-extern rwlock_t xtime_lock;
-
 int hz(void)
 {
 	return(HZ);
@@ -57,9 +56,9 @@
 void um_timer(int irq, void *dev, struct pt_regs *regs)
 {
 	do_timer(regs);
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 	timer();
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 long um_time(int * tloc)
diff -urN -X dontdiff linux-2.5.59/arch/v850/kernel/time.c linux-2.5-seqlock/arch/v850/kernel/time.c
--- linux-2.5.59/arch/v850/kernel/time.c	2003-01-16 18:22:22.000000000 -0800
+++ linux-2.5-seqlock/arch/v850/kernel/time.c	2003-01-30 14:48:35.000000000 -0800
@@ -17,6 +17,7 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
+#include <linux/time.h>
 #include <linux/timex.h>
 #include <linux/profile.h>
 
@@ -107,8 +108,6 @@
 #endif /* 0 */
 }
 
-extern rwlock_t xtime_lock;
-
 /*
  * This version of gettimeofday has near microsecond resolution.
  */
@@ -120,21 +119,24 @@
 #endif
 	unsigned long flags;
 	unsigned long usec, sec;
+	unsigned long seq;
+
+	do {
+		seq = seq_read_lock_irqsave(&xtime_lock, flags);
 
-	read_lock_irqsave (&xtime_lock, flags);
 #if 0
-	usec = mach_gettimeoffset ? mach_gettimeoffset () : 0;
+		usec = mach_gettimeoffset ? mach_gettimeoffset () : 0;
 #else
-	usec = 0;
+		usec = 0;
 #endif
 #if 0 /* DAVIDM later if possible */
-	lost = lost_ticks;
-	if (lost)
-		usec += lost * (1000000/HZ);
+		lost = lost_ticks;
+		if (lost)
+			usec += lost * (1000000/HZ);
 #endif
-	sec = xtime.tv_sec;
-	usec += xtime.tv_nsec / 1000;
-	read_unlock_irqrestore (&xtime_lock, flags);
+		sec = xtime.tv_sec;
+		usec += xtime.tv_nsec / 1000;
+	} while (seq_read_unlock_irqrestore(&xtime_lock, seq, flags));
 
 	while (usec >= 1000000) {
 		usec -= 1000000;
@@ -147,7 +149,7 @@
 
 void do_settimeofday (struct timeval *tv)
 {
-	write_lock_irq (&xtime_lock);
+	seq_write_lock_irq (&xtime_lock);
 
 	/* This is revolting. We need to set the xtime.tv_nsec
 	 * correctly. However, the value in this location is
@@ -172,7 +174,7 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq (&xtime_lock);
+	seq_write_unlock_irq (&xtime_lock);
 }
 
 static int timer_dev_id;
diff -urN -X dontdiff linux-2.5.59/arch/x86_64/kernel/time.c linux-2.5-seqlock/arch/x86_64/kernel/time.c
--- linux-2.5.59/arch/x86_64/kernel/time.c	2003-01-16 18:22:23.000000000 -0800
+++ linux-2.5-seqlock/arch/x86_64/kernel/time.c	2003-01-30 12:13:49.000000000 -0800
@@ -18,6 +18,7 @@
 #include <linux/init.h>
 #include <linux/mc146818rtc.h>
 #include <linux/irq.h>
+#include <linux/time.h>
 #include <linux/ioport.h>
 #include <linux/module.h>
 #include <linux/device.h>
@@ -27,7 +28,6 @@
 
 u64 jiffies_64; 
 
-extern rwlock_t xtime_lock;
 spinlock_t rtc_lock = SPIN_LOCK_UNLOCKED;
 
 unsigned int cpu_khz;					/* TSC clocks / usec, not used here */
@@ -70,21 +70,22 @@
 
 void do_gettimeofday(struct timeval *tv)
 {
-	unsigned long flags, t;
+	unsigned long flags, t, seq;
  	unsigned int sec, usec;
 
-	read_lock_irqsave(&xtime_lock, flags);
-	spin_lock(&time_offset_lock);
+	spin_lock_irqsave(&time_offset_lock, flags);
+	do {
+		seq = seq_read_lock(&xtime_lock);
+
+		sec = xtime.tv_sec;
+		usec = xtime.tv_nsec / 1000;
+
+		t = (jiffies - wall_jiffies) * (1000000L / HZ) + do_gettimeoffset();
+		if (t > timeoffset) timeoffset = t;
+		usec += timeoffset;
 
-	sec = xtime.tv_sec;
-	usec = xtime.tv_nsec / 1000;
-
-	t = (jiffies - wall_jiffies) * (1000000L / HZ) + do_gettimeoffset();
-	if (t > timeoffset) timeoffset = t;
-	usec += timeoffset;
-
-	spin_unlock(&time_offset_lock);
-	read_unlock_irqrestore(&xtime_lock, flags);
+	} while (seq_read_unlock(&xtime_lock, seq));
+	spin_unlock_irqrestore(&time_offset_lock, flags);
 
 	tv->tv_sec = sec + usec / 1000000;
 	tv->tv_usec = usec % 1000000;
@@ -98,7 +99,7 @@
 
 void do_settimeofday(struct timeval *tv)
 {
-	write_lock_irq(&xtime_lock);
+	seq_write_lock_irq(&xtime_lock);
 	vxtime_lock();
 
 	tv->tv_usec -= do_gettimeoffset() +
@@ -118,7 +119,7 @@
 	time_maxerror = NTP_PHASE_LIMIT;
 	time_esterror = NTP_PHASE_LIMIT;
 
-	write_unlock_irq(&xtime_lock);
+	seq_write_unlock_irq(&xtime_lock);
 }
 
 /*
@@ -201,7 +202,7 @@
  * variables, because both do_timer() and us change them -arca+vojtech
 	 */
 
-	write_lock(&xtime_lock);
+	seq_write_lock(&xtime_lock);
 	vxtime_lock();
 
 	{
@@ -250,7 +251,7 @@
 	}
  
 	vxtime_unlock();
-	write_unlock(&xtime_lock);
+	seq_write_unlock(&xtime_lock);
 }
 
 unsigned long get_cmos_time(void)

--=-FDAvaF2Vpnf5wZXjoFpb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
