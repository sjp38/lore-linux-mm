Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C534C828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:41:58 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id u190so238218232pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:41:58 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id yk10si11846756pac.24.2016.03.20.11.41.43
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 11/71] mmc: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:18 +0300
Message-Id: <1458499278-1516-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>

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
Cc: Ulf Hansson <ulf.hansson@linaro.org>
---
 drivers/mmc/core/host.c         | 6 +++---
 drivers/mmc/host/sh_mmcif.c     | 2 +-
 drivers/mmc/host/tmio_mmc_dma.c | 4 ++--
 drivers/mmc/host/tmio_mmc_pio.c | 2 +-
 drivers/mmc/host/usdhi6rol0.c   | 2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/mmc/core/host.c b/drivers/mmc/core/host.c
index 0aecd5c00b86..8f86feff3e3a 100644
--- a/drivers/mmc/core/host.c
+++ b/drivers/mmc/core/host.c
@@ -355,11 +355,11 @@ struct mmc_host *mmc_alloc_host(int extra, struct device *dev)
 	 * They have to set these according to their abilities.
 	 */
 	host->max_segs = 1;
-	host->max_seg_size = PAGE_CACHE_SIZE;
+	host->max_seg_size = PAGE_SIZE;
 
-	host->max_req_size = PAGE_CACHE_SIZE;
+	host->max_req_size = PAGE_SIZE;
 	host->max_blk_size = 512;
-	host->max_blk_count = PAGE_CACHE_SIZE / 512;
+	host->max_blk_count = PAGE_SIZE / 512;
 
 	return host;
 }
diff --git a/drivers/mmc/host/sh_mmcif.c b/drivers/mmc/host/sh_mmcif.c
index 6234eab38ff3..a8f001d44683 100644
--- a/drivers/mmc/host/sh_mmcif.c
+++ b/drivers/mmc/host/sh_mmcif.c
@@ -1513,7 +1513,7 @@ static int sh_mmcif_probe(struct platform_device *pdev)
 		mmc->caps |= pd->caps;
 	mmc->max_segs = 32;
 	mmc->max_blk_size = 512;
-	mmc->max_req_size = PAGE_CACHE_SIZE * mmc->max_segs;
+	mmc->max_req_size = PAGE_SIZE * mmc->max_segs;
 	mmc->max_blk_count = mmc->max_req_size / mmc->max_blk_size;
 	mmc->max_seg_size = mmc->max_req_size;
 
diff --git a/drivers/mmc/host/tmio_mmc_dma.c b/drivers/mmc/host/tmio_mmc_dma.c
index 4a0d6b80eaa3..c3122c9e468f 100644
--- a/drivers/mmc/host/tmio_mmc_dma.c
+++ b/drivers/mmc/host/tmio_mmc_dma.c
@@ -63,7 +63,7 @@ static void tmio_mmc_start_dma_rx(struct tmio_mmc_host *host)
 		}
 	}
 
-	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_CACHE_SIZE ||
+	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_SIZE ||
 			  (align & PAGE_MASK))) || !multiple) {
 		ret = -EINVAL;
 		goto pio;
@@ -139,7 +139,7 @@ static void tmio_mmc_start_dma_tx(struct tmio_mmc_host *host)
 		}
 	}
 
-	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_CACHE_SIZE ||
+	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_SIZE ||
 			  (align & PAGE_MASK))) || !multiple) {
 		ret = -EINVAL;
 		goto pio;
diff --git a/drivers/mmc/host/tmio_mmc_pio.c b/drivers/mmc/host/tmio_mmc_pio.c
index a10fde40b6c3..233627e20299 100644
--- a/drivers/mmc/host/tmio_mmc_pio.c
+++ b/drivers/mmc/host/tmio_mmc_pio.c
@@ -1122,7 +1122,7 @@ int tmio_mmc_host_probe(struct tmio_mmc_host *_host,
 	mmc->caps2 |= pdata->capabilities2;
 	mmc->max_segs = 32;
 	mmc->max_blk_size = 512;
-	mmc->max_blk_count = (PAGE_CACHE_SIZE / mmc->max_blk_size) *
+	mmc->max_blk_count = (PAGE_SIZE / mmc->max_blk_size) *
 		mmc->max_segs;
 	mmc->max_req_size = mmc->max_blk_size * mmc->max_blk_count;
 	mmc->max_seg_size = mmc->max_req_size;
diff --git a/drivers/mmc/host/usdhi6rol0.c b/drivers/mmc/host/usdhi6rol0.c
index b47122d3e8d8..8eeca2b0f34a 100644
--- a/drivers/mmc/host/usdhi6rol0.c
+++ b/drivers/mmc/host/usdhi6rol0.c
@@ -1789,7 +1789,7 @@ static int usdhi6_probe(struct platform_device *pdev)
 	/* Set .max_segs to some random number. Feel free to adjust. */
 	mmc->max_segs = 32;
 	mmc->max_blk_size = 512;
-	mmc->max_req_size = PAGE_CACHE_SIZE * mmc->max_segs;
+	mmc->max_req_size = PAGE_SIZE * mmc->max_segs;
 	mmc->max_blk_count = mmc->max_req_size / mmc->max_blk_size;
 	/*
 	 * Setting .max_seg_size to 1 page would simplify our page-mapping code,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
