Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 24 Dec 2018 18:56:58 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range
Message-ID: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, mchehab@kernel.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range to map range of kernel memory
to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
---
 drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
index 015e737..898adef 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
@@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
 static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
 {
 	struct vb2_dma_sg_buf *buf = buf_priv;
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
-	int i = 0;
+	unsigned long page_count = vma_pages(vma);
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
+	err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
+	if (err) {
+		printk(KERN_ERR "Remapping memory, error: %d\n", err);
+		return err;
+	}
 
 	/*
 	 * Use common vm_area operations to track buffer refcount.
-- 
1.9.1
