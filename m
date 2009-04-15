Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDF95F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 23:35:05 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3F3ZX5M031461
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:05:33 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3F3ZiGo4300964
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:05:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3F3ZXxM003640
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:35:33 +1000
Date: Wed, 15 Apr 2009 09:04:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: meminfo Committed_AS underflows
Message-ID: <20090415033455.GS7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1239737619.32604.118.camel@nimitz> <20090415105033.AC29.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090415105033.AC29.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 11:04:59]:

>  	committed = atomic_long_read(&vm_committed_space);
> +	if (committed < 0)
> +		committed = 0;

Isn't this like pushing the problem under the rug?

>  	allowed = ((totalram_pages - hugetlb_total_pages())
>  		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> 
> Index: b/mm/swap.c
> ===================================================================
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -519,7 +519,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
>   * We tolerate a little inaccuracy to avoid ping-ponging the counter between
>   * CPUs
>   */
> -#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
> +#define ACCT_THRESHOLD	max_t(long, 16, num_online_cpus() * 2)
>

Hmm.. this is a one time expansion, free of CPU hotplug.

Should we use nr_cpu_ids or num_possible_cpus()?
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
