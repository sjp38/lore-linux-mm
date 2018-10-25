Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1E06B02A8
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 11:00:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x10-v6so5002214edx.9
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 08:00:58 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l3si3531125edv.432.2018.10.25.08.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 08:00:57 -0700 (PDT)
Date: Thu, 25 Oct 2018 08:00:44 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V6 06/21] swap: Support PMD swap mapping when splitting
 huge PMD
Message-ID: <20181025150044.urvklakbzd6jauyb@ca-dmjordan1.us.oracle.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
 <20181010071924.18767-7-ying.huang@intel.com>
 <20181024172549.xyevip5kclq2ig33@ca-dmjordan1.us.oracle.com>
 <87bm7ivoav.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bm7ivoav.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Thu, Oct 25, 2018 at 08:54:16AM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> 
> > On Wed, Oct 10, 2018 at 03:19:09PM +0800, Huang Ying wrote:
> >> +#ifdef CONFIG_THP_SWAP
> >> +/*
> >> + * The corresponding page table shouldn't be changed under us, that
> >> + * is, the page table lock should be held.
> >> + */
> >> +int split_swap_cluster_map(swp_entry_t entry)
> >> +{
> >> +	struct swap_info_struct *si;
> >> +	struct swap_cluster_info *ci;
> >> +	unsigned long offset = swp_offset(entry);
> >> +
> >> +	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));
> >> +	si = _swap_info_get(entry);
> >> +	if (!si)
> >> +		return -EBUSY;
> >
> > I think this return value doesn't get used anywhere?
> 
> Yes.  And the error is only possible if page table is corrupted.  So
> maybe add a VM_BUG_ON() in it caller __split_huge_swap_pmd()?

Taking a second look at this, I see we'd get some nice pr_err message in this
case, so VM_BUG_ON doesn't seem necessary.

Still odd there's an unchecked return value, but it could be useful to future
callers.  Just my nitpick, feel free to leave as is.
