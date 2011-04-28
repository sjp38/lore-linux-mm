Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8CFD6B002D
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:55:19 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3SFskY1025953
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:54:47 -0700
Received: by eyd9 with SMTP id 9so1253989eyd.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:54:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
References: <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos>
 <alpine.LFD.2.02.1104281051090.19095@ionos> <BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com>
 <20110428102609.GJ2135@linux.vnet.ibm.com> <1303997401.7819.5.camel@marge.simson.net>
 <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 28 Apr 2011 08:48:39 -0700
Message-ID: <BANLkTi=-D80vqazya6aHfV0841SBkNPsSQ@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Mike Galbraith <efault@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 28, 2011 at 8:28 AM, Sedat Dilek <sedat.dilek@googlemail.com> wrote:
>
> From the very beginning it looked as the system is "stable" due to:

Actually, look here, right from the beginning that log is showing
total breakage:

  Thu Apr 28 16:49:51 CEST 2011
    .rt_time                       : 233.923773
  Thu Apr 28 16:50:06 CEST 2011
    .rt_time                       : 259.446506
  Thu Apr 28 16:50:22 CEST 2011
    .rt_time                       : 273.110840
  Thu Apr 28 16:50:37 CEST 2011
    .rt_time                       : 282.713537
  Thu Apr 28 16:50:52 CEST 2011
    .rt_time                       : 288.136013
  Thu Apr 28 16:51:07 CEST 2011
    .rt_time                       : 293.057088
..
  Thu Apr 28 16:58:29 CEST 2011
    .rt_time                       : 888.893877
  Thu Apr 28 16:58:44 CEST 2011
    .rt_time                       : 950.005460

iow, rt_time just constantly grows. You have that "sleep 15" between
every log entry, so rt_time growing by 10-100 ms every 15 seconds
obviously does mean that it's using real CPU time, but it's still well
in the "much less than 1% CPU" range. So the rcu thread is clearly
doing work, but equally clearly it should NOT be throttled.

But since it is constantly growing, at some point it _will_ hit that
magical "950ms total time used", and then it gets throttled. For no
good reason.

It shouldn't have been throttled in the first place, and then the
other bug - that it isn't apparently ever unthrottled - just makes it
not work at all.

So that whole throttling is totally broken.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
