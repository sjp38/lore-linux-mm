Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2DC1C9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 13:09:33 -0400 (EDT)
Date: Tue, 26 Apr 2011 19:09:18 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110426190918.01660ccf@neptune.home>
In-Reply-To: <20110426183859.6ff6279b@neptune.home>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Mike Frysinger <vapier.adi@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Tue, 26 April 2011 Bruno Pr=C3=A9mont <bonbons@linux-vserver.org> wrote:
> On Tue, 26 April 2011 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wro=
te:
> > On Tue, Apr 26, 2011 at 08:19:04AM +0200, Bruno Pr=C3=A9mont wrote:
> > > Though I will use the few minutes I have this evening to try to fetch
> > > kernel traces of running tasks with sysrq+t which may eventually give
> > > us a hint at where rcu_thread is stuck/waiting.
> >=20
> > This would be very helpful to me!
>=20
> Here it comes:
>=20
> rcu_kthread (when build processes are STOPped):
> [  836.050003] rcu_kthread     R running   7324     6      2 0x00000000
> [  836.050003]  dd473f28 00000046 5a000240 dd65207c dd407360 dd651d40 000=
0035c dd473ed8
> [  836.050003]  c10bf8a2 c14d63d8 dd65207c dd473f28 dd445040 dd445040 dd4=
73eec c10be848
> [  836.050003]  dd651d40 dd407360 ddfdca00 dd473f14 c10bfde2 00000000 000=
00001 000007b6
> [  836.050003] Call Trace:
> [  836.050003]  [<c10bf8a2>] ? check_object+0x92/0x210
> [  836.050003]  [<c10be848>] ? init_object+0x38/0x70
> [  836.050003]  [<c10bfde2>] ? free_debug_processing+0x112/0x1f0
> [  836.050003]  [<c103d9fd>] ? lock_timer_base+0x2d/0x70
> [  836.050003]  [<c13c8ec7>] schedule_timeout+0x137/0x280
> [  836.050003]  [<c10c02b8>] ? kmem_cache_free+0xe8/0x140
> [  836.050003]  [<c103db60>] ? sys_gettid+0x20/0x20
> [  836.050003]  [<c13c9064>] schedule_timeout_interruptible+0x14/0x20
> [  836.050003]  [<c10736e0>] rcu_kthread+0xa0/0xc0
> [  836.050003]  [<c104de00>] ? wake_up_bit+0x70/0x70
> [  836.050003]  [<c1073640>] ? rcu_process_callbacks+0x60/0x60
> [  836.050003]  [<c104d874>] kthread+0x74/0x80
> [  836.050003]  [<c104d800>] ? flush_kthread_worker+0x90/0x90
> [  836.050003]  [<c13caeb6>] kernel_thread_helper+0x6/0xd
>=20
> a few minutes later when build processes have been killed:
> [  966.930008] rcu_kthread     R running   7324     6      2 0x00000000
> [  966.930008]  dd473f28 00000046 5a000240 dd65207c dd407360 dd651d40 000=
0035c dd473ed8
> [  966.930008]  c10bf8a2 c14d63d8 dd65207c dd473f28 dd445040 dd445040 dd4=
73eec c10be848
> [  966.930008]  dd651d40 dd407360 ddfdca00 dd473f14 c10bfde2 00000000 000=
00001 000007b6
> [  966.930008] Call Trace:
> [  966.930008]  [<c10bf8a2>] ? check_object+0x92/0x210
> [  966.930008]  [<c10be848>] ? init_object+0x38/0x70
> [  966.930008]  [<c10bfde2>] ? free_debug_processing+0x112/0x1f0
> [  966.930008]  [<c103d9fd>] ? lock_timer_base+0x2d/0x70
> [  966.930008]  [<c13c8ec7>] schedule_timeout+0x137/0x280
> [  966.930008]  [<c10c02b8>] ? kmem_cache_free+0xe8/0x140
> [  966.930008]  [<c103db60>] ? sys_gettid+0x20/0x20
> [  966.930008]  [<c13c9064>] schedule_timeout_interruptible+0x14/0x20
> [  966.930008]  [<c10736e0>] rcu_kthread+0xa0/0xc0
> [  966.930008]  [<c104de00>] ? wake_up_bit+0x70/0x70
> [  966.930008]  [<c1073640>] ? rcu_process_callbacks+0x60/0x60
> [  966.930008]  [<c104d874>] kthread+0x74/0x80
> [  966.930008]  [<c104d800>] ? flush_kthread_worker+0x90/0x90
> [  966.930008]  [<c13caeb6>] kernel_thread_helper+0x6/0xd
>=20
> Attached (gzipped) the complete dmesg log (dmesg-t1 contains dmesg from b=
oot until
> after first sysrq+t  -- dmesg-t2 the output of sysrq+t 2 minutes later
> after having killed build processes).
> Just in case, I joined slabinfo.
> Ten minutes later rcu_kthread trace has not changed at all.

Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
context switches and exactly one non-voluntary one.

In addition when rcu_kthread has stopped doing its work
`swapoff $(swapdevice)` seems to block forever (at least normal shutdown
blocks on disabling swap device).
If I get to do it when I get back home I will manually try to swapoff
and take process traces with sysrq-t.

Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
