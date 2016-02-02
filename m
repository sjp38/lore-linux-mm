Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id BE21A6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 03:18:31 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 128so105816826wmz.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 00:18:31 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y41si2965466wmh.107.2016.02.02.00.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 00:18:30 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id l66so1220594wml.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 00:18:30 -0800 (PST)
Date: Tue, 2 Feb 2016 09:18:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/2] mm, vmstat: cancel pending work of the cpu_stat_off
 CPU
Message-ID: <20160202081828.GC19910@dhcp22.suse.cz>
References: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
 <1454001466-27398-2-git-send-email-mhocko@kernel.org>
 <1454399605.11183.8.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454399605.11183.8.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <mgalbraith@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cristopher Lameter <clameter@sgi.com>, Mike Galbraith <mgalbraith@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 02-02-16 08:53:25, Mike Galbraith wrote:
> Cancel pending work of the cpu_stat_off CPU.

Thanks for catching that Mike. This was a last minute change and I
screwed it...

Andrew could you fold this into the original patch, please?

Thanks!

> Signed-off-by: Mike Galbraith <mgalbraith@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmstat.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1486,25 +1486,25 @@ static void vmstat_shepherd(struct work_
>  
>  	get_online_cpus();
>  	/* Check processors whose vmstat worker threads have been disabled */
> -	for_each_cpu(cpu, cpu_stat_off)
> +	for_each_cpu(cpu, cpu_stat_off) {
> +		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
> +
>  		if (need_update(cpu)) {
>  			if (cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
> -				queue_delayed_work_on(cpu, vmstat_wq,
> -					&per_cpu(vmstat_work, cpu), 0);
> +				queue_delayed_work_on(cpu, vmstat_wq, dw, 0);
>  		} else {
>  			/*
>  			 * Cancel the work if quiet_vmstat has put this
>  			 * cpu on cpu_stat_off because the work item might
>  			 * be still scheduled
>  			 */
> -			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> +			cancel_delayed_work(dw);
>  		}
> -
> +	}
>  	put_online_cpus();
>  
>  	schedule_delayed_work(&shepherd,
>  		round_jiffies_relative(sysctl_stat_interval));
> -
>  }
>  
>  static void __init start_shepherd_timer(void)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
