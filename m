Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 659606B0007
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 10:07:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n17-v6so14058063pff.10
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 07:07:53 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h9-v6si16588770pgi.502.2018.07.10.07.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 07:07:52 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 05/21] mm, THP, swap: Support PMD swap mapping in
 free_swap_and_cache()/swap_free()
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-6-ying.huang@intel.com>
 <49178f48-6635-353c-678d-3db436d3f9c3@linux.intel.com>
 <87y3ejh8ax.fsf@yhuang-dev.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <836c95a7-5f03-6d9e-6f0a-839b5fb8ba99@linux.intel.com>
Date: Tue, 10 Jul 2018 07:07:39 -0700
MIME-Version: 1.0
In-Reply-To: <87y3ejh8ax.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On 07/10/2018 12:13 AM, Huang, Ying wrote:
> Dave Hansen <dave.hansen@linux.intel.com> writes:
>> The code non-resuse was, and continues to be, IMNHO, one of the largest
>> sources of bugs with the original THP implementation.  It might be
>> infeasible to do here, but let's at least give it as much of a go as we can.
> 
> I totally agree that we should unify the code path for huge and normal
> page/swap if possible.  One concern is code size for !CONFIG_THP_SWAP.

I've honestly never heard that as an argument before.  In general, our
.c files implement *full* functionality: the most complex case.  The
headers #ifdef that functionality down because of our .config or
architecture.

The thing that matters here is debugging and reviewing the _complicated_
case, IMNHO.

> The original method is good for that.  The new method may introduce some
> huge swap related code that is hard to be eliminated for
> !CONFIG_THP_SWAP.  Andrew Morton pointed this out for the patchset of
> the first step of the THP swap optimization.
> 
> This may be mitigated at least partly via,
> 
> `
> #ifdef CONFIG_THP_SWAP
> #define nr_swap_entries(nr)          (nr)
> #else
> #define nr_swap_entries(nr)          1
> #endif
> 
> void do_something(swp_entry_t entry, int __nr_entries)
> {
>         int i, nr_entries = nr_swap_entries(__nr_entries);
> 
>         if (nr_entries = SWAPFILE_CLUSTER)
>                 ; /* huge swap specific */
>         else
>                 ; /* normal swap specific */
> 
>         for (i = 0; i < nr_entries; i++) {
>                 ; /* do something for each entry */
>         }
> 
>         /* ... */
> }
> `

While that isn't perfect, it's better than the current state of things.

While you are refactoring things, I think you also need to take a good
look at roughly chopping this series in half by finding another stopping
point.  You've done a great job so far of trickling this functionality
in so far, but 21 patches is quite a bit, and the set is only going to
get larger.
