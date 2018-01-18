Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A24716B0261
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 19:07:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s22so3975704pfh.21
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:07:12 -0800 (PST)
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id x124si4728898pgb.437.2018.01.17.16.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 16:07:11 -0800 (PST)
From: =?UTF-8?q?Jan=20H=2E=20Sch=C3=B6nherr?= <jschoenh@amazon.de>
Subject: [PATCH 2/2] mm: Fix devm_memremap_pages() collision handling
Date: Thu, 18 Jan 2018 01:06:02 +0100
Message-Id: <20180118000602.5527-2-jschoenh@amazon.de>
In-Reply-To: <20180118000602.5527-1-jschoenh@amazon.de>
References: <20180118000602.5527-1-jschoenh@amazon.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?Jan=20H=2E=20Sch=C3=B6nherr?= <jschoenh@amazon.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If devm_memremap_pages() detects a collision while adding entries
to the radix-tree, we call pgmap_radix_release(). Unfortunately,
the function removes *all* entries for the range -- including the
entries that caused the collision in the first place.

Modify pgmap_radix_release() to take an additional argument to
indicate where to stop, so that only newly added entries are removed
from the tree.

Fixes: 9476df7d80df ("mm: introduce find_dev_pagemap()")
Signed-off-by: Jan H. SchA?nherr <jschoenh@amazon.de>
---
 kernel/memremap.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 4712ce6..2b136d4 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -248,13 +248,16 @@ int device_private_entry_fault(struct vm_area_struct *vma,
 EXPORT_SYMBOL(device_private_entry_fault);
 #endif /* CONFIG_DEVICE_PRIVATE */
 
-static void pgmap_radix_release(struct resource *res)
+static void pgmap_radix_release(struct resource *res, unsigned long end_pgoff)
 {
 	unsigned long pgoff, order;
 
 	mutex_lock(&pgmap_lock);
-	foreach_order_pgoff(res, order, pgoff)
+	foreach_order_pgoff(res, order, pgoff) {
+		if (pgoff >= end_pgoff)
+			break;
 		radix_tree_delete(&pgmap_radix, PHYS_PFN(res->start) + pgoff);
+	}
 	mutex_unlock(&pgmap_lock);
 
 	synchronize_rcu();
@@ -309,7 +312,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
-	pgmap_radix_release(res);
+	pgmap_radix_release(res, -1);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
 			"%s: failed to free all reserved pages\n", __func__);
 }
@@ -459,7 +462,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
  err_pfn_remap:
  err_radix:
-	pgmap_radix_release(res);
+	pgmap_radix_release(res, pgoff);
 	devres_free(page_map);
 	return ERR_PTR(error);
 }
-- 
2.9.3.1.gcba166c.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
