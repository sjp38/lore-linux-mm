Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 8A58B6B0087
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:08:22 -0400 (EDT)
Date: Tue, 14 May 2013 17:08:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH 7/7] drain batch list during long operations
Message-ID: <20130514160818.GY11497@suse.de>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507212003.7990B2F5@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130507212003.7990B2F5@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Tue, May 07, 2013 at 02:20:03PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This was a suggestion from Mel:
> 
> 	http://lkml.kernel.org/r/20120914085634.GM11157@csn.ul.ie
> 
> Any pages we collect on 'batch_for_mapping_removal' will have
> their lock_page() held during the duration of their stay on the
> list.  If some other user is trying to get at them during this
> time, they might end up having to wait for a while, especially if
> we go off and do pageout() on some other page.
> 
> This ensures that we drain the batch if we are about to perform a
> writeout.
> 
> I added some statistics to the __remove_mapping_batch() code to
> track how large the lists are that we pass in to it.  With this
> patch, the average list length drops about 10% (from about 4.1 to
> 3.8).  The workload here was a make -j4 kernel compile on a VM
> with 200MB of RAM.
> 
> I've still got the statistics patch around if anyone is
> interested.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  linux.git-davehans/kernel/sched/fair.c |    2 ++
>  linux.git-davehans/mm/vmscan.c         |   10 ++++++++++
>  2 files changed, 12 insertions(+)
> 
> diff -puN kernel/sched/fair.c~drain-batch-list-during-long-operations kernel/sched/fair.c
> --- linux.git/kernel/sched/fair.c~drain-batch-list-during-long-operations	2013-05-07 13:48:15.267113941 -0700
> +++ linux.git-davehans/kernel/sched/fair.c	2013-05-07 13:48:15.275114295 -0700
> @@ -5211,6 +5211,8 @@ more_balance:
>  		if (sd->balance_interval < sd->max_interval)
>  			sd->balance_interval *= 2;
>  	}
> +	//if (printk_ratelimit())
> +	//	printk("sd->balance_interval: %d\n", sd->balance_interval);
>  
>  	goto out;
>  

heh

> diff -puN mm/vmscan.c~drain-batch-list-during-long-operations mm/vmscan.c
> --- linux.git/mm/vmscan.c~drain-batch-list-during-long-operations	2013-05-07 13:48:15.268113985 -0700
> +++ linux.git-davehans/mm/vmscan.c	2013-05-07 13:48:15.272114163 -0700
> @@ -936,6 +936,16 @@ static unsigned long shrink_page_list(st
>  			if (!sc->may_writepage)
>  				goto keep_locked;
>  
> +			/*
> +			 * We hold a bunch of page locks on the batch.
> +			 * pageout() can take a while, so drain the
> +			 * batch before we perform pageout.
> +			 */
> +			nr_reclaimed +=
> +		               __remove_mapping_batch(&batch_for_mapping_removal,
> +		                                      &ret_pages,
> +		                                      &free_pages);
> +

There is also a wait_on_page_writeback() above that would affect
memcg's but this alone alleviates a lot of my concerns about lock hold
times.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
