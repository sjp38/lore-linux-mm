Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D64818E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 21:34:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e15-v6so1127470pfi.5
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 18:34:41 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h3-v6si600713pgc.122.2018.09.26.18.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 18:34:40 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V5 RESEND 03/21] swap: Support PMD swap mapping in swap_duplicate()
References: <20180925071348.31458-1-ying.huang@intel.com>
	<20180925071348.31458-4-ying.huang@intel.com>
	<20180925191953.4ped5ki7u3ymafmd@ca-dmjordan1.us.oracle.com>
	<874lecifj4.fsf@yhuang-dev.intel.com>
	<20180926145145.6xp2kxpngyd54f6i@ca-dmjordan1.us.oracle.com>
Date: Thu, 27 Sep 2018 09:34:36 +0800
In-Reply-To: <20180926145145.6xp2kxpngyd54f6i@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Wed, 26 Sep 2018 07:51:45 -0700")
Message-ID: <87r2hfhger.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Wed, Sep 26, 2018 at 08:55:59PM +0800, Huang, Ying wrote:
>> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
>> > On Tue, Sep 25, 2018 at 03:13:30PM +0800, Huang Ying wrote:
>> >>  /*
>> >>   * Increase reference count of swap entry by 1.
>> >> - * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
>> >> - * but could not be atomically allocated.  Returns 0, just as if it succeeded,
>> >> - * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
>> >> - * might occur if a page table entry has got corrupted.
>> >> + *
>> >> + * Return error code in following case.
>> >> + * - success -> 0
>> >> + * - swap_count_continuation is required but could not be atomically allocated.
>> >> + *   *entry is used to return swap entry to call add_swap_count_continuation().
>> >> + *								      -> ENOMEM
>> >> + * - otherwise same as __swap_duplicate()
>> >>   */
>> >> -int swap_duplicate(swp_entry_t entry)
>> >> +int swap_duplicate(swp_entry_t *entry, int entry_size)
>> >>  {
>> >>  	int err = 0;
>> >>  
>> >> -	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
>> >> -		err = add_swap_count_continuation(entry, GFP_ATOMIC);
>> >> +	while (!err &&
>> >> +	       (err = __swap_duplicate(entry, entry_size, 1)) == -ENOMEM)
>> >> +		err = add_swap_count_continuation(*entry, GFP_ATOMIC);
>> >>  	return err;
>> >
>> > Now we're returning any error we get from __swap_duplicate, apparently to
>> > accommodate ENOTDIR later in the series, which is a change from the behavior
>> > introduced in 570a335b8e22 ("swap_info: swap count continuations").  This might
>> > belong in a separate patch given its potential for side effects.
>> 
>> I have checked all the calls of the function and found there will be no
>> bad effect.  Do you have any side effect?
>
> Before I was just being vaguely concerned about any unintended side effects,
> but looking again, yes I do.
>
> Now when swap_duplicate returns an error in copy_one_pte, copy_one_pte returns
> a (potentially nonzero) entry.val, which copy_pte_range interprets
> unconditionally as 'try adding a swap count continuation.'  Not what we want
> for returns other than -ENOMEM.

Thanks for pointing this out!  Before the change in the patchset, the
behavior is,

Something wrong is detected in swap_duplicate(), but the error is
ignored.  Then copy_one_pte() will think everything is OK, so that it
can proceed to call set_pte_at().  The system will be in inconsistent
state and some data may be polluted!

But this doesn't cause any problem in practical.  Per my understanding,
because if other part of the kernel works correctly, it's impossible for
swap_duplicate() return any error except -ENOMEM before the change in
this patchset.  But the error may be possible during development, and it
may serve as some kind of document too.  So I suggest to add

VM_BUG_ON(error != -ENOMEM);

in swap_duplicate().  What do you think about that?

> So it might make sense to have a separate patch that changes swap_duplicate's
> return and makes callers handle it.

Thanks for your help to take a deep look at this.  I want to try to fix
all potential problems firstly, because the number of the caller is
quite limited.  Do you agree?

Best Regards,
Huang, Ying
