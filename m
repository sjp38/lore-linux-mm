Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76DBC6B0005
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 20:54:22 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j9-v6so3056754pfn.20
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 17:54:22 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 61-v6si6311362plr.72.2018.10.24.17.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 17:54:21 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V6 06/21] swap: Support PMD swap mapping when splitting huge PMD
References: <20181010071924.18767-1-ying.huang@intel.com>
	<20181010071924.18767-7-ying.huang@intel.com>
	<20181024172549.xyevip5kclq2ig33@ca-dmjordan1.us.oracle.com>
Date: Thu, 25 Oct 2018 08:54:16 +0800
In-Reply-To: <20181024172549.xyevip5kclq2ig33@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Wed, 24 Oct 2018 10:25:49 -0700")
Message-ID: <87bm7ivoav.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Wed, Oct 10, 2018 at 03:19:09PM +0800, Huang Ying wrote:
>> +#ifdef CONFIG_THP_SWAP
>> +/*
>> + * The corresponding page table shouldn't be changed under us, that
>> + * is, the page table lock should be held.
>> + */
>> +int split_swap_cluster_map(swp_entry_t entry)
>> +{
>> +	struct swap_info_struct *si;
>> +	struct swap_cluster_info *ci;
>> +	unsigned long offset = swp_offset(entry);
>> +
>> +	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));
>> +	si = _swap_info_get(entry);
>> +	if (!si)
>> +		return -EBUSY;
>
> I think this return value doesn't get used anywhere?

Yes.  And the error is only possible if page table is corrupted.  So
maybe add a VM_BUG_ON() in it caller __split_huge_swap_pmd()?

Best Regards,
Huang, Ying
