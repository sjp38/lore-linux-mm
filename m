Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FD376B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 14:41:56 -0400 (EDT)
Date: Wed, 27 Apr 2011 20:41:39 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110427204139.1b0ea23b@neptune.home>
In-Reply-To: <20110427081501.5ba28155@pluto.restena.lu>
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
	<20110427081501.5ba28155@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/rD33rqvMsowUUXjcTUxWjtu"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

--MP_/rD33rqvMsowUUXjcTUxWjtu
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wed, 27 April 2011 Bruno Pr=C3=A9mont wrote:
> On Wed, 27 Apr 2011 00:28:37 +0200 (CEST) Thomas Gleixner wrote:
> > On Tue, 26 Apr 2011, Linus Torvalds wrote:
> > > On Tue, Apr 26, 2011 at 10:09 AM, Bruno Pr=C3=A9mont wrote:
> > > >
> > > > Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
> > > > context switches and exactly one non-voluntary one.
> > > >
> > > > In addition when rcu_kthread has stopped doing its work
> > > > `swapoff $(swapdevice)` seems to block forever (at least normal shu=
tdown
> > > > blocks on disabling swap device).

Apparently it's not swapoff but `umount -a -t tmpfs` that's getting
stuck here. Manual swapoff worked.

The stuck umount:
[ 1714.960735] umount          D 5a000040  5668 20331  20324 0x00000000
[ 1714.960735]  c3c99e5c 00000086 dd407900 5a000040 dd25a1a8 dd407900 dd25a=
120 c3c99e0c
[ 1714.960735]  c3c99e24 c10c1be2 c14d9f20 c3c99e5c c3c8c680 c3c8c680 00000=
0bb c3c99e24
[ 1714.960735]  c10c0b88 dd25a120 dd407900 ddfd4b40 c3c99e4c ddfc9d20 dd402=
380 5a000010
[ 1714.960735] Call Trace:
[ 1714.960735]  [<c10c1be2>] ? check_object+0x92/0x210
[ 1714.960735]  [<c10c0b88>] ? init_object+0x38/0x70
[ 1714.960735]  [<c10c1be2>] ? check_object+0x92/0x210
[ 1714.960735]  [<c13cb37d>] schedule_timeout+0x16d/0x280
[ 1714.960735]  [<c10c0b88>] ? init_object+0x38/0x70
[ 1714.960735]  [<c10c2122>] ? free_debug_processing+0x112/0x1f0
[ 1714.960735]  [<c10a3791>] ? shmem_put_super+0x11/0x20
[ 1714.960735]  [<c13cae9c>] wait_for_common+0x9c/0x150
[ 1714.960735]  [<c102c890>] ? try_to_wake_up+0x170/0x170
[ 1714.960735]  [<c13caff2>] wait_for_completion+0x12/0x20
[ 1714.960735]  [<c1075ad7>] rcu_barrier_sched+0x47/0x50
[ 1714.960735]  [<c104d3c0>] ? alloc_pid+0x370/0x370
[ 1714.960735]  [<c10ce74a>] deactivate_locked_super+0x3a/0x60
[ 1714.960735]  [<c10ce948>] deactivate_super+0x48/0x70
[ 1714.960735]  [<c10e7427>] mntput_no_expire+0x87/0xe0
[ 1714.960735]  [<c10e7800>] sys_umount+0x60/0x320
[ 1714.960735]  [<c10b231a>] ? remove_vma+0x3a/0x50
[ 1714.960735]  [<c10b3b22>] ? do_munmap+0x212/0x2f0
[ 1714.960735]  [<c10e7ad9>] sys_oldumount+0x19/0x20
[ 1714.960735]  [<c13cce10>] sysenter_do_call+0x12/0x26

which looks like lock conflict with RCU:

[ 1714.960735] rcu_kthread     R running   6924     6      2 0x00000000
[ 1714.960735]  dd473f28 00000046 5a000240 dbd6ba7c dd407360 ddfaf840 dbd6b=
740 dd473ed8
[ 1714.960735]  ddfaee00 dd407a20 5a000000 dd473f28 dd445040 dd445040 00000=
09c dd473f0c
[ 1714.960735]  c10c1be2 c14d9f20 dbf7057c 0000005a 000000bb 000000bb dd473=
f0c c10c0b88
[ 1714.960735] Call Trace:
[ 1714.960735]  [<c10c1be2>] ? check_object+0x92/0x210
[ 1714.960735]  [<c10c0b88>] ? init_object+0x38/0x70
[ 1714.960735]  [<c103fd8d>] ? lock_timer_base+0x2d/0x70
[ 1714.960735]  [<c13cb347>] schedule_timeout+0x137/0x280
[ 1714.960735]  [<c103fef0>] ? sys_gettid+0x20/0x20
[ 1714.960735]  [<c13cb4e4>] schedule_timeout_interruptible+0x14/0x20
[ 1714.960735]  [<c1075a70>] rcu_kthread+0xa0/0xc0
[ 1714.960735]  [<c1050190>] ? wake_up_bit+0x70/0x70
[ 1714.960735]  [<c10759d0>] ? rcu_process_callbacks+0x60/0x60
[ 1714.960735]  [<c104fc04>] kthread+0x74/0x80
[ 1714.960735]  [<c104fb90>] ? flush_kthread_worker+0x90/0x90
[ 1714.960735]  [<c13cd336>] kernel_thread_helper+0x6/0xd

(I have rest of sysreq+t output available in case someone wants it)

> > > > If I get to do it when I get back home I will manually try to swapo=
ff
> > > > and take process traces with sysrq-t.
> > >=20
> > > That "exactly one non-voluntary one" sounds like the smoking gun.

It's not the gun we're looking for as it's already smoking long before
any RCU-managed slabs start piling up (e.g. already when I get at a
shell after boot sequence).

Voluntary context switches stay constant from the time on SLABs pile up.
(which makes sense as it doesn't run get CPU slices anymore)

> > Can you please enable CONFIG_SCHED_DEBUG and provide the output of
> > /proc/sched_stat when the problem surfaces and a minute after the
> > first snapshot?

hm, did you mean CONFIG_SCHEDSTAT or /proc/sched_debug?

I did use CONFIG_SCHED_DEBUG (and there is no /proc/sched_stat) so I took
/proc/sched_debug which exists... (attached, taken about 7min and +1min
after SLABs started piling up), though build processes were SIGSTOPped
during first minute.

printk wrote (in case its timestamp is useful, more below):
[  518.480103] sched: RT throttling activated

If my choice was the wrong one, please tell so I can generate the other
ones.

> > Also please apply the patch below and check, whether the printk shows
> > up in your dmesg.
>=20
> > Index: linux-2.6-tip/kernel/sched_rt.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6-tip.orig/kernel/sched_rt.c
> > +++ linux-2.6-tip/kernel/sched_rt.c
> > @@ -609,6 +609,7 @@ static int sched_rt_runtime_exceeded(str
> > =20
> >  	if (rt_rq->rt_time > runtime) {
> >  		rt_rq->rt_throttled =3D 1;
> > +		printk_once(KERN_WARNING "sched: RT throttling activated\n");

This gun is triggering right before RCU-managed slabs start piling up as
visible under slabtop so chances are it's at least a related!

Bruno


> >  		if (rt_rq_throttled(rt_rq)) {
> >  			sched_rt_rq_dequeue(rt_rq);
> >  			return 1;

--MP_/rD33rqvMsowUUXjcTUxWjtu
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=sched_debug-n

Sched Debug Version: v0.10, 2.6.39-rc4-jupiter1-00187-g686c4cb-dirty #3
ktime                                   : 905613.047984
sched_clk                               : 905964.436991
cpu_clk                                 : 905613.047795
jiffies                                 : 60561
sched_clock_stable                      : 0

sysctl_sched
  .sysctl_sched_latency                    : 6.000000
  .sysctl_sched_min_granularity            : 0.750000
  .sysctl_sched_wakeup_granularity         : 1.000000
  .sysctl_sched_child_runs_first           : 0
  .sysctl_sched_features                   : 7279
  .sysctl_sched_tunable_scaling            : 1 (logaritmic)

cpu#0, 1536.952 MHz
  .nr_running                    : 3
  .load                          : 1024
  .nr_switches                   : 256821
  .nr_load_updates               : 34218
  .nr_uninterruptible            : 0
  .next_balance                  : 0.000000
  .curr->pid                     : 20302
  .clock                         : 905610.184134
  .cpu_load[0]                   : 1024
  .cpu_load[1]                   : 512
  .cpu_load[2]                   : 256
  .cpu_load[3]                   : 128
  .cpu_load[4]                   : 64

cfs_rq[0]:/autogroup-31
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 32.428483
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250290.624883
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 48651.034996
  .se->vruntime                  : 11386.544607
  .se->sum_exec_runtime          : 33.477059
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-30
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 4.750914
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250318.302452
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 48650.930709
  .se->vruntime                  : 11383.513621
  .se->sum_exec_runtime          : 5.799490
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-29
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 1.259565
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250321.793801
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 47345.196993
  .se->vruntime                  : 11143.631354
  .se->sum_exec_runtime          : 2.308141
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-27
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 5.664943
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250317.388423
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 46773.145157
  .se->vruntime                  : 10850.993742
  .se->sum_exec_runtime          : 6.713519
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-25
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 12.001858
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250311.051508
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 884979.311623
  .se->vruntime                  : 250196.905043
  .se->sum_exec_runtime          : 13.050434
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-23
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 0.704941
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250322.348425
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 33068.602462
  .se->vruntime                  : 10100.905811
  .se->sum_exec_runtime          : 1.753517
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-21
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 11731.456625
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -238591.596741
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 900349.982653
  .se->vruntime                  : 250318.886477
  .se->sum_exec_runtime          : 4895.135656
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-19
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 47.286940
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250275.766426
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 900927.938404
  .se->vruntime                  : 250315.931378
  .se->sum_exec_runtime          : 48.335516
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-17
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 357.298120
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -249965.755246
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 650398.332497
  .se->vruntime                  : 248631.217388
  .se->sum_exec_runtime          : 358.346696
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-16
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 8.865868
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250314.187498
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 23672.153504
  .se->vruntime                  : 9597.142868
  .se->sum_exec_runtime          : 4.501025
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-14
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 0.379704
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250323.433070
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 24113.709183
  .se->vruntime                  : 9701.835305
  .se->sum_exec_runtime          : 0.668872
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-13
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 899.191622
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -249423.861744
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 900715.342667
  .se->vruntime                  : 250318.391635
  .se->sum_exec_runtime          : 896.780102
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-12
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 7881.771616
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -242441.281750
  .nr_spread_over                : 0
  .nr_running                    : 1
  .load                          : 1024
  .se->exec_start                : 901282.397156
  .se->vruntime                  : 250323.053366
  .se->sum_exec_runtime          : 7886.452282
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-11
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 327444.606138
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : 77121.552772
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 590827.086481
  .se->vruntime                  : 246807.766077
  .se->sum_exec_runtime          : 227004.896350
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-9
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 4.901558
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250318.151808
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 16353.807059
  .se->vruntime                  : 8798.213404
  .se->sum_exec_runtime          : 5.864229
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-8
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 5.092357
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250317.961009
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 16351.804335
  .se->vruntime                  : 8798.060733
  .se->sum_exec_runtime          : 6.047419
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-4
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 194.043637
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250129.009729
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 214180.833484
  .se->vruntime                  : 16973.019690
  .se->sum_exec_runtime          : 1179.311396
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-1
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 46.620704
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250276.432662
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 900942.773257
  .se->vruntime                  : 250316.002285
  .se->sum_exec_runtime          : 49.120925
  .se->load.weight               : 1024

cfs_rq[0]:/
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 250323.053366
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : 0.000000
  .nr_spread_over                : 0
  .nr_running                    : 1
  .load                          : 1024

rt_rq[0]:
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.008387
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
     rcu_kthread     6         0.000000     24701    98               0               0               0.000000               0.000000               0.000000 /
      watchdog/0     7         0.000000       154     0               0               0               0.000000               0.000000               0.000000 /
R            cat 20302      7884.303335         0   120               0               0               0.000000               0.000000               0.000000 /autogroup-12


--MP_/rD33rqvMsowUUXjcTUxWjtu
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=sched_debug-n+60

Sched Debug Version: v0.10, 2.6.39-rc4-jupiter1-00187-g686c4cb-dirty #3
ktime                                   : 965620.925133
sched_clk                               : 965968.533388
cpu_clk                                 : 965620.925129
jiffies                                 : 66562
sched_clock_stable                      : 0

sysctl_sched
  .sysctl_sched_latency                    : 6.000000
  .sysctl_sched_min_granularity            : 0.750000
  .sysctl_sched_wakeup_granularity         : 1.000000
  .sysctl_sched_child_runs_first           : 0
  .sysctl_sched_features                   : 7279
  .sysctl_sched_tunable_scaling            : 1 (logaritmic)

cpu#0, 1536.952 MHz
  .nr_running                    : 4
  .load                          : 2048
  .nr_switches                   : 258178
  .nr_load_updates               : 34735
  .nr_uninterruptible            : 0
  .next_balance                  : 0.000000
  .curr->pid                     : 20304
  .clock                         : 965620.017504
  .cpu_load[0]                   : 2048
  .cpu_load[1]                   : 1024
  .cpu_load[2]                   : 512
  .cpu_load[3]                   : 256
  .cpu_load[4]                   : 129

cfs_rq[0]:/autogroup-31
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 32.428483
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250659.411324
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 48651.034996
  .se->vruntime                  : 11386.544607
  .se->sum_exec_runtime          : 33.477059
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-30
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 4.750914
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250687.088893
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 48650.930709
  .se->vruntime                  : 11383.513621
  .se->sum_exec_runtime          : 5.799490
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-29
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 1.259565
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250690.580242
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 47345.196993
  .se->vruntime                  : 11143.631354
  .se->sum_exec_runtime          : 2.308141
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-27
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 5.664943
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250686.174864
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 46773.145157
  .se->vruntime                  : 10850.993742
  .se->sum_exec_runtime          : 6.713519
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-25
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 12.062566
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250679.777241
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 944999.839634
  .se->vruntime                  : 250569.218332
  .se->sum_exec_runtime          : 13.111142
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-23
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 0.704941
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250691.134866
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 33068.602462
  .se->vruntime                  : 10100.905811
  .se->sum_exec_runtime          : 1.753517
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-21
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 12601.382211
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -238090.457596
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 960317.931144
  .se->vruntime                  : 250691.825513
  .se->sum_exec_runtime          : 5246.772916
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-19
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 49.695928
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250642.143879
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 960895.765697
  .se->vruntime                  : 250688.869265
  .se->sum_exec_runtime          : 50.744504
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-17
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 357.298120
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250334.541687
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 650398.332497
  .se->vruntime                  : 248631.217388
  .se->sum_exec_runtime          : 358.346696
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-16
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 8.865868
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250682.973939
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 23672.153504
  .se->vruntime                  : 9597.142868
  .se->sum_exec_runtime          : 4.501025
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-14
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 0.379704
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250692.219511
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 24113.709183
  .se->vruntime                  : 9701.835305
  .se->sum_exec_runtime          : 0.668872
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-13
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 948.016263
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -249743.823544
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 960791.018110
  .se->vruntime                  : 250691.430149
  .se->sum_exec_runtime          : 945.604743
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-12
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 7896.659461
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -242795.180346
  .nr_spread_over                : 0
  .nr_running                    : 1
  .load                          : 1024
  .se->exec_start                : 961260.183602
  .se->vruntime                  : 250691.669201
  .se->sum_exec_runtime          : 7896.210852
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-11
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 327444.606138
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : 76752.766331
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 590827.086481
  .se->vruntime                  : 246807.766077
  .se->sum_exec_runtime          : 227004.896350
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-9
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 4.901558
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250686.938249
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 16353.807059
  .se->vruntime                  : 8798.213404
  .se->sum_exec_runtime          : 5.864229
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-8
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 5.092357
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250686.747450
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 16351.804335
  .se->vruntime                  : 8798.060733
  .se->sum_exec_runtime          : 6.047419
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-4
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 194.043637
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250497.796170
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 214180.833484
  .se->vruntime                  : 16973.019690
  .se->sum_exec_runtime          : 1179.311396
  .se->load.weight               : 1024

cfs_rq[0]:/autogroup-1
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 0.000001
  .min_vruntime                  : 48.036315
  .max_vruntime                  : 0.000001
  .spread                        : 0.000000
  .spread0                       : -250643.803492
  .nr_spread_over                : 0
  .nr_running                    : 0
  .load                          : 0
  .se->exec_start                : 960971.811607
  .se->vruntime                  : 250688.941814
  .se->sum_exec_runtime          : 50.536536
  .se->load.weight               : 1024

cfs_rq[0]:/
  .exec_clock                    : 0.000000
  .MIN_vruntime                  : 250691.839807
  .min_vruntime                  : 250691.839807
  .max_vruntime                  : 250691.839807
  .spread                        : 0.000000
  .spread0                       : 0.000000
  .nr_spread_over                : 0
  .nr_running                    : 2
  .load                          : 2048

rt_rq[0]:
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.008387
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
     rcu_kthread     6         0.000000     24701    98               0               0               0.000000               0.000000               0.000000 /
      watchdog/0     7         0.000000       154     0               0               0               0.000000               0.000000               0.000000 /
R            cat 20304      7896.659461         0   120               0               0               0.000000               0.000000               0.000000 /autogroup-12


--MP_/rD33rqvMsowUUXjcTUxWjtu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
