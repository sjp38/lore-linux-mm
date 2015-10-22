Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB9A82F64
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:58:04 -0400 (EDT)
Received: by lfbn126 with SMTP id n126so24800921lfb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:58:03 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id k185si10474099lfe.96.2015.10.22.11.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 11:58:02 -0700 (PDT)
Date: Thu, 22 Oct 2015 21:57:47 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 8/8] mm: memcontrol: hook up vmpressure to socket pressure
Message-ID: <20151022185747.GQ18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1445487696-21545-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:36AM -0400, Johannes Weiner wrote:
...
> @@ -185,8 +183,29 @@ static void vmpressure_work_fn(struct work_struct *work)
>  	vmpr->reclaimed = 0;
>  	spin_unlock(&vmpr->sr_lock);
>  
> +	level = vmpressure_calc_level(scanned, reclaimed);
> +
> +	if (level > VMPRESSURE_LOW) {

So we start socket_pressure at MEDIUM. Why not at LOW or CRITICAL?

> +		struct mem_cgroup *memcg;
> +		/*
> +		 * Let the socket buffer allocator know that we are
> +		 * having trouble reclaiming LRU pages.
> +		 *
> +		 * For hysteresis, keep the pressure state asserted
> +		 * for a second in which subsequent pressure events
> +		 * can occur.
> +		 *
> +		 * XXX: is vmpressure a global feature or part of
> +		 * memcg? There shouldn't be anything memcg-specific
> +		 * about exporting reclaim success ratios from the VM.
> +		 */
> +		memcg = container_of(vmpr, struct mem_cgroup, vmpressure);
> +		if (memcg != root_mem_cgroup)
> +			memcg->socket_pressure = jiffies + HZ;

Why 1 second?

Thanks,
Vladimir

> +	}
> +
>  	do {
> -		if (vmpressure_event(vmpr, scanned, reclaimed))
> +		if (vmpressure_event(vmpr, level))
>  			break;
>  		/*
>  		 * If not handled, propagate the event upward into the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
