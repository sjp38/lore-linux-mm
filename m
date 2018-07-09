Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37BE46B030D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:20:52 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m6-v6so24084925qkd.20
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:20:52 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v184-v6si7514464qkd.398.2018.07.09.10.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 10:20:51 -0700 (PDT)
Date: Mon, 9 Jul 2018 10:20:37 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -v4 14/21] mm, cgroup, THP, swap: Support to move
 swap account for PMD swap mapping
Message-ID: <20180709172037.254zyuadep2hj5po@ca-dmjordan1.us.oracle.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-15-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622035151.6676-15-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Fri, Jun 22, 2018 at 11:51:44AM +0800, Huang, Ying wrote:
> Because there is no way to prevent a huge swap cluster from being
> split except when it has SWAP_HAS_CACHE flag set.

What about making get_mctgt_type_thp take the cluster lock?  That function
would be the first lock_cluster user outside of swapfile.c, but it would
serialize with split_swap_cluster.

> It is possible for
> the huge swap cluster to be split and the charge for the swap slots
> inside to be changed, after we check the PMD swap mapping and the huge
> swap cluster before we commit the charge moving.  But the race window
> is so small, that we will just ignore the race.

Moving the charges is a slow path, so can't we just be correct here and not
leak?
