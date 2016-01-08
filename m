Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A5F3A828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 00:28:14 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so4592100pfb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 21:28:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hp4si71961805pad.113.2016.01.07.21.28.13
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 21:28:14 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v8 1/9] dax: fix NULL pointer dereference in __dax_dbg()
Date: Thu,  7 Jan 2016 22:27:51 -0700
Message-Id: <1452230879-18117-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

In __dax_pmd_fault() we currently assume that get_block() will always set
bh.b_bdev and we unconditionally dereference it in __dax_dbg().  This
assumption isn't always true - when called for reads of holes
ext4_dax_mmap_get_block() returns a buffer head where bh->b_bdev is never
set.  I hit this BUG while testing the DAX PMD fault path.

Instead, initialize bh.b_bdev before passing bh into get_block().  It is
possible that the filesystem's get_block() will update bh.b_bdev, and this
is fine - we just want to initialize bh.b_bdev to something reasonable so
that the calls to __dax_dbg() work and print something useful.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/dax.c b/fs/dax.c
index 7af8797..513bba5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -624,6 +624,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	}
 
 	memset(&bh, 0, sizeof(bh));
+	bh.b_bdev = inode->i_sb->s_bdev;
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
