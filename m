Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 685936B02E1
	for <linux-mm@kvack.org>; Thu, 18 May 2017 01:33:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p29so26671046pgn.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 22:33:51 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w20si4183059pgj.196.2017.05.17.22.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 22:33:50 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v11 1/5] mm, THP, swap: Delay splitting THP during swap out
References: <20170515112522.32457-1-ying.huang@intel.com>
	<20170515112522.32457-2-ying.huang@intel.com>
Date: Thu, 18 May 2017 13:33:47 +0800
In-Reply-To: <20170515112522.32457-2-ying.huang@intel.com> (Ying Huang's
	message of "Mon, 15 May 2017 19:25:18 +0800")
Message-ID: <87k25ed8zo.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org


"Huang, Ying" <ying.huang@intel.com> writes:

> From: Huang Ying <ying.huang@intel.com>
>
> In this patch, splitting huge page is delayed from almost the first
> step of swapping out to after allocating the swap space for the
> THP (Transparent Huge Page) and adding the THP into the swap cache.
> This will batch the corresponding operation, thus improve THP swap out
> throughput.
>
> This is the first step for the THP swap optimization.  The plan is to
> delay splitting the THP step by step and avoid splitting the THP
> finally.
>

I found two issues in this patch, could you fold the following fix patch
into the original patch?

Best Regards,
Huang, Ying

------------------------------------------------------------->
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH] mm, THP, swap: Fix two issues in THP optimize patch

When changing the logic for cluster allocation for THP in
get_swap_page(), I made a mistake so that a normal swap slot may be
allocated for a THP instead of return with failure.  This is fixed in
the patch.

And I found two likely/unlikely annotation is wrong in
get_swap_pages(), because that is slow path, I just removed the
likely/unlikely annotation.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swap_slots.c | 5 +++--
 mm/swapfile.c   | 4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 78047d1efedd..90c1032a8ac3 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -309,8 +309,9 @@ swp_entry_t get_swap_page(struct page *page)
 
 	entry.val = 0;
 
-	if (IS_ENABLED(CONFIG_THP_SWAP) && PageTransHuge(page)) {
-		get_swap_pages(1, true, &entry);
+	if (PageTransHuge(page)) {
+		if (IS_ENABLED(CONFIG_THP_SWAP))
+			get_swap_pages(1, true, &entry);
 		return entry;
 	}
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f4c0f2a92bf0..984f0dd94948 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -937,13 +937,13 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
-		if (likely(cluster))
+		if (cluster)
 			n_ret = swap_alloc_cluster(si, swp_entries);
 		else
 			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
 						    n_goal, swp_entries);
 		spin_unlock(&si->lock);
-		if (n_ret || unlikely(cluster))
+		if (n_ret || cluster)
 			goto check_out;
 		pr_debug("scan_swap_map of si %d failed to find offset\n",
 			si->type);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
