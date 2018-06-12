Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 839B06B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 21:23:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y26-v6so11124730pfn.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 18:23:25 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id q14-v6si18809650pll.324.2018.06.11.18.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 18:23:23 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
References: <20180523082625.6897-1-ying.huang@intel.com>
	<20180523082625.6897-4-ying.huang@intel.com>
	<20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
Date: Tue, 12 Jun 2018 09:23:19 +0800
In-Reply-To: <20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Mon, 11 Jun 2018 13:42:31 -0700")
Message-ID: <87o9ggpzlk.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Hi, Daniel,

Thanks for your effort to review this series.

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> Hi,
>
> The series up to and including this patch doesn't build.  For this patch we
> need:
>
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index c6b3eab73fde..2f2d07627113 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -433,7 +433,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>                 /*
>                  * Swap entry may have been freed since our caller observed it.
>                  */
> -               err = swapcache_prepare(entry);
> +               err = swapcache_prepare(entry, false);
>                 if (err == -EEXIST) {
>                         radix_tree_preload_end();
>                         /*

Thanks for pointing this out!  Will change in the next version.

>
> On Wed, May 23, 2018 at 04:26:07PM +0800, Huang, Ying wrote:
>> @@ -3516,11 +3512,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>
> Two comments about this part of __swap_duplicate as long as you're moving it to
> another function:
>
>    } else if (count || has_cache) {
>    
>    	if ((count & ~COUNT_CONTINUED) < SWAP_MAP_MAX)          /* #1   */
>    		count += usage;
>    	else if ((count & ~COUNT_CONTINUED) > SWAP_MAP_MAX)     /* #2   */
>    		err = -EINVAL;
>
> #1:  __swap_duplicate_locked might use
>
>     VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);
>
> to document the unstated assumption that usage is 1 (otherwise count could
> overflow).

Sounds good.  Will do this.

> #2:  We've masked off SWAP_HAS_CACHE and COUNT_CONTINUED, and already checked
> for SWAP_MAP_BAD, so I think condition #2 always fails and can just be removed.

I think this is used to check some software bug.  For example,
SWAP_MAP_SHMEM will yield true here.

>> +#ifdef CONFIG_THP_SWAP
>> +static int __swap_duplicate_cluster(swp_entry_t *entry, unsigned char usage)
> ...
>> +	} else {
>> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> +retry:
>> +			err = __swap_duplicate_locked(si, offset + i, 1);
>
> I guess usage is assumed to be 1 at this point (__swap_duplicate_locked makes
> the same assumption).  Maybe make this explicit with
>
> 			err = __swap_duplicate_locked(si, offset + i, usage);
>
> , use 'usage' in cluster_set_count and __swap_entry_free too, and then
> earlier have a
>
>        VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);
>
> ?

Yes.  I will fix this.  And we can just check it in
__swap_duplicate_locked() and all these will be covered.

>> +#else
>> +static inline int __swap_duplicate_cluster(swp_entry_t *entry,
>
> This doesn't need inline.

Why not?  This is just a one line stub.

> Not related to your changes, but while we're here, the comment with
> SWAP_HAS_CONT in swap_count() could be deleted: I don't think there ever was a
> SWAP_HAS_CONT.

Yes.  We should correct this.  Because this should go to a separate patch,
would you mind to submit a patch to fix it?

> The rest looks ok up to this point.

Thanks!

Best Regards,
Huang, Ying
