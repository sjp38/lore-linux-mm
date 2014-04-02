Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 271646B009D
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 21:08:23 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wp18so11778514obc.7
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 18:08:22 -0700 (PDT)
Received: from mail-oa0-x24a.google.com (mail-oa0-x24a.google.com [2607:f8b0:4003:c02::24a])
        by mx.google.com with ESMTPS id o4si163333oei.151.2014.04.01.18.08.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 18:08:22 -0700 (PDT)
Received: by mail-oa0-f74.google.com with SMTP id i7so2141519oag.3
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 18:08:22 -0700 (PDT)
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org> <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org> <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com> <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com> <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com> <20140401142947.927642a408d84df27d581e36@linux-foundation.org> <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com> <20140401144801.603c288674ab8f417b42a043@linux-foundation.org> <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.co
 m> <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com> <1396399239.25314.47.camel@buesod1.americas.hpqcorp.net>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
In-reply-to: <1396399239.25314.47.camel@buesod1.americas.hpqcorp.net>
Date: Tue, 01 Apr 2014 18:08:21 -0700
Message-ID: <xr937g78k06y.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


On Tue, Apr 01 2014, Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Tue, 2014-04-01 at 19:56 -0400, KOSAKI Motohiro wrote:
>> >> > Ah-hah, that's interesting info.
>> >> >
>> >> > Let's make the default 64GB?
>> >>
>> >> 64GB is infinity at that time, but it no longer near infinity today. I like
>> >> very large or total memory proportional number.
>> >
>> > So I still like 0 for unlimited. Nice, clean and much easier to look at
>> > than ULONG_MAX. And since we cannot disable shm through SHMMIN, I really
>> > don't see any disadvantages, as opposed to some other arbitrary value.
>> > Furthermore it wouldn't break userspace: any existing sysctl would
>> > continue to work, and if not set, the user never has to worry about this
>> > tunable again.
>> >
>> > Please let me know if you all agree with this...
>> 
>> Surething. Why not. :)
>
> *sigh* actually, the plot thickens a bit with SHMALL (total size of shm
> segments system wide, in pages). Currently by default:
>
> #define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
>
> This deals with physical memory, at least admins are recommended to set
> it to some large percentage of ram / pagesize. So I think that if we
> loose control over the default value, users can potentially DoS the
> system, or at least cause excessive swapping if not manually set, but
> then again the same goes for anon mem... so do we care?

At least when there's an egregious anon leak the oom killer has the
power to free the memory by killing until the memory is unreferenced.
This isn't true for shm or tmpfs.  So shm is more effective than anon at
crushing a machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
