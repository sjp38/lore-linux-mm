Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7568D6B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 03:50:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so11823987plq.8
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 00:50:04 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id t9-v6si1821270pgo.42.2018.07.10.00.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 00:50:02 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 14/21] mm, cgroup, THP, swap: Support to move swap account for PMD swap mapping
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-15-ying.huang@intel.com>
	<20180709172037.254zyuadep2hj5po@ca-dmjordan1.us.oracle.com>
Date: Tue, 10 Jul 2018 15:49:58 +0800
In-Reply-To: <20180709172037.254zyuadep2hj5po@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Mon, 9 Jul 2018 10:20:37 -0700")
Message-ID: <87tvp7h6mx.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Jun 22, 2018 at 11:51:44AM +0800, Huang, Ying wrote:
>> Because there is no way to prevent a huge swap cluster from being
>> split except when it has SWAP_HAS_CACHE flag set.
>
> What about making get_mctgt_type_thp take the cluster lock?  That function
> would be the first lock_cluster user outside of swapfile.c, but it would
> serialize with split_swap_cluster.
>
>> It is possible for
>> the huge swap cluster to be split and the charge for the swap slots
>> inside to be changed, after we check the PMD swap mapping and the huge
>> swap cluster before we commit the charge moving.  But the race window
>> is so small, that we will just ignore the race.
>
> Moving the charges is a slow path, so can't we just be correct here and not
> leak?

Check the code and thought about this again, found the race may not
exist.  Because the PMD is locked when get_mctgt_type_thp() is called
until charge is completed for the PMD.  So the charge of the huge swap
cluster cannot be changed at the same time even if the huge swap cluster
is split by other processes.  Right?

Will update the comments for this.

Best Regards,
Huang, Ying
