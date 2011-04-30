From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/3] readahead: reduce unnecessary mmap_miss increases
Date: Sat, 30 Apr 2011 11:22:45 +0800
Message-ID: <20110430033018.057418160__29975.9999187247$1304134323$gmane$org@intel.com>
References: <20110430032243.355805181@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=readahead-reduce-mmap_miss-increases.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Li Shaohua <shaohua.li@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Andi Kleen <ak@linux.intel.com>

The original INT_MAX is too large, reduce it to

- avoid unnecessarily dirtying/bouncing the cache line
- restore mmap read-around faster on changed access pattern

Background: in the mosbench exim benchmark which does multi-threaded
page faults on shared struct file, the ra->mmap_miss updates are found
to cause excessive cache line bouncing on tmpfs. The ra state updates
are needless for tmpfs because it actually disabled readahead totally
(shmem_backing_dev_info.ra_pages == 0).

Tested-by: Tim Chen <tim.c.chen@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/filemap.c	2011-04-23 09:01:44.000000000 +0800
+++ linux-next/mm/filemap.c	2011-04-23 09:17:21.000000000 +0800
@@ -1538,7 +1538,8 @@ static void do_sync_mmap_readahead(struc
 		return;
 	}
 
-	if (ra->mmap_miss < INT_MAX)
+	/* Avoid banging the cache line if not needed */
+	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
 		ra->mmap_miss++;
 
 	/*
