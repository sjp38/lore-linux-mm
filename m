Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C537C8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:00:48 -0400 (EDT)
Date: Mon, 25 Apr 2011 19:00:32 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425190032.7904c95d@neptune.home>
In-Reply-To: <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
	<20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/vrAER.CnzSaKkVhqSuKkUhO"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

--MP_/vrAER.CnzSaKkVhqSuKkUhO
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Mon, 25 April 2011 Linus Torvalds wrote:
> 2011/4/25 Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>:
> >
> > kmemleak reports 86681 new leaks between shortly after boot and -2 stat=
e.
> > (and 2348 additional ones between -2 and -4).
>=20
> I wouldn't necessarily trust kmemleak with the whole RCU-freeing
> thing. In your slubinfo reports, the kmemleak data itself also tends
> to overwhelm everything else - none of it looks unreasonable per se.
>=20
> That said, you clearly have a *lot* of filp entries. I wouldn't
> consider it unreasonable, though, because depending on load those may
> well be fine. Perhaps you really do have some application(s) that hold
> thousands of files open. The default file limit is 1024 (I think), but
> you can raise it, and some programs do end up opening tens of
> thousands of files for filesystem scanning purposes.
>=20
> That said, I would suggest simply trying a saner kernel configuration,
> and seeing if that makes a difference:
>=20
> > Yes, it's uni-processor system, so SMP=3Dn.
> > TINY_RCU=3Dy, PREEMPT_VOLUNTARY=3Dy (whole /proc/config.gz attached kee=
ping
> > compression)
>=20
> I'm not at all certain that TINY_RCU is appropriate for
> general-purpose loads. I'd call it more of a "embedded low-performance
> option".

Well, TINY_RCU is the only option when doing PREEMPT_VOLUNTARY on
SMP=3Dn...

> The _real_ RCU implementation ("tree rcu") forces quiescent states
> every few jiffies and has logic to handle "I've got tons of RCU
> events, I really need to start handling them now". All of which I
> think tiny-rcu lacks.

Going to try it out (will take some time to compile), kmemleak disabled.

> So right now I suspect that you have a situation where you just have a
> simple load that just ends up never triggering any RCU cleanup, and
> the tiny-rcu thing just keeps on gathering events and delays freeing
> stuff almost arbitrarily long.

I hope tiny-rcu is not that broken... as it would mean driving any
PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compiling
packages (and probably also just unpacking larger tarballs or running
things like du).

And with system doing nothing (except monitoring itself) memory usage
goes increasing all the time until it starves (well it seems to keep
~20M free, pushing processes it can to swap). Config is just being
make oldconfig from working 2.6.38 kernel (answering default for new
options)

Memory usage evolution graph in first message of this thread:
http://thread.gmane.org/gmane.linux.kernel.mm/61909/focus=3D1130480

Attached graph matching numbers of previous mail. (dropping caches was at
17:55, system idle since then)

Bruno


> So try CONFIG_PREEMPT and CONFIG_TREE_PREEMPT_RCU to see if the
> behavior goes away. That would confirm the "it's just tinyrcu being
> too dang stupid" hypothesis.
>=20
>                      Linus

--MP_/vrAER.CnzSaKkVhqSuKkUhO
Content-Type: image/png
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=jupiter.png

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

--MP_/vrAER.CnzSaKkVhqSuKkUhO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
