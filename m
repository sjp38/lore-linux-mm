Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 58A93900001
	for <linux-mm@kvack.org>; Sat, 30 Apr 2011 05:14:17 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2955296qyk.14
        for <linux-mm@kvack.org>; Sat, 30 Apr 2011 02:14:15 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20110429221450.5af5d22b@neptune.home>
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
	<20110429221450.5af5d22b@neptune.home>
Date: Sat, 30 Apr 2011 11:14:15 +0200
Message-ID: <BANLkTikLoKbVQUQtScW0ihT+by9tu-+Yew@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, john stultz <johnstul@us.ibm.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Fri, Apr 29, 2011 at 10:14 PM, Bruno Pr=C3=A9mont
<bonbons@linux-vserver.org> wrote:
> On Fri, 29 April 2011 Thomas Gleixner wrote:
>> On Fri, 29 Apr 2011, Bruno Pr=C3=A9mont wrote:
>> > On Fri, 29 April 2011 Thomas Gleixner wrote:
>> > > On Thu, 28 Apr 2011, john stultz wrote:
>> > > > On Thu, 2011-04-28 at 23:04 +0200, Thomas Gleixner wrote:
>> > > > > /me suspects hrtimer changes to be the real culprit.
>> > > >
>> > > > I'm not seeing anything on right off, but it does smell like
>> > > > e06383db9ec591696a06654257474b85bac1f8cb would be where such an is=
sue
>> > > > would crop up.
>> > > >
>> > > > Bruno, could you try checking out e06383db9ec, confirming it still
>> > > > occurs (and then maybe seeing if it goes away at e06383db9ec^1)?
>> > > >
>> > > > I'll keep digging in the meantime.
>> > >
>> > > I found the bug already. The problem is that sched_init() calls
>> > > init_rt_bandwidth() which calls hrtimer_init() _BEFORE_
>> > > hrtimers_init() is called.
>> > >
>> > > That was unnoticed so far as the CLOCK id to hrtimer base conversion
>> > > was hardcoded. Now we use a table which is set up at hrtimers_init()=
,
>> > > so the bandwith hrtimer ends up on CLOCK_REALTIME because the table =
is
>> > > in the bss.
>> > >
>> > > The patch below fixes this, by providing the table statically rather
>> > > than runtime initialized. Though that whole ordering wants to be
>> > > revisited.
>> >
>> > Works here as well (applied alone), /proc/$(pidof rcu_kthread)/sched s=
hows
>> > total runtime continuing to increase beyond 950 and slubs continue bei=
ng
>> > released!
>>
>> Does the CPU time show up in top/ps as well now ?
>
> Yes, it does (currently at 0:09 in ps for 9336.075 in
> /proc/$(pidof rcu_kthread)/sched)
>
> Thanks,
> Bruno
>

Just FYI: The patch is now in mainline (2.6.39-rc5-git3).

- Sedat -

[1] http://git.us.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommit;h=3Dce31332d3c77532d6ea97ddcb475a2b02dd358b4
[2] http://www.kernel.org/diff/diffview.cgi?file=3D/pub/linux/kernel/v2.6/s=
napshots/patch-2.6.39-rc5-git3.bz2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
