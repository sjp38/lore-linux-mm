Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 130536B0513
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 10:01:31 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x14-v6so7434073edr.7
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 07:01:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y14si705182edw.172.2018.11.07.07.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 07:01:29 -0800 (PST)
Date: Wed, 7 Nov 2018 16:01:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix NUMA statistics updates
Message-ID: <20181107150128.GG27423@dhcp22.suse.cz>
References: <1541601517-17282-1-git-send-email-janne.huttunen@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541601517-17282-1-git-send-email-janne.huttunen@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janne Huttunen <janne.huttunen@nokia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

[CC Andrew]

On Wed 07-11-18 16:38:37, Janne Huttunen wrote:
> Scan through the whole array to see if an update is needed. While we're
> at it, use sizeof() to be safe against any possible type changes in the
> future.
> 
> Fixes: 1d90ca897cb0 ("mm: update NUMA counter threshold size")
> Signed-off-by: Janne Huttunen <janne.huttunen@nokia.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Feel free to use the explanation below to answer what is the runtime
effect of the patch ;)

> ---
> Compile tested only! I don't know what error (if any) only scanning
> half of the array causes, so I cannot verify that this patch actually
> fixes it.

The bug here is that we wouldn't sync per-cpu counters into global ones
if there was an update of numa_stats for higher cpus. Highly theoretical
one though because it is much more probable that zone_stats are updated
so we would refresh anyway. So I wouldn't bother to mark this for
stable, yet something nice to fix.

Thanks

>  mm/vmstat.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7878da7..eca984d 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1827,12 +1827,13 @@ static bool need_update(int cpu)
>  
>  		/*
>  		 * The fast way of checking if there are any vmstat diffs.
> -		 * This works because the diffs are byte sized items.
>  		 */
> -		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
> +		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS *
> +			       sizeof(p->vm_stat_diff[0])))
>  			return true;
>  #ifdef CONFIG_NUMA
> -		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_NUMA_STAT_ITEMS))
> +		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_NUMA_STAT_ITEMS *
> +			       sizeof(p->vm_numa_stat_diff[0])))
>  			return true;
>  #endif
>  	}
> -- 
> 2.5.5

-- 
Michal Hocko
SUSE Labs
