Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 9392E6B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 08:15:20 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2847034dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 05:15:19 -0700 (PDT)
Date: Fri, 8 Jun 2012 05:13:34 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Message-ID: <20120608121334.GA20772@lizard>
References: <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com>
 <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608084105.GA9883@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7B01@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608103501.GA15827@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7C35@008-AM1MPN1-004.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045F7C35@008-AM1MPN1-004.mgdnok.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kosaki.motohiro@gmail.com, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 08, 2012 at 11:03:29AM +0000, leonid.moiseichuk@nokia.com wrote:
> > -----Original Message-----
> > From: ext Anton Vorontsov [mailto:cbouatmailru@gmail.com]
> > Sent: 08 June, 2012 13:35
> ...
> > > Context switches, parsing, activity in userspace even memory situation is
> > not changed.
> > 
> > Sure, there is some additional overhead. I'm just saying that it is not drastic. It
> > would be like 100 sprintfs + 100 sscanfs + 2 context switches? Well, it is
> > unfortunate... but come on, today's phones are running X11 and Java. :-)
> 
> Vmstat generation is not so trivial. Meminfo has even higher overhead. I just checked generation time using idling device and open/read test:
> - vmstat min 30, avg 94 max 2746 uSeconds
> - meminfo min 30, average 65 max 15961 uSeconds
> 
> In comparison /proc/version for the same conditions: min 30, average 41, max 1505 uSeconds

Hm. I would expect that avg value for meminfo will be much worse
than vmstat (meminfo grabs some locks).

OK, if we consider 100ms interval, then this would be like 0.1%
overhead? Not great, but still better than memcg:

http://lkml.org/lkml/2011/12/21/487 

:-)

Personally? I'm all for saving these 0.1% tho, I'm all for vmevent.
But, for example, it's still broken for SMP as it is costly to
update vm_stat. And I see no way to fix this.

So, I guess the right approach would be to find ways to not depend on
frequent vm_stat updates (and thus reads).

userland deferred timers (and infrequent reads from vmstat) +
"userland vm pressure notifications" looks promising for the userland
solution.

For in-kernel solution it is all the same, a deferred timer that
reads vm_stat occasionally (no pressure case) + in-kernel shrinker
notifications for fast reaction under pressure.

> > > In kernel space you can use sliding timer (increasing interval) + shinker.
> > 
> > Well, w/ Minchan's idea, we can get shrinker notifications into the userland,
> > so the sliding timer thing would be still possible.
> 
> Only as a post-schrinker actions. In case of memory stressing or
> close-to-stressing conditions shrinkers called very often, I saw up to
> 50 times per second.

Well, yes. But in userland you would just poll/select on the shrinker
notification fd, you won't get more than you can (or want to) process.

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
