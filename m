Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25E7D6B0008
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 22:12:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w11-v6so13607771pfk.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:12:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l4-v6si22856569plb.213.2018.07.12.19.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 19:12:40 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] mm, swap: Make CONFIG_THP_SWAP depends on CONFIG_SWAP
Date: Fri, 13 Jul 2018 10:12:28 +0800
Message-Id: <20180713021228.439-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

From: Huang Ying <ying.huang@intel.com>

CONFIG_THP_SWAP should depend on CONFIG_SWAP, because it's
unreasonable to optimize swapping for THP (Transparent Huge Page)
without basic swapping support.

In original code, when CONFIG_SWAP=n and CONFIG_THP_SWAP=y,
split_swap_cluster() will not be built because it is in swapfile.c,
but it will be called in huge_memory.c.  This doesn't trigger a build
error in practice because the call site is enclosed by
PageSwapCache(), which is defined to be constant 0 when CONFIG_SWAP=n.
But this is fragile and should be fixed.

The comments are fixed too to reflect the latest progress.

Fixes: 38d8b4e6bdc8 ("mm, THP, swap: delay splitting THP during swap out")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/Kconfig | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index b78e7cd4e9fe..97114c94239c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -419,10 +419,11 @@ config ARCH_WANTS_THP_SWAP
 
 config THP_SWAP
 	def_bool y
-	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP
+	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
 	help
 	  Swap transparent huge pages in one piece, without splitting.
-	  XXX: For now this only does clustered swap space allocation.
+	  XXX: For now, swap cluster backing transparent huge page
+	  will be split after swapout.
 
 	  For selection by architectures with reasonable THP sizes.
 
-- 
2.16.4
