Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2E5E69000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 02:15:05 -0400 (EDT)
Date: Wed, 27 Apr 2011 08:15:01 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110427081501.5ba28155@pluto.restena.lu>
In-Reply-To: <alpine.LFD.2.02.1104262314110.3323@ionos>
References: <20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
	<20110425190032.7904c95d@neptune.home>
	<BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
	<20110425203606.4e78246c@neptune.home>
	<20110425191607.GL2468@linux.vnet.ibm.com>
	<20110425231016.34b4293e@neptune.home>
	<BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
	<20110425214933.GO2468@linux.vnet.ibm.com>
	<20110426081904.0d2b1494@pluto.restena.lu>
	<20110426112756.GF4308@linux.vnet.ibm.com>
	<20110426183859.6ff6279b@neptune.home>
	<20110426190918.01660ccf@neptune.home>
	<BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	<alpine.LFD.2.02.1104262314110.3323@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, 27 Apr 2011 00:28:37 +0200 (CEST) Thomas Gleixner wrote:
> On Tue, 26 Apr 2011, Linus Torvalds wrote:
> > On Tue, Apr 26, 2011 at 10:09 AM, Bruno Pr=C3=A9mont wrote:
> > >
> > > Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
> > > context switches and exactly one non-voluntary one.
> > >
> > > In addition when rcu_kthread has stopped doing its work
> > > `swapoff $(swapdevice)` seems to block forever (at least normal shutd=
own
> > > blocks on disabling swap device).
> > > If I get to do it when I get back home I will manually try to swapoff
> > > and take process traces with sysrq-t.
> >=20
> > That "exactly one non-voluntary one" sounds like the smoking gun.
> >=20
> > Normally SCHED_FIFO runs until it voluntarily gives up the CPU. That's
> > kind of the point of SCHED_FIFO. Involuntary context switches happen
> > when some higher-priority SCHED_FIFO process becomes runnable (irq
> > handlers? You _do_ have CONFIG_IRQ_FORCED_THREADING=3Dy in your config
> > too), and maybe there is a bug in the runqueue handling for that case.
>=20
> The forced irq threading is only effective when you add the command
> line parameter "threadirqs". I don't see any irq threads in the ps
> outputs, so that's not the problem.
>=20
> Though the whole ps output is weird. There is only one thread/process
> which accumulated CPU time
>=20
> collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:14

Whole system does not have much uptime so it's quite expected that CPU
time remains low. collectd is the only daemon that has more work to do
(scan many files every 10s)
On the ps output with stopped build processes there should be some more
with accumulated CPU time... though looking at it only top and python
have accumulated anything.

Next time I can scan /proc/${PID}/ for more precise CPU times to see
how zero they are.

> All others show 0:00 CPU time - not only kthread_rcu.
>=20
> Bruno, are you running on real hardware or in a virtual machine?

It's real hardware (nforce420 chipset - aka first nforce generation -,
AMD Athlon 1800 CPU, 512MB of RAM out of which 32MB taken by
IGP, so something like 7-10 or so years old)

> Can you please enable CONFIG_SCHED_DEBUG and provide the output of
> /proc/sched_stat when the problem surfaces and a minute after the
> first snapshot?
>=20
> Also please apply the patch below and check, whether the printk shows
> up in your dmesg.

Will include in my testing when back home this evening. (Will have to
offload kernel compilations to a quicker box otherwise my evening will
be much too short...)

Bruno


> Thanks,
>=20
> 	tglx
>=20
> ---
>  kernel/sched_rt.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> Index: linux-2.6-tip/kernel/sched_rt.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6-tip.orig/kernel/sched_rt.c
> +++ linux-2.6-tip/kernel/sched_rt.c
> @@ -609,6 +609,7 @@ static int sched_rt_runtime_exceeded(str
> =20
>  	if (rt_rq->rt_time > runtime) {
>  		rt_rq->rt_throttled =3D 1;
> +		printk_once(KERN_WARNING "sched: RT throttling activated\n");
>  		if (rt_rq_throttled(rt_rq)) {
>  			sched_rt_rq_dequeue(rt_rq);
>  			return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
