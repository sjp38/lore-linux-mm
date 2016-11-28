Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0FA76B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 04:28:03 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id jb2so19394809wjb.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:28:03 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ww1si53688557wjb.147.2016.11.28.01.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 01:28:02 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g23so17879143wme.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:28:02 -0800 (PST)
Date: Mon, 28 Nov 2016 10:28:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/22] mm/vmstat: Avoid on each online CPU loops
Message-ID: <20161128092800.GC14835@dhcp22.suse.cz>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
 <20161126231350.10321-9-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161126231350.10321-9-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Sun 27-11-16 00:13:36, Sebastian Andrzej Siewior wrote:
[...]
>  static void __init init_cpu_node_state(void)
>  {
> -	int cpu;
> +	int node;
>  
> -	for_each_online_cpu(cpu)
> -		node_set_state(cpu_to_node(cpu), N_CPU);
> +	for_each_online_node(node)
> +		node_set_state(node, N_CPU);

Is this really correct? The point of the original code was to mark only
those nodes which have at least one CPU. Or am I missing something?

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

This looks OK

>  
>  	node_clear_state(node, N_CPU);
>  }
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
