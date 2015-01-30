Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 87F9E6B0088
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 10:27:55 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id hs14so24177648lab.9
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:27:54 -0800 (PST)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id h5si7230916wij.97.2015.01.30.07.27.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 07:27:53 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id l15so3341013wiw.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:27:52 -0800 (PST)
Date: Fri, 30 Jan 2015 16:27:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150130152750.GH15505@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
 <20150114165036.GI4706@dhcp22.suse.cz>
 <54B7F7C4.2070105@codeaurora.org>
 <20150116154922.GB4650@dhcp22.suse.cz>
 <alpine.DEB.2.11.1501291131510.22780@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501291131510.22780@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Thu 29-01-15 11:32:43, Christoph Lameter wrote:
[...]
> Subject: vmstat: Reduce time interval to stat update on idle cpu
> 
> It was noted that the vm stat shepherd runs every 2 seconds and
> that the vmstat update is then scheduled 2 seconds in the future.
> 
> This yields an interval of double the time interval which is not
> desired.
> 
> Change the shepherd so that it does not delay the vmstat update
> on the other cpu. We stil have to use schedule_delayed_work since
> we are using a delayed_work_struct but we can set the delay to 0.
>
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c
> +++ linux/mm/vmstat.c
> @@ -1435,8 +1435,8 @@ static void vmstat_shepherd(struct work_
>  		if (need_update(cpu) &&
>  			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
> 
> -			schedule_delayed_work_on(cpu, &per_cpu(vmstat_work, cpu),
> -				__round_jiffies_relative(sysctl_stat_interval, cpu));
> +			schedule_delayed_work_on(cpu,
> +				&per_cpu(vmstat_work, cpu), 0);
> 
>  	put_online_cpus();
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
