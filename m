Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 56AC06B0039
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:05:15 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so2771769eek.6
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:05:14 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id o49si4334155eef.248.2014.05.09.08.05.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:05:14 -0700 (PDT)
Date: Fri, 9 May 2014 17:05:12 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: vmstat: On demand vmstat workers V4
In-Reply-To: <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
Message-ID: <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org> <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org> <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org

On Fri, 9 May 2014, Christoph Lameter wrote:
> On Fri, 9 May 2014, Thomas Gleixner wrote:
> > I think we agreed long ago, that for the whole HPC FULL_NOHZ stuff you
> > have to sacrify at least one CPU for housekeeping purposes of all
> > kinds, timekeeping, statistics and whatever.
> 
> Ok how do I figure out that cpu? I'd rather have a specific cpu that
> never changes.

I followed the full nohz development only losely, but back then when
all started here at my place with frederic, we had a way to define the
housekeeper cpu. I think we lazily had it hardwired to 0 :)

That probably changed, but I'm sure there is still a way to define a
housekeeper. And we should simply force the timekeeping on that
housekeeper. That comes with the price, that the housekeeper is not
allowed to go deep idle, but I bet that in HPC scenarios this does not
matter at all simply because the whole machine is under full load.

Frederic?

> > So if you have a housekeeper, then it makes absolutely no sense at all
> > to move it around in circles.
> >
> > Can you please enlighten me why we need this at all?
> 
> The vmstat kworker thread checks every 2 seconds if there are vmstat
> updates that need to be folded into the global statistics. This is not
> necessary if the application is running and no OS services are being used.
> Thus we could switch off vmstat updates and avoid taking the processor
> away from the application.
> 
> This has also been noted by multiple other people at was brought up at the
> mm summit by others who noted the same issues.

I understand why you want to get this done by a housekeeper, I just
did not understand why we need this whole move it around business is
required.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
