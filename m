Date: Thu, 21 Aug 2008 19:22:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of CPUs
In-Reply-To: <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <1219311154.8651.96.camel@twins> <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080821192130.22B5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com, travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

Sorry, following patch is crap.
please forget it.

I'll respin it soon.


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





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
