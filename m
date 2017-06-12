Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5BC26B03A1
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:37 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s33so42640818qtg.1
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k23si8522421qtb.47.2017.06.12.05.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:36 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 11/13] Documentation: flesh out the section in vfs.txt on storing and reporting writeback errors
Date: Mon, 12 Jun 2017 08:23:04 -0400
Message-Id: <20170612122316.13244-13-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

I waxed a little loquacious here, but I figured that more detail was
better, and writeback error handling is so hard to get right.

Although I think we'll eventually remove it once the transition is
complete, I've gone ahead and documented the FS_WB_ERRSEQ flag as well.

Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/vfs.txt | 50 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 47 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index f42b90687d40..c3efdd833a3d 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -576,7 +576,49 @@ should clear PG_Dirty and set PG_Writeback.  It can be actually
 written at any point after PG_Dirty is clear.  Once it is known to be
 safe, PG_Writeback is cleared.
 
-Writeback makes use of a writeback_control structure...
+Writeback makes use of a writeback_control structure to direct the
+operations.  This gives the the writepage and writepages operations some
+information about the nature of and reason for the writeback request,
+and the constraints under which it is being done.  It is also used to
+return information back to the caller about the result of a writepage or
+writepages request.
+
+Handling errors during writeback
+--------------------------------
+Most applications that utilize the pagecache will periodically call
+fsync to ensure that data written has made it to the backing store.
+When there is an error during writeback, expect that error to be
+reported when fsync is called.  After an error has been reported to
+fsync, subsequent fsync calls on the same file descriptor should return
+0, unless further writeback errors have occurred since the previous
+fsync.
+
+Ideally, the kernel would report an error only on file descriptions on
+which writes were done that subsequently failed to be written back.  The
+generic pagecache infrastructure does not track the file descriptions
+that have dirtied each individual page however, so determining which
+file descriptors should get back an error is not possible.
+
+Instead, the generic writeback error tracking infrastructure in the
+kernel settles for reporting errors to fsync on all file descriptions
+that were open at the time that the error occurred.  In a situation with
+multiple writers, all of them will get back an error on a subsequent fsync,
+even if all of the writes done through that particular file descriptor
+succeeded (or even if there were no writes on that file descriptor at all).
+
+Filesystems that wish to use this infrastructure should call
+filemap_set_wb_err to record the error in the address_space when it
+occurs.  Then, at the end of their fsync operation, they should call
+filemap_report_wb_err to ensure that the struct file's error cursor
+has advanced to the correct point in the stream of errors emitted by
+the backing device(s).
+
+Older kernels used a different method for tracking errors, based on flags
+in the address_space. We're currently switching everything over to use
+the infrastructure based on errseq_t values. During the transition,
+filesystem authors will want to also ensure their file_system_type has
+FS_WB_ERRSEQ set in fs_flags to ensure that shared infrastructure is
+aware of the model in use.
 
 struct address_space_operations
 -------------------------------
@@ -804,7 +846,8 @@ struct address_space_operations {
 The File Object
 ===============
 
-A file object represents a file opened by a process.
+A file object represents a file opened by a process. This is also known
+as an "open file description" in POSIX parlance.
 
 
 struct file_operations
@@ -887,7 +930,8 @@ otherwise noted.
 
   release: called when the last reference to an open file is closed
 
-  fsync: called by the fsync(2) system call
+  fsync: called by the fsync(2) system call. Also see the section above
+	 entitled "Handling errors during writeback".
 
   fasync: called by the fcntl(2) system call when asynchronous
 	(non-blocking) mode is enabled for a file
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
