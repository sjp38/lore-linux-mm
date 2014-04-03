Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3E26B005C
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 19:39:59 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so2778868obc.1
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 16:39:58 -0700 (PDT)
Received: from mail-oa0-x22c.google.com (mail-oa0-x22c.google.com [2607:f8b0:4003:c02::22c])
        by mx.google.com with ESMTPS id z8si5532197oex.146.2014.04.03.16.39.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 16:39:58 -0700 (PDT)
Received: by mail-oa0-f44.google.com with SMTP id n16so2804938oag.3
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 16:39:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1396554637.2550.11.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
 <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
 <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
 <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com>
 <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com>
 <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net> <533DB03D.7010308@colorfullife.com>
 <1396554637.2550.11.camel@buesod1.americas.hpqcorp.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 3 Apr 2014 19:39:38 -0400
Message-ID: <CAHGf_=rT7WswD0LOxVeDDpae-Ahaz4wEcpE8HLmDwOBw598z8g@mail.gmail.com>
Subject: Re: [PATCH] ipc,shm: disable shmmax and shmall by default
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Apr 3, 2014 at 3:50 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Thu, 2014-04-03 at 21:02 +0200, Manfred Spraul wrote:
>> Hi Davidlohr,
>>
>> On 04/03/2014 02:20 AM, Davidlohr Bueso wrote:
>> > The default size for shmmax is, and always has been, 32Mb.
>> > Today, in the XXI century, it seems that this value is rather small,
>> > making users have to increase it via sysctl, which can cause
>> > unnecessary work and userspace application workarounds[1].
>> >
>> > Instead of choosing yet another arbitrary value, larger than 32Mb,
>> > this patch disables the use of both shmmax and shmall by default,
>> > allowing users to create segments of unlimited sizes. Users and
>> > applications that already explicitly set these values through sysctl
>> > are left untouched, and thus does not change any of the behavior.
>> >
>> > So a value of 0 bytes or pages, for shmmax and shmall, respectively,
>> > implies unlimited memory, as opposed to disabling sysv shared memory.
>> > This is safe as 0 cannot possibly be used previously as SHMMIN is
>> > hardcoded to 1 and cannot be modified.
>
>> Are we sure that no user space apps uses shmctl(IPC_INFO) and prints a
>> pretty error message if shmall is too small?
>> We would break these apps.
>
> Good point. 0 bytes/pages would definitely trigger an unexpected error
> message if users did this. But on the other hand I'm not sure this
> actually is a _real_ scenario, since upon overflow the value can still
> end up being 0, which is totally bogus and would cause the same
> breakage.
>
> So I see two possible workarounds:
> (i) Use ULONG_MAX for the shmmax default instead. This would make shmall
> default to 1152921504606846720 and 268435456, for 64 and 32bit systems,
> respectively.
>
> (ii) Keep the 0 bytes, but add a new a "transition" tunable that, if set
> (default off), would allow 0 bytes to be unlimited. With time, users
> could hopefully update their applications and we could eventually get
> rid of it. This _seems_ to be the less aggressive way to go.

Do you mean

set 0: IPC_INFO return shmmax = 0.
set 1: IPC_INFO return shmmax = ULONG_MAX.

?

That makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
