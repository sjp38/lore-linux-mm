Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D97A86B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:42:46 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2736131pbb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 01:42:46 -0700 (PDT)
Date: Fri, 8 Jun 2012 01:41:06 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Message-ID: <20120608084105.GA9883@lizard>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com>
 <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kosaki.motohiro@gmail.com, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 08, 2012 at 08:16:04AM +0000, leonid.moiseichuk@nokia.com wrote:
> > -----Original Message-----
> > From: ext Anton Vorontsov [mailto:anton.vorontsov@linaro.org]
> > Sent: 08 June, 2012 10:59
> ... 
> > a) Two more context swtiches;
> > b) Serialization/deserialization of /proc/vmstat.
> > 
> > > It also will cause page trashing because user-space code could be pushed
> > out from cache if VM decide.
> > 
> > This can solved by moving a "watcher" to a separate (daemon) process, and
> > mlocking it. We do this in ulmkd.
> 
> Right. It but it has drawbacks as well e.g. ensure that daemon scheduled properly and propagate reaction decision outside ulmkd.

No, ulmkd itself propagates the decision (i.e. it kills processes).

Here is how it works:

1. Android activity manager (it is tons of Java-code, runs inside a
   JVM) maintains list of applications and their "importance" index.
   This huge pile of code (and the whole JVM) of course can't be
   mlocked, and so it only maintains the list.

2. Once ulmkd (a separate low memory killer daemon, written in C)
   receives notification that system is low on memory, then it looks 
   at the already prepared lists, and based on the processes'
   importance (and current free memory level) it kills appropriate
   apps.

Note that in-kernel LMK does absolutely the same as ulmkd, just
in the kernel (and the "importance index" is passed to LMK as
per-process oom_score_adj).

> Also I understand your statement about "watcher" as probably you use one timer for daemon. 
> Btw, in my variant (memnotify.c) I used only one timer, it is enough.

Not quite following.

In ulmkd I don't use timers at all, and by "watcher" I mean the
some userspace daemon that receives lowmemory/pressure events
(in our case it is ulmkd).

If we start "polling" on /proc/vmstat via userland deferred timers,
that would be a single timer, just like in vmevent case. So, I'm
not sure what is the difference?..

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
