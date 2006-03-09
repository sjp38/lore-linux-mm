Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 4/5 V0.1 - handle
	misplaced anon pages
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1141928990.6393.14.camel@localhost.localdomain>
References: <1141928990.6393.14.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 16:48:04 -0500
Message-Id: <1141940884.8326.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 13:29 -0500, Lee Schermerhorn wrote:
> Migrate-on-fault prototype 4/5 V0.1 - handle misplaced anon pages

Resend #4:

Migrate-on-fault prototype 4/5 V0.1 - handle misplaced anon pages

This patch simply hooks the anon page fault handler [do_swap_page()]
to check for and migrate misplaced pages.

File and shmem fault paths will be addressed in separate patches.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git8/mm/memory.c
===================================================================
--- linux-2.6.16-rc5-git8.orig/mm/memory.c	2006-03-06 13:40:48.000000000 -0500
+++ linux-2.6.16-rc5-git8/mm/memory.c	2006-03-07 08:53:30.000000000 -0500
@@ -48,6 +48,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/mempolicy.h>	/* check_migrate_misplaced_page() */
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -1926,6 +1927,8 @@ again:
 
 	/* The page isn't present yet, go ahead with the fault. */
 
+	page = check_migrate_misplaced_page(page, vma, address);
+
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
