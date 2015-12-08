Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id DFF8A6B027C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:33:14 -0500 (EST)
Received: by pfbg73 with SMTP id g73so3170680pfb.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:33:14 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 1si1330906pfc.3.2015.12.07.17.33.14
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:33:14 -0800 (PST)
Subject: [PATCH -mm 02/25] dax: increase granularity of dax_clear_blocks()
 operations
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:32:47 -0800
Message-ID: <20151208013247.25030.52030.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.com>

dax_clear_blocks is currently performing a cond_resched() after every
PAGE_SIZE memset.  We need not check so frequently, for example md-raid
only calls cond_resched() at stripe granularity.  Also, in preparation
for introducing a dax_map_atomic() operation that temporarily pins a dax
mapping move the call to cond_resched() to the outer loop.

Reviewed-by: Jan Kara <jack@suse.com>
Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 19492cc65a30..e11d88835bb2 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -28,6 +28,7 @@
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
+#include <linux/sizes.h>
 
 /*
  * dax_clear_blocks() is called from within transaction context from XFS,
@@ -43,24 +44,17 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 	do {
 		void __pmem *addr;
 		unsigned long pfn;
-		long count;
+		long count, sz;
 
 		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
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
+		sz = min_t(long, count, SZ_1M);
+		clear_pmem(addr, sz);
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
