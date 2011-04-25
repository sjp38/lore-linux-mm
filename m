Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F17898D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 12:31:56 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3PGVOmU027798
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 09:31:26 -0700
Received: by ewy9 with SMTP id 9so1076333ewy.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 09:31:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425180450.1ede0845@neptune.home>
References: <20110424202158.45578f31@neptune.home> <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com> <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home> <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
 <20110425180450.1ede0845@neptune.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Apr 2011 09:31:03 -0700
Message-ID: <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

2011/4/25 Bruno Pr=E9mont <bonbons@linux-vserver.org>:
>
> kmemleak reports 86681 new leaks between shortly after boot and -2 state.
> (and 2348 additional ones between -2 and -4).

I wouldn't necessarily trust kmemleak with the whole RCU-freeing
thing. In your slubinfo reports, the kmemleak data itself also tends
to overwhelm everything else - none of it looks unreasonable per se.

That said, you clearly have a *lot* of filp entries. I wouldn't
consider it unreasonable, though, because depending on load those may
well be fine. Perhaps you really do have some application(s) that hold
thousands of files open. The default file limit is 1024 (I think), but
you can raise it, and some programs do end up opening tens of
thousands of files for filesystem scanning purposes.

That said, I would suggest simply trying a saner kernel configuration,
and seeing if that makes a difference:

> Yes, it's uni-processor system, so SMP=3Dn.
> TINY_RCU=3Dy, PREEMPT_VOLUNTARY=3Dy (whole /proc/config.gz attached keepi=
ng
> compression)

I'm not at all certain that TINY_RCU is appropriate for
general-purpose loads. I'd call it more of a "embedded low-performance
option".

The _real_ RCU implementation ("tree rcu") forces quiescent states
every few jiffies and has logic to handle "I've got tons of RCU
events, I really need to start handling them now". All of which I
think tiny-rcu lacks.

So right now I suspect that you have a situation where you just have a
simple load that just ends up never triggering any RCU cleanup, and
the tiny-rcu thing just keeps on gathering events and delays freeing
stuff almost arbitrarily long.

So try CONFIG_PREEMPT and CONFIG_TREE_PREEMPT_RCU to see if the
behavior goes away. That would confirm the "it's just tinyrcu being
too dang stupid" hypothesis.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
