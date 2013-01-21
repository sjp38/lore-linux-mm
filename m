Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6F9E06B0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2013 22:16:04 -0500 (EST)
Date: Mon, 21 Jan 2013 14:15:49 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
Subject: [PATCH] Subtract min_free_kbytes from dirtyable memory
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org

When calculating amount of dirtyable memory, min_free_kbytes should be
subtracted because it is not intended for dirty pages.

Using an "extern int" because that is the only interface to some such
sysctl values.

(This patch does not solve the PAE OOM issue.)

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
Reference: http://bugs.debian.org/695182
Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>

--- mm/page-writeback.c.old	2012-12-06 22:20:40.000000000 +1100
+++ mm/page-writeback.c	2013-01-21 13:57:05.000000000 +1100
@@ -343,12 +343,16 @@
 unsigned long determine_dirtyable_memory(void)
 {
 	unsigned long x;
+	extern int min_free_kbytes;
 
 	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
 
+	/* Subtract min_free_kbytes */
+	x -= min(x, min_free_kbytes >> (PAGE_SHIFT - 10));
+
 	return x + 1;	/* Ensure that we never return 0 */
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
