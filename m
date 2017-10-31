Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4B44280244
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:28:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p2so484095pfk.13
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:28:38 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f86si2856113pfe.565.2017.10.31.16.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:28:37 -0700 (PDT)
Subject: [PATCH 07/15] dax: stop requiring a live device for dax_flush()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:13 -0700
Message-ID: <150949213329.24061.13836721890938350458.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

Now that dax_flush() is no longer a driver callback (commit c3ca015fab6d
"dax: remove the pmem_dax_ops->flush abstraction"), stop requiring the
dax_read_lock() to be held and the device to be alive.  This is in
preparation for switching filesystem-dax to store pfns instead of
sectors in the radix.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 66bcdf42c413..abfd4e92d669 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -283,9 +283,6 @@ EXPORT_SYMBOL_GPL(dax_copy_from_iter);
 void arch_wb_cache_pmem(void *addr, size_t size);
 void dax_flush(struct dax_device *dax_dev, void *addr, size_t size)
 {
-	if (unlikely(!dax_alive(dax_dev)))
-		return;
-
 	if (unlikely(!test_bit(DAXDEV_WRITE_CACHE, &dax_dev->flags)))
 		return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
