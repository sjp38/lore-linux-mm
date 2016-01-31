Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 64E42828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:19:59 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x125so68092236pfb.0
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:19:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sb2si16574417pac.161.2016.01.31.04.19.58
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:19:58 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 1/6] dax: Use vmf->gfp_mask
Date: Sun, 31 Jan 2016 23:19:50 +1100
Message-Id: <1454242795-18038-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

We were assuming that it was OK to do a GFP_KERNEL allocation in page
fault context.  That appears to be largely true, but filesystems are
permitted to override that in their setting of mapping->gfp_flags, which
the VM then massages into vmf->gfp_flags.  No practical difference for
now, but there may come a day when we would have surprised a filesystem.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 2f9bb89..11be8c7 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -292,7 +292,7 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	struct inode *inode = mapping->host;
 	if (!page)
 		page = find_or_create_page(mapping, vmf->pgoff,
-						GFP_KERNEL | __GFP_ZERO);
+						vmf->gfp_mask | __GFP_ZERO);
 	if (!page)
 		return VM_FAULT_OOM;
 	/* Recheck i_size under page lock to avoid truncate race */
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
