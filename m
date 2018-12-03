Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFFB6B68EB
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:56:48 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so6482390edc.9
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:56:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11-v6si3021232ejz.109.2018.12.03.03.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 03:56:47 -0800 (PST)
Date: Mon, 3 Dec 2018 12:56:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm/vmscan: Enable kswapd to reclaim low-protected
 memory
Message-ID: <20181203115646.GP31738@dhcp22.suse.cz>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203080119.18989-2-xlpang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203080119.18989-2-xlpang@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 03-12-18 16:01:18, Xunlei Pang wrote:
> There may be cgroup memory overcommitment, it will become
> even common in the future.
> 
> Let's enable kswapd to reclaim low-protected memory in case
> of memory pressure, to mitigate the global direct reclaim
> pressures which could cause jitters to the response time of
> lantency-sensitive groups.

Please be more descriptive about the problem you are trying to handle
here. I haven't actually read the patch but let me emphasise that the
low limit protection is important isolation tool. And allowing kswapd to
reclaim protected memcgs is going to break the semantic as it has been
introduced and designed.

> 
> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
> ---
>  mm/vmscan.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 62ac0c488624..3d412eb91f73 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3531,6 +3531,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  
>  	count_vm_event(PAGEOUTRUN);
>  
> +retry:
>  	do {
>  		unsigned long nr_reclaimed = sc.nr_reclaimed;
>  		bool raise_priority = true;
> @@ -3622,6 +3623,13 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			sc.priority--;
>  	} while (sc.priority >= 1);
>  
> +	if (!sc.nr_reclaimed && sc.memcg_low_skipped) {
> +		sc.priority = DEF_PRIORITY;
> +		sc.memcg_low_reclaim = 1;
> +		sc.memcg_low_skipped = 0;
> +		goto retry;
> +	}
> +
>  	if (!sc.nr_reclaimed)
>  		pgdat->kswapd_failures++;
>  
> -- 
> 2.13.5 (Apple Git-94)
> 

-- 
Michal Hocko
SUSE Labs
