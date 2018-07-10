Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEC76B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 03:14:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s16-v6so11802815plr.22
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 00:14:04 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z4-v6si15051657pge.173.2018.07.10.00.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 00:14:01 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 05/21] mm, THP, swap: Support PMD swap mapping in free_swap_and_cache()/swap_free()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-6-ying.huang@intel.com>
	<49178f48-6635-353c-678d-3db436d3f9c3@linux.intel.com>
Date: Tue, 10 Jul 2018 15:13:58 +0800
In-Reply-To: <49178f48-6635-353c-678d-3db436d3f9c3@linux.intel.com> (Dave
	Hansen's message of "Mon, 9 Jul 2018 10:19:25 -0700")
Message-ID: <87y3ejh8ax.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> I'm seeing a pattern here.
>
> old code:
>
> foo()
> {
> 	do_swap_something()
> }
>
> new code:
>
> foo(bool cluster)
> {
> 	if (cluster)
> 		do_swap_cluster_something();
> 	else
> 		do_swap_something();
> }
>
> That make me fear that we have:
> 1. Created a new, wholly untested code path
> 2. Created two places to patch bugs
> 3. Are not reusing code when possible
>
> The code non-resuse was, and continues to be, IMNHO, one of the largest
> sources of bugs with the original THP implementation.  It might be
> infeasible to do here, but let's at least give it as much of a go as we can.

I totally agree that we should unify the code path for huge and normal
page/swap if possible.  One concern is code size for !CONFIG_THP_SWAP.
The original method is good for that.  The new method may introduce some
huge swap related code that is hard to be eliminated for
!CONFIG_THP_SWAP.  Andrew Morton pointed this out for the patchset of
the first step of the THP swap optimization.

This may be mitigated at least partly via,

`
#ifdef CONFIG_THP_SWAP
#define nr_swap_entries(nr)          (nr)
#else
#define nr_swap_entries(nr)          1
#endif

void do_something(swp_entry_t entry, int __nr_entries)
{
        int i, nr_entries = nr_swap_entries(__nr_entries);

        if (nr_entries = SWAPFILE_CLUSTER)
                ; /* huge swap specific */
        else
                ; /* normal swap specific */

        for (i = 0; i < nr_entries; i++) {
                ; /* do something for each entry */
        }

        /* ... */
}
`

and rely on compiler to do the dirty work for us if possible.

Hi, Andrew,

What do you think about this?

> Can I ask that you take another round through this set and:
>
> 1. Consolidate code refactoring into separate patches

Sure.

> 2. Add comments to code, and avoid doing it solely in changelogs

Sure.

> 3. Make an effort to share more code between the old code and new
>    code.  Where code can not be shared, call that out in the changelog.

Will do that if we resolve the code size concern.

> This is a *really* hard-to-review set at the moment.  Doing those things
> will make it much easier to review and hopefully give us more
> maintainable code going forward.
>
> My apologies for not having done this review sooner.

Thanks a lot for your comments!

Best Regards,
Huang, Ying
