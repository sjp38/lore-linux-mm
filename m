Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C07B56B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 06:36:42 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2710201dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 03:36:41 -0700 (PDT)
Date: Fri, 8 Jun 2012 03:35:02 -0700
From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Message-ID: <20120608103501.GA15827@lizard>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com>
 <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608084105.GA9883@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7B01@008-AM1MPN1-004.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045F7B01@008-AM1MPN1-004.mgdnok.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kosaki.motohiro@gmail.com, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 08, 2012 at 08:57:13AM +0000, leonid.moiseichuk@nokia.com wrote:
> > -----Original Message-----
> > From: ext Anton Vorontsov [mailto:anton.vorontsov@linaro.org]
> > Sent: 08 June, 2012 11:41
> ...
> > > Right. It but it has drawbacks as well e.g. ensure that daemon scheduled
> > properly and propagate reaction decision outside ulmkd.
> > 
> > No, ulmkd itself propagates the decision (i.e. it kills processes).
> 
> That is a decision "select & kill" :)
> Propagation of this decision required time. Not all processes could be killed. You may stuck in killing in some cases.

Yeah. But since we have plenty of free memory (i.e. we're getting
notified in advance), it's OK to be not super-fast.

And if we're losing control, OOMK will help us. (Btw, we can
introduce "thrash killer" in-kernel driver. This would also help
desktop use case, when the system is thrashing so hard that it
becomes unresponsive, we'd better do something about it. When
browser goes crazy on my laptop, I wish I had such a driver. :-)
It takes forever to get OOM condition w/ 2GB swap space, slow
hard drive and CPU all busy w/ moving pages back and forward.)

> > If we start "polling" on /proc/vmstat via userland deferred timers, that would
> > be a single timer, just like in vmevent case. So, I'm not sure what is the
> > difference?..
> 
> Context switches, parsing, activity in userspace even memory situation is not changed.

Sure, there is some additional overhead. I'm just saying that it is
not drastic. It would be like 100 sprintfs + 100 sscanfs + 2 context
switches? Well, it is unfortunate... but come on, today's phones are
running X11 and Java. :-)

> In kernel space you can use sliding timer (increasing interval) + shinker.

Well, w/ Minchan's idea, we can get shrinker notifications into the
userland, so the sliding timer thing would be still possible.

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
