Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF0B6B02FA
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:12:55 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 39so42415953qts.5
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:12:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d201si18838996qka.36.2017.04.24.11.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:12:54 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 02/15] mm/put_page: move ZONE_DEVICE page reference decrement v2
Date: Mon, 24 Apr 2017 14:12:30 -0400
Message-Id: <20170424181243.20320-3-jglisse@redhat.com>
In-Reply-To: <20170424181243.20320-1-jglisse@redhat.com>
References: <20170424181243.20320-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/mm.h | 14 +++++++++++---
 kernel/memremap.c  |  6 ++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c82e8db..022423c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -821,11 +821,19 @@ static inline void put_page(struct page *page)
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
index ea714ee..97ef676 100644
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
