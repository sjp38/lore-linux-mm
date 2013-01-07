Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 4AFE16B0070
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 22:42:44 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH v2] mm: memblock: fix wrong memmove size in memblock_merge_regions()
Date: Mon, 7 Jan 2013 11:41:36 +0800
Message-Id: <1357530096-28548-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

The memmove span covers from (next+1) to the end of the array, and the index
of next is (i+1), so the index of (next+1) is (i+2). So the size of remaining
array elements is (type->cnt - (i + 2)).

Cc: Tejun Heo <tj@kernel.org>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
ChangeLog v1->v2:
- Add a comment pointed out by Tejun.
---
 mm/memblock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6259055..88adc8a 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -314,7 +314,8 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
 		}
 
 		this->size += next->size;
-		memmove(next, next + 1, (type->cnt - (i + 1)) * sizeof(*next));
+		/* move forward from next + 1, index of which is i + 2 */
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
