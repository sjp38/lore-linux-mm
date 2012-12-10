Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 4B6D76B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 14:15:53 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1535072bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 11:15:51 -0800 (PST)
Date: Mon, 10 Dec 2012 20:15:45 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT TREE] Unified NUMA balancing tree, v3
Message-ID: <20121210191545.GA14412@gmail.com>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
 <alpine.LFD.2.02.1212101902050.4422@ionos>
 <50C62CE7.2000306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C62CE7.2000306@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Rik van Riel <riel@redhat.com> wrote:

> On 12/10/2012 01:22 PM, Thomas Gleixner wrote:
> 
> > So autonuma and numacore are basically on the same page, 
> > with a slight advantage for numacore in the THP enabled 
> > case. balancenuma is closer to mainline than to 
> > autonuma/numacore.
> 
> Indeed, when the system is fully loaded, numacore does very 
> well.

Note that the latest (-v3) code also does well in under-loaded 
situations:

   http://lkml.org/lkml/2012/12/7/331

Here's the 'perf bench numa' comparison to 'balancenuma':

                            balancenuma  | NUMA-tip
 [test unit]            :          -v10  |    -v3
------------------------------------------------------------
 2x1-bw-process         :         6.136  |  9.647:  57.2%
 3x1-bw-process         :         7.250  | 14.528: 100.4%
 4x1-bw-process         :         6.867  | 18.903: 175.3%
 8x1-bw-process         :         7.974  | 26.829: 236.5%
 8x1-bw-process-NOTHP   :         5.937  | 22.237: 274.5%
 16x1-bw-process        :         5.592  | 29.294: 423.9%
 4x1-bw-thread          :        13.598  | 19.290:  41.9%
 8x1-bw-thread          :        16.356  | 26.391:  61.4%
 16x1-bw-thread         :        24.608  | 29.557:  20.1%
 32x1-bw-thread         :        25.477  | 30.232:  18.7%
 2x3-bw-thread          :         8.785  | 15.327:  74.5%
 4x4-bw-thread          :         6.366  | 27.957: 339.2%
 4x6-bw-thread          :         6.287  | 27.877: 343.4%
 4x8-bw-thread          :         5.860  | 28.439: 385.3%
 4x8-bw-thread-NOTHP    :         6.167  | 25.067: 306.5%
 3x3-bw-thread          :         8.235  | 21.560: 161.8%
 5x5-bw-thread          :         5.762  | 26.081: 352.6%
 2x16-bw-thread         :         5.920  | 23.269: 293.1%
 1x32-bw-thread         :         5.828  | 18.985: 225.8%
 numa02-bw              :        29.054  | 31.431:   8.2%
 numa02-bw-NOTHP        :        27.064  | 29.104:   7.5%
 numa01-bw-thread	:        20.338  | 28.607:  40.7%
 numa01-bw-thread-NOTHP :        18.528  | 21.119:  14.0%
------------------------------------------------------------

More than half of these testcases are under-loaded situations.

> The main issues that have been observed with numacore are when 
> the system is only partially loaded. Something strange seems 
> to be going on that causes performance regressions in that 
> situation.

I haven't seen such reports with -v3 yet, which is what Thomas 
tested. Mel has not tested -v3 yet AFAICS.

If there are any such instances left then I'll investigate, but 
right now it's looking pretty good.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
