Date: Mon, 11 Jun 2007 19:51:30 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the TIF_MEMDIE task to exit
Message-ID: <20070611175130.GL7443@v2.random>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random> <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com> <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com> <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random> <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com> <20070611165032.GJ7443@v2.random> <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2007 at 09:57:59AM -0700, Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Andrea Arcangeli wrote:
> 
> > On Mon, Jun 11, 2007 at 09:07:59AM -0700, Christoph Lameter wrote:
> > > Filtering tasks is a very expensive operation on huge systems. We have had 
> > 
> > Come on, oom_kill.c only happens at oom time, after the huge complex
> > processing has figured out it's time to call into oom_kill.c, how can
> > you care about the performance of oom_kill.c?  Apparently some folks
> > prefer to panic when oom triggers go figure...
> 
> Its pretty bad if a large system sits for hours just because it cannot 
> finish its OOM processing. We have reports of that taking 4 hours!

Which is why I posted these fixes, so it will hopefully take much less
than 4 hours. Even normal production systems takes far too long
today. Most of these fixes are meant to reduce the complexity involved
in detecting when the system is oom (starting from number 01). Keep in
mind the whole 4 hours are spent _outside_ oom_kill.c.

> It avoids repeated scans over a super sized tasklist with heavy lock 
> contention. 4 loops for every OOM kill! If a number of processes will be 

Once the tasklist_lock has been taken, what else is going to trash
inside oom_kill.c?

> OOM killed then it will take hours to sort out the lock contention.

Did you measure it or this is just your imagination? I don't buy your
hypothetical "several hours spent in oom_kill.c" numbers. How long
does "ls /proc" takes? Can your run top at all?

> Want this as a a SUSE bug?

Feel free to file a SUSE bugreport so I hope you will back your claim
with some real profiling data and so we can check if this can be fixed
in software of it's the hardware to blame (in which case we need a
CONFIG_SLOW_NUMA, since other hardware implementations may prefer to
use the oom-selector during local-oom killing too and not only during
the global ones).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
