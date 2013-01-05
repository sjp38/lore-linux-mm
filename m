Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A16406B0070
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 19:42:32 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id fn20so10435284lab.26
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 16:42:30 -0800 (PST)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2] mm: bootmem: fix free_all_bootmem_core with odd bitmap alignment
Date: Sat,  5 Jan 2013 04:42:16 +0400
Message-Id: <1357346536-26642-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>

Currently free_all_bootmem_core ignores that node_min_pfn may be not
multiple of BITS_PER_LONG. E.g. commit 6dccdcbe "mm: bootmem: fix
checking the bitmap when finally freeing bootmem" shifts vec by lower
bits of start instead of lower bits of idx. Also

  if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL)

assumes that vec bit 0 corresponds to start pfn, which is only true when
node_min_pfn is a multiple of BITS_PER_LONG. Also loop in the else
clause can double-free pages (e.g. with node_min_pfn == start == 1,
map[0] == ~0 on 32-bit machine page 32 will be double-freed).

This bug causes the following message during xtensa kernel boot:

[    0.000000] bootmem::free_all_bootmem_core nid=0 start=1 end=8000
[    0.000000] BUG: Bad page state in process swapper  pfn:00001
[    0.000000] page:d04bd020 count:0 mapcount:-127 mapping:  (null) index:0x2
[    0.000000] page flags: 0x0()
[    0.000000]
[    0.000000] Stack: 00000000 00000002 00000004 ffffffff d0193e44 ffffff81 00000000 00000002
[    0.000000]        90038c66 d0193e90 d04bd020 000001a8 00000000 ffffffff 00000000 00000020
[    0.000000]        90039a4c d0193eb0 d04bd020 00000001 d04b7b20 ffff8ad0 00000000 00000000
[    0.000000] Call Trace:
[    0.000000]  [<d0038bf8>] bad_page+0x8c/0x9c
[    0.000000]  [<d0038c66>] free_pages_prepare+0x5e/0x88
[    0.000000]  [<d0039a4c>] free_hot_cold_page+0xc/0xa0
[    0.000000]  [<d0039b28>] __free_pages+0x24/0x38
[    0.000000]  [<d01b8230>] __free_pages_bootmem+0x54/0x56
[    0.000000]  [<d01b1667>] free_all_bootmem_core$part$11+0xeb/0x138
[    0.000000]  [<d01b179e>] free_all_bootmem+0x46/0x58
[    0.000000]  [<d01ae7a9>] mem_init+0x25/0xa4
[    0.000000]  [<d01ad13e>] start_kernel+0x11e/0x25c
[    0.000000]  [<d01a9121>] should_never_return+0x0/0x3be7

The fix is the following:
- always align vec so that its bit 0 corresponds to start
- provide BITS_PER_LONG bits in vec, if those bits are available in the map
- don't free pages past next start position in the else clause.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Sent wrong version for v1, 'while' should have been 'for'.

 mm/bootmem.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 1324cd7..1157be7 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -185,10 +185,23 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 
 	while (start < end) {
 		unsigned long *map, idx, vec;
+		unsigned shift;
 
 		map = bdata->node_bootmem_map;
 		idx = start - bdata->node_min_pfn;
+		shift = idx & (BITS_PER_LONG - 1);
+		/*
+		 * vec holds at most BITS_PER_LONG map bits,
+		 * bit 0 corresponds to start.
+		 */
 		vec = ~map[idx / BITS_PER_LONG];
+
+		if (shift) {
+			vec >>= shift;
+			if (end - start >= BITS_PER_LONG)
+				vec |= ~map[idx / BITS_PER_LONG + 1] <<
+					(BITS_PER_LONG - shift);
+		}
 		/*
 		 * If we have a properly aligned and fully unreserved
 		 * BITS_PER_LONG block of pages in front of us, free
@@ -201,19 +214,17 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 			count += BITS_PER_LONG;
 			start += BITS_PER_LONG;
 		} else {
-			unsigned long off = 0;
+			unsigned long cur;
 
-			vec >>= start & (BITS_PER_LONG - 1);
-			while (vec) {
+			start = ALIGN(start + 1, BITS_PER_LONG);
+			for (cur = start; vec && cur != start; ++cur) {
 				if (vec & 1) {
-					page = pfn_to_page(start + off);
+					page = pfn_to_page(cur);
 					__free_pages_bootmem(page, 0);
 					count++;
 				}
 				vec >>= 1;
-				off++;
 			}
-			start = ALIGN(start + 1, BITS_PER_LONG);
 		}
 	}
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
