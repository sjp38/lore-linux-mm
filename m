Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 1F51D6B0070
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 15:07:14 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3791574eek.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 12:07:12 -0800 (PST)
Date: Mon, 19 Nov 2012 21:07:07 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119200707.GA12381@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121119162909.GL8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Mel Gorman <mgorman@suse.de> wrote:

> >   [ SPECjbb transactions/sec ]            |
> >   [ higher is better         ]            |
> >                                           |
> >   SPECjbb single-1x32    524k     507k    |       638k           +21.7%
> >   -----------------------------------------------------------------------
> > 
> 
> I was not able to run a full sets of tests today as I was 
> distracted so all I have is a multi JVM comparison. I'll keep 
> it shorter than average
> 
>                           3.7.0                 3.7.0
>                  rc5-stats-v4r2   rc5-schednuma-v16r1
> TPut   1     101903.00 (  0.00%)     77651.00 (-23.80%)
> TPut   2     213825.00 (  0.00%)    160285.00 (-25.04%)
> TPut   3     307905.00 (  0.00%)    237472.00 (-22.87%)
> TPut   4     397046.00 (  0.00%)    302814.00 (-23.73%)
> TPut   5     477557.00 (  0.00%)    364281.00 (-23.72%)
> TPut   6     542973.00 (  0.00%)    420810.00 (-22.50%)
> TPut   7     540466.00 (  0.00%)    448976.00 (-16.93%)
> TPut   8     543226.00 (  0.00%)    463568.00 (-14.66%)
> TPut   9     513351.00 (  0.00%)    468238.00 ( -8.79%)
> TPut   10    484126.00 (  0.00%)    457018.00 ( -5.60%)

These figures are IMO way too low for a 64-way system. I have a 
32-way system with midrange server CPUs and get 650k+/sec 
easily.

Have you tried to analyze the root cause, what does 'perf top' 
show during the run and how much idle time is there?

Trying to reproduce your findings I have done 4x JVM tests 
myself, using 4x 8-warehouse setups, with a sizing of -Xms8192m 
-Xmx8192m -Xss256k, and here are the results:

                         v3.7       v3.7                                  
  SPECjbb single-1x32    524k       638k         +21.7%
  SPECjbb  multi-4x8     633k       655k          +3.4%

So while here we are only marginally better than the 
single-instance numbers (I will try to improve that in numa/core 
v17), they are still better than mainline - and they are 
definitely not slower as your numbers suggest ...

So we need to go back to the basics to figure this out: please 
outline exactly which commit ID of the numa/core tree you have 
booted. Also, how does 'perf top' look like on your box?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
