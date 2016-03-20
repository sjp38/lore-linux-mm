Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DCA47830AE
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:50:06 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so237591045pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:50:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i62si14046921pfi.222.2016.03.20.11.41.45
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/71] scsi: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:22 +0300
Message-Id: <1458499278-1516-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, =?UTF-8?q?Kai=20M=C3=A4kisara?= <Kai.Makisara@kolumbus.fi>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Kai MA?kisara <Kai.Makisara@kolumbus.fi>
---
 drivers/scsi/sd.c | 2 +-
 drivers/scsi/st.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/sd.c b/drivers/scsi/sd.c
index 5a5457ac9cdb..1bd0753f678a 100644
--- a/drivers/scsi/sd.c
+++ b/drivers/scsi/sd.c
@@ -2891,7 +2891,7 @@ static int sd_revalidate_disk(struct gendisk *disk)
 	if (sdkp->opt_xfer_blocks &&
 	    sdkp->opt_xfer_blocks <= dev_max &&
 	    sdkp->opt_xfer_blocks <= SD_DEF_XFER_BLOCKS &&
-	    sdkp->opt_xfer_blocks * sdp->sector_size >= PAGE_CACHE_SIZE)
+	    sdkp->opt_xfer_blocks * sdp->sector_size >= PAGE_SIZE)
 		rw_max = q->limits.io_opt =
 			sdkp->opt_xfer_blocks * sdp->sector_size;
 	else
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 607b0a505844..0177a9a4849f 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4943,7 +4943,7 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
  out_unmap:
 	if (res > 0) {
 		for (j=0; j < res; j++)
-			page_cache_release(pages[j]);
+			put_page(pages[j]);
 		res = 0;
 	}
 	kfree(pages);
@@ -4965,7 +4965,7 @@ static int sgl_unmap_user_pages(struct st_buffer *STbp,
 		/* FIXME: cache flush missing for rw==READ
 		 * FIXME: call the correct reference counting function
 		 */
-		page_cache_release(page);
+		put_page(page);
 	}
 	kfree(STbp->mapped_pages);
 	STbp->mapped_pages = NULL;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
