Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 99D768D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:36:20 -0400 (EDT)
Date: Mon, 25 Apr 2011 20:36:06 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425203606.4e78246c@neptune.home>
In-Reply-To: <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
	<20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
	<20110425190032.7904c95d@neptune.home>
	<BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, 25 April 2011 Linus Torvalds wrote:
> On Mon, Apr 25, 2011 at 10:00 AM, Bruno Pr=C3=A9mont wrote:
> >
> > I hope tiny-rcu is not that broken... as it would mean driving any
> > PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compiling
> > packages (and probably also just unpacking larger tarballs or running
> > things like du).
>=20
> I'm sure that TINYRCU can be fixed if it really is the problem.
>=20
> So I just want to make sure that we know what the root cause of your
> problem is. It's quite possible that it _is_ a real leak of filp or
> something, but before possibly wasting time trying to figure that out,
> let's see if your config is to blame.

With changed config (PREEMPT=3Dy, TREE_PREEMPT_RCU=3Dy) I haven't reproduced
yet.

When I was reproducing with TINYRCU things went normally for some time
until suddenly slabs stopped being freed.

> > And with system doing nothing (except monitoring itself) memory usage
> > goes increasing all the time until it starves (well it seems to keep
> > ~20M free, pushing processes it can to swap). Config is just being
> > make oldconfig from working 2.6.38 kernel (answering default for new
> > options)
>=20
> How sure are you that the system really is idle? Quite frankly, the
> constant growing doesn't really look idle to me.

Except the SIGSTOPed build there is not much left, collectd running in
background (it polls /proc for process counts, fork rate, memory usage,
... opening, reading, closing the files -- scanning every 10 seconds),
slabtop on one terminal.

CPU activity was near-zero with 10%-20% spikes of system use every 10
minutes and io-wait when all cache had been pushed out.

> > Attached graph matching numbers of previous mail. (dropping caches was =
at
> > 17:55, system idle since then)
>=20
> Nothing at all going on in 'ps' during that time? And what does
> slabinfo say at that point now that kmemleak isn't dominating
> everything else?

ps definitely does not show anything special, 30 or so userspace processes.
Didn't check ls /proc/*/fd though. Will do at next occurrence.


Going to test further with various PREEMPT and RCU selections. Will report
back as I progress (but won't have much time tomorrow).

Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
