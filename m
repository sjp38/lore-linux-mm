Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB4818E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 10:52:00 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id w19-v6so52247862ioa.10
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:52:00 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w6-v6si3253284ioc.44.2018.09.26.07.51.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 07:51:59 -0700 (PDT)
Date: Wed, 26 Sep 2018 07:51:45 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V5 RESEND 03/21] swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180926145145.6xp2kxpngyd54f6i@ca-dmjordan1.us.oracle.com>
References: <20180925071348.31458-1-ying.huang@intel.com>
 <20180925071348.31458-4-ying.huang@intel.com>
 <20180925191953.4ped5ki7u3ymafmd@ca-dmjordan1.us.oracle.com>
 <874lecifj4.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874lecifj4.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Wed, Sep 26, 2018 at 08:55:59PM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> > On Tue, Sep 25, 2018 at 03:13:30PM +0800, Huang Ying wrote:
> >>  /*
> >>   * Increase reference count of swap entry by 1.
> >> - * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
> >> - * but could not be atomically allocated.  Returns 0, just as if it succeeded,
> >> - * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
> >> - * might occur if a page table entry has got corrupted.
> >> + *
> >> + * Return error code in following case.
> >> + * - success -> 0
> >> + * - swap_count_continuation is required but could not be atomically allocated.
> >> + *   *entry is used to return swap entry to call add_swap_count_continuation().
> >> + *								      -> ENOMEM
> >> + * - otherwise same as __swap_duplicate()
> >>   */
> >> -int swap_duplicate(swp_entry_t entry)
> >> +int swap_duplicate(swp_entry_t *entry, int entry_size)
> >>  {
> >>  	int err = 0;
> >>  
> >> -	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
> >> -		err = add_swap_count_continuation(entry, GFP_ATOMIC);
> >> +	while (!err &&
> >> +	       (err = __swap_duplicate(entry, entry_size, 1)) == -ENOMEM)
> >> +		err = add_swap_count_continuation(*entry, GFP_ATOMIC);
> >>  	return err;
> >
> > Now we're returning any error we get from __swap_duplicate, apparently to
> > accommodate ENOTDIR later in the series, which is a change from the behavior
> > introduced in 570a335b8e22 ("swap_info: swap count continuations").  This might
> > belong in a separate patch given its potential for side effects.
> 
> I have checked all the calls of the function and found there will be no
> bad effect.  Do you have any side effect?

Before I was just being vaguely concerned about any unintended side effects,
but looking again, yes I do.

Now when swap_duplicate returns an error in copy_one_pte, copy_one_pte returns
a (potentially nonzero) entry.val, which copy_pte_range interprets
unconditionally as 'try adding a swap count continuation.'  Not what we want
for returns other than -ENOMEM.

So it might make sense to have a separate patch that changes swap_duplicate's
return and makes callers handle it.
