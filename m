Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 485FB6B0397
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:47:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l11so127845758iod.15
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:47:49 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p5si10277383pgn.312.2017.04.21.05.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:47:48 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, swap: Fix swap space leak in error path of swap_free_entries()
Date: Fri, 21 Apr 2017 20:47:39 +0800
Message-Id: <20170421124739.24534-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

From: Huang Ying <ying.huang@intel.com>

In swapcache_free_entries(), if swap_info_get_cont() return NULL,
something wrong occurs for the swap entry.  But we should still
continue to free the following swap entries in the array instead of
skip them to avoid swap space leak.  This is just problem in error
path, where system may be in an inconsistent state, but it is still
good to fix it.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 178130880b90..71890061f653 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1079,8 +1079,6 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
 		p = swap_info_get_cont(entries[i], prev);
 		if (p)
 			swap_entry_free(p, entries[i]);
-		else
-			break;
 		prev = p;
 	}
 	if (p)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
