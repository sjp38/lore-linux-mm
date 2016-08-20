Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 031886B0069
	for <linux-mm@kvack.org>; Sat, 20 Aug 2016 04:00:24 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j67so172657826oih.3
        for <linux-mm@kvack.org>; Sat, 20 Aug 2016 01:00:23 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0083.hostedemail.com. [216.40.44.83])
        by mx.google.com with ESMTPS id q71si11331880iod.242.2016.08.20.01.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Aug 2016 01:00:23 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] seq_file: Add __seq_open_private_bufsize for seq file_operation sizes
Date: Sat, 20 Aug 2016 01:00:16 -0700
Message-Id: <4c686b178bf96e2cc01cea05c55fbd7d6a0fb66e.1471679737.git.joe@perches.com>
In-Reply-To: <20160820072927.GA23645@dhcp22.suse.cz>
References: <20160820072927.GA23645@dhcp22.suse.cz>
In-Reply-To: <cover.1471679737.git.joe@perches.com>
References: <cover.1471679737.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Specifying an initial output buffer size can reduce the
number of regenerations of the seq_<output> buffers when
the buffer overflows.

Add another version of __seq_open_private that takes an
initial buffer size.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/seq_file.c            | 31 +++++++++++++++++++++++++++++++
 include/linux/seq_file.h |  3 +++
 2 files changed, 34 insertions(+)

diff --git a/fs/seq_file.c b/fs/seq_file.c
index b8ac757e..d98fa77 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -652,6 +652,37 @@ int seq_open_private(struct file *filp, const struct seq_operations *ops,
 }
 EXPORT_SYMBOL(seq_open_private);
 
+void *__seq_open_private_bufsize(struct file *f,
+				 const struct seq_operations *ops,
+				 int psize, size_t bufsize)
+{
+	int rc;
+	void *private;
+	struct seq_file *seq;
+
+	private = kzalloc(psize, GFP_KERNEL);
+	if (private == NULL)
+		goto out;
+
+	rc = seq_open(f, ops);
+	if (rc < 0)
+		goto out_free;
+
+	seq = f->private_data;
+	seq->private = private;
+
+	kfree(seq->buf);
+	seq->buf = seq_buf_alloc(seq->size = round_up(bufsize, PAGE_SIZE));
+
+	return private;
+
+out_free:
+	kfree(private);
+out:
+	return NULL;
+}
+EXPORT_SYMBOL(__seq_open_private_bufsize);
+
 void seq_putc(struct seq_file *m, char c)
 {
 	if (m->count >= m->size)
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index e305b66..719f1b8 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -136,6 +136,9 @@ int single_open(struct file *, int (*)(struct seq_file *, void *), void *);
 int single_open_size(struct file *, int (*)(struct seq_file *, void *), void *, size_t);
 int single_release(struct inode *, struct file *);
 void *__seq_open_private(struct file *, const struct seq_operations *, int);
+void *__seq_open_private_bufsize(struct file *f,
+				 const struct seq_operations *ops,
+				 int psize, size_t bufsize);
 int seq_open_private(struct file *, const struct seq_operations *, int);
 int seq_release_private(struct inode *, struct file *);
 
-- 
2.8.0.rc4.16.g56331f8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
