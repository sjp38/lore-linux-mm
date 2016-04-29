Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6CC6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 17:56:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so258679846pfe.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:56:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ff4si24507380pad.48.2016.04.29.14.56.06
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 14:56:06 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v4 8/7] Documentation: add error handling information to dax.txt
Date: Fri, 29 Apr 2016 15:55:42 -0600
Message-Id: <1461966942-21205-1-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>

This just provides information of the basic paths that can be used to
deal with (i.e. clear) media errors from the file system point-of-view.

Cc: Dave Chinner <david@fromorbit.com>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---

While this isn't a design document for new mechanisms for adding
error recovery/redundancy at the block/fs layers, this attempts to
explain the bare essentials required for anything operating above
the pmem block driver in the stack.

 Documentation/filesystems/dax.txt | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index 7bde640..71cd8fa 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -79,6 +79,40 @@ These filesystems may be used for inspiration:
 - ext4: the fourth extended filesystem, see Documentation/filesystems/ext4.txt
 
 
+Handling Media Errors
+---------------------
+
+The libnvdimm subsystem stores a record of known media error locations for
+each pmem block device (in gendisk->badblocks). If we fault at such location,
+or one with a latent error not yet discovered, the application can expect
+to receive a SIGBUS. Libnvdimm also allows clearing of these errors by simply
+writing the affected sectors (through the pmem driver, and if the underlying
+NVDIMM supports the clear_poison DSM defined by ACPI).
+
+Since DAX IO normally doesn't go through the driver/bio path, applications or
+sysadmins have an option to restore the lost data from a prior backup/inbuilt
+redundancy in the following two ways:
+
+1. Delete the affected file, and restore from a backup (sysadmin route):
+   This will free the file system blocks that were being used by the file,
+   and the next time they're allocated, they will be zeroed first, which
+   happens through the driver, and will clear bad sectors.
+
+2. Open the file with O_DIRECT, and restore a sector's worth of data at the
+   bad location (application route):
+   We allow O_DIRECT writes to go through the normal O_DIRECT path that sends
+   bios down through the driver. If an application is able to restore its own
+   data, it can use this path to clear errors.
+
+These are the two basic paths that allow DAX filesystems to continue operating
+in the presence of media errors. More robust error recovery mechanisms can be
+built on top of this in the future, for example, involving redundancy/mirroring
+provided at the block layer through DM, or additionally, at the filesystem
+level. These would have to rely on the above two tenets, that error clearing
+can happen either by sending an IO through the driver, or zeroing (also through
+the driver).
+
+
 Shortcomings
 ------------
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
