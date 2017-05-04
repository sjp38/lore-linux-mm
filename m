Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38BA46B02C4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 15:59:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 191so17657655pfb.8
        for <linux-mm@kvack.org>; Thu, 04 May 2017 12:59:23 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t21si1160788pfj.0.2017.05.04.12.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 12:59:22 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 2/2] dax: fix data corruption due to stale mmap reads
Date: Thu,  4 May 2017 13:59:10 -0600
Message-Id: <20170504195910.11579-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20170504195910.11579-1-ross.zwisler@linux.intel.com>
References: <20170504195910.11579-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anna Schumaker <anna.schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Latchesar Ionkov <lucho@ionkov.net>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Ron Minnich <rminnich@sandia.gov>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, Trond Myklebust <trond.myklebust@primarydata.com>, v9fs-developer@lists.sourceforge.net

Users of DAX can suffer data corruption from stale mmap reads via the
following sequence:

- open an mmap over a 2MiB hole

- read from a 2MiB hole, faulting in a 2MiB zero page

- write to the hole with write(3p).  The write succeeds but we incorrectly
  leave the 2MiB zero page mapping intact.

- via the mmap, read the data that was just written.  Since the zero page
  mapping is still intact we read back zeroes instead of the new data.

We fix this by unconditionally calling invalidate_inode_pages2_range() in
dax_iomap_actor() for new block allocations, and by enhancing
invalidate_inode_pages2_range() so that it properly unmaps the DAX entries
being removed from the radix tree.

This is based on an initial patch from Jan Kara.

I've written an fstest that triggers this error:
http://www.spinics.net/lists/linux-mm/msg126276.html

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Fixes: c6dcf52c23d2 ("mm: Invalidate DAX radix tree entries only if appropriate")
Reported-by: Jan Kara <jack@suse.cz>
Cc: <stable@vger.kernel.org>    [4.10+]
---

Changes since v1:
 - Instead of unmapping each DAX entry individually in
   __dax_invalidate_mapping_entry(), instead unmap the whole range at once
   inside of invalidate_inode_pages2_range().  Each unmap requires an rmap
   walk so this should be less expensive, plus now we don't have to drop
   and re-acquire the mapping->tree_lock for each entry. (Jan)

These patches apply cleanly to v4.11 and have passed an xfstest run.
They also apply to v4.10.13 with a little help from git am's 3-way merger.

---
 fs/dax.c      |  8 ++++----
 mm/truncate.c | 10 ++++++++++
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 166504c..1f2c880 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -999,11 +999,11 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		return -EIO;
 
 	/*
-	 * Write can allocate block for an area which has a hole page mapped
-	 * into page tables. We have to tear down these mappings so that data
-	 * written by write(2) is visible in mmap.
+	 * Write can allocate block for an area which has a hole page or zero
+	 * PMD entry in the radix tree.  We have to tear down these mappings so
+	 * that data written by write(2) is visible in mmap.
 	 */
-	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
+	if (iomap->flags & IOMAP_F_NEW) {
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pos >> PAGE_SHIFT,
 					      (end - 1) >> PAGE_SHIFT);
diff --git a/mm/truncate.c b/mm/truncate.c
index c537184..ad40316 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -683,6 +683,16 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		cond_resched();
 		index++;
 	}
+
+	/*
+	 * Ensure that any DAX exceptional entries that have been invalidated
+	 * are also unmapped.
+	 */
+	if (dax_mapping(mapping)) {
+		unmap_mapping_range(mapping, (loff_t)start << PAGE_SHIFT,
+				(loff_t)(1 + end - start) << PAGE_SHIFT, 0);
+	}
+
 	cleancache_invalidate_inode(mapping);
 	return ret;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
