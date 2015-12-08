Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7A46B027D
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:33:20 -0500 (EST)
Received: by pfbg73 with SMTP id g73so3171960pfb.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:33:20 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id t72si1283148pfa.153.2015.12.07.17.33.19
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:33:19 -0800 (PST)
Subject: [PATCH -mm 03/25] dax: guarantee page aligned results from
 bdev_direct_access()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:32:52 -0800
Message-ID: <20151208013252.25030.89320.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org

If a ->direct_access() implementation ever returns a map count less than
PAGE_SIZE, catch the error in bdev_direct_access().  This simplifies
error checking in upper layers.

Reported-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/block_dev.c |    2 ++
 fs/dax.c       |    1 -
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index c27362de0039..653d14ccc86e 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -489,6 +489,8 @@ long bdev_direct_access(struct block_device *bdev, sector_t sector,
 	avail = ops->direct_access(bdev, sector, addr, pfn);
 	if (!avail)
 		return -ERANGE;
+	if (avail > 0 && avail & ~PAGE_MASK)
+		return -ENXIO;
 	return min(avail, size);
 }
 EXPORT_SYMBOL_GPL(bdev_direct_access);
diff --git a/fs/dax.c b/fs/dax.c
index e11d88835bb2..6e498c2570bf 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -52,7 +52,6 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 		sz = min_t(long, count, SZ_1M);
 		clear_pmem(addr, sz);
 		size -= sz;
-		BUG_ON(sz & 511);
 		sector += sz / 512;
 		cond_resched();
 	} while (size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
