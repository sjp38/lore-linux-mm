Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B046E6B0374
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:27 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t187so21665289oie.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o8si3529808oib.192.2017.06.29.06.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:20:26 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 11/18] mm: set both AS_EIO/AS_ENOSPC and errseq_t in mapping_set_error
Date: Thu, 29 Jun 2017 09:19:47 -0400
Message-Id: <20170629131954.28733-12-jlayton@kernel.org>
In-Reply-To: <20170629131954.28733-1-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

When a writeback error occurs, we want later callers to be able to pick
up that fact when they go to wait on that writeback to complete.
Traditionally, we've used AS_EIO/AS_ENOSPC flags to track that, but
that's problematic since only one "checker" will be informed when an
error occurs.

In later patches, we're going to want to convert many of these callers
to check for errors since a well-defined point in time. For now, ensure
that we can handle both sorts of checks by both setting errors in both
places when there is a writeback failure.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/pagemap.h | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 316a19f6b635..28acc94e0f81 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -28,14 +28,33 @@ enum mapping_flags {
 	AS_NO_WRITEBACK_TAGS = 5,
 };
 
+/**
+ * mapping_set_error - record a writeback error in the address_space
+ * @mapping - the mapping in which an error should be set
+ * @error - the error to set in the mapping
+ *
+ * When writeback fails in some way, we must record that error so that
+ * userspace can be informed when fsync and the like are called.  We endeavor
+ * to report errors on any file that was open at the time of the error.  Some
+ * internal callers also need to know when writeback errors have occurred.
+ *
+ * When a writeback error occurs, most filesystems will want to call
+ * mapping_set_error to record the error in the mapping so that it can be
+ * reported when the application calls fsync(2).
+ */
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
-	if (unlikely(error)) {
-		if (error == -ENOSPC)
-			set_bit(AS_ENOSPC, &mapping->flags);
-		else
-			set_bit(AS_EIO, &mapping->flags);
-	}
+	if (likely(!error))
+		return;
+
+	/* Record in wb_err for checkers using errseq_t based tracking */
+	filemap_set_wb_err(mapping, error);
+
+	/* Record it in flags for now, for legacy callers */
+	if (error == -ENOSPC)
+		set_bit(AS_ENOSPC, &mapping->flags);
+	else
+		set_bit(AS_EIO, &mapping->flags);
 }
 
 static inline void mapping_set_unevictable(struct address_space *mapping)
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
