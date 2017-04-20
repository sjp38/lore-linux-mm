Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C20386B03A2
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 20:43:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l196so45298365ioe.19
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 17:43:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s5si4478073pgo.232.2017.04.19.17.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 17:43:15 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v9 1/3] mm, THP, swap: Delay splitting THP during swap out
References: <20170419070625.19776-1-ying.huang@intel.com>
	<20170419070625.19776-2-ying.huang@intel.com>
	<20170419155252.GA3376@cmpxchg.org>
Date: Thu, 20 Apr 2017 08:43:12 +0800
In-Reply-To: <20170419155252.GA3376@cmpxchg.org> (Johannes Weiner's message of
	"Wed, 19 Apr 2017 11:52:52 -0400")
Message-ID: <87inlzrjrz.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Hi, Johannes,

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Wed, Apr 19, 2017 at 03:06:23PM +0800, Huang, Ying wrote:
>> @@ -206,17 +212,34 @@ int add_to_swap(struct page *page, struct list_head *list)
>>  	 */
>>  	err = add_to_swap_cache(page, entry,
>>  			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
>> -
>> -	if (!err) {
>> -		return 1;
>> -	} else {	/* -ENOMEM radix-tree allocation failure */
>> +	/* -ENOMEM radix-tree allocation failure */
>> +	if (err)
>>  		/*
>>  		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>>  		 * clear SWAP_HAS_CACHE flag.
>>  		 */
>> -		swapcache_free(entry);
>> -		return 0;
>> +		goto fail_free;
>> +
>> +	if (unlikely(PageTransHuge(page))) {
>> +		err = split_huge_page_to_list(page, list);
>> +		if (err) {
>> +			delete_from_swap_cache(page);
>> +			return 0;
>> +		}
>>  	}
>> +
>> +	return 1;
>> +
>> +fail_free:
>> +	if (unlikely(PageTransHuge(page)))
>> +		swapcache_free_cluster(entry);
>> +	else
>> +		swapcache_free(entry);
>> +fail:
>> +	if (unlikely(PageTransHuge(page)) &&
>> +	    !split_huge_page_to_list(page, list))
>> +		goto retry;
>
> May I ask why you added the unlikelies there? Can you generally say
> THPs are unlikely in this path? Is the swap-out path so hot that
> branch layout is critical? I doubt either is true.

I just found there are unlikely() encloses PageTransHuge() in the
original add_to_swap(), so I just follow the original style.  But I
don't think they make much sense too.  Will remove them in the next
version.

> Also please mention changes like these in the changelog next time.

Sorry and will do that in the future.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
