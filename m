Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30BE16B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 01:31:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s3-v6so580527plp.21
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 22:31:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d33-v6si347435pla.57.2018.07.02.22.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 22:31:28 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 08/21] mm, THP, swap: Support to read a huge swap cluster for swapin a THP
Date: Mon, 02 Jul 2018 14:02:47 +0800
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-9-ying.huang@intel.com>
	<20180629062126.GJ7646@bombadil.infradead.org>
Message-ID: <87y3esvqab.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Matthew Wilcox <willy@infradead.org> writes:

> On Fri, Jun 22, 2018 at 11:51:38AM +0800, Huang, Ying wrote:
>> +++ b/mm/swap_state.c
>> @@ -426,33 +447,37 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>>  		/*
>>  		 * call radix_tree_preload() while we can wait.
>>  		 */
>> -		err = radix_tree_maybe_preload(gfp_mask & GFP_KERNEL);
>> +		err = radix_tree_maybe_preload_order(gfp_mask & GFP_KERNEL,
>> +						     compound_order(new_page));
>>  		if (err)
>>  			break;
>
> There's no more preloading in the XArray world, so this can just be dropped.

Sure.

>>  		/*
>>  		 * Swap entry may have been freed since our caller observed it.
>>  		 */
>> +		err = swapcache_prepare(hentry, huge_cluster);
>> +		if (err) {
>>  			radix_tree_preload_end();
>> -			break;
>> +			if (err == -EEXIST) {
>> +				/*
>> +				 * We might race against get_swap_page() and
>> +				 * stumble across a SWAP_HAS_CACHE swap_map
>> +				 * entry whose page has not been brought into
>> +				 * the swapcache yet.
>> +				 */
>> +				cond_resched();
>> +				continue;
>> +			} else if (err == -ENOTDIR) {
>> +				/* huge swap cluster is split under us */
>> +				continue;
>> +			} else		/* swp entry is obsolete ? */
>> +				break;
>
> I'm not entirely happy about -ENOTDIR being overloaded to mean this.
> Maybe we can return a new enum rather than an errno?

Can we use -ESTALE instead?  The "huge swap cluster is split under us"
means the swap entry is kind of "staled".

> Also, I'm not sure that a true/false parameter is the right approach for
> "is this a huge page".  I think we'll have usecases for swap entries which
> are both larger and smaller than PMD_SIZE.

OK.  I can change the interface to number of swap entries style to make
it more flexible.

> I was hoping to encode the swap entry size into the entry; we only need one
> extra bit to do that (no matter the size of the entry).  I detailed the
> encoding scheme here:
>
> https://plus.google.com/117536210417097546339/posts/hvctn17WUZu
>
> (let me know if that doesn't work for you; I'm not very experienced with
> this G+ thing)

The encoding method looks good.  To use it, we need to

- Encode swap entry and size into swap_entry_size
- Call function with swap_entry_size
- Decode swap_entry_size to swap entry and size

It appears that there is no real benefit?

Best Regards,
Huang, Ying
