Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 357DB6B0397
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f191so41432610qka.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13si1675764qth.45.2017.03.16.08.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:03:51 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 02/16] mm/put_page: move ref decrement to put_zone_device_page()
Date: Thu, 16 Mar 2017 12:05:21 -0400
Message-Id: <1489680335-6594-3-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This does not affect non ZONE_DEVICE page. In order to allow
ZONE_DEVICE page to be tracked we need to detect when refcount
of a ZONE_DEVICE page reach 1 (not 0 as non ZONE_DEVICE page).

This patch just move put_page_testzero() from put_page() to
put_zone_device_page() and only for ZONE_DEVICE. It does not
add any overhead compare to existing code.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/mm.h | 8 +++++---
 kernel/memremap.c  | 2 ++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5f01c88..28e8b28 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -793,11 +793,13 @@ static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
 
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
index 40d4af8..c821946 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -190,6 +190,8 @@ EXPORT_SYMBOL(get_zone_device_page);
 
 void put_zone_device_page(struct page *page)
 {
+	page_ref_dec(page);
+
 	put_dev_pagemap(page->pgmap);
 }
 EXPORT_SYMBOL(put_zone_device_page);
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
