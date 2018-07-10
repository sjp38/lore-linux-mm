Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 145E76B000E
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:51:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17-v6so12560678pff.17
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:51:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v71-v6si17859820pfj.354.2018.07.10.06.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 06:51:04 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-4-ying.huang@intel.com>
 <92b86ab6-6f51-97b0-337c-b7e98a30b6cb@linux.intel.com>
 <878t6jio7x.fsf@yhuang-dev.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <1b8a9fa8-79a3-c515-26b1-cea6d9eb9aeb@linux.intel.com>
Date: Tue, 10 Jul 2018 06:50:33 -0700
MIME-Version: 1.0
In-Reply-To: <878t6jio7x.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

> Yes.  Boolean parameter isn't good at most times.  Matthew Wilcox
> suggested to use
> 
>         swap_duplicate(&entry, HPAGE_PMD_NR);
> 
> vs.
> 
>         swap_duplicate(&entry, 1);
> 
> He thinks this makes the interface more flexible to support other swap
> entry size in the future.  What do you think about that?

That looks great to me too.

>>>  		if (likely(!non_swap_entry(entry))) {
>>> -			if (swap_duplicate(entry) < 0)
>>> +			if (swap_duplicate(&entry, false) < 0)
>>>  				return entry.val;
>>>  
>>>  			/* make sure dst_mm is on swapoff's mmlist. */
>>
>> I'll also point out that in a multi-hundred-line patch, adding arguments
>> to a existing function would not be something I'd try to include in the
>> patch.  I'd break it out separately unless absolutely necessary.
> 
> You mean add another patch, which only adds arguments to the function,
> but not change the body of the function?

Yes.  Or, just add the non-THP-swap version first.
