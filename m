Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEE62803ED
	for <linux-mm@kvack.org>; Mon, 22 May 2017 12:52:24 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v27so52500554qtg.6
        for <linux-mm@kvack.org>; Mon, 22 May 2017 09:52:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r17si19155428qkh.119.2017.05.22.09.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 09:52:23 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 08/15] mm/ZONE_DEVICE: special case put_page() for device private pages
Date: Mon, 22 May 2017 12:51:59 -0400
Message-Id: <20170522165206.6284-9-jglisse@redhat.com>
In-Reply-To: <20170522165206.6284-1-jglisse@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
have any user. For device private pages this is important to catch
and thus we need to special case put_page() for this.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/mm.h | 30 ++++++++++++++++++++++++++++++
 kernel/memremap.c  |  1 -
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a825dab..11f7bac 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -23,6 +23,7 @@
 #include <linux/page_ext.h>
 #include <linux/err.h>
 #include <linux/page_ref.h>
+#include <linux/memremap.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -795,6 +796,20 @@ static inline bool is_device_private_page(const struct page *page)
 	return ((page_zonenum(page) == ZONE_DEVICE) &&
 		(page->pgmap->type == MEMORY_DEVICE_PRIVATE));
 }
+
+static inline void put_zone_device_private_page(struct page *page)
+{
+	int count = page_ref_dec_return(page);
+
+	/*
+	 * If refcount is 1 then page is freed and refcount is stable as nobody
+	 * holds a reference on the page.
+	 */
+	if (count == 1)
+		page->pgmap->page_free(page, page->pgmap->data);
+	else if (!count)
+		__put_page(page);
+}
 #else
 static inline bool is_zone_device_page(const struct page *page)
 {
@@ -805,6 +820,10 @@ static inline bool is_device_private_page(const struct page *page)
 {
 	return false;
 }
+
+static inline void put_zone_device_private_page(struct page *page)
+{
+}
 #endif
 
 static inline void get_page(struct page *page)
@@ -822,6 +841,17 @@ static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
 
+	/*
+	 * For private device pages we need to catch refcount transition from
+	 * 2 to 1, when refcount reach one it means the private device page is
+	 * free and we need to inform the device driver through callback. See
+	 * include/linux/memremap.h and HMM for details.
+	 */
+	if (unlikely(is_device_private_page(page))) {
+		put_zone_device_private_page(page);
+		return;
+	}
+
 	if (put_page_testzero(page))
 		__put_page(page);
 }
diff --git a/kernel/memremap.c b/kernel/memremap.c
index dbdb656..71f6f28 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -11,7 +11,6 @@
  * General Public License for more details.
  */
 #include <linux/radix-tree.h>
-#include <linux/memremap.h>
 #include <linux/device.h>
 #include <linux/types.h>
 #include <linux/pfn_t.h>
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
