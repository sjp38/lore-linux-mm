Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4PI55mD020708
	for <linux-mm@kvack.org>; Wed, 25 May 2005 14:05:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4PI553f078304
	for <linux-mm@kvack.org>; Wed, 25 May 2005 12:05:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4PI54hL017782
	for <linux-mm@kvack.org>; Wed, 25 May 2005 12:05:05 -0600
Message-ID: <4294BE45.3000502@austin.ibm.com>
Date: Wed, 25 May 2005 13:04:53 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 11
References: <20050522200507.6ED7AECFC@skynet.csn.ul.ie>
In-Reply-To: <20050522200507.6ED7AECFC@skynet.csn.ul.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> Changelog since V10
> 
> o Important - All allocation types now use per-cpu caches like the standard
>   allocator. Older versions may have trouble with large numbers of processors

Do you have a new set of benchmarks we could see?  The ones you had for 
v10 were pretty useful.

> o Removed all the additional buddy allocator statistic code

Is there a separate patch for the statistic code or is it no longer 
being maintained?

> +/*
> + * Shared per-cpu lists would cause fragmentation over time
> + * The pcpu_list is to keep kernel and userrclm allocations
> + * apart while still allowing all allocation types to have
> + * per-cpu lists
> + */

Why are kernel nonreclaimable and kernel reclaimable joined here?  I'm 
not saying you are wrong, I'm just ignorant and need some education.

> +struct pcpu_list {
> +	int count;
> +	struct list_head list;
> +} ____cacheline_aligned_in_smp;
> +
>  struct per_cpu_pages {
> -	int count;		/* number of pages in the list */
> +	struct pcpu_list pcpu_list[2]; /* 0: kernel 1: user */
>  	int low;		/* low watermark, refill needed */
>  	int high;		/* high watermark, emptying needed */
>  	int batch;		/* chunk size for buddy add/remove */
> -	struct list_head list;	/* the list of pages */
>  };
>  

Instead of defining 0 and 1 in a comment why not use a #define?

 > +			pcp->pcpu_list[0].count = 0;
 > +			pcp->pcpu_list[1].count = 0;

The #define would make code like this look more readable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
