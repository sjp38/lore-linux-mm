Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 393CF6B0070
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 00:27:32 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so11014648pdi.3
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:32 -0800 (PST)
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com. [209.85.192.170])
        by mx.google.com with ESMTPS id s6si12312639pdr.132.2014.12.14.21.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 21:27:30 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id v10so10986138pde.1
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:29 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 3/8] swap: don't add ITER_BVEC flag to direct_IO rw
Date: Sun, 14 Dec 2014 21:26:57 -0800
Message-Id: <5f9e8a7dcdf08bd2dd433f1a42690ab8e67e7915.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

The rw argument to direct_IO has some ill-defined semantics. Some
filesystems (e.g., ext4, FAT) decide whether they're doing a write with
rw == WRITE, but others (e.g., XFS) check rw & WRITE. Let's set a good
example in the swap file code and say ITER_BVEC belongs in
iov_iter->flags but not in rw. This caters to the least common
denominator and avoids a sweeping change of every direct_IO
implementation for now.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 1630ac0..c229f88 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -285,8 +285,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		set_page_writeback(page);
 		unlock_page(page);
 		mutex_lock(&inode->i_mutex);
-		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
-						&kiocb, &from,
+		ret = mapping->a_ops->direct_IO(WRITE, &kiocb, &from,
 						kiocb.ki_pos);
 		mutex_unlock(&inode->i_mutex);
 		if (ret == PAGE_SIZE) {
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
