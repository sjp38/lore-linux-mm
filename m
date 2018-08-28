Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88E9D6B45B8
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 06:39:21 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id y74-v6so225197lfd.4
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:39:21 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id e15-v6si342976lfg.95.2018.08.28.03.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 03:39:19 -0700 (PDT)
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: [PATCH 1/2] kmemleak: dump all objects for slab usage analysis
Date: Tue, 28 Aug 2018 12:39:13 +0200
Message-Id: <20180828103914.30434-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

In order to be able to analyse the kernel's slab usage, we'd need a list
of allocated objects and their allocation stacks.  Kmemleak already
maintains such a list internally, so we expose it via debugfs file.

This file can be post-processed in userspace and converted to a suitable
format for slab usage analysis.

Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
---
 mm/kmemleak.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 17dd883198ae..7bef05c690d6 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1759,6 +1759,34 @@ static int kmemleak_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static void kmemleak_print_object(struct seq_file *seq,
+				  struct kmemleak_object *object)
+{
+	int i;
+
+	seq_printf(seq, "object 0x%08lx (size %zu):\n",
+		   object->pointer, object->size);
+	seq_printf(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
+		   object->comm, object->pid, object->jiffies);
+
+	for (i = 0; i < object->trace_len; i++) {
+		void *ptr = (void *)object->trace[i];
+
+		seq_printf(seq, "    [<%p>] %pS\n", ptr, ptr);
+	}
+}
+
+static int kmemleak_all_seq_show(struct seq_file *seq, void *v)
+{
+	struct kmemleak_object *object = v;
+	unsigned long flags;
+
+	spin_lock_irqsave(&object->lock, flags);
+	kmemleak_print_object(seq, object);
+	spin_unlock_irqrestore(&object->lock, flags);
+	return 0;
+}
+
 static const struct seq_operations kmemleak_seq_ops = {
 	.start = kmemleak_seq_start,
 	.next  = kmemleak_seq_next,
@@ -1766,11 +1794,23 @@ static const struct seq_operations kmemleak_seq_ops = {
 	.show  = kmemleak_seq_show,
 };
 
+static const struct seq_operations kmemleak_all_seq_ops = {
+	.start = kmemleak_seq_start,
+	.next  = kmemleak_seq_next,
+	.stop  = kmemleak_seq_stop,
+	.show  = kmemleak_all_seq_show,
+};
+
 static int kmemleak_open(struct inode *inode, struct file *file)
 {
 	return seq_open(file, &kmemleak_seq_ops);
 }
 
+static int kmemleak_all_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &kmemleak_all_seq_ops);
+}
+
 static int dump_str_object_info(const char *str)
 {
 	unsigned long flags;
@@ -1911,6 +1951,14 @@ static const struct file_operations kmemleak_fops = {
 	.release	= seq_release,
 };
 
+static const struct file_operations kmemleak_all_fops = {
+	.owner		= THIS_MODULE,
+	.open		= kmemleak_all_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static void __kmemleak_do_cleanup(void)
 {
 	struct kmemleak_object *object;
@@ -2102,6 +2150,11 @@ static int __init kmemleak_late_init(void)
 	if (!dentry)
 		pr_warn("Failed to create the debugfs kmemleak file\n");
 
+	dentry = debugfs_create_file("kmemleak_all", 0400, NULL, NULL,
+				     &kmemleak_all_fops);
+	if (!dentry)
+		pr_warn("Failed to create the debugfs kmemleak_all file\n");
+
 	if (kmemleak_error) {
 		/*
 		 * Some error occurred and kmemleak was disabled. There is a
-- 
2.11.0
