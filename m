Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81DDF6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 04:24:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so35576251wmf.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:24:21 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id uf7si53645977wjb.178.2016.11.28.01.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 01:24:20 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g23so17862553wme.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:24:20 -0800 (PST)
Date: Mon, 28 Nov 2016 10:24:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/22] mm/vmstat: Drop get_online_cpus() from
 init_cpu_node_state/vmstat_cpu_dead()
Message-ID: <20161128092415.GB14835@dhcp22.suse.cz>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
 <20161126231350.10321-8-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161126231350.10321-8-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Sun 27-11-16 00:13:35, Sebastian Andrzej Siewior wrote:
> Both functions are called with protection against cpu hotplug already so
> *_online_cpus() could be dropped.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmstat.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 604f26a4f696..0b63ffb5c407 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1722,24 +1722,19 @@ static void __init init_cpu_node_state(void)
>  {
>  	int cpu;
>  
> -	get_online_cpus();
>  	for_each_online_cpu(cpu)
>  		node_set_state(cpu_to_node(cpu), N_CPU);
> -	put_online_cpus();
>  }
>  
>  static void vmstat_cpu_dead(int node)
>  {
>  	int cpu;
>  
> -	get_online_cpus();
>  	for_each_online_cpu(cpu)
>  		if (cpu_to_node(cpu) == node)
> -			goto end;
> +			return;
>  
>  	node_clear_state(node, N_CPU);
> -end:
> -	put_online_cpus();
>  }
>  
>  /*
> -- 
> 2.10.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
