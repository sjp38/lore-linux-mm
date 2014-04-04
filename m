Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFE76B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 01:00:38 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id l6so3023097oag.39
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 22:00:38 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id i2si6005894oeu.210.2014.04.03.22.00.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 22:00:37 -0700 (PDT)
Message-ID: <1396587632.2499.5.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: disable shmmax and shmall by default
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 03 Apr 2014 22:00:32 -0700
In-Reply-To: <CAHGf_=rT7WswD0LOxVeDDpae-Ahaz4wEcpE8HLmDwOBw598z8g@mail.gmail.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <20140331170546.3b3e72f0.akpm@linux-foundation.org>
	 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
	 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
	 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
	 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
	 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
	 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
	 <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com>
	 <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com>
	 <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
	 <533DB03D.7010308@colorfullife.com>
	 <1396554637.2550.11.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rT7WswD0LOxVeDDpae-Ahaz4wEcpE8HLmDwOBw598z8g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, 2014-04-03 at 19:39 -0400, KOSAKI Motohiro wrote:
> On Thu, Apr 3, 2014 at 3:50 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > On Thu, 2014-04-03 at 21:02 +0200, Manfred Spraul wrote:
> >> Hi Davidlohr,
> >>
> >> On 04/03/2014 02:20 AM, Davidlohr Bueso wrote:
> >> > The default size for shmmax is, and always has been, 32Mb.
> >> > Today, in the XXI century, it seems that this value is rather small,
> >> > making users have to increase it via sysctl, which can cause
> >> > unnecessary work and userspace application workarounds[1].
> >> >
> >> > Instead of choosing yet another arbitrary value, larger than 32Mb,
> >> > this patch disables the use of both shmmax and shmall by default,
> >> > allowing users to create segments of unlimited sizes. Users and
> >> > applications that already explicitly set these values through sysctl
> >> > are left untouched, and thus does not change any of the behavior.
> >> >
> >> > So a value of 0 bytes or pages, for shmmax and shmall, respectively,
> >> > implies unlimited memory, as opposed to disabling sysv shared memory.
> >> > This is safe as 0 cannot possibly be used previously as SHMMIN is
> >> > hardcoded to 1 and cannot be modified.
> >
> >> Are we sure that no user space apps uses shmctl(IPC_INFO) and prints a
> >> pretty error message if shmall is too small?
> >> We would break these apps.
> >
> > Good point. 0 bytes/pages would definitely trigger an unexpected error
> > message if users did this. But on the other hand I'm not sure this
> > actually is a _real_ scenario, since upon overflow the value can still
> > end up being 0, which is totally bogus and would cause the same
> > breakage.
> >
> > So I see two possible workarounds:
> > (i) Use ULONG_MAX for the shmmax default instead. This would make shmall
> > default to 1152921504606846720 and 268435456, for 64 and 32bit systems,
> > respectively.
> >
> > (ii) Keep the 0 bytes, but add a new a "transition" tunable that, if set
> > (default off), would allow 0 bytes to be unlimited. With time, users
> > could hopefully update their applications and we could eventually get
> > rid of it. This _seems_ to be the less aggressive way to go.
> 
> Do you mean
> 
> set 0: IPC_INFO return shmmax = 0.
> set 1: IPC_INFO return shmmax = ULONG_MAX.
> 
> ?
> 
> That makes sense.

Well I was mostly referring to:

set 0: leave things as there are now.
set 1: this patch.

I don't think it makes much sense to set unlimited for both 0 and
ULONG_MAX, that would probably just create even more confusion. 

But then again, we shouldn't even care about breaking things with shmmax
or shmall with 0 value, it just makes no sense from a user PoV. shmmax
cannot be 0 unless there's an overflow, which voids any valid cases, and
thus shmall cannot be 0 either as it would go against any values set for
shmmax. I think it's safe to ignore this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
