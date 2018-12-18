Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3DE68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:54:51 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s25so16634875ioc.14
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:54:51 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u71si1805644ita.88.2018.12.18.12.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 12:54:50 -0800 (PST)
Date: Tue, 18 Dec 2018 12:54:44 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V9 07/21] swap: Support PMD swap mapping when splitting
 huge PMD
Message-ID: <20181218205443.shqczdh3era6heaf@ca-dmjordan1.us.oracle.com>
References: <20181214062754.13723-1-ying.huang@intel.com>
 <20181214062754.13723-8-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214062754.13723-8-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>, aneesh.kumar@linux.vnet.ibm.com

+Aneesh

On Fri, Dec 14, 2018 at 02:27:40PM +0800, Huang Ying wrote:
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bd2543e10938..49df3e7c96c7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c

> +int split_swap_cluster_map(swp_entry_t entry)
        ...
> +	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));

Hi Ying, I crashed on this in v6 as reported and it still dies on me now.

> @@ -2150,6 +2185,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
        ...
> +	if (IS_ENABLED(CONFIG_THP_SWAP) && is_swap_pmd(old_pmd))
> +		return __split_huge_swap_pmd(vma, haddr, pmd);

Problem is 'pmd' is passed here, which has been pmdp_invalidate()ed under the
assumption that it is not a swap entry.  pmd's pfn bits get inverted for L1TF,
so the swap entry gets corrupted and this BUG is the first place that notices.

I don't see a reason to invalidate so soon, so what about just moving the
invalidation down, past the migration/swap checks?
