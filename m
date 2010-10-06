Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7652D6B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 16:49:17 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 4/4] HWPOISON: Stop shrinking at right page count
Date: Wed,  6 Oct 2010 22:49:01 +0200
Message-Id: <1286398141-13749-5-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@linux.intel.com>

When we call the slab shrinker to free a page we need to stop at
page count one because the caller always holds a single reference, not zero.

This avoids useless looping over slab shrinkers and freeing too much
memory.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 886144b..7c1af9b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -237,7 +237,7 @@ void shake_page(struct page *p, int access)
 		int nr;
 		do {
 			nr = shrink_slab(1000, GFP_KERNEL, 1000);
-			if (page_count(p) == 0)
+			if (page_count(p) == 1)
 				break;
 		} while (nr > 10);
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
