Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A49256B0069
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:20:15 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so45046624wme.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 07:20:15 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 199si2993597wmi.91.2016.11.29.07.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 07:20:14 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g23so24947272wme.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 07:20:14 -0800 (PST)
Date: Tue, 29 Nov 2016 16:20:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/22 v2] mm/vmstat: Avoid on each online CPU loops
Message-ID: <20161129152012.GB9796@dhcp22.suse.cz>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
 <20161126231350.10321-9-bigeasy@linutronix.de>
 <20161128092800.GC14835@dhcp22.suse.cz>
 <alpine.DEB.2.20.1611291505340.4358@nanos>
 <20161129145113.fn3lw5aazjjvdrr3@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161129145113.fn3lw5aazjjvdrr3@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, rt@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue 29-11-16 15:51:14, Sebastian Andrzej Siewior wrote:
> Both iterations over online cpus can be replaced by the proper node
> specific functions.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> v1a?|v2: take into account that we may have online nodes with no CPUs.
> 
>  mm/vmstat.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 0b63ffb5c407..5152cd1c490f 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1720,19 +1720,21 @@ static void __init start_shepherd_timer(void)
>  
>  static void __init init_cpu_node_state(void)
>  {
> -	int cpu;
> +	int node;
>  
> -	for_each_online_cpu(cpu)
> -		node_set_state(cpu_to_node(cpu), N_CPU);
> +	for_each_online_node(node) {
> +		if (cpumask_weight(cpumask_of_node(node)) > 0)
> +			node_set_state(node, N_CPU);
> +	}
>  }
>  
>  static void vmstat_cpu_dead(int node)
>  {
> -	int cpu;
> +	const struct cpumask *node_cpus;
>  
> -	for_each_online_cpu(cpu)
> -		if (cpu_to_node(cpu) == node)
> -			return;
> +	node_cpus = cpumask_of_node(node);
> +	if (cpumask_weight(node_cpus) > 0)
> +		return;
>  
>  	node_clear_state(node, N_CPU);
>  }
> -- 
> 2.10.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
