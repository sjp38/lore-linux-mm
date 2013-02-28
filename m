Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5C6376B0025
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:57:57 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 14:57:55 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9F9763E4003E
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:39 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLvdWu041170
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:39 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLvYZM013345
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:36 -0700
Received: from kernel.stglabs.ibm.com (kernel.stglabs.ibm.com [9.114.214.19])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r1SLvWUo013254
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:33 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 21/24] init/main: call memlayout_global_init() in start_kernel().
Date: Thu, 28 Feb 2013 13:57:24 -0800
Message-Id: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

memlayout_global_init() initializes the first memlayout, which is
assumed to match the initial page-flag nid settings.

This is done in start_kernel() as the initdata used to populate the
memlayout is purged from memory early in the boot process (XXX: When?).

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 init/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/init/main.c b/init/main.c
index 63534a1..a1c2094 100644
--- a/init/main.c
+++ b/init/main.c
@@ -72,6 +72,7 @@
 #include <linux/ptrace.h>
 #include <linux/blkdev.h>
 #include <linux/elevator.h>
+#include <linux/memlayout.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -618,6 +619,7 @@ asmlinkage void __init start_kernel(void)
 	security_init();
 	dbg_late_init();
 	vfs_caches_init(totalram_pages);
+	memlayout_global_init();
 	signals_init();
 	/* rootfs populating might need page-writeback */
 	page_writeback_init();
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
