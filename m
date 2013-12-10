Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id EFD3E6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:45:07 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so1990361eek.12
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 22:45:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l2si12968924een.83.2013.12.09.22.45.05
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 22:45:06 -0800 (PST)
Date: Tue, 10 Dec 2013 01:44:35 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386657875-icl2pjx6-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386483293-15354-9-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-9-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 09/12] sched/numa: fix task scan rate adjustment
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Wanpeng,

On Sun, Dec 08, 2013 at 02:14:50PM +0800, Wanpeng Li wrote:
> commit 04bb2f947 (sched/numa: Adjust scan rate in task_numa_placement) calculate
> period_slot which should be used as base value of scan rate increase if remote
> access dominate. However, current codes forget to use it, this patch fix it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  kernel/sched/fair.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 7073c76..b077f1b3 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1358,7 +1358,7 @@ static void update_task_scan_period(struct task_struct *p,
>  		 */
>  		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
>  		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
> -		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
> +		diff = (period_slot * ratio) / NUMA_PERIOD_SLOTS;
>  	}
>  
>  	p->numa_scan_period = clamp(p->numa_scan_period + diff,

It seems to me that the original code is correct, because the mathematical
meaning of this hunk is clear:

  diff = (diff calculated by local-remote ratio) * (private-shared ratio)

If you use period_slot here, diff always becomes less then 1/10 finally by
the second ratio multiplication (because we divide by NUMA_PERIOD_SLOTS twice),
and I don't see the justification.

And if my idea is correct, we don't have to recalculate period_slot when
we multiply private-shared ratio. So we can remove that line.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
