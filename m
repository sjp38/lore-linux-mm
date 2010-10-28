Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BDFDA8D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:09:38 -0400 (EDT)
Date: Thu, 28 Oct 2010 15:09:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: vmstat: Use a single setter function and
 callback for adjusting percpu thresholds
Message-Id: <20101028150904.79fe9beb.akpm@linux-foundation.org>
In-Reply-To: <1288278816-32667-3-git-send-email-mel@csn.ul.ie>
References: <1288278816-32667-1-git-send-email-mel@csn.ul.ie>
	<1288278816-32667-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010 16:13:36 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> reduce_pgdat_percpu_threshold() and restore_pgdat_percpu_threshold()
> exist to adjust the per-cpu vmstat thresholds while kswapd is awake to
> avoid errors due to counter drift. The functions duplicate some code so
> this patch replaces them with a single set_pgdat_percpu_threshold() that
> takes a callback function to calculate the desired threshold as a
> parameter.

hm.  Could have passed in some silly flag rather than a function
pointer but whatever.

>
> ...
>
> -void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
> +void set_pgdat_percpu_threshold(pg_data_t *pgdat,
> +				int (*calculate_pressure)(struct zone *))
>  {
>  	struct zone *zone;
>  	int cpu;
> @@ -196,28 +197,7 @@ void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
>  		if (!zone->percpu_drift_mark)
>  			continue;
>  
> -		threshold = calculate_pressure_threshold(zone);
> -		for_each_online_cpu(cpu)
> -			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> -							= threshold;
> -	}
> -	put_online_cpus();
> -}
> -
> -void restore_pgdat_percpu_threshold(pg_data_t *pgdat)
> -{
> -	struct zone *zone;
> -	int cpu;
> -	int threshold;
> -	int i;
> -
> -	get_online_cpus();
> -	for (i = 0; i < pgdat->nr_zones; i++) {
> -		zone = &pgdat->node_zones[i];
> -		if (!zone->percpu_drift_mark)
> -			continue;
> -
> -		threshold = calculate_threshold(zone);
> +		threshold = calculate_pressure(zone);

Readability nit: it's better to use the

		threshold = (*calculate_pressure)(zone);

syntax here.  So the code reader doesn't go running around trying to
find the function "calculate_pressure".  I've been fooled that way
plenty of times.


>  		for_each_online_cpu(cpu)
>  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
>  							= threshold;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
