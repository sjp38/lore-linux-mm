Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B872D6B0266
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:37:53 -0500 (EST)
Received: by pfdd184 with SMTP id d184so39746933pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:37:53 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id us7si16762890pac.204.2015.12.09.18.37.52
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:37:53 -0800 (PST)
Subject: [-mm PATCH v2 03/25] dax: guarantee page aligned results from
 bdev_direct_access()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:37:25 -0800
Message-ID: <20151210023725.30368.51320.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
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
index fe0cc27929ec..6a0fc382e7af 100644
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
index 11721c0fc127..1080fb50fa4d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -52,7 +52,6 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 		sz = min_t(long, count, SZ_128K);
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
