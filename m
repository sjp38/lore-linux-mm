Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA629000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 13:13:38 -0400 (EDT)
Received: from mail-vx0-f169.google.com (mail-vx0-f169.google.com [209.85.220.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3QHCxQK023177
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:13:00 -0700
Received: by vxk20 with SMTP id 20so909900vxk.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:12:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426183859.6ff6279b@neptune.home>
References: <20110425180450.1ede0845@neptune.home> <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
 <20110425190032.7904c95d@neptune.home> <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
 <20110425203606.4e78246c@neptune.home> <20110425191607.GL2468@linux.vnet.ibm.com>
 <20110425231016.34b4293e@neptune.home> <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
 <20110425214933.GO2468@linux.vnet.ibm.com> <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 26 Apr 2011 10:12:39 -0700
Message-ID: <BANLkTin3UG=xF1VQOtdEDOnShoMQwQ7gFg@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Tue, Apr 26, 2011 at 9:38 AM, Bruno Pr=E9mont
<bonbons@linux-vserver.org> wrote:
>
> Here it comes:
>
> rcu_kthread (when build processes are STOPped):
> [ =A0836.050003] rcu_kthread =A0 =A0 R running =A0 7324 =A0 =A0 6 =A0 =A0=
 =A02 0x00000000
> [ =A0836.050003] =A0dd473f28 00000046 5a000240 dd65207c dd407360 dd651d40=
 0000035c dd473ed8
> [ =A0836.050003] =A0c10bf8a2 c14d63d8 dd65207c dd473f28 dd445040 dd445040=
 dd473eec c10be848
> [ =A0836.050003] =A0dd651d40 dd407360 ddfdca00 dd473f14 c10bfde2 00000000=
 00000001 000007b6
> [ =A0836.050003] Call Trace:
> [ =A0836.050003] =A0[<c10bf8a2>] ? check_object+0x92/0x210
> [ =A0836.050003] =A0[<c10be848>] ? init_object+0x38/0x70
> [ =A0836.050003] =A0[<c10bfde2>] ? free_debug_processing+0x112/0x1f0
> [ =A0836.050003] =A0[<c103d9fd>] ? lock_timer_base+0x2d/0x70
> [ =A0836.050003] =A0[<c13c8ec7>] schedule_timeout+0x137/0x280

Hmm.

I'm adding Ingo and Peter to the cc, because this whole "rcu_kthread
is running, but never actually running" is starting to smell like a
scheduler issue.

Peter/Ingo: RCUTINY seems to be broken for Bruno. During any kind of
heavy workload, at some point it looks like rcu_kthread simply stops
making any progress. It's constantly in runnable state, but it doesn't
actually use any CPU time, and it's not processing the RCU callbacks,
so the RCU memory freeing isn't happening, and slabs just build up
until the machine dies.

And it really is RCUTINY, because the thing doesn't happen with the
regular tree-RCU.

This is without CONFIG_RCU_BOOST_PRIO, so we basically have

        struct sched_param sp;

        rcu_kthread_task =3D kthread_run(rcu_kthread, NULL, "rcu_kthread");
        sp.sched_priority =3D RCU_BOOST_PRIO;
        sched_setscheduler_nocheck(rcu_kthread_task, SCHED_FIFO, &sp);

where RCU_BOOST_PRIO is 1 for the non-boost case.

Is that so low that even the idle thread will take priority? It's a UP
config with PREEMPT_VOLUNTARY. So pretty much _all_ the stars are
aligned for odd scheduling behavior.

Other users of SCHED_FIFO tend to set the priority really high (eg
"MAX_RT_PRIO-1" is clearly the default one - softirq's, watchdog), but
"1" is not unheard of either (touchscreen/ucb1400_ts and
mmc/core/sdio_irq), and there are some other random choises out tere.

Any ideas?

                             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
