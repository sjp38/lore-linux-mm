Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 861386B0438
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:46 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n68so1887292itn.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x63si6426459ioi.168.2016.11.18.09.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:46 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 03/18] mm/ZONE_DEVICE/free_hot_cold_page: catch ZONE_DEVICE pages
Date: Fri, 18 Nov 2016 13:18:12 -0500
Message-Id: <1479493107-982-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Catch page from ZONE_DEVICE in free_hot_cold_page(). This should never
happen as ZONE_DEVICE page must always have an elevated refcount.

This is to catch refcounting issues in a sane way for ZONE_DEVICE pages.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 mm/page_alloc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fbfead..09b2630 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2435,6 +2435,16 @@ void free_hot_cold_page(struct page *page, bool cold)
 	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
+	/*
+	 * This should never happen ! Page from ZONE_DEVICE always must have an
+	 * active refcount. Complain about it and try to restore the refcount.
+	 */
+	if (is_zone_device_page(page)) {
+		VM_BUG_ON_PAGE(is_zone_device_page(page), page);
+		page_ref_inc(page);
+		return;
+	}
+
 	if (!free_pcp_prepare(page))
 		return;
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
