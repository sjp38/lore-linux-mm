Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A352C6B028C
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:43 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:43 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B5B36C90046
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:38 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301c8L346910
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301c8R006008
	for <linux-mm@kvack.org>; Thu, 2 May 2013 21:01:38 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 24/31] init/main: call memlayout_global_init() in start_kernel().
Date: Thu,  2 May 2013 17:00:56 -0700
Message-Id: <1367539263-19999-25-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

memlayout_global_init() initializes the first memlayout, which is
assumed to match the initial page-flag nid settings.

This is done in start_kernel() as the initdata used to populate the
memlayout is purged from memory early in the boot process (XXX: When?).

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 init/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/init/main.c b/init/main.c
index ceed17a..8ed5209 100644
--- a/init/main.c
+++ b/init/main.c
@@ -74,6 +74,7 @@
 #include <linux/ptrace.h>
 #include <linux/blkdev.h>
 #include <linux/elevator.h>
+#include <linux/memlayout.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -613,6 +614,7 @@ asmlinkage void __init start_kernel(void)
 	security_init();
 	dbg_late_init();
 	vfs_caches_init(totalram_pages);
+	memlayout_global_init();
 	signals_init();
 	/* rootfs populating might need page-writeback */
 	page_writeback_init();
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
