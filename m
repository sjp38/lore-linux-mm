Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE10A4403D7
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:29:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 76so500775pfr.3
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:29:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v5si2818806pfl.215.2017.10.31.16.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:29:00 -0700 (PDT)
Subject: [PATCH 11/15] [media] v4l2: disable filesystem-dax mapping support
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:35 -0700
Message-ID: <150949215507.24061.16244906635037694605.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, Mauro Carvalho Chehab <mchehab@kernel.org>, hch@lst.de, linux-media@vger.kernel.org

V4L2 memory registrations are incompatible with filesystem-dax that
needs the ability to revoke dma access to a mapping at will, or
otherwise allow the kernel to wait for completion of DMA. The
filesystem-dax implementation breaks the traditional solution of
truncate of active file backed mappings since there is no page-cache
page we can orphan to sustain ongoing DMA.

If v4l2 wants to support long lived DMA mappings it needs to arrange to
hold a file lease or use some other mechanism so that the kernel can
coordinate revoking DMA access when the filesystem needs to truncate
mappings.

Reported-by: Jan Kara <jack@suse.cz>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: linux-media@vger.kernel.org
Cc: <stable@vger.kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/media/v4l2-core/videobuf-dma-sg.c |   39 ++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 0b5c43f7e020..37a4ae61b2c0 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -155,8 +155,9 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 			int direction, unsigned long data, unsigned long size)
 {
 	unsigned long first, last;
-	int err, rw = 0;
+	int err, rw = 0, i, nr_pages;
 	unsigned int flags = FOLL_FORCE;
+	struct vm_area_struct **vmas = NULL;
 
 	dma->direction = direction;
 	switch (dma->direction) {
@@ -179,6 +180,16 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 	if (NULL == dma->pages)
 		return -ENOMEM;
 
+	if (IS_ENABLED(CONFIG_FS_DAX)) {
+		vmas = kmalloc(dma->nr_pages * sizeof(struct vm_area_struct *),
+				GFP_KERNEL);
+		if (NULL == vmas) {
+			kfree(dma->pages);
+			dma->pages = NULL;
+			return -ENOMEM;
+		}
+	}
+
 	if (rw == READ)
 		flags |= FOLL_WRITE;
 
@@ -186,7 +197,31 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 		data, size, dma->nr_pages);
 
 	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
-			     flags, dma->pages, NULL);
+			     flags, dma->pages, vmas);
+	nr_pages = err;
+
+	for (i = 0; vmas && i < nr_pages; i++) {
+		struct vm_area_struct *vma = vmas[i];
+		struct inode *inode;
+
+		if (!vma_is_dax(vma))
+			continue;
+
+		/* device-dax is safe for long-lived v4l2 mappings... */
+		inode = file_inode(vma->vm_file);
+		if (inode->i_mode == S_IFCHR)
+			continue;
+
+		/* ...filesystem-dax is not. */
+		err = -EOPNOTSUPP;
+		break;
+
+		/*
+		 * FIXME: add a 'with lease' mechanism for v4l2 to
+		 * obtain time bounded access to filesytem-dax mappings
+		 */
+	}
+	kfree(vmas);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
