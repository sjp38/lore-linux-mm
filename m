Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A92576B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 11:59:23 -0400 (EDT)
Message-ID: <0000014078672ca0-b0ac80d0-e47f-4e87-aee0-d879eed081ff-000000@email.amazonses.com>
Date: Tue, 13 Aug 2013 15:59:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 3/3] seq_file: Use kmalloc_large for page sized allocation
References: <20130813154940.741769876@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

There is no point in using the slab allocation functions for
large page order allocation. Use kmalloc_large().

This fixes the warning about large allocs but it will still cause
large contiguous allocs that could fail because of memory fragmentation.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/fs/seq_file.c
===================================================================
--- linux.orig/fs/seq_file.c	2013-07-31 10:39:03.050472030 -0500
+++ linux/fs/seq_file.c	2013-07-31 10:39:03.050472030 -0500
@@ -136,7 +136,7 @@ static int traverse(struct seq_file *m,
 Eoverflow:
 	m->op->stop(m, p);
 	kfree(m->buf);
-	m->buf = kmalloc(m->size <<= 1, GFP_KERNEL);
+	m->buf = kmalloc_large(m->size <<= 1, GFP_KERNEL);
 	return !m->buf ? -ENOMEM : -EAGAIN;
 }
 
@@ -232,7 +232,7 @@ ssize_t seq_read(struct file *file, char
 			goto Fill;
 		m->op->stop(m, p);
 		kfree(m->buf);
-		m->buf = kmalloc(m->size <<= 1, GFP_KERNEL);
+		m->buf = kmalloc_large(m->size <<= 1, GFP_KERNEL);
 		if (!m->buf)
 			goto Enomem;
 		m->count = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
