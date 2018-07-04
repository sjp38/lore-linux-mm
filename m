Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB956B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 20:12:56 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 123-v6so4005805qkg.8
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 17:12:56 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b29-v6si1109512qvf.283.2018.07.03.17.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 17:12:55 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:12:35 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -v4 08/21] mm, THP, swap: Support to read a huge swap
 cluster for swapin a THP
Message-ID: <20180704001235.w7xexi3jp6ostas5@ca-dmjordan1.us.oracle.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-9-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622035151.6676-9-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Fri, Jun 22, 2018 at 11:51:38AM +0800, Huang, Ying wrote:
> @@ -411,14 +414,32 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
...
> +			if (thp_swap_supported() && huge_cluster) {
> +				gfp_t gfp = alloc_hugepage_direct_gfpmask(vma);
> +
> +				new_page = alloc_hugepage_vma(gfp, vma,
> +						addr, HPAGE_PMD_ORDER);

When allocating a huge page, we ignore the gfp_mask argument.

That doesn't matter right now since AFAICT we're not losing any flags: gfp_mask
from existing callers of __read_swap_cache_async seems to always be a subset of
GFP_HIGHUSER_MOVABLE and alloc_hugepage_direct_gfpmask always returns a
superset of that.

But maybe we should warn here in case we end up violating a restriction from a
future caller.  Something like this?:

> +				gfp_t gfp = alloc_hugepage_direct_gfpmask(vma);
                                VM_WARN_ONCE((gfp | gfp_mask) != gfp,
					     "ignoring gfp_mask bits");
