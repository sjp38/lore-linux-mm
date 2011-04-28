Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51D24900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 19:06:57 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2210725qwa.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:06:53 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <alpine.LFD.2.02.1104282353140.3005@ionos>
References: <20110426112756.GF4308@linux.vnet.ibm.com>
	<20110426183859.6ff6279b@neptune.home>
	<20110426190918.01660ccf@neptune.home>
	<BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	<alpine.LFD.2.02.1104262314110.3323@ionos>
	<20110427081501.5ba28155@pluto.restena.lu>
	<20110427204139.1b0ea23b@neptune.home>
	<alpine.LFD.2.02.1104272351290.3323@ionos>
	<alpine.LFD.2.02.1104281051090.19095@ionos>
	<BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com>
	<20110428102609.GJ2135@linux.vnet.ibm.com>
	<1303997401.7819.5.camel@marge.simson.net>
	<BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
	<alpine.LFD.2.02.1104282044120.3005@ionos>
	<20110428222301.0b745a0a@neptune.home>
	<alpine.LFD.2.02.1104282227340.3005@ionos>
	<20110428224444.43107883@neptune.home>
	<alpine.LFD.2.02.1104282251080.3005@ionos>
	<1304027480.2971.121.camel@work-vm>
	<alpine.LFD.2.02.1104282353140.3005@ionos>
Date: Fri, 29 Apr 2011 01:06:52 +0200
Message-ID: <BANLkTi=uDstjKEQaPOkxX94NxMQU2Pu5gA@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: john stultz <johnstul@us.ibm.com>, =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Fri, Apr 29, 2011 at 12:02 AM, Thomas Gleixner <tglx@linutronix.de> wrot=
e:
> On Thu, 28 Apr 2011, john stultz wrote:
>> On Thu, 2011-04-28 at 23:04 +0200, Thomas Gleixner wrote:
>> > /me suspects hrtimer changes to be the real culprit.
>>
>> I'm not seeing anything on right off, but it does smell like
>> e06383db9ec591696a06654257474b85bac1f8cb would be where such an issue
>> would crop up.
>>
>> Bruno, could you try checking out e06383db9ec, confirming it still
>> occurs (and then maybe seeing if it goes away at e06383db9ec^1)?
>>
>> I'll keep digging in the meantime.
>
> I found the bug already. The problem is that sched_init() calls
> init_rt_bandwidth() which calls hrtimer_init() _BEFORE_
> hrtimers_init() is called.
>
> That was unnoticed so far as the CLOCK id to hrtimer base conversion
> was hardcoded. Now we use a table which is set up at hrtimers_init(),
> so the bandwith hrtimer ends up on CLOCK_REALTIME because the table is
> in the bss.
>
> The patch below fixes this, by providing the table statically rather
> than runtime initialized. Though that whole ordering wants to be
> revisited.
>
> Thanks,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tglx
>
> --- linux-2.6.orig/kernel/hrtimer.c
> +++ linux-2.6/kernel/hrtimer.c
> @@ -81,7 +81,11 @@ DEFINE_PER_CPU(struct hrtimer_cpu_base,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0};
>
> -static int hrtimer_clock_to_base_table[MAX_CLOCKS];
> +static int hrtimer_clock_to_base_table[MAX_CLOCKS] =3D {
> + =C2=A0 =C2=A0 =C2=A0 [CLOCK_REALTIME] =3D HRTIMER_BASE_REALTIME,
> + =C2=A0 =C2=A0 =C2=A0 [CLOCK_MONOTONIC] =3D HRTIMER_BASE_MONOTONIC,
> + =C2=A0 =C2=A0 =C2=A0 [CLOCK_BOOTTIME] =3D HRTIMER_BASE_BOOTTIME,
> +};
>
> =C2=A0static inline int hrtimer_clockid_to_base(clockid_t clock_id)
> =C2=A0{
> @@ -1722,10 +1726,6 @@ static struct notifier_block __cpuinitda
>
> =C2=A0void __init hrtimers_init(void)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 hrtimer_clock_to_base_table[CLOCK_REALTIME] =3D HR=
TIMER_BASE_REALTIME;
> - =C2=A0 =C2=A0 =C2=A0 hrtimer_clock_to_base_table[CLOCK_MONOTONIC] =3D H=
RTIMER_BASE_MONOTONIC;
> - =C2=A0 =C2=A0 =C2=A0 hrtimer_clock_to_base_table[CLOCK_BOOTTIME] =3D HR=
TIMER_BASE_BOOTTIME;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0hrtimer_cpu_notify(&hrtimers_nb, (unsigned lon=
g)CPU_UP_PREPARE,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0(void *)(long)smp_processor_id());
> =C2=A0 =C2=A0 =C2=A0 =C2=A0register_cpu_notifier(&hrtimers_nb);
>
>
>

Looks good so far, no stalls or call-traces.

Really stressing with 20+ open tabs in firefox with flash-movie
running in one of them , tar-job, IRC-client etc.
I will run some more tests and collect data and send them later.

- Sedat -

P.S.: Patchset against linux-2.6-rcu.git#sedat.2011.04.23a where 0003
is from [2]

[1] http://git.us.kernel.org/?p=3Dlinux/kernel/git/paulmck/linux-2.6-rcu.gi=
t;a=3Dshortlog;h=3Drefs/heads/sedat.2011.04.23a
[2] https://patchwork.kernel.org/patch/739782/

$ l ../RCU-HOORAY/
insgesamt 40
drwxr-xr-x  2 sd sd  4096 29. Apr 01:02 .
drwxr-xr-x 35 sd sd 20480 29. Apr 01:01 ..
-rw-r--r--  1 sd sd   726 29. Apr 01:01
0001-Revert-rcu-restrict-TREE_RCU-to-SMP-builds-with-PREE.patch
-rw-r--r--  1 sd sd   735 29. Apr 01:01
0002-sched-Add-warning-when-RT-throttling-is-activated.patch
-rw-r--r--  1 sd sd  2376 29. Apr 01:01
0003-2.6.39-rc4-Kernel-leaking-memory-during-FS-scanning-.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
