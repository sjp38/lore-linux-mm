Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 2A5816B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:45:11 -0400 (EDT)
Date: Wed, 31 Jul 2013 15:45:09 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm/slab: ppc: ubi: kmalloc_slab WARNING / PPC + UBI driver
In-Reply-To: <alpine.DEB.2.02.1307311015320.30997@gentwo.org>
Message-ID: <000001403567762a-60a27288-f0b2-4855-b88c-6a6f21ec537c-000000@email.amazonses.com>
References: <51F8F827.6020108@gmail.com> <alpine.DEB.2.02.1307310858150.30572@gentwo.org> <alpine.DEB.2.02.1307311015320.30997@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wladislav Wiebe <wladislav.kw@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, dedekind1@gmail.com, dwmw2@infradead.org, linux-mtd@lists.infradead.org, Mel Gorman <mel@csn.ul.ie>

Crap you cannot do PAGE_SIZE allocations with kmalloc_large. Fails when
freeing pages. Need to only do the multiple page allocs with
kmalloc_large.

Subject: seq_file: Use kmalloc_large for page sized allocation

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
