Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3216B0074
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 20:40:42 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so10236972pde.24
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:40:42 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id zm8si136362pac.232.2014.04.01.17.40.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 17:40:41 -0700 (PDT)
Message-ID: <1396399239.25314.47.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 01 Apr 2014 17:40:39 -0700
In-Reply-To: <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	 <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2014-04-01 at 19:56 -0400, KOSAKI Motohiro wrote:
> >> > Ah-hah, that's interesting info.
> >> >
> >> > Let's make the default 64GB?
> >>
> >> 64GB is infinity at that time, but it no longer near infinity today. I like
> >> very large or total memory proportional number.
> >
> > So I still like 0 for unlimited. Nice, clean and much easier to look at
> > than ULONG_MAX. And since we cannot disable shm through SHMMIN, I really
> > don't see any disadvantages, as opposed to some other arbitrary value.
> > Furthermore it wouldn't break userspace: any existing sysctl would
> > continue to work, and if not set, the user never has to worry about this
> > tunable again.
> >
> > Please let me know if you all agree with this...
> 
> Surething. Why not. :)

*sigh* actually, the plot thickens a bit with SHMALL (total size of shm
segments system wide, in pages). Currently by default:

#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))

This deals with physical memory, at least admins are recommended to set
it to some large percentage of ram / pagesize. So I think that if we
loose control over the default value, users can potentially DoS the
system, or at least cause excessive swapping if not manually set, but
then again the same goes for anon mem... so do we care?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
