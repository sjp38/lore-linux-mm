Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B015D6B03AE
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:40:42 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a130so6330779qkb.21
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:40:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a49si18779514qtb.17.2017.04.05.13.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:40:41 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 02/16] mm/put_page: move ZONE_DEVICE page reference decrement v2
Date: Wed,  5 Apr 2017 16:40:12 -0400
Message-Id: <20170405204026.3940-3-jglisse@redhat.com>
In-Reply-To: <20170405204026.3940-1-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Move page reference decrement of ZONE_DEVICE from put_page()
to put_zone_device_page() this does not affect non ZONE_DEVICE
page.

Doing this allow to catch when a ZONE_DEVICE page refcount reach
1 which means the device is no longer reference by any one (unlike
page from other zone, ZONE_DEVICE page refcount never reach 0).

This patch is just a preparatory patch for HMM.

Changes since v1:
  - commit message

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/mm.h | 14 +++++++++++---
 kernel/memremap.c  |  6 ++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0860a2b..92db0fb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -813,11 +813,19 @@ static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
 
+	/*
+	 * ZONE_DEVICE pages should never have their refcount reach 0 (this
+	 * would be a bug), so call page_ref_dec() in put_zone_device_page()
+	 * to decrement page refcount and skip __put_page() here, as this
+	 * would worsen things if a ZONE_DEVICE had a refcount bug.
+	 */
+	if (unlikely(is_zone_device_page(page))) {
+		put_zone_device_page(page);
+		return;
+	}
+
 	if (put_page_testzero(page))
 		__put_page(page);
-
-	if (unlikely(is_zone_device_page(page)))
-		put_zone_device_page(page);
 }
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6b4505d..0228a01 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -190,6 +190,12 @@ EXPORT_SYMBOL(get_zone_device_page);
 
 void put_zone_device_page(struct page *page)
 {
+	/*
+	 * ZONE_DEVICE page refcount should never reach 0 and never be freed
+	 * to kernel memory allocator.
+	 */
+	page_ref_dec(page);
+
 	put_dev_pagemap(page->pgmap);
 }
 EXPORT_SYMBOL(put_zone_device_page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
