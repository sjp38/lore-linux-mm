Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 429C56B0007
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 21:08:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v9-v6so5104906pfn.6
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:08:49 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j19-v6si3193470pgg.313.2018.07.10.18.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 18:08:47 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 04/21] mm, THP, swap: Support PMD swap mapping in swapcache_free_cluster()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-5-ying.huang@intel.com>
	<dd7b3dd7-9e10-4b9f-b931-915298bfd627@linux.intel.com>
	<874lh7intc.fsf@yhuang-dev.intel.com>
	<444d0718-8b89-5ef1-15c8-1bbbc6cb1bf3@linux.intel.com>
Date: Wed, 11 Jul 2018 09:08:44 +0800
In-Reply-To: <444d0718-8b89-5ef1-15c8-1bbbc6cb1bf3@linux.intel.com> (Dave
	Hansen's message of "Tue, 10 Jul 2018 06:54:21 -0700")
Message-ID: <87lgaih943.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 07/09/2018 11:53 PM, Huang, Ying wrote:
>> Dave Hansen <dave.hansen@linux.intel.com> writes:
>>>> +#ifdef CONFIG_THP_SWAP
>>>> +static inline int cluster_swapcount(struct swap_cluster_info *ci)
>>>> +{
>>>> +	if (!ci || !cluster_is_huge(ci))
>>>> +		return 0;
>>>> +
>>>> +	return cluster_count(ci) - SWAPFILE_CLUSTER;
>>>> +}
>>>> +#else
>>>> +#define cluster_swapcount(ci)			0
>>>> +#endif
>>>
>>> Dumb questions, round 2:  On a CONFIG_THP_SWAP=n build, presumably,
>>> cluster_is_huge()=0 always, so cluster_swapout() always returns 0.  Right?
>>>
>>> So, why the #ifdef?
>> 
>> #ifdef here is to reduce the code size for !CONFIG_THP_SWAP.
>
> I'd just remove the !CONFIG_THP_SWAP version entirely.

Sure.  Unless there are some build errors after some other refactoring.

>>>> @@ -1288,24 +1301,30 @@ static void swapcache_free_cluster(swp_entry_t entry)
>>>>  
>>>>  	ci = lock_cluster(si, offset);
>>>>  	VM_BUG_ON(!cluster_is_huge(ci));
>>>> +	VM_BUG_ON(!is_cluster_offset(offset));
>>>> +	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
>>>>  	map = si->swap_map + offset;
>>>> -	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>>>> -		val = map[i];
>>>> -		VM_BUG_ON(!(val & SWAP_HAS_CACHE));
>>>> -		if (val == SWAP_HAS_CACHE)
>>>> -			free_entries++;
>>>> +	if (!cluster_swapcount(ci)) {
>>>> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>>>> +			val = map[i];
>>>> +			VM_BUG_ON(!(val & SWAP_HAS_CACHE));
>>>> +			if (val == SWAP_HAS_CACHE)
>>>> +				free_entries++;
>>>> +		}
>>>> +		if (free_entries != SWAPFILE_CLUSTER)
>>>> +			cluster_clear_huge(ci);
>>>>  	}
>>>
>>> Also, I'll point out that cluster_swapcount() continues the horrific
>>> naming of cluster_couunt(), not saying what the count is *of*.  The
>>> return value doesn't help much:
>>>
>>> 	return cluster_count(ci) - SWAPFILE_CLUSTER;
>> 
>> We have page_swapcount() for page, swp_swapcount() for swap entry.
>> cluster_swapcount() tries to mimic them for swap cluster.  But I am not
>> good at naming in general.  What's your suggestion?
>
> I don't have a suggestion because I haven't the foggiest idea what it is
> doing. :)
>
> Is it the number of instantiated swap cache pages that are referring to
> this cluster?  Is it just huge pages?  Huge and small?  One refcount per
> huge page, or 512?

page_swapcount() and swp_swapcount() for a normal swap entry is the
number of PTE swap mapping to the normal swap entry.

cluster_swapcount() for a huge swap entry (or huge swap cluster) is the
number of PMD swap mapping to the huge swap entry.

Originally, cluster_count is the reference count of the swap entries in
the swap cluster (that is, how many entries are in use).  Now, it is the
sum of the reference count of the swap entries in the swap cluster and
the number of PMD swap mapping to the huge swap entry.

I need to add comments for this at least.

Best Regards,
Huang, Ying
