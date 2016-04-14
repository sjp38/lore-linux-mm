Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF19F6B0005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 22:50:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t124so105644130pfb.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 19:50:42 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id c64si11503757pfa.69.2016.04.13.19.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 19:50:41 -0700 (PDT)
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 14 Apr 2016 12:50:38 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1650F3578060
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:50:36 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3E2oNhP57344140
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:50:35 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3E2nwFS009831
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:49:58 +1000
From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH] mm: Disable DEFERRED_STRUCT_PAGE_INIT on !NO_BOOTMEM
Date: Thu, 14 Apr 2016 12:49:30 +1000
Message-Id: <1460602170-5821-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, zhlcindy@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, Gavin Shan <gwshan@linux.vnet.ibm.com>

When we have !NO_BOOTMEM, the deferred page struct initialization
doesn't work well because the pages reserved in bootmem are released
to the page allocator uncoditionally. It causes memory corruption
and system crash eventually.

As Mel suggested, the bootmem is retiring slowly. We fix the issue
by simply hiding DEFERRED_STRUCT_PAGE_INIT when bootmem is enabled.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 989f8f3..646cf9f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -626,7 +626,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 	bool "Defer initialisation of struct pages to kthreads"
 	default n
 	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
-	depends on MEMORY_HOTPLUG
+	depends on NO_BOOTMEM && MEMORY_HOTPLUG
 	help
 	  Ordinarily all struct pages are initialised during early boot in a
 	  single thread. On very large machines this can take a considerable
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
