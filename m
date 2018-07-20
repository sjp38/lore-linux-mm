Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9786B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 06:30:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so4503331edi.20
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:30:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x18-v6si1318099edb.460.2018.07.20.03.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 03:30:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] fs/seq_file: remove kmalloc(ops) for single_open seqfiles
Date: Fri, 20 Jul 2018 12:29:52 +0200
Message-Id: <20180720102952.30935-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>

single_open() currently allocates seq_operations with kmalloc(). This is
suboptimal, because that's four pointers, of which three are constant, and
only the 'show' op differs. We also have to be careful to use single_release()
to avoid leaking the ops structure.

Instead of this we can have a fixed single_show() function and constant ops
structure for these seq_files. We can store the pointer to the 'show' op as
a new field of struct seq_file. That's also not terribly elegant, because the
field is there also for non-single_open() seq files, but it's a single pointer
in an already existing (and already relatively large) structure instead of
an extra kmalloc of four pointers, so the tradeoff is OK.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 Documentation/filesystems/seq_file.txt |  5 +++-
 fs/seq_file.c                          | 40 ++++++++++++--------------
 include/linux/seq_file.h               |  5 ++--
 3 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/Documentation/filesystems/seq_file.txt b/Documentation/filesystems/seq_file.txt
index 9de4303201e1..ed61495abee8 100644
--- a/Documentation/filesystems/seq_file.txt
+++ b/Documentation/filesystems/seq_file.txt
@@ -335,4 +335,7 @@ When output time comes, the show() function will be called once. The data
 value given to single_open() can be found in the private field of the
 seq_file structure. When using single_open(), the programmer should use
 single_release() instead of seq_release() in the file_operations structure
-to avoid a memory leak.
+to avoid a memory leak. Note that the implementation has changed and current
+kernels will not leak anymore, but it's better to keep using single_release()
+in case the implementation details change again.
+
diff --git a/fs/seq_file.c b/fs/seq_file.c
index 4cc090b50cc5..3fd2ded04d93 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -563,22 +563,27 @@ static void single_stop(struct seq_file *p, void *v)
 {
 }
 
+static int single_show(struct seq_file *p, void *v)
+{
+	return p->single_show_op(p, v);
+}
+
+static const struct seq_operations single_seq_op = {
+	.start	= single_start,
+	.next	= single_next,
+	.stop	= single_stop,
+	.show	= single_show
+};
+
 int single_open(struct file *file, int (*show)(struct seq_file *, void *),
 		void *data)
 {
-	struct seq_operations *op = kmalloc(sizeof(*op), GFP_KERNEL_ACCOUNT);
-	int res = -ENOMEM;
-
-	if (op) {
-		op->start = single_start;
-		op->next = single_next;
-		op->stop = single_stop;
-		op->show = show;
-		res = seq_open(file, op);
-		if (!res)
-			((struct seq_file *)file->private_data)->private = data;
-		else
-			kfree(op);
+	int res;
+
+	res = seq_open(file, &single_seq_op);
+	if (!res) {
+		((struct seq_file *)file->private_data)->private = data;
+		((struct seq_file *)file->private_data)->single_show_op = show;
 	}
 	return res;
 }
@@ -602,15 +607,6 @@ int single_open_size(struct file *file, int (*show)(struct seq_file *, void *),
 }
 EXPORT_SYMBOL(single_open_size);
 
-int single_release(struct inode *inode, struct file *file)
-{
-	const struct seq_operations *op = ((struct seq_file *)file->private_data)->op;
-	int res = seq_release(inode, file);
-	kfree(op);
-	return res;
-}
-EXPORT_SYMBOL(single_release);
-
 int seq_release_private(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index a121982af0f5..c9a70c584a7d 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -24,9 +24,10 @@ struct seq_file {
 	u64 version;
 	struct mutex lock;
 	const struct seq_operations *op;
-	int poll_event;
+	int (*single_show_op)(struct seq_file *, void *);
 	const struct file *file;
 	void *private;
+	int poll_event;
 };
 
 struct seq_operations {
@@ -140,7 +141,7 @@ int seq_path_root(struct seq_file *m, const struct path *path,
 
 int single_open(struct file *, int (*)(struct seq_file *, void *), void *);
 int single_open_size(struct file *, int (*)(struct seq_file *, void *), void *, size_t);
-int single_release(struct inode *, struct file *);
+#define single_release	seq_release
 void *__seq_open_private(struct file *, const struct seq_operations *, int);
 int seq_open_private(struct file *, const struct seq_operations *, int);
 int seq_release_private(struct inode *, struct file *);
-- 
2.18.0
