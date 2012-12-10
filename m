Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id E05E56B006E
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 14:28:35 -0500 (EST)
Date: Mon, 10 Dec 2012 19:28:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [GIT TREE] Unified NUMA balancing tree, v3
Message-ID: <20121210192828.GL1009@suse.de>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
 <alpine.LFD.2.02.1212101902050.4422@ionos>
 <50C62CE7.2000306@redhat.com>
 <20121210191545.GA14412@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121210191545.GA14412@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Dec 10, 2012 at 08:15:45PM +0100, Ingo Molnar wrote:
> 
> * Rik van Riel <riel@redhat.com> wrote:
> 
> > On 12/10/2012 01:22 PM, Thomas Gleixner wrote:
> > 
> > > So autonuma and numacore are basically on the same page, 
> > > with a slight advantage for numacore in the THP enabled 
> > > case. balancenuma is closer to mainline than to 
> > > autonuma/numacore.
> > 
> > Indeed, when the system is fully loaded, numacore does very 
> > well.
> 
> Note that the latest (-v3) code also does well in under-loaded 
> situations:
> 
>    http://lkml.org/lkml/2012/12/7/331
> 
> Here's the 'perf bench numa' comparison to 'balancenuma':
> 
>                             balancenuma  | NUMA-tip
>  [test unit]            :          -v10  |    -v3
> ------------------------------------------------------------
>  2x1-bw-process         :         6.136  |  9.647:  57.2%
>  3x1-bw-process         :         7.250  | 14.528: 100.4%
>  4x1-bw-process         :         6.867  | 18.903: 175.3%
>  8x1-bw-process         :         7.974  | 26.829: 236.5%
>  8x1-bw-process-NOTHP   :         5.937  | 22.237: 274.5%
>  16x1-bw-process        :         5.592  | 29.294: 423.9%
>  4x1-bw-thread          :        13.598  | 19.290:  41.9%
>  8x1-bw-thread          :        16.356  | 26.391:  61.4%
>  16x1-bw-thread         :        24.608  | 29.557:  20.1%
>  32x1-bw-thread         :        25.477  | 30.232:  18.7%
>  2x3-bw-thread          :         8.785  | 15.327:  74.5%
>  4x4-bw-thread          :         6.366  | 27.957: 339.2%
>  4x6-bw-thread          :         6.287  | 27.877: 343.4%
>  4x8-bw-thread          :         5.860  | 28.439: 385.3%
>  4x8-bw-thread-NOTHP    :         6.167  | 25.067: 306.5%
>  3x3-bw-thread          :         8.235  | 21.560: 161.8%
>  5x5-bw-thread          :         5.762  | 26.081: 352.6%
>  2x16-bw-thread         :         5.920  | 23.269: 293.1%
>  1x32-bw-thread         :         5.828  | 18.985: 225.8%
>  numa02-bw              :        29.054  | 31.431:   8.2%
>  numa02-bw-NOTHP        :        27.064  | 29.104:   7.5%
>  numa01-bw-thread	:        20.338  | 28.607:  40.7%
>  numa01-bw-thread-NOTHP :        18.528  | 21.119:  14.0%
> ------------------------------------------------------------
> 
> More than half of these testcases are under-loaded situations.
> 
> > The main issues that have been observed with numacore are when 
> > the system is only partially loaded. Something strange seems 
> > to be going on that causes performance regressions in that 
> > situation.
> 
> I haven't seen such reports with -v3 yet, which is what Thomas 
> tested. Mel has not tested -v3 yet AFAICS.
> 

Yes, I have. The drop I took and the results I posted to you were based
on a tip/master pull from December 9th. v3 was released on December
7th and your release said to test based on tip/master. The results are
here https://lkml.org/lkml/2012/12/9/108 . Look at the columns marked
numafix-20121209 which is tip/master with a bodge on top to remove the "if
(p->nr_cpus_allowed != num_online_cpus())" check.

To my continued frustration, the results begin at the line "Here is the
comparison on the rough off-chance you actually read it this time." I
guess you didn't feel the need.

> If there are any such instances left then I'll investigate, but 
> right now it's looking pretty good.
> 

If you had read that report, you would know that I didn't have results
for specjbb with THP enabled due to the JVM crashing with null pointer
exceptions.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
