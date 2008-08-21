Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
	CPUs
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080821002757.b7c807ad.akpm@linux-foundation.org>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820234615.258a9c04.akpm@linux-foundation.org>
	 <20080821.001322.236658980.davem@davemloft.net>
	 <20080821002757.b7c807ad.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 21 Aug 2008 11:32:34 +0200
Message-Id: <1219311154.8651.96.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com, travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-08-21 at 00:27 -0700, Andrew Morton wrote:
> On Thu, 21 Aug 2008 00:13:22 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Wed, 20 Aug 2008 23:46:15 -0700
> > 
> > > On Wed, 20 Aug 2008 20:08:13 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > +	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
> > > 
> > > sparc64 allmodconfig:
> > > 
> > > mm/quicklist.c: In function `max_pages':
> > > mm/quicklist.c:44: error: invalid lvalue in unary `&'
> > > 
> > > we seem to have a made a spectacular mess of cpumasks lately.
> > 
> > It should explode similarly on x86, since it also defines node_to_cpumask()
> > as an inline function.
> > 
> > IA64 seems to be one of the few platforms to define this as a macro
> > evaluating to the node-to-cpumask array entry, so it's clear what
> > platform Motohiro-san did build testing on :-)
> 
> Seems to compile OK on x86_32, x86_64, ia64 and powerpc for some reason.
> 
> This seems to fix things on sparc64:
> 
> --- a/mm/quicklist.c~mm-quicklist-shouldnt-be-proportional-to-number-of-cpus-fix
> +++ a/mm/quicklist.c
> @@ -28,7 +28,7 @@ static unsigned long max_pages(unsigned 
>  	unsigned long node_free_pages, max;
>  	int node = numa_node_id();
>  	struct zone *zones = NODE_DATA(node)->node_zones;
> -	int num_cpus_per_node;
> +	cpumask_t node_cpumask;
>  
>  	node_free_pages =
>  #ifdef CONFIG_ZONE_DMA
> @@ -41,8 +41,8 @@ static unsigned long max_pages(unsigned 
>  
>  	max = node_free_pages / FRACTION_OF_NODE_MEM;
>  
> -	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
> -	max /= num_cpus_per_node;
> +	node_cpumask = node_to_cpumask(node);
> +	max /= cpus_weight_nr(node_cpumask);
>  
>  	return max(max, min_pages);
>  }

humm, I thought we wanted to keep cpumask_t stuff away from our stack -
since on insanely large SGI boxen (/me looks at mike) the thing becomes
512 bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
