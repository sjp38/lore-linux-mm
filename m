Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA06196
	for <linux-mm@kvack.org>; Sun, 6 Oct 2002 15:11:58 -0700 (PDT)
Message-ID: <3DA0B52C.6E1E53FD@digeo.com>
Date: Sun, 06 Oct 2002 15:11:56 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.40-mm2
References: <3DA0854E.CF9080D7@digeo.com> <3DA0A144.8070301@us.ibm.com> <3DA0B151.6EF8C8D9@digeo.com> <3DA0B422.C23B23D4@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

grr.  So that's what that "send" button does.

Updated patch:


--- 2.5.40/kernel/timer.c~timer-tricks	Sun Oct  6 15:08:02 2002
+++ 2.5.40-akpm/kernel/timer.c	Sun Oct  6 15:08:45 2002
@@ -265,23 +265,19 @@ repeat:
  */
 int del_timer_sync(timer_t *timer)
 {
-	tvec_base_t *base = tvec_bases;
 	int i, ret;
 
 	ret = del_timer(timer);
 
 	for (i = 0; i < NR_CPUS; i++) {
-		if (!cpu_online(i))
-			continue;
-		if (base->running_timer == timer) {
-			while (base->running_timer == timer) {
-				cpu_relax();
-				preempt_disable();
-				preempt_enable();
+		if (cpu_online(i)) {
+			tvec_base_t *base = tvec_bases + i;
+			if (base->running_timer == timer) {
+				while (base->running_timer == timer)
+					cpu_relax();
+				break;
 			}
-			break;
 		}
-		base++;
 	}
 	return ret;
 }
@@ -359,9 +355,9 @@ repeat:
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
