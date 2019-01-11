Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7708E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:07:55 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t2so10529069pfj.15
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:07:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b22sor3942539pfe.48.2019.01.11.07.07.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:07:54 -0800 (PST)
Date: Fri, 11 Jan 2019 20:41:54 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range_buggy
Message-ID: <20190111151154.GA2819@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, mchehab@kernel.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Convert to use vm_insert_range_buggy to map range of kernel memory
to user vma.

This driver has ignored vm_pgoff. We could later "fix" these drivers
to behave according to the normal vm_pgoff offsetting simply by
removing the _buggy suffix on the function name and if that causes
regressions, it gives us an easy way to revert.

There is an existing bug inside gem_mmap_obj(), where user passed
length is not checked against buf->num_pages. For any value of
length > buf->num_pages it will end up overrun buf->pages[i],
which could lead to a potential bug.

This has been addressed by passing buf->num_pages as input to
vm_insert_range_buggy() and inside this API error condition is
checked which will avoid overrun the page boundary.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
index 015e737..ef046b4 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
@@ -328,28 +328,18 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
 static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
 {
 	struct vb2_dma_sg_buf *buf = buf_priv;
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
-	int i = 0;
+	int err;
 
 	if (!buf) {
 		printk(KERN_ERR "No memory to map\n");
 		return -EINVAL;
 	}
 
-	do {
-		int ret;
-
-		ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
-		if (ret) {
-			printk(KERN_ERR "Remapping memory, error: %d\n", ret);
-			return ret;
-		}
-
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
-
+	err = vm_insert_range_buggy(vma, buf->pages, buf->num_pages);
+	if (err) {
+		printk(KERN_ERR "Remapping memory, error: %d\n", err);
+		return err;
+	}
 
 	/*
 	 * Use common vm_area operations to track buffer refcount.
-- 
1.9.1
