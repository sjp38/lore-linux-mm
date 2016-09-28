Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFC128025C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 04:43:06 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 92so100268474iom.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:43:06 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id d190si8902786itc.11.2016.09.28.01.42.43
        for <linux-mm@kvack.org>;
        Wed, 28 Sep 2016 01:42:45 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160927171804.GA17845@linux.intel.com>
In-Reply-To: <20160927171804.GA17845@linux.intel.com>
Subject: Re: [PATCH 2/8] mm/swap: Add cluster lock
Date: Wed, 28 Sep 2016 16:42:21 +0800
Message-ID: <004101d21964$3b3d68f0$b1b83ad0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tim.c.chen@linux.intel.com, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Huang Ying' <ying.huang@intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Shaohua Li' <shli@kernel.org>, 'Minchan Kim' <minchan@kernel.org>, 'Rik van Riel' <riel@redhat.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vladimir Davydov' <vdavydov@virtuozzo.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@kernel.org>

On Wednesday, September 28, 2016 1:18 AM Tim Chen wrote
> 
> @@ -447,8 +505,9 @@ static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
>  	unsigned long *offset, unsigned long *scan_base)
>  {
>  	struct percpu_cluster *cluster;
> +	struct swap_cluster_info *ci;
>  	bool found_free;
> -	unsigned long tmp;
> +	unsigned long tmp, max;
> 
>  new_cluster:
>  	cluster = this_cpu_ptr(si->percpu_cluster);
> @@ -476,14 +535,21 @@ new_cluster:
>  	 * check if there is still free entry in the cluster
>  	 */
>  	tmp = cluster->next;
> -	while (tmp < si->max && tmp < (cluster_next(&cluster->index) + 1) *
> -	       SWAPFILE_CLUSTER) {

Currently tmp is checked to be less than both values.

> +	max = max_t(unsigned long, si->max,
> +		    (cluster_next(&cluster->index) + 1) * SWAPFILE_CLUSTER);
> +	if (tmp >= max) {
> +		cluster_set_null(&cluster->index);
> +		goto new_cluster;
> +	}
> +	ci = lock_cluster(si, tmp);
> +	while (tmp < max) {

In this work tmp is checked to be less than the max value.
Semantic change hoped?

>  		if (!si->swap_map[tmp]) {
>  			found_free = true;
>  			break;
>  		}
>  		tmp++;
>  	}
> +	unlock_cluster(ci);
>  	if (!found_free) {
>  		cluster_set_null(&cluster->index);
>  		goto new_cluster;
> 
thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
