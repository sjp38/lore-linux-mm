From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051025111802.7378.40401.sendpatchset@cherry.local>
Subject: [PATCH] NUMA: broken per cpu pageset counters
Date: Tue, 25 Oct 2005 20:17:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

The NUMA counters in struct per_cpu_pageset (linux/mmzone.h) are never cleared
today. This works ok for CPU 0 on NUMA machines because boot_pageset[] is 
already zero, but for other CPU:s this results in uninitialized counters.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

Tested on dual x86_64 hardware with 2.6.14-rc5-git5. 

/proc/zoneinfo:
....
            numa_hit:       15064664480448666958
            numa_miss:      15061573751478353360
            numa_foreign:   15082960697523852788
            interleave_hit: 15083101074612482007
            local_node:     15084090651888212814
            other_node:     5860683432910092144
....

--- linux-2.6.14-rc5-git5/mm/page_alloc.c	2005-10-24 15:37:48.000000000 +0900
+++ linux-2.6.14-rc5-git5-setup_pageset_zero_fix/mm/page_alloc.c	2005-10-25 19:48:06.000000000 +0900
@@ -1750,6 +1750,8 @@ inline void setup_pageset(struct per_cpu
 {
 	struct per_cpu_pages *pcp;
 
+	memset(p, 0, sizeof(*p));
+
 	pcp = &p->pcp[0];		/* hot */
 	pcp->count = 0;
 	pcp->low = 2 * batch;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
