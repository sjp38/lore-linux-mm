Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67C5D6B0261
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:45:26 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 67so2853201ioh.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:45:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 203si2456024iti.60.2017.01.06.07.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 07:45:25 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v15 01/16] mm/free_hot_cold_page: catch ZONE_DEVICE pages
Date: Fri,  6 Jan 2017 11:46:28 -0500
Message-Id: <1483721203-1678-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Catch page from ZONE_DEVICE in free_hot_cold_page(). This should never
happen as ZONE_DEVICE page must always have an elevated refcount.

This is safety-net to catch any refcounting issues in a sane way for any
ZONE_DEVICE pages.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 mm/page_alloc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1c24112..355beb4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2445,6 +2445,16 @@ void free_hot_cold_page(struct page *page, bool cold)
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
