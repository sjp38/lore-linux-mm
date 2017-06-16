Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 906CE44043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:35:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n40so42474742qtb.4
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:35:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t190si2691316qkf.49.2017.06.16.12.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:35:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 12/22] mm: tracepoints for writeback error events
Date: Fri, 16 Jun 2017 15:34:17 -0400
Message-Id: <20170616193427.13955-13-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

To enable that, make __errseq_set return the value that it was set to
when we exit the loop. Take heed that that value is not suitable as a
later "since" value, as it will not have been marked seen.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/errseq.h         |  2 +-
 include/linux/fs.h             |  5 +++-
 include/trace/events/filemap.h | 55 ++++++++++++++++++++++++++++++++++++++++++
 lib/errseq.c                   | 20 ++++++++++-----
 mm/filemap.c                   | 13 +++++++++-
 5 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/include/linux/errseq.h b/include/linux/errseq.h
index 0d2555f310cd..9e0d444ac88d 100644
--- a/include/linux/errseq.h
+++ b/include/linux/errseq.h
@@ -5,7 +5,7 @@
 
 typedef u32	errseq_t;
 
-void __errseq_set(errseq_t *eseq, int err);
+errseq_t __errseq_set(errseq_t *eseq, int err);
 static inline void errseq_set(errseq_t *eseq, int err)
 {
 	/* Optimize for the common case of no error */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 09d511771b25..8980e5ce2063 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2525,6 +2525,7 @@ extern int filemap_fdatawrite_range(struct address_space *mapping,
 extern int filemap_check_errors(struct address_space *mapping);
 
 extern int __must_check filemap_report_wb_err(struct file *file);
+extern void __filemap_set_wb_err(struct address_space *mapping, int err);
 
 /**
  * filemap_set_wb_err - set a writeback error on an address_space
@@ -2544,7 +2545,9 @@ extern int __must_check filemap_report_wb_err(struct file *file);
  */
 static inline void filemap_set_wb_err(struct address_space *mapping, int err)
 {
-	errseq_set(&mapping->wb_err, err);
+	/* Fastpath for common case of no error */
+	if (unlikely(err))
+		__filemap_set_wb_err(mapping, err);
 }
 
 /**
diff --git a/include/trace/events/filemap.h b/include/trace/events/filemap.h
index 42febb6bc1d5..2af66920f267 100644
--- a/include/trace/events/filemap.h
+++ b/include/trace/events/filemap.h
@@ -10,6 +10,7 @@
 #include <linux/memcontrol.h>
 #include <linux/device.h>
 #include <linux/kdev_t.h>
+#include <linux/errseq.h>
 
 DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
 
@@ -52,6 +53,60 @@ DEFINE_EVENT(mm_filemap_op_page_cache, mm_filemap_add_to_page_cache,
 	TP_ARGS(page)
 	);
 
+TRACE_EVENT(filemap_set_wb_err,
+		TP_PROTO(struct address_space *mapping, errseq_t eseq),
+
+		TP_ARGS(mapping, eseq),
+
+		TP_STRUCT__entry(
+			__field(unsigned long, i_ino)
+			__field(dev_t, s_dev)
+			__field(errseq_t, errseq)
+		),
+
+		TP_fast_assign(
+			__entry->i_ino = mapping->host->i_ino;
+			__entry->errseq = eseq;
+			if (mapping->host->i_sb)
+				__entry->s_dev = mapping->host->i_sb->s_dev;
+			else
+				__entry->s_dev = mapping->host->i_rdev;
+		),
+
+		TP_printk("dev=%d:%d ino=0x%lx errseq=0x%x",
+			MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
+			__entry->i_ino, __entry->errseq)
+);
+
+TRACE_EVENT(filemap_report_wb_err,
+		TP_PROTO(struct file *file, errseq_t old),
+
+		TP_ARGS(file, old),
+
+		TP_STRUCT__entry(
+			__field(struct file *, file);
+			__field(unsigned long, i_ino)
+			__field(dev_t, s_dev)
+			__field(errseq_t, old)
+			__field(errseq_t, new)
+		),
+
+		TP_fast_assign(
+			__entry->file = file;
+			__entry->i_ino = file->f_mapping->host->i_ino;
+			if (file->f_mapping->host->i_sb)
+				__entry->s_dev = file->f_mapping->host->i_sb->s_dev;
+			else
+				__entry->s_dev = file->f_mapping->host->i_rdev;
+			__entry->old = old;
+			__entry->new = file->f_wb_err;
+		),
+
+		TP_printk("file=%p dev=%d:%d ino=0x%lx old=0x%x new=0x%x",
+			__entry->file, MAJOR(__entry->s_dev),
+			MINOR(__entry->s_dev), __entry->i_ino, __entry->old,
+			__entry->new)
+);
 #endif /* _TRACE_FILEMAP_H */
 
 /* This part must be outside protection */
diff --git a/lib/errseq.c b/lib/errseq.c
index d129c0611c1f..009972d3000c 100644
--- a/lib/errseq.c
+++ b/lib/errseq.c
@@ -52,10 +52,14 @@
  *
  * Most callers will want to use the errseq_set inline wrapper to efficiently
  * handle the common case where err is 0.
+ *
+ * We do return an errseq_t here, primarily for debugging purposes. The return
+ * value should not be used as a previously sampled value in later calls as it
+ * will not have the SEEN flag set.
  */
-void __errseq_set(errseq_t *eseq, int err)
+errseq_t __errseq_set(errseq_t *eseq, int err)
 {
-	errseq_t old;
+	errseq_t cur, old;
 
 	/* MAX_ERRNO must be able to serve as a mask */
 	BUILD_BUG_ON_NOT_POWER_OF_2(MAX_ERRNO + 1);
@@ -66,13 +70,14 @@ void __errseq_set(errseq_t *eseq, int err)
 	 * also don't accept zero here as that would effectively clear a
 	 * previous error.
 	 */
+	old = READ_ONCE(*eseq);
+
 	if (WARN(unlikely(err == 0 || (unsigned int)-err > MAX_ERRNO),
 				"err = %d\n", err))
-		return;
+		return old;
 
-	old = READ_ONCE(*eseq);
 	for (;;) {
-		errseq_t new, cur;
+		errseq_t new;
 
 		/* Clear out error bits and set new error */
 		new = (old & ~(MAX_ERRNO|ERRSEQ_SEEN)) | -err;
@@ -82,8 +87,10 @@ void __errseq_set(errseq_t *eseq, int err)
 			new += ERRSEQ_CTR_INC;
 
 		/* If there would be no change, then call it done */
-		if (new == old)
+		if (new == old) {
+			cur = new;
 			break;
+		}
 
 		/* Try to swap the new value into place */
 		cur = cmpxchg(eseq, old, new);
@@ -98,6 +105,7 @@ void __errseq_set(errseq_t *eseq, int err)
 		/* Raced with an update, try again */
 		old = cur;
 	}
+	return cur;
 }
 EXPORT_SYMBOL(__errseq_set);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 2803b30cbb5d..879623032016 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -555,6 +555,14 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
+void __filemap_set_wb_err(struct address_space *mapping, int err)
+{
+	errseq_t eseq = __errseq_set(&mapping->wb_err, err);
+	trace_filemap_set_wb_err(mapping, eseq);
+
+}
+EXPORT_SYMBOL(__filemap_set_wb_err);
+
 /**
  * filemap_report_wb_err - report wb error (if any) that was previously set
  * @file: struct file on which the error is being reported
@@ -579,14 +587,17 @@ EXPORT_SYMBOL(filemap_write_and_wait_range);
 int filemap_report_wb_err(struct file *file)
 {
 	int err = 0;
+	errseq_t old = READ_ONCE(file->f_wb_err);
 	struct address_space *mapping = file->f_mapping;
 
 	/* Locklessly handle the common case where nothing has changed */
-	if (errseq_check(&mapping->wb_err, READ_ONCE(file->f_wb_err))) {
+	if (errseq_check(&mapping->wb_err, old)) {
 		/* Something changed, must use slow path */
 		spin_lock(&file->f_lock);
+		old = file->f_wb_err;
 		err = errseq_check_and_advance(&mapping->wb_err,
 						&file->f_wb_err);
+		trace_filemap_report_wb_err(file, old);
 		spin_unlock(&file->f_lock);
 	}
 	return err;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
