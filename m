Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91C108E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:15:23 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o9so15494447pgv.19
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 19:15:23 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x23si14455287pgk.272.2018.12.18.19.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 19:15:22 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V9 07/21] swap: Support PMD swap mapping when splitting huge PMD
References: <20181214062754.13723-1-ying.huang@intel.com>
	<20181214062754.13723-8-ying.huang@intel.com>
	<20181218205443.shqczdh3era6heaf@ca-dmjordan1.us.oracle.com>
Date: Wed, 19 Dec 2018 11:15:17 +0800
In-Reply-To: <20181218205443.shqczdh3era6heaf@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 18 Dec 2018 12:54:44 -0800")
Message-ID: <87bm5iqkai.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, aneesh.kumar@linux.vnet.ibm.com

Hi, Daniel,

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> +Aneesh
>
> On Fri, Dec 14, 2018 at 02:27:40PM +0800, Huang Ying wrote:
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index bd2543e10938..49df3e7c96c7 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>
>> +int split_swap_cluster_map(swp_entry_t entry)
>         ...
>> +	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));
>
> Hi Ying, I crashed on this in v6 as reported and it still dies on me now.

Sorry, I missed the original report for v6.  I should have been more careful.

>> @@ -2150,6 +2185,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>         ...
>> +	if (IS_ENABLED(CONFIG_THP_SWAP) && is_swap_pmd(old_pmd))
>> +		return __split_huge_swap_pmd(vma, haddr, pmd);
>
> Problem is 'pmd' is passed here, which has been pmdp_invalidate()ed under the
> assumption that it is not a swap entry.  pmd's pfn bits get inverted for L1TF,
> so the swap entry gets corrupted and this BUG is the first place that notices.
>
> I don't see a reason to invalidate so soon, so what about just moving the
> invalidation down, past the migration/swap checks?

Yes.  That can fix the issue.  I will fix this in that way.

Best Regards,
Huang, Ying
