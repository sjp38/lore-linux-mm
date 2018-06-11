Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5F316B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 16:42:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w74-v6so20482603qka.4
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:42:50 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s11-v6si3506031qvb.73.2018.06.11.13.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 13:42:49 -0700 (PDT)
Date: Mon, 11 Jun 2018 13:42:31 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
 <20180523082625.6897-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523082625.6897-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Hi,

The series up to and including this patch doesn't build.  For this patch we
need:

diff --git a/mm/swap_state.c b/mm/swap_state.c
index c6b3eab73fde..2f2d07627113 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -433,7 +433,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
                /*
                 * Swap entry may have been freed since our caller observed it.
                 */
-               err = swapcache_prepare(entry);
+               err = swapcache_prepare(entry, false);
                if (err == -EEXIST) {
                        radix_tree_preload_end();
                        /*


On Wed, May 23, 2018 at 04:26:07PM +0800, Huang, Ying wrote:
> @@ -3516,11 +3512,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)

Two comments about this part of __swap_duplicate as long as you're moving it to
another function:

   } else if (count || has_cache) {
   
   	if ((count & ~COUNT_CONTINUED) < SWAP_MAP_MAX)          /* #1   */
   		count += usage;
   	else if ((count & ~COUNT_CONTINUED) > SWAP_MAP_MAX)     /* #2   */
   		err = -EINVAL;

#1:  __swap_duplicate_locked might use

    VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);

to document the unstated assumption that usage is 1 (otherwise count could
overflow).

#2:  We've masked off SWAP_HAS_CACHE and COUNT_CONTINUED, and already checked
for SWAP_MAP_BAD, so I think condition #2 always fails and can just be removed.

> +#ifdef CONFIG_THP_SWAP
> +static int __swap_duplicate_cluster(swp_entry_t *entry, unsigned char usage)
...
> +	} else {
> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
> +retry:
> +			err = __swap_duplicate_locked(si, offset + i, 1);

I guess usage is assumed to be 1 at this point (__swap_duplicate_locked makes
the same assumption).  Maybe make this explicit with

			err = __swap_duplicate_locked(si, offset + i, usage);

, use 'usage' in cluster_set_count and __swap_entry_free too, and then
earlier have a

       VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);

?

> +#else
> +static inline int __swap_duplicate_cluster(swp_entry_t *entry,

This doesn't need inline.


Not related to your changes, but while we're here, the comment with
SWAP_HAS_CONT in swap_count() could be deleted: I don't think there ever was a
SWAP_HAS_CONT.

The rest looks ok up to this point.
