Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59E7E6B0010
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 22:25:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u16-v6so1954170pfm.15
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 19:25:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h3-v6si2563613plk.47.2018.07.03.19.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 19:24:59 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 08/21] mm, THP, swap: Support to read a huge swap cluster for swapin a THP
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-9-ying.huang@intel.com>
	<20180704001235.w7xexi3jp6ostas5@ca-dmjordan1.us.oracle.com>
Date: Wed, 04 Jul 2018 10:24:46 +0800
In-Reply-To: <20180704001235.w7xexi3jp6ostas5@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 3 Jul 2018 17:12:35 -0700")
Message-ID: <874lhfvitt.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Jun 22, 2018 at 11:51:38AM +0800, Huang, Ying wrote:
>> @@ -411,14 +414,32 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
> ...
>> +			if (thp_swap_supported() && huge_cluster) {
>> +				gfp_t gfp = alloc_hugepage_direct_gfpmask(vma);
>> +
>> +				new_page = alloc_hugepage_vma(gfp, vma,
>> +						addr, HPAGE_PMD_ORDER);
>
> When allocating a huge page, we ignore the gfp_mask argument.
>
> That doesn't matter right now since AFAICT we're not losing any flags: gfp_mask
> from existing callers of __read_swap_cache_async seems to always be a subset of
> GFP_HIGHUSER_MOVABLE and alloc_hugepage_direct_gfpmask always returns a
> superset of that.
>
> But maybe we should warn here in case we end up violating a restriction from a
> future caller.  Something like this?:
>
>> +				gfp_t gfp = alloc_hugepage_direct_gfpmask(vma);
>                                 VM_WARN_ONCE((gfp | gfp_mask) != gfp,
> 					     "ignoring gfp_mask bits");

This looks good!  Thanks!  Will add this.

Best Regards,
Huang, Ying
