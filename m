Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C28396B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:04:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p85-v6so21410884qke.23
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 05:04:51 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a18-v6si651363qvn.176.2018.06.12.05.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 05:04:50 -0700 (PDT)
Date: Tue, 12 Jun 2018 05:04:30 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180612120430.f4wce5hygca5wlhg@ca-dmjordan1.us.oracle.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
 <20180523082625.6897-4-ying.huang@intel.com>
 <20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
 <87o9ggpzlk.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87o9ggpzlk.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue, Jun 12, 2018 at 09:23:19AM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> > #2:  We've masked off SWAP_HAS_CACHE and COUNT_CONTINUED, and already checked
> > for SWAP_MAP_BAD, so I think condition #2 always fails and can just be removed.
> 
> I think this is used to check some software bug.  For example,
> SWAP_MAP_SHMEM will yield true here.

So it does!  And so __swap_duplicate returns -EINVAL in that case, which
swap_shmem_alloc just ignores.  Confusing, and an explicit check for
SWAP_MAP_SHMEM would be cleaner, but why fix what isn't broken.

> 
> >> +#ifdef CONFIG_THP_SWAP
> >> +static int __swap_duplicate_cluster(swp_entry_t *entry, unsigned char usage)
> > ...
> >> +	} else {
> >> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
> >> +retry:
> >> +			err = __swap_duplicate_locked(si, offset + i, 1);
> >
> > I guess usage is assumed to be 1 at this point (__swap_duplicate_locked makes
> > the same assumption).  Maybe make this explicit with
> >
> > 			err = __swap_duplicate_locked(si, offset + i, usage);
> >
> > , use 'usage' in cluster_set_count and __swap_entry_free too, and then
> > earlier have a
> >
> >        VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);
> >
> > ?
> 
> Yes.  I will fix this.  And we can just check it in
> __swap_duplicate_locked() and all these will be covered.

I'll respond to your other mail.

> > Not related to your changes, but while we're here, the comment with
> > SWAP_HAS_CONT in swap_count() could be deleted: I don't think there ever was a
> > SWAP_HAS_CONT.
> 
> Yes.  We should correct this.  Because this should go to a separate patch,
> would you mind to submit a patch to fix it?

Sure, I'll do that.

Daniel
