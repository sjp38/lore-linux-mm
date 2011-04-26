Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAE09000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 13:19:15 -0400 (EDT)
Received: from mail-vw0-f41.google.com (mail-vw0-f41.google.com [209.85.212.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3QHIgRs023721
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:18:43 -0700
Received: by vws4 with SMTP id 4so898827vws.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:18:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426190918.01660ccf@neptune.home>
References: <20110425180450.1ede0845@neptune.home> <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
 <20110425190032.7904c95d@neptune.home> <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
 <20110425203606.4e78246c@neptune.home> <20110425191607.GL2468@linux.vnet.ibm.com>
 <20110425231016.34b4293e@neptune.home> <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
 <20110425214933.GO2468@linux.vnet.ibm.com> <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 26 Apr 2011 10:18:22 -0700
Message-ID: <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Tue, Apr 26, 2011 at 10:09 AM, Bruno Pr=E9mont
<bonbons@linux-vserver.org> wrote:
>
> Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
> context switches and exactly one non-voluntary one.
>
> In addition when rcu_kthread has stopped doing its work
> `swapoff $(swapdevice)` seems to block forever (at least normal shutdown
> blocks on disabling swap device).
> If I get to do it when I get back home I will manually try to swapoff
> and take process traces with sysrq-t.

That "exactly one non-voluntary one" sounds like the smoking gun.

Normally SCHED_FIFO runs until it voluntarily gives up the CPU. That's
kind of the point of SCHED_FIFO. Involuntary context switches happen
when some higher-priority SCHED_FIFO process becomes runnable (irq
handlers? You _do_ have CONFIG_IRQ_FORCED_THREADING=3Dy in your config
too), and maybe there is a bug in the runqueue handling for that case.

Ingo, do you have any tests for SCHED_FIFO scheduling? Particularly
with UP and voluntary preempt?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
