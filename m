Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB5BC2806CB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 20:51:33 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id v34so46627718iov.22
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 17:51:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a71si4510303pfc.170.2017.04.19.17.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 17:51:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v9 3/3] mm, THP, swap: Enable THP swap optimization only if has compound map
References: <20170419070625.19776-1-ying.huang@intel.com>
	<20170419070625.19776-4-ying.huang@intel.com>
	<20170419160029.GB3376@cmpxchg.org>
Date: Thu, 20 Apr 2017 08:51:30 +0800
In-Reply-To: <20170419160029.GB3376@cmpxchg.org> (Johannes Weiner's message of
	"Wed, 19 Apr 2017 12:00:29 -0400")
Message-ID: <87a87brje5.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Wed, Apr 19, 2017 at 03:06:25PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> If there is no compound map for a THP (Transparent Huge Page), it is
>> possible that the map count of some sub-pages of the THP is 0.  So it
>> is better to split the THP before swapping out. In this way, the
>> sub-pages not mapped will be freed, and we can avoid the unnecessary
>> swap out operations for these sub-pages.
>> 
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>>  mm/swap_state.c | 12 +++++++++---
>>  1 file changed, 9 insertions(+), 3 deletions(-)
>> 
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index 3a3217f68937..b025c9878e5e 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -192,9 +192,15 @@ int add_to_swap(struct page *page, struct list_head *list)
>>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>>  
>> -	/* cannot split, skip it */
>> -	if (unlikely(PageTransHuge(page)) && !can_split_huge_page(page, NULL))
>> -		return 0;
>> +	if (unlikely(PageTransHuge(page))) {
>> +		/* cannot split, skip it */
>> +		if (!can_split_huge_page(page, NULL))
>> +			return 0;
>> +		/* fallback to split huge page firstly if no PMD map */
>> +		if (!compound_mapcount(page) &&
>> +		    split_huge_page_to_list(page, list))
>> +			return 0;
>> +	}
>
> This looks good to me, but could you please elaborate the comment a
> little bit with what you have in the changelog? Something like:
>
> 	/*
> 	 * Split pages without a PMD map right away. Chances are
> 	 * some or all of the tail pages can be freed without IO.
> 	 */

The comments look much better!  Thanks!  I will change it.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
