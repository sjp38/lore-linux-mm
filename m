Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAB3583294
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:34:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w1so41551862qtg.6
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:34:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l72si2686775qki.98.2017.06.16.12.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:34:53 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 04/22] buffer: set errors in mapping at the time that the error occurs
Date: Fri, 16 Jun 2017 15:34:09 -0400
Message-Id: <20170616193427.13955-5-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

I noticed on xfs that I could still sometimes get back an error on fsync
on a fd that was opened after the error condition had been cleared.

The problem is that the buffer code sets the write_io_error flag and
then later checks that flag to set the error in the mapping. That flag
perisists for quite a while however. If the file is later opened with
O_TRUNC, the buffers will then be invalidated and the mapping's error
set such that a subsequent fsync will return error. I think this is
incorrect, as there was no writeback between the open and fsync.

Add a new mark_buffer_write_io_error operation that sets the flag and
the error in the mapping at the same time. Replace all calls to
set_buffer_write_io_error with mark_buffer_write_io_error, and remove
the places that check this flag in order to set the error in the
mapping.

This sets the error in the mapping earlier, at the time that it's first
detected.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c                 | 20 +++++++++++++-------
 fs/gfs2/lops.c              |  2 +-
 include/linux/buffer_head.h |  1 +
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 7b4f4bfde91e..4d5d03b42e11 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -178,7 +178,7 @@ void end_buffer_write_sync(struct buffer_head *bh, int uptodate)
 		set_buffer_uptodate(bh);
 	} else {
 		buffer_io_error(bh, ", lost sync page write");
-		set_buffer_write_io_error(bh);
+		mark_buffer_write_io_error(bh);
 		clear_buffer_uptodate(bh);
 	}
 	unlock_buffer(bh);
@@ -352,8 +352,7 @@ void end_buffer_async_write(struct buffer_head *bh, int uptodate)
 		set_buffer_uptodate(bh);
 	} else {
 		buffer_io_error(bh, ", lost async page write");
-		mapping_set_error(page->mapping, -EIO);
-		set_buffer_write_io_error(bh);
+		mark_buffer_write_io_error(bh);
 		clear_buffer_uptodate(bh);
 		SetPageError(page);
 	}
@@ -481,8 +480,6 @@ static void __remove_assoc_queue(struct buffer_head *bh)
 {
 	list_del_init(&bh->b_assoc_buffers);
 	WARN_ON(!bh->b_assoc_map);
-	if (buffer_write_io_error(bh))
-		mapping_set_error(bh->b_assoc_map, -EIO);
 	bh->b_assoc_map = NULL;
 }
 
@@ -1181,6 +1178,17 @@ void mark_buffer_dirty(struct buffer_head *bh)
 }
 EXPORT_SYMBOL(mark_buffer_dirty);
 
+void mark_buffer_write_io_error(struct buffer_head *bh)
+{
+	set_buffer_write_io_error(bh);
+	/* FIXME: do we need to set this in both places? */
+	if (bh->b_page && bh->b_page->mapping)
+		mapping_set_error(bh->b_page->mapping, -EIO);
+	if (bh->b_assoc_map)
+		mapping_set_error(bh->b_assoc_map, -EIO);
+}
+EXPORT_SYMBOL(mark_buffer_write_io_error);
+
 /*
  * Decrement a buffer_head's reference count.  If all buffers against a page
  * have zero reference count, are clean and unlocked, and if the page is clean
@@ -3266,8 +3274,6 @@ drop_buffers(struct page *page, struct buffer_head **buffers_to_free)
 
 	bh = head;
 	do {
-		if (buffer_write_io_error(bh) && page->mapping)
-			mapping_set_error(page->mapping, -EIO);
 		if (buffer_busy(bh))
 			goto failed;
 		bh = bh->b_this_page;
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 885d36e7a29f..1a9c2c08c1a1 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -182,7 +182,7 @@ static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp, struct bio_vec *bvec,
 		bh = bh->b_this_page;
 	do {
 		if (error)
-			set_buffer_write_io_error(bh);
+			mark_buffer_write_io_error(bh);
 		unlock_buffer(bh);
 		next = bh->b_this_page;
 		size -= bh->b_size;
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index bd029e52ef5e..e0abeba3ced7 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -149,6 +149,7 @@ void buffer_check_dirty_writeback(struct page *page,
  */
 
 void mark_buffer_dirty(struct buffer_head *bh);
+void mark_buffer_write_io_error(struct buffer_head *bh);
 void init_buffer(struct buffer_head *, bh_end_io_t *, void *);
 void touch_buffer(struct buffer_head *bh);
 void set_bh_page(struct buffer_head *bh,
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
