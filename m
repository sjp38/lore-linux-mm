Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 763486B0003
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 21:28:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l21-v6so10807139pff.3
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:28:32 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 144-v6si17501683pge.406.2018.07.10.18.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 18:28:31 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 05/21] mm, THP, swap: Support PMD swap mapping in free_swap_and_cache()/swap_free()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-6-ying.huang@intel.com>
	<49178f48-6635-353c-678d-3db436d3f9c3@linux.intel.com>
	<87y3ejh8ax.fsf@yhuang-dev.intel.com>
	<836c95a7-5f03-6d9e-6f0a-839b5fb8ba99@linux.intel.com>
Date: Wed, 11 Jul 2018 09:28:13 +0800
In-Reply-To: <836c95a7-5f03-6d9e-6f0a-839b5fb8ba99@linux.intel.com> (Dave
	Hansen's message of "Tue, 10 Jul 2018 07:07:39 -0700")
Message-ID: <87h8l6h87m.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 07/10/2018 12:13 AM, Huang, Ying wrote:
>> Dave Hansen <dave.hansen@linux.intel.com> writes:
>>> The code non-resuse was, and continues to be, IMNHO, one of the largest
>>> sources of bugs with the original THP implementation.  It might be
>>> infeasible to do here, but let's at least give it as much of a go as we can.
>> 
>> I totally agree that we should unify the code path for huge and normal
>> page/swap if possible.  One concern is code size for !CONFIG_THP_SWAP.
>
> I've honestly never heard that as an argument before.  In general, our
> .c files implement *full* functionality: the most complex case.  The
> headers #ifdef that functionality down because of our .config or
> architecture.
>
> The thing that matters here is debugging and reviewing the _complicated_
> case, IMNHO.

I agree with your point here.  I will try it and measure the code size
change too.

>> The original method is good for that.  The new method may introduce some
>> huge swap related code that is hard to be eliminated for
>> !CONFIG_THP_SWAP.  Andrew Morton pointed this out for the patchset of
>> the first step of the THP swap optimization.
>> 
>> This may be mitigated at least partly via,
>> 
>> `
>> #ifdef CONFIG_THP_SWAP
>> #define nr_swap_entries(nr)          (nr)
>> #else
>> #define nr_swap_entries(nr)          1
>> #endif
>> 
>> void do_something(swp_entry_t entry, int __nr_entries)
>> {
>>         int i, nr_entries = nr_swap_entries(__nr_entries);
>> 
>>         if (nr_entries = SWAPFILE_CLUSTER)
>>                 ; /* huge swap specific */
>>         else
>>                 ; /* normal swap specific */
>> 
>>         for (i = 0; i < nr_entries; i++) {
>>                 ; /* do something for each entry */
>>         }
>> 
>>         /* ... */
>> }
>> `
>
> While that isn't perfect, it's better than the current state of things.
>
> While you are refactoring things, I think you also need to take a good
> look at roughly chopping this series in half by finding another stopping
> point.  You've done a great job so far of trickling this functionality
> in so far, but 21 patches is quite a bit, and the set is only going to
> get larger.

Yes.  The patchset is too large.  I will try to reduce it if possible.
At least [21/21] can be separated.  [02/21] may be sent separately
too.  Other parts are hard, THP swapin and creating/supporting PMD swap
mapping need to be in one patchset.

Best Regards,
Huang, Ying
