Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27F3F6B0069
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:12:17 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o3so4832374wjo.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:12:17 -0800 (PST)
Received: from mail-wj0-x22d.google.com (mail-wj0-x22d.google.com. [2a00:1450:400c:c01::22d])
        by mx.google.com with ESMTPS id 74si6283273wmh.144.2016.12.14.01.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 01:12:15 -0800 (PST)
Received: by mail-wj0-x22d.google.com with SMTP id xy5so22217966wjc.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:12:15 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 1/2] mm: don't dereference struct page fields of invalid pages
Date: Wed, 14 Dec 2016 09:11:46 +0000
Message-Id: <1481706707-6211-2-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, rrichter@cavium.com, james.morse@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The VM_BUG_ON() check in move_freepages() checks whether the node
id of a page matches the node id of its zone. However, it does this
before having checked whether the struct page pointer refers to a
valid struct page to begin with. This is guaranteed in most cases,
but may not be the case if CONFIG_HOLES_IN_ZONE=y.

So reorder the VM_BUG_ON() with the pfn_valid_within() check.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f64e7bcb43b7..4e298e31fa86 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1864,14 +1864,14 @@ int move_freepages(struct zone *zone,
 #endif
 
 	for (page = start_page; page <= end_page;) {
-		/* Make sure we are not inadvertently changing nodes */
-		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
-
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
 			continue;
 		}
 
+		/* Make sure we are not inadvertently changing nodes */
+		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
+
 		if (!PageBuddy(page)) {
 			page++;
 			continue;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
