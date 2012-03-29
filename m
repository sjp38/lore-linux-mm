Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 24DBF6B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 22:26:20 -0400 (EDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCH] mm/memblock.c: Correctly check whether to trim a block
Date: Wed, 28 Mar 2012 19:25:58 -0700
Message-Id: <1332987958-10766-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, benh@kernel.crashing.org, yinghai@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

Currently in __memblock_remove, the check to trim the top of
a block off only checks if the requested base is less than the
memblock end. If the end of the requested region is equal to
the start of a memblock, this will incorrectly try to remove
the block, possibly causing an integer underflow:

   ---------------------------------------
   |                    |                |
   |                    |                |
  base              end = rgn->base    rend

An additional check is needed to see if the end of the requested
region is greater than the memblock region:

   ----------------------
   |                     |
   |                     |
  rgn->base    base     rend      end
                |                  |
                |                  |
                --------------------

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 5338237..e174ee0 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -459,7 +459,7 @@ static long __init_memblock __memblock_remove(struct memblock_type *type,
 		}
 
 		/* And check if we need to trim the top of a block */
-		if (base < rend)
+		if (base < rend && end > rend)
 			rgn->size -= rend - base;
 
 	}
-- 
1.7.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
