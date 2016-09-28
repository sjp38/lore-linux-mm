Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFE2828025C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 04:51:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n24so78916672pfb.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:51:22 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id kg11si7468506pab.248.2016.09.28.01.51.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 01:51:22 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 2/8] mm/swap: Add cluster lock
References: <20160927171804.GA17845@linux.intel.com>
	<004101d21964$3b3d68f0$b1b83ad0$@alibaba-inc.com>
Date: Wed, 28 Sep 2016 16:51:18 +0800
In-Reply-To: <004101d21964$3b3d68f0$b1b83ad0$@alibaba-inc.com> (Hillf Danton's
	message of "Wed, 28 Sep 2016 16:42:21 +0800")
Message-ID: <87mvispfuh.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: tim.c.chen@linux.intel.com, 'Andrew Morton' <akpm@linux-foundation.org>, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Huang Ying' <ying.huang@intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Shaohua Li' <shli@kernel.org>, 'Minchan Kim' <minchan@kernel.org>, 'Rik van Riel' <riel@redhat.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vladimir Davydov' <vdavydov@virtuozzo.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@kernel.org>

Hillf Danton <hillf.zj@alibaba-inc.com> writes:

> On Wednesday, September 28, 2016 1:18 AM Tim Chen wrote
>> 
>> @@ -447,8 +505,9 @@ static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
>>  	unsigned long *offset, unsigned long *scan_base)
>>  {
>>  	struct percpu_cluster *cluster;
>> +	struct swap_cluster_info *ci;
>>  	bool found_free;
>> -	unsigned long tmp;
>> +	unsigned long tmp, max;
>> 
>>  new_cluster:
>>  	cluster = this_cpu_ptr(si->percpu_cluster);
>> @@ -476,14 +535,21 @@ new_cluster:
>>  	 * check if there is still free entry in the cluster
>>  	 */
>>  	tmp = cluster->next;
>> -	while (tmp < si->max && tmp < (cluster_next(&cluster->index) + 1) *
>> -	       SWAPFILE_CLUSTER) {
>
> Currently tmp is checked to be less than both values.
>
>> +	max = max_t(unsigned long, si->max,
>> +		    (cluster_next(&cluster->index) + 1) * SWAPFILE_CLUSTER);
>> +	if (tmp >= max) {
>> +		cluster_set_null(&cluster->index);
>> +		goto new_cluster;
>> +	}
>> +	ci = lock_cluster(si, tmp);
>> +	while (tmp < max) {
>
> In this work tmp is checked to be less than the max value.
> Semantic change hoped?

Oops!  tmp should be checked to be more than the min value.  Will fix it
in the next version.  Thanks for pointing out this!

Best Regards,
Huang, Ying

>>  		if (!si->swap_map[tmp]) {
>>  			found_free = true;
>>  			break;
>>  		}
>>  		tmp++;
>>  	}
>> +	unlock_cluster(ci);
>>  	if (!found_free) {
>>  		cluster_set_null(&cluster->index);
>>  		goto new_cluster;
>> 
> thanks
> Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
