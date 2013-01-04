Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 5EFD86B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 04:11:46 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [RFC PATCH] mm: memblock: fix wrong memmove size in memblock_merge_regions()
Date: Fri, 4 Jan 2013 17:10:50 +0800
Message-Id: <1357290650-25544-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

The memmove span covers from (next+1) to the end of the array, and the index
of next is (i+1), so the index of (next+1) is (i+2). So the size of remaining
array elements is (type->cnt - (i + 2)).

PS. It seems that memblock_merge_regions() could be made some improvement:
we need't memmove the remaining array elements until we find a none-mergable
element, but now we memmove everytime we find a neighboring compatible region.
I'm not sure if the trial is worth though.

Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6259055..85ce056 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -314,7 +314,7 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
 		}
 
 		this->size += next->size;
-		memmove(next, next + 1, (type->cnt - (i + 1)) * sizeof(*next));
+		memmove(next, next + 1, (type->cnt - (i + 2)) * sizeof(*next));
 		type->cnt--;
 	}
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
