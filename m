Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A41216B0266
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 19:07:13 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z12so17279773qti.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:07:13 -0800 (PST)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com. [52.95.49.90])
        by mx.google.com with ESMTPS id m41si4340751qtk.442.2018.01.17.16.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 16:07:12 -0800 (PST)
From: =?UTF-8?q?Jan=20H=2E=20Sch=C3=B6nherr?= <jschoenh@amazon.de>
Subject: [PATCH 1/2] mm: Fix memory size alignment in devm_memremap_pages_release()
Date: Thu, 18 Jan 2018 01:06:01 +0100
Message-Id: <20180118000602.5527-1-jschoenh@amazon.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?Jan=20H=2E=20Sch=C3=B6nherr?= <jschoenh@amazon.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The functions devm_memremap_pages() and devm_memremap_pages_release() use
different ways to calculate the section-aligned amount of memory. The
latter function may use an incorrect size if the memory region is small
but straddles a section border.

Use the same code for both.

Fixes: 5f29a77cd957 ("mm: fix mixed zone detection in devm_memremap_pages")
Signed-off-by: Jan H. SchA?nherr <jschoenh@amazon.de>
---
 kernel/memremap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 403ab9c..4712ce6 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -301,7 +301,8 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+		- align_start;
 
 	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size);
-- 
2.9.3.1.gcba166c.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
