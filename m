Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6DB6B03A7
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m57so42582340qta.9
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t207si8498423qke.312.2017.06.12.05.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:45 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 14/20] dax: set errors in mapping when writeback fails
Date: Mon, 12 Jun 2017 08:23:10 -0400
Message-Id: <20170612122316.13244-19-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Jan Kara's description for this patch is much better than mine, so I'm
quoting it verbatim here:

-----------------8<-----------------
DAX currently doesn't set errors in the mapping when cache flushing
fails in dax_writeback_mapping_range(). Since this function can get
called only from fsync(2) or sync(2), this is actually as good as it can
currently get since we correctly propagate the error up from
dax_writeback_mapping_range() to filemap_fdatawrite()

However, in the future better writeback error handling will enable us to
properly report these errors on fsync(2) even if there are multiple file
descriptors open against the file or if sync(2) gets called before
fsync(2). So convert DAX to using standard error reporting through the
mapping.
-----------------8<-----------------

For now, only do this when the FS_WB_ERRSEQ flag is set. The
AS_EIO/AS_ENOSPC flags are not currently cleared in the older code when
writeback initiation fails, only when we discover an error after waiting
on writeback to complete, so we only want to do this with errseq_t based
error handling to prevent seeing duplicate errors on fsync.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-and-Tested-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 2a6889b3585f..ba3b17eefcfc 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -856,8 +856,24 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 			ret = dax_writeback_one(bdev, dax_dev, mapping,
 					indices[i], pvec.pages[i]);
-			if (ret < 0)
+			if (ret < 0) {
+				/*
+				 * For fs' that use errseq_t based error
+				 * tracking, we must call mapping_set_error
+				 * here to ensure that fsync on all open fds
+				 * get back an error. Doing this with the old
+				 * wb error tracking infrastructure is
+				 * problematic though, as DAX writeback is
+				 * synchronous, and the error flags are not
+				 * cleared when initiation fails, only when
+				 * it fails after the write has been submitted
+				 * to the backing store.
+				 */
+				if (mapping->host->i_sb->s_type->fs_flags &
+						FS_WB_ERRSEQ)
+					mapping_set_error(mapping, ret);
 				goto out;
+			}
 		}
 	}
 out:
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
