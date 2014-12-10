Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B93136B0071
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:43 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so1756199pad.1
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:43 -0800 (PST)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com. [209.85.220.42])
        by mx.google.com with ESMTPS id zv7si4533720pac.17.2014.12.09.17.46.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:42 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id et14so1739013pad.15
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:41 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 3/7] swap: use direct I/O for SWP_FILE swap_readpage
Date: Tue,  9 Dec 2014 17:45:44 -0800
Message-Id: <9c1d4746d1e7e41114496be8912cb74e36d5df48.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>, Mel Gorman <mgorman@suse.de>

On Mon, Nov 17, 2014 at 07:48:17AM -0800, Christoph Hellwig wrote:
> With the new iov_iter infrastructure that supprots direct I/O to kernel
> pages please get rid of the ->readpage hack first.  I'm still utterly
> disapoined that this crap ever got merged.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b..10715e0 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -283,8 +283,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 		set_page_writeback(page);
 		unlock_page(page);
-		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
-						&kiocb, &from,
+		ret = mapping->a_ops->direct_IO(WRITE, &kiocb, &from,
 						kiocb.ki_pos);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
@@ -348,12 +347,37 @@ int swap_readpage(struct page *page)
 	}
 
 	if (sis->flags & SWP_FILE) {
+		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
+		struct bio_vec bv = {
+			.bv_page = page,
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
+		};
+		struct iov_iter to = {
+			.type = ITER_BVEC | READ,
+			.count = PAGE_SIZE,
+			.iov_offset = 0,
+			.nr_segs = 1,
+		};
+		to.bvec = &bv;	/* older gcc versions are broken */
+
+		init_sync_kiocb(&kiocb, swap_file);
+		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_nbytes = PAGE_SIZE;
 
-		ret = mapping->a_ops->readpage(swap_file, page);
-		if (!ret)
+		ret = mapping->a_ops->direct_IO(READ, &kiocb, &to,
+						kiocb.ki_pos);
+		if (ret == PAGE_SIZE) {
+			SetPageUptodate(page);
 			count_vm_event(PSWPIN);
+			ret = 0;
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+		unlock_page(page);
 		return ret;
 	}
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
