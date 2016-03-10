Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3916828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:56:01 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id u190so50955152pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:56:01 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ua2si9297558pac.51.2016.03.10.15.55.40
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:40 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 12/14] dax: Use vmf->gfp_mask
Date: Thu, 10 Mar 2016 18:55:29 -0500
Message-Id: <1457654131-4562-13-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, willy@linux.intel.com

We were assuming that it was OK to do a GFP_KERNEL allocation in page
fault context.  That appears to be largely true, but filesystems are
permitted to override that in their setting of mapping->gfp_flags, which
the VM then massages into vmf->gfp_flags.  No practical difference for
now, but there may come a day when we would have surprised a filesystem.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 35f0709..50636e1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -316,7 +316,7 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	struct inode *inode = mapping->host;
 	if (!page)
 		page = find_or_create_page(mapping, vmf->pgoff,
-						GFP_KERNEL | __GFP_ZERO);
+						vmf->gfp_mask | __GFP_ZERO);
 	if (!page)
 		return VM_FAULT_OOM;
 	/* Recheck i_size under page lock to avoid truncate race */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
