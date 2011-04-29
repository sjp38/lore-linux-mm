Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4BBDD900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 16:15:05 -0400 (EDT)
Date: Fri, 29 Apr 2011 22:14:50 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110429221450.5af5d22b@neptune.home>
In-Reply-To: <alpine.LFD.2.02.1104292209220.3005@ionos>
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
	<20110429213100.75f771eb@neptune.home>
	<alpine.LFD.2.02.1104292209220.3005@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: john stultz <johnstul@us.ibm.com>, sedat.dilek@gmail.com, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Fri, 29 April 2011 Thomas Gleixner wrote:
> On Fri, 29 Apr 2011, Bruno Pr=C3=A9mont wrote:
> > On Fri, 29 April 2011 Thomas Gleixner wrote:
> > > On Thu, 28 Apr 2011, john stultz wrote:
> > > > On Thu, 2011-04-28 at 23:04 +0200, Thomas Gleixner wrote:
> > > > > /me suspects hrtimer changes to be the real culprit.
> > > >=20
> > > > I'm not seeing anything on right off, but it does smell like
> > > > e06383db9ec591696a06654257474b85bac1f8cb would be where such an iss=
ue
> > > > would crop up.
> > > >=20
> > > > Bruno, could you try checking out e06383db9ec, confirming it still
> > > > occurs (and then maybe seeing if it goes away at e06383db9ec^1)?
> > > >=20
> > > > I'll keep digging in the meantime.
> > >=20
> > > I found the bug already. The problem is that sched_init() calls
> > > init_rt_bandwidth() which calls hrtimer_init() _BEFORE_
> > > hrtimers_init() is called.
> > >=20
> > > That was unnoticed so far as the CLOCK id to hrtimer base conversion
> > > was hardcoded. Now we use a table which is set up at hrtimers_init(),
> > > so the bandwith hrtimer ends up on CLOCK_REALTIME because the table is
> > > in the bss.
> > >=20
> > > The patch below fixes this, by providing the table statically rather
> > > than runtime initialized. Though that whole ordering wants to be
> > > revisited.
> >=20
> > Works here as well (applied alone), /proc/$(pidof rcu_kthread)/sched sh=
ows
> > total runtime continuing to increase beyond 950 and slubs continue being
> > released!
>=20
> Does the CPU time show up in top/ps as well now ?

Yes, it does (currently at 0:09 in ps for 9336.075 in
/proc/$(pidof rcu_kthread)/sched)

Thanks,
Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
