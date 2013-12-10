Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id AA11B6B0073
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:28:03 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so2031805eek.13
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:28:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si13239005eeo.226.2013.12.10.00.28.02
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 00:28:02 -0800 (PST)
Date: Tue, 10 Dec 2013 08:27:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 09/12] sched/numa: fix task scan rate adjustment
Message-ID: <20131210082758.GC11295@suse.de>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-9-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386657875-icl2pjx6-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386657875-icl2pjx6-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 01:44:35AM -0500, Naoya Horiguchi wrote:
> Hi Wanpeng,
> 
> On Sun, Dec 08, 2013 at 02:14:50PM +0800, Wanpeng Li wrote:
> > commit 04bb2f947 (sched/numa: Adjust scan rate in task_numa_placement) calculate
> > period_slot which should be used as base value of scan rate increase if remote
> > access dominate. However, current codes forget to use it, this patch fix it.
> > 
> > Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> > ---
> >  kernel/sched/fair.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 7073c76..b077f1b3 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -1358,7 +1358,7 @@ static void update_task_scan_period(struct task_struct *p,
> >  		 */
> >  		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
> >  		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
> > -		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
> > +		diff = (period_slot * ratio) / NUMA_PERIOD_SLOTS;
> >  	}
> >  
> >  	p->numa_scan_period = clamp(p->numa_scan_period + diff,
> 
> It seems to me that the original code is correct, because the mathematical
> meaning of this hunk is clear:
> 
>   diff = (diff calculated by local-remote ratio) * (private-shared ratio)
> 

Thanks Naoya.

The original code is as intended and was meant to scale the difference
between the NUMA_PERIOD_THRESHOLD and local/remote ratio when adjusting
the scan period. The period_slot recalculation can be dropped.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
