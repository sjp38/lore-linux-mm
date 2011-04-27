Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED4AC6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:28:34 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3RNST50023549
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:28:30 -0700
Received: by ewy9 with SMTP id 9so957129ewy.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:28:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1104280028250.3323@ionos>
References: <20110425214933.GO2468@linux.vnet.ibm.com> <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos>
 <20110427222727.GU2135@linux.vnet.ibm.com> <alpine.LFD.2.02.1104280028250.3323@ionos>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Apr 2011 16:28:09 -0700
Message-ID: <BANLkTi=Ad2DUQ2Lr-Q5Y+eYxKMyz04fL2g@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, Apr 27, 2011 at 3:32 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> Well that's going to paper over the problem at hand possibly. I really
> don't see why that thing would run for more than 950ms in a row even
> if there is a large number of callbacks pending.

Stop with this bogosity already, guys.

We _know_ it didn't run continuously for 950ms. That number is totally
made up. There's not enough work for it to run that long, but more
importantly, the thread has zero CPU time. There is _zero_ reason to
believe that it runs for long periods.

There is some scheduler bug, probably the rt_time hasn't been
initialized at all, or runtime we compare against is zero, or the
calculations are just wrong.

The 950ms didn't happen. Stop harping on it. It almost certainly
simply doesn't exist.

Since that

       if (rt_rq->rt_time > runtime) {
               rt_rq->rt_throttled = 1;
+               printk_once(KERN_WARNING "sched: RT throttling activated\n");

test triggers, we know that either 'runtime' or 'rt_time' is just
bogus. Make the printk print out the values, and maybe that gives some
hints.

But in the meantime, I'd suggest looking for the places that
initialize or calculate those values, and just assume that some of
them are buggy.

> And then I don't have an explanation for the hosed CPU accounting and
> why that thing does not get another 950ms RT time when the 50ms
> throttling break is over.

Again, don't even bother talking about "another 950ms". It didn't
happen in the first place, there's no "another" there either.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
