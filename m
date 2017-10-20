Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10DD66B0260
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:45:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x7so8047149pfa.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:45:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w189si9498776pgd.176.2017.10.19.19.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:45:49 -0700 (PDT)
Subject: [PATCH v3 05/13] dax: stop requiring a live device for dax_flush()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Oct 2017 19:39:24 -0700
Message-ID: <150846716412.24336.5216410632309453014.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hch@lst.de

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
index 26c324a5aef4..be65430b4483 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -280,9 +280,6 @@ EXPORT_SYMBOL_GPL(dax_copy_from_iter);
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
