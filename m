Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35C708E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:20:11 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v1-v6so10663670ybk.22
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 12:20:11 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t6-v6si329055ywd.201.2018.09.25.12.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 12:20:10 -0700 (PDT)
Date: Tue, 25 Sep 2018 12:19:53 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V5 RESEND 03/21] swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180925191953.4ped5ki7u3ymafmd@ca-dmjordan1.us.oracle.com>
References: <20180925071348.31458-1-ying.huang@intel.com>
 <20180925071348.31458-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925071348.31458-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Tue, Sep 25, 2018 at 03:13:30PM +0800, Huang Ying wrote:
> @@ -3487,35 +3521,66 @@ static int __swap_duplicate_locked(struct swap_info_struct *p,
>  }
>  
>  /*
> - * Verify that a swap entry is valid and increment its swap map count.
> + * Verify that the swap entries from *entry is valid and increment their
> + * PMD/PTE swap mapping count.
>   *
>   * Returns error code in following case.
>   * - success -> 0
>   * - swp_entry is invalid -> EINVAL
> - * - swp_entry is migration entry -> EINVAL

I'm assuming it wasn't possible to hit this error before this patch, and you're
just removing it now since you're in the area?

>   * - swap-cache reference is requested but there is already one. -> EEXIST
>   * - swap-cache reference is requested but the entry is not used. -> ENOENT
>   * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
> + * - the huge swap cluster has been split. -> ENOTDIR

Strangely intuitive choice of error code :)

>  /*
>   * Increase reference count of swap entry by 1.
> - * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
> - * but could not be atomically allocated.  Returns 0, just as if it succeeded,
> - * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
> - * might occur if a page table entry has got corrupted.
> + *
> + * Return error code in following case.
> + * - success -> 0
> + * - swap_count_continuation is required but could not be atomically allocated.
> + *   *entry is used to return swap entry to call add_swap_count_continuation().
> + *								      -> ENOMEM
> + * - otherwise same as __swap_duplicate()
>   */
> -int swap_duplicate(swp_entry_t entry)
> +int swap_duplicate(swp_entry_t *entry, int entry_size)
>  {
>  	int err = 0;
>  
> -	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
> -		err = add_swap_count_continuation(entry, GFP_ATOMIC);
> +	while (!err &&
> +	       (err = __swap_duplicate(entry, entry_size, 1)) == -ENOMEM)
> +		err = add_swap_count_continuation(*entry, GFP_ATOMIC);
>  	return err;

Now we're returning any error we get from __swap_duplicate, apparently to
accommodate ENOTDIR later in the series, which is a change from the behavior
introduced in 570a335b8e22 ("swap_info: swap count continuations").  This might
belong in a separate patch given its potential for side effects.

Although, I don't understand why 570a335b8e22 ignored errors other than -ENOMEM
when both swap_duplicate callers _seem_ from a quick read to be able to respond
gracefully to any error.
