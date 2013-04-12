Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 969C86B0071
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:41 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:40 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id E0681C9001A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:37 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EbvJ31522994
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:37 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1Ebft001515
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 22:14:37 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 18/25] init/main: call memlayout_global_init() in start_kernel().
Date: Thu, 11 Apr 2013 18:13:50 -0700
Message-Id: <1365729237-29711-19-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
