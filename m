From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/3] readahead: reduce unnecessary mmap_miss increases
Date: Tue, 26 Apr 2011 17:43:54 +0800
Message-ID: <20110426094859.463438303__31041.8783840307$1303811507$gmane$org@intel.com>
References: <20110426094352.030753173@intel.com>
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
