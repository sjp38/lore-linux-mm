Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D08D66B000A
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:53:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so11764403plt.17
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 23:53:39 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id h5-v6si16216514plr.268.2018.07.09.23.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 23:53:38 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 04/21] mm, THP, swap: Support PMD swap mapping in swapcache_free_cluster()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-5-ying.huang@intel.com>
	<dd7b3dd7-9e10-4b9f-b931-915298bfd627@linux.intel.com>
Date: Tue, 10 Jul 2018 14:53:35 +0800
In-Reply-To: <dd7b3dd7-9e10-4b9f-b931-915298bfd627@linux.intel.com> (Dave
	Hansen's message of "Mon, 9 Jul 2018 10:11:57 -0700")
Message-ID: <874lh7intc.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

>> +#ifdef CONFIG_THP_SWAP
>> +static inline int cluster_swapcount(struct swap_cluster_info *ci)
>> +{
>> +	if (!ci || !cluster_is_huge(ci))
>> +		return 0;
>> +
>> +	return cluster_count(ci) - SWAPFILE_CLUSTER;
>> +}
>> +#else
>> +#define cluster_swapcount(ci)			0
>> +#endif
>
> Dumb questions, round 2:  On a CONFIG_THP_SWAP=n build, presumably,
> cluster_is_huge()=0 always, so cluster_swapout() always returns 0.  Right?
>
> So, why the #ifdef?

#ifdef here is to reduce the code size for !CONFIG_THP_SWAP.

>>  /*
>>   * It's possible scan_swap_map() uses a free cluster in the middle of free
>>   * cluster list. Avoiding such abuse to avoid list corruption.
>> @@ -905,6 +917,7 @@ static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
>>  	struct swap_cluster_info *ci;
>>  
>>  	ci = lock_cluster(si, offset);
>> +	memset(si->swap_map + offset, 0, SWAPFILE_CLUSTER);
>>  	cluster_set_count_flag(ci, 0, 0);
>>  	free_cluster(si, idx);
>>  	unlock_cluster(ci);
>
> This is another case of gloriously comment-free code, but stuff that
> _was_ covered in the changelog.  I'd much rather have code comments than
> changelog comments.  Could we fix that?
>
> I'm generally finding it quite hard to review this because I keep having
> to refer back to the changelog to see if what you are doing matches what
> you said you were doing.

Sure.  Will fix this.

>> @@ -1288,24 +1301,30 @@ static void swapcache_free_cluster(swp_entry_t entry)
>>  
>>  	ci = lock_cluster(si, offset);
>>  	VM_BUG_ON(!cluster_is_huge(ci));
>> +	VM_BUG_ON(!is_cluster_offset(offset));
>> +	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
>>  	map = si->swap_map + offset;
>> -	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> -		val = map[i];
>> -		VM_BUG_ON(!(val & SWAP_HAS_CACHE));
>> -		if (val == SWAP_HAS_CACHE)
>> -			free_entries++;
>> +	if (!cluster_swapcount(ci)) {
>> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> +			val = map[i];
>> +			VM_BUG_ON(!(val & SWAP_HAS_CACHE));
>> +			if (val == SWAP_HAS_CACHE)
>> +				free_entries++;
>> +		}
>> +		if (free_entries != SWAPFILE_CLUSTER)
>> +			cluster_clear_huge(ci);
>>  	}
>
> Also, I'll point out that cluster_swapcount() continues the horrific
> naming of cluster_couunt(), not saying what the count is *of*.  The
> return value doesn't help much:
>
> 	return cluster_count(ci) - SWAPFILE_CLUSTER;

We have page_swapcount() for page, swp_swapcount() for swap entry.
cluster_swapcount() tries to mimic them for swap cluster.  But I am not
good at naming in general.  What's your suggestion?

Best Regards,
Huang, Ying
