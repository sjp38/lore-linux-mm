Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD2952806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:27 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n4so1497690qte.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k38si314829qtf.53.2017.05.09.08.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:50:27 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 16/27] fs: adapt sync_file_range to new reporting infrastructure
Date: Tue,  9 May 2017 11:49:19 -0400
Message-Id: <20170509154930.29524-17-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

Since it returns errors in a way similar to fsync, have it use the same
method for returning previously-reported writeback errors.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/sync.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/sync.c b/fs/sync.c
index 11ba023434b1..89a03b5252d2 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -271,8 +271,11 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
  *
  *
  * SYNC_FILE_RANGE_WAIT_BEFORE and SYNC_FILE_RANGE_WAIT_AFTER will detect any
- * I/O errors or ENOSPC conditions and will return those to the caller, after
- * clearing the EIO and ENOSPC flags in the address_space.
+ * error condition that occurred prior to or after writeback, and will return
+ * that to the caller, while advancing the file's errseq_t cursor. Note that
+ * any errors returned here may have occurred in an area of the file that is
+ * not covered by the given range as most filesystems track writeback errors
+ * on a per-address_space basis
  *
  * It should be noted that none of these operations write out the file's
  * metadata.  So unless the application is strictly performing overwrites of
@@ -282,7 +285,7 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
 SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 				unsigned int, flags)
 {
-	int ret;
+	int ret, ret2;
 	struct fd f;
 	struct address_space *mapping;
 	loff_t endbyte;			/* inclusive */
@@ -356,7 +359,9 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 
 	if (flags & SYNC_FILE_RANGE_WAIT_AFTER)
 		ret = filemap_fdatawait_range(mapping, offset, endbyte);
-
+	ret2 = filemap_report_wb_error(f.file);
+	if (!ret)
+		ret = ret2;
 out_put:
 	fdput(f);
 out:
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
