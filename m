Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 383F76B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:37:47 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l66so16417817wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:37:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si16036585wjr.11.2016.01.28.07.37.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 07:37:46 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm/Kconfig: correct description of DEFERRED_STRUCT_PAGE_INIT
Date: Thu, 28 Jan 2016 16:37:28 +0100
Message-Id: <1453995448-27582-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

The description mentions kswapd threads, while the deferred struct page
initialization is actually done by one-off "pgdatinitX" threads. Fix the
description so that potentially users are not confused about pgdatinit threads
using CPU after boot instead of kswapd.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/Kconfig | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 97a4e06b15c0..03cbfa072f42 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -624,7 +624,7 @@ config ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 	bool
 
 config DEFERRED_STRUCT_PAGE_INIT
-	bool "Defer initialisation of struct pages to kswapd"
+	bool "Defer initialisation of struct pages to kthreads"
 	default n
 	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 	depends on MEMORY_HOTPLUG
@@ -633,9 +633,10 @@ config DEFERRED_STRUCT_PAGE_INIT
 	  single thread. On very large machines this can take a considerable
 	  amount of time. If this option is set, large machines will bring up
 	  a subset of memmap at boot and then initialise the rest in parallel
-	  when kswapd starts. This has a potential performance impact on
-	  processes running early in the lifetime of the systemm until kswapd
-	  finishes the initialisation.
+	  by starting one-off "pgdatinitX" kernel thread for each node X. This
+	  has a potential performance impact on processes running early in the
+	  lifetime of the system until these kthreads finish the
+	  initialisation.
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
