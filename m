Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4151A90010B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 14:50:17 -0400 (EDT)
Date: Thu, 28 Apr 2011 20:49:42 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
In-Reply-To: <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
Message-ID: <alpine.LFD.2.02.1104282044120.3005@ionos>
References: <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home> <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com> <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos> <alpine.LFD.2.02.1104281051090.19095@ionos> <BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com> <20110428102609.GJ2135@linux.vnet.ibm.com> <1303997401.7819.5.camel@marge.simson.net>
 <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, =?ISO-8859-15?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 28 Apr 2011, Sedat Dilek wrote:
> On Thu, Apr 28, 2011 at 3:30 PM, Mike Galbraith <efault@gmx.de> wrote:
> rt_rq[0]:
>   .rt_nr_running                 : 0
>   .rt_throttled                  : 0

>   .rt_time                       : 888.893877

>   .rt_time                       : 950.005460

So rt_time is constantly accumulated, but never decreased. The
decrease happens in the timer callback. Looks like the timer is not
running for whatever reason.

Can you add the following patch as well ?

Thanks,

	tglx

--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -172,7 +172,7 @@ static enum hrtimer_restart sched_rt_per
 		idle = do_sched_rt_period_timer(rt_b, overrun);
 	}
 
-	return idle ? HRTIMER_NORESTART : HRTIMER_RESTART;
+	return HRTIMER_RESTART;
 }
 
 static

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
