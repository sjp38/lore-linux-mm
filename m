Message-ID: <3EB05F61.5070404@us.ibm.com>
Date: Wed, 30 Apr 2003 16:42:25 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] remove unnecessary PAE pgd set
Content-Type: multipart/mixed;
 boundary="------------030002090605080700060007"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, Paul Larson <plars@linuxtestproject.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030002090605080700060007
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

With PAE on, there are only 4 PGD entries.  The kernel ones never
change, so there is no need to copy them when a vmalloc fault occurs.
This was this was causing problems with the split pmd patches, but it is
still correct for mainline.

Tested with and without PAE.  I ran it in a loop turning on and off 10
swap partitions, which is what excited the original bug.
http://bugme.osdl.org/show_bug.cgi?id=640
-- 
Dave Hansen
haveblue@us.ibm.com

--------------030002090605080700060007
Content-Type: text/plain;
 name="vmal_fault-optimization-PAE-2.5.68-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmal_fault-optimization-PAE-2.5.68-0.patch"

--- linux-2.5.68-vmal_fault/arch/i386/mm/fault.c.orig	Wed Apr 30 13:36:49 2003
+++ linux-2.5.68-vmal_fault/arch/i386/mm/fault.c	Wed Apr 30 13:36:18 2003
@@ -405,7 +405,15 @@
 
 		if (!pgd_present(*pgd_k))
 			goto no_context;
+		/*
+		 * kernel pmd pages are shared among all processes
+		 * with PAE on.  Since vmalloc pages are always
+		 * in the kernel area, this will always be a 
+		 * waste with PAE on.
+		 */
+#ifndef CONFIG_X86_PAE
 		set_pgd(pgd, *pgd_k);
+#endif
 		
 		pmd = pmd_offset(pgd, address);
 		pmd_k = pmd_offset(pgd_k, address);

--------------030002090605080700060007--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
