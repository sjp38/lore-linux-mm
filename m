Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D7BE36B0255
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:17 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so100481130pad.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id wf3si6420263pab.166.2015.10.09.18.01.16
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:17 -0700 (PDT)
Subject: [PATCH v2 02/20] dax: increase granularity of dax_clear_blocks()
 operations
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:33 -0400
Message-ID: <20151010005533.17221.47618.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, ross.zwisler@linux.intel.com, linux-kernel@vger.kernel.org, hch@lst.de

dax_clear_blocks is currently performing a cond_resched() after every
PAGE_SIZE memset.  We need not check so frequently, for example md-raid
only calls cond_resched() at stripe granularity.  Also, in preparation
for introducing a dax_map_atomic() operation that temporarily pins a dax
mapping move the call to cond_resched() to the outer loop.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index cc9a6e3d7389..7031b0312596 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -28,6 +28,7 @@
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
+#include <linux/sizes.h>
 
 /*
  * dax_clear_blocks() is called from within transaction context from XFS,
@@ -43,24 +44,20 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 	do {
 		void __pmem *addr;
 		unsigned long pfn;
-		long count;
+		long count, sz;
 
-		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
+		sz = min_t(long, size, SZ_1M);
+		count = bdev_direct_access(bdev, sector, &addr, &pfn, sz);
 		if (count < 0)
 			return count;
-		BUG_ON(size < count);
-		while (count > 0) {
-			unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
-			if (pgsz > count)
-				pgsz = count;
-			clear_pmem(addr, pgsz);
-			addr += pgsz;
-			size -= pgsz;
-			count -= pgsz;
-			BUG_ON(pgsz & 511);
-			sector += pgsz / 512;
-			cond_resched();
-		}
+		if (count < sz)
+			sz = count;
+		clear_pmem(addr, sz);
+		addr += sz;
+		size -= sz;
+		BUG_ON(sz & 511);
+		sector += sz / 512;
+		cond_resched();
 	} while (size);
 
 	wmb_pmem();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
