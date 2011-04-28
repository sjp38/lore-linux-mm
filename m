Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 801BF6B0012
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:44:58 -0400 (EDT)
Date: Thu, 28 Apr 2011 22:44:44 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110428224444.43107883@neptune.home>
In-Reply-To: <alpine.LFD.2.02.1104282227340.3005@ionos>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: sedat.dilek@gmail.com, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 28 April 2011 Thomas Gleixner wrote:
> On Thu, 28 Apr 2011, Bruno Pr=C3=A9mont wrote:
> > On Thu, 28 April 2011 Thomas Gleixner wrote:
> > > -	return idle ? HRTIMER_NORESTART : HRTIMER_RESTART;
> > > +	return HRTIMER_RESTART;
> >=20
> > This doesn't help here.
> > Be it applied on top of the others, full diff attached
> > or applied alone (with throttling printk).
> >=20
> > Could it be that NO_HZ=3Dy has some importance in this matter?
>=20
> Might be. Can you try with nohz=3Doff on the kernel command line ?

Doesn't make any visible difference (tested with "applied alone" kernel
as of above).

> Can you please provide the output of /proc/timer_list ?

See below,
Bruno



Timer List Version: v0.6
HRTIMER_MAX_CLOCK_BASES: 3
now at 1150126155286 nsecs

cpu: 0
 clock 0:
  .base:       c1559360
  .index:      0
  .resolution: 1 nsecs
  .get_time:   ktime_get_real
  .offset:     1304021489280954699 nsecs
active timers:
 #0: def_rt_bandwidth, sched_rt_period_timer, S:01, enqueue_task_rt, swappe=
r/1
 # expires at 1304028703000000000-1304028703000000000 nsecs [in 13040275528=
73844714 to 1304027552873844714 nsecs]
 clock 1:
  .base:       c155938c
  .index:      1
  .resolution: 1 nsecs
  .get_time:   ktime_get
  .offset:     0 nsecs
active timers:
 #0: tick_cpu_sched, tick_sched_timer, S:01, hrtimer_start_range_ns, swappe=
r/0
 # expires at 1150130000000-1150130000000 nsecs [in 3844714 to 3844714 nsec=
s]
 #1: <dd612844>, it_real_fn, S:01, hrtimer_start, ntpd/1623
 # expires at 1150443573670-1150443573670 nsecs [in 317418384 to 317418384 =
nsecs]
 #2: <dd443ad4>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, init/1
 # expires at 1150450113736-1150455113735 nsecs [in 323958450 to 328958449 =
nsecs]
 #3: <db6bbad4>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, slabtop/1817
 # expires at 1152632990798-1152635990795 nsecs [in 2506835512 to 250983550=
9 nsecs]
 #4: watchdog_hrtimer, watchdog_timer_fn, S:01, hrtimer_start, watchdog/0/7
 # expires at 1152742107906-1152742107906 nsecs [in 2615952620 to 261595262=
0 nsecs]
 #5: <dce4be54>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, collectd/1647
 # expires at 1159748146627-1159748196627 nsecs [in 9621991341 to 962204134=
1 nsecs]
 #6: <daf75e54>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, collectd/1644
 # expires at 1159748971801-1159749021801 nsecs [in 9622816515 to 962286651=
5 nsecs]
 #7: <dce49e54>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, collectd/1646
 # expires at 1159749646863-1159749696863 nsecs [in 9623491577 to 962354157=
7 nsecs]
 #8: <daf77e54>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, collectd/1645
 # expires at 1159750273989-1159750323989 nsecs [in 9624118703 to 962416870=
3 nsecs]
 #9: <dbd51e54>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, collectd/1643
 # expires at 1159751170319-1159751220319 nsecs [in 9625015033 to 962506503=
3 nsecs]
 #10: <db687f44>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, collectd/16=
41
 # expires at 1159884463552-1159884513552 nsecs [in 9758308266 to 975835826=
6 nsecs]
 #11: <db6bdb6c>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, rpcbind/1699
 # expires at 1164510072442-1164540072440 nsecs [in 14383917156 to 14413917=
154 nsecs]
 #12: <dccbbb6c>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, syslog-ng/1=
599
 # expires at 1859759077032-1859859077032 nsecs [in 709632921746 to 7097329=
21746 nsecs]
 #13: <dce2bb6c>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, dhcpcd/1557
 # expires at 86432406451906-86432506451906 nsecs [in 85282280296620 to 852=
82380296620 nsecs]
 #14: <dccbdad4>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, gpm/1659
 # expires at 86440042646716-86440142646716 nsecs [in 85289916491430 to 852=
90016491430 nsecs]
 clock 2:
  .base:       c15593b8
  .index:      7
  .resolution: 1 nsecs
  .get_time:   ktime_get_boottime
  .offset:     0 nsecs
active timers:
  .expires_next   : 1150130000000 nsecs
  .hres_active    : 1
  .nr_events      : 62851
  .nr_retries     : 1232
  .nr_hangs       : 0
  .max_hang_time  : 0 nsecs
  .nohz_mode      : 2
  .idle_tick      : 1150120000000 nsecs
  .tick_stopped   : 0
  .idle_jiffies   : 85011
  .idle_calls     : 59192
  .idle_sleeps    : 23733
  .idle_entrytime : 1150123805083 nsecs
  .idle_waketime  : 1150123805083 nsecs
  .idle_exittime  : 1150123876750 nsecs
  .idle_sleeptime : 861310470458 nsecs
  .iowait_sleeptime: 72683738430 nsecs
  .last_jiffies   : 85011
  .next_jiffies   : 85017
  .idle_expires   : 1150170000000 nsecs
jiffies: 85012


Tick Device: mode:     1
Broadcast device
Clock Event Device: pit
 max_delta_ns:   27461866
 min_delta_ns:   12571
 mult:           5124677
 shift:          32
 mode:           3
 next_event:     9223372036854775807 nsecs
 set_next_event: pit_next_event
 set_mode:       init_pit_timer
 event_handler:  tick_handle_oneshot_broadcast
 retries:        0
tick_broadcast_mask: 00000000
tick_broadcast_oneshot_mask: 00000000


Tick Device: mode:     1
Per CPU device: 0
Clock Event Device: lapic
 max_delta_ns:   128554655331
 min_delta_ns:   1000
 mult:           71746698
 shift:          32
 mode:           3
 next_event:     1150130000000 nsecs
 set_next_event: lapic_next_event
 set_mode:       lapic_timer_setup
 event_handler:  hrtimer_interrupt
 retries:        1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
