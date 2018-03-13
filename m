Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6502C6B0005
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 21:20:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x7so6576584pfd.19
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 18:20:58 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c200si6679663pfb.373.2018.03.12.18.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 18:20:57 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm: Fix race between swapoff and mincore
Date: Tue, 13 Mar 2018 09:20:36 +0800
Message-Id: <20180313012036.1597-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>

From: Huang Ying <ying.huang@intel.com>

>From commit 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB
trunks") on, after swapoff, the address_space associated with the swap
device will be freed.  So swap_address_space() users which touch the
address_space need some kind of mechanism to prevent the address_space
from being freed during accessing.

When mincore process unmapped range for swapped shmem pages, it
doesn't hold the lock to prevent swap device from being swapoff.  So
the following race is possible,

CPU1					CPU2
do_mincore()				swapoff()
  walk_page_range()
    mincore_unmapped_range()
      __mincore_unmapped_range
        mincore_page
	  as = swap_address_space()
          ...				  exit_swap_address_space()
          ...				    kvfree(spaces)
	  find_get_page(as)

The address space may be accessed after being freed.

To fix the race, get_swap_device()/put_swap_device() is used to
enclose find_get_page() to check whether the swap entry is valid and
prevent the swap device from being swapoff during accessing.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/mincore.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index fc37afe226e6..a66f2052c7b1 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -68,8 +68,16 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		 */
 		if (radix_tree_exceptional_entry(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
-			page = find_get_page(swap_address_space(swp),
-					     swp_offset(swp));
+			struct swap_info_struct *si;
+
+			/* Prevent swap device to being swapoff under us */
+			si = get_swap_device(swp);
+			if (si) {
+				page = find_get_page(swap_address_space(swp),
+						     swp_offset(swp));
+				put_swap_device(si);
+			} else
+				page = NULL;
 		}
 	} else
 		page = find_get_page(mapping, pgoff);
-- 
2.15.1
