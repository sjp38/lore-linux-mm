Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 706836B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 17:24:39 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l1so105416985oib.4
        for <linux-mm@kvack.org>; Tue, 30 May 2017 14:24:39 -0700 (PDT)
Received: from gateway31.websitewelcome.com (gateway31.websitewelcome.com. [192.185.143.234])
        by mx.google.com with ESMTPS id v40si6043762otd.212.2017.05.30.14.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 14:24:38 -0700 (PDT)
Received: from cm4.websitewelcome.com (unknown [108.167.139.16])
	by gateway31.websitewelcome.com (Postfix) with ESMTP id 0C8F373370
	for <linux-mm@kvack.org>; Tue, 30 May 2017 16:24:38 -0500 (CDT)
Date: Tue, 30 May 2017 16:24:36 -0500
From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] mm: add NULL check to avoid potential NULL pointer
 dereference
Message-ID: <20170530212436.GA6195@embeddedgus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <garsilva@embeddedor.com>

NULL check at line 1226: if (!pgdat), implies that pointer pgdat
might be NULL.
Function rollback_node_hotadd() dereference this pointer.
Add NULL check to avoid a potential NULL pointer dereference.

Addresses-Coverity-ID: 1369133
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 599c675..ea3bc3e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1273,7 +1273,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 
 error:
 	/* rollback pgdat allocation and others */
-	if (new_pgdat)
+	if (new_pgdat && pgdat)
 		rollback_node_hotadd(nid, pgdat);
 	memblock_remove(start, size);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
