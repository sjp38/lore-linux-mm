Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9C76D6B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:28:32 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so4266794qaq.29
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:28:32 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id u7si2202330qab.6.2014.05.09.08.28.31
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 08:28:32 -0700 (PDT)
Date: Fri, 9 May 2014 10:28:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: On demand vmstat workers V4
In-Reply-To: <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.10.1405091027040.11318@gentwo.org>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org> <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org> <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org

On Fri, 9 May 2014, Thomas Gleixner wrote:

> > Ok how do I figure out that cpu? I'd rather have a specific cpu that
> > never changes.
>
> I followed the full nohz development only losely, but back then when
> all started here at my place with frederic, we had a way to define the
> housekeeper cpu. I think we lazily had it hardwired to 0 :)

Yes that would be the easiest and simplest. We dedicate cpu 0 to OS
services around
here anyways.

> That probably changed, but I'm sure there is still a way to define a
> housekeeper. And we should simply force the timekeeping on that
> housekeeper. That comes with the price, that the housekeeper is not
> allowed to go deep idle, but I bet that in HPC scenarios this does not
> matter at all simply because the whole machine is under full load.

Excellent. Yes. Good.

> >
> > The vmstat kworker thread checks every 2 seconds if there are vmstat
> > updates that need to be folded into the global statistics. This is not
> > necessary if the application is running and no OS services are being used.
> > Thus we could switch off vmstat updates and avoid taking the processor
> > away from the application.
> >
> > This has also been noted by multiple other people at was brought up at the
> > mm summit by others who noted the same issues.
>
> I understand why you want to get this done by a housekeeper, I just
> did not understand why we need this whole move it around business is
> required.

This came about because of another objection against having it simply
fixed to a processor. After all that processor may be disabled etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
