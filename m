Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83D7F6B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:05:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a192so14723469pge.1
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:05:44 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v61si31615plb.248.2017.11.06.17.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:05:43 -0800 (PST)
Subject: [PATCH 3/3] [media] v4l2: disable filesystem-dax mapping support
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 06 Nov 2017 16:57:28 -0800
Message-ID: <151001624873.16354.2551756846133945335.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Mauro Carvalho Chehab <mchehab@kernel.org>, linux-media@vger.kernel.org

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
 drivers/media/v4l2-core/videobuf-dma-sg.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 0b5c43f7e020..f412429cf5ba 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -185,12 +185,13 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
-	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
+	err = get_user_pages_longterm(data & PAGE_MASK, dma->nr_pages,
 			     flags, dma->pages, NULL);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
-		dprintk(1, "get_user_pages: err=%d [%d]\n", err, dma->nr_pages);
+		dprintk(1, "get_user_pages_longterm: err=%d [%d]\n", err,
+			dma->nr_pages);
 		return err < 0 ? err : -EINVAL;
 	}
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
