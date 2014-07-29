Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0917F6B0035
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 11:22:25 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so10433912qge.16
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:22:24 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id p18si38212636qga.38.2014.07.29.08.22.23
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 08:22:24 -0700 (PDT)
Date: Tue, 29 Jul 2014 10:22:06 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <20140729131226.GS7462@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407291020470.21102@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140729075637.GA19379@twins.programming.kicks-ass.net> <20140729120525.GA28366@mtj.dyndns.org> <20140729122303.GA3935@laptop>
 <20140729131226.GS7462@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

On Tue, 29 Jul 2014, Tejun Heo wrote:

> I'm not sure that's a viable way forward.  It's not like we can
> readily trigger the problematic cases which can lead to long pauses
> during cpu down.  Besides, we need the distinction at the API level,
> which is the whole point of this.  The best way probably is converting
> all the correctness ones (these are the minorities) over to
> queue_work_on() so that the per-cpu requirement is explicit.

Ok so we would need this fix to avoid the message:


Subject: vmstat: use schedule_delayed_work_on to avoid false positives

It seems that schedule_delayed_work_on will check for preemption even
though none can occur. schedule_delayed_work_on will not do that. So
use that function to suppress false positives.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-07-29 10:14:42.356988271 -0500
+++ linux/mm/vmstat.c	2014-07-29 10:18:28.205920997 -0500
@@ -1255,7 +1255,8 @@ static void vmstat_update(struct work_st
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
+		schedule_delayed_work_on(smp_processor_id(),
+			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
 	else {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
