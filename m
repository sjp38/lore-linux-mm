Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA05887
	for <linux-mm@kvack.org>; Sun, 6 Oct 2002 14:55:31 -0700 (PDT)
Message-ID: <3DA0B151.6EF8C8D9@digeo.com>
Date: Sun, 06 Oct 2002 14:55:29 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.40-mm2
References: <3DA0854E.CF9080D7@digeo.com> <3DA0A144.8070301@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> 
> Andrew Morton wrote:
> >   Ingo said that his 2.4-based per-cpu-pages patch was beneficial to
> >   specweb, but nobody has tested these patches with specweb.  Hint.
> 
> cc'ing Ingo, because I think this might be related to the timer bh
> removal.
> 
> 2.5.40 doesn't last very long under Specweb.  It always dies out with
> one of these oopses after a little while:
> 
> CPU:    3
> EIP:    0060:[<801204a9>]    Not tainted
> EFLAGS: 00010006
> EIP is at run_timer_tasklet+0xcd/0x13c

Well from a quick peek, there is some funny stuff happening in the
timer code.

- del_timer_sync() iterates across all CPUs, but does not do
  actually _do_ anything for each CPU.  (I suspect this may
  be the source of your crash - del_timer_sync() is bust)

- the back-to-back preempt_disable()/preempt_enable() is
  unusual.  What's that for?

- __run_timers() is doing spin_unlock_irq() inside spin_lock_irqsave().
  That's probably not a bug in this context, but it's a wart.


This help?


--- 2.5.40/kernel/timer.c~timer-tricks	Sun Oct  6 14:50:39 2002
+++ 2.5.40-akpm/kernel/timer.c	Sun Oct  6 14:52:34 2002
@@ -265,20 +265,19 @@ repeat:
  */
 int del_timer_sync(timer_t *timer)
 {
-	tvec_base_t *base = tvec_bases;
 	int i, ret;
 
 	ret = del_timer(timer);
 
 	for (i = 0; i < NR_CPUS; i++) {
+		tvec_base_t *base;
+
 		if (!cpu_online(i))
 			continue;
+		base = tvec_bases + i;
 		if (base->running_timer == timer) {
-			while (base->running_timer == timer) {
+			while (base->running_timer == timer)
 				cpu_relax();
-				preempt_disable();
-				preempt_enable();
-			}
 			break;
 		}
 		base++;
@@ -359,9 +358,9 @@ repeat:
 #if CONFIG_SMP
 			base->running_timer = timer;
 #endif
-			spin_unlock_irq(&base->lock);
+			spin_unlock_irqrestore(&base->lock, flags);
 			fn(data);
-			spin_lock_irq(&base->lock);
+			spin_lock_irqsave(&base->lock, flags);
 			goto repeat;
 		}
 		++base->timer_jiffies; 

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
