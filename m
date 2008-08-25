Message-ID: <48B2FE79.8060709@sgi.com>
Date: Mon, 25 Aug 2008 11:48:25 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
 CPUs
References: <20080821002757.b7c807ad.akpm@linux-foundation.org> <1219311154.8651.96.camel@twins> <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi Peter,
> 
> Thank you good point out!
> 
>>> @@ -41,8 +41,8 @@ static unsigned long max_pages(unsigned 
>>>  
>>>  	max = node_free_pages / FRACTION_OF_NODE_MEM;
>>>  
>>> -	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
>>> -	max /= num_cpus_per_node;
>>> +	node_cpumask = node_to_cpumask(node);
>>> +	max /= cpus_weight_nr(node_cpumask);
>>>  
>>>  	return max(max, min_pages);
>>>  }
>> humm, I thought we wanted to keep cpumask_t stuff away from our stack -
>> since on insanely large SGI boxen (/me looks at mike) the thing becomes
>> 512 bytes.
> 
> Hm, interesting.
> I think following patch fill your point, right?
> 
> but I worry about it works on sparc64...
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  mm/quicklist.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> Index: b/mm/quicklist.c
> ===================================================================
> --- a/mm/quicklist.c
> +++ b/mm/quicklist.c
> @@ -26,7 +26,10 @@ DEFINE_PER_CPU(struct quicklist, quickli
>  static unsigned long max_pages(unsigned long min_pages)
>  {
>  	unsigned long node_free_pages, max;
> -	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
> +	int node = numa_node_id();
> +	struct zone *zones = NODE_DATA(node)->node_zones;
> +	int num_cpus_on_node;
> +	node_to_cpumask_ptr(cpumask_on_node, node);
>  
>  	node_free_pages =
>  #ifdef CONFIG_ZONE_DMA
> @@ -38,6 +41,10 @@ static unsigned long max_pages(unsigned 
>  		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
>  
>  	max = node_free_pages / FRACTION_OF_NODE_MEM;
> +
> +	num_cpus_on_node = cpus_weight_nr(*cpumask_on_node);
> +	max /= num_cpus_on_node;
> +
>  	return max(max, min_pages);
>  }
>  
> 

Exactly!  And (many thanks to them!) the sparc maintainers have
implemented a similar internal function definition for node_to_cpumask_ptr().

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
