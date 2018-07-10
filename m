Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2A186B0298
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:49:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 17-v6so5982380qkz.15
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:49:37 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z62-v6si4201186qke.230.2018.07.10.15.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:49:36 -0700 (PDT)
Date: Tue, 10 Jul 2018 15:49:23 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -v4 14/21] mm, cgroup, THP, swap: Support to move
 swap account for PMD swap mapping
Message-ID: <20180710224923.lm5n7d2jot6pggw2@ca-dmjordan1.us.oracle.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-15-ying.huang@intel.com>
 <20180709172037.254zyuadep2hj5po@ca-dmjordan1.us.oracle.com>
 <87tvp7h6mx.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tvp7h6mx.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue, Jul 10, 2018 at 03:49:58PM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> 
> > On Fri, Jun 22, 2018 at 11:51:44AM +0800, Huang, Ying wrote:
> >> Because there is no way to prevent a huge swap cluster from being
> >> split except when it has SWAP_HAS_CACHE flag set.
> >
> > What about making get_mctgt_type_thp take the cluster lock?  That function
> > would be the first lock_cluster user outside of swapfile.c, but it would
> > serialize with split_swap_cluster.
> >
> >> It is possible for
> >> the huge swap cluster to be split and the charge for the swap slots
> >> inside to be changed, after we check the PMD swap mapping and the huge
> >> swap cluster before we commit the charge moving.  But the race window
> >> is so small, that we will just ignore the race.
> >
> > Moving the charges is a slow path, so can't we just be correct here and not
> > leak?
> 
> Check the code and thought about this again, found the race may not
> exist.  Because the PMD is locked when get_mctgt_type_thp() is called
> until charge is completed for the PMD.  So the charge of the huge swap
> cluster cannot be changed at the same time even if the huge swap cluster
> is split by other processes.

That's true, the PMD lock does prevent the swap charge from going stale between
the time mem_cgroup_move_charge_pte_range identifies a huge swap entry in
get_mctgt_type_thp and the time it moves the charge in mem_cgroup_move_account,
at least for some events like swapping in pages.

> Right?

I'm not sure the PMD lock covers everything, but after looking a while longer
at this, the charge moving seems to be a best-effort feature in other respects,
so the accounting doesn't need to be completely accurate.
