Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 06FD16B0012
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 17:04:18 -0400 (EDT)
Date: Thu, 28 Apr 2011 23:04:01 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
In-Reply-To: <20110428224444.43107883@neptune.home>
Message-ID: <alpine.LFD.2.02.1104282251080.3005@ionos>
References: <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home> <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com> <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos> <alpine.LFD.2.02.1104281051090.19095@ionos> <BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com> <20110428102609.GJ2135@linux.vnet.ibm.com> <1303997401.7819.5.camel@marge.simson.net>
 <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com> <alpine.LFD.2.02.1104282044120.3005@ionos> <20110428222301.0b745a0a@neptune.home> <alpine.LFD.2.02.1104282227340.3005@ionos> <20110428224444.43107883@neptune.home>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-929818264-1304024642=:3005"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: sedat.dilek@gmail.com, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>, John Stultz <johnstul@us.ibm.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-929818264-1304024642=:3005
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 28 Apr 2011, Bruno PrA(C)mont wrote:
> Timer List Version: v0.6
> HRTIMER_MAX_CLOCK_BASES: 3
> now at 1150126155286 nsecs
> 
> cpu: 0
>  clock 0:
>   .base:       c1559360
>   .index:      0
>   .resolution: 1 nsecs
>   .get_time:   ktime_get_real
>   .offset:     1304021489280954699 nsecs
> active timers:
>  #0: def_rt_bandwidth, sched_rt_period_timer, S:01, enqueue_task_rt, swapper/1
>  # expires at 1304028703000000000-1304028703000000000 nsecs [in 1304027552873844714 to 1304027552873844714 nsecs]

Ok, that expiry time is obviously bogus as it does not account the offset:

So in reality it's: expires in: 6063592890015ns 

Which is still completely wrong. The timer should expire at max a
second from now. But it's going to expire in 6063.592890015 seconds
from now, which is pretty much explaining the after 2hrs stuff got
going again.

But the real interesting question is why he heck is that timer on
CLOCK_REALTIME ???? It is initalized for CLOCK_MONOTONIC.

/me suspects hrtimer changes to be the real culprit.

John ????

Thanks,

	tglx




--8323328-929818264-1304024642=:3005--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
