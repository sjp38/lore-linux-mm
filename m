Message-ID: <424452F2.7080206@engr.sgi.com>
Date: Fri, 25 Mar 2005 12:05:38 -0600
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: patch to remove warning in 2.6.11 + Hirokazu's page migration patches
Content-Type: multipart/mixed;
 boundary="------------060808060407090108000106"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060808060407090108000106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hirokazu,

The attached patch fixes a minor problem with your 2.6.11 page migration
patches.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--------------060808060407090108000106
Content-Type: text/plain;
 name="fix-warning-about-clear_user_pages-in-memory.c.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-warning-about-clear_user_pages-in-memory.c.patch"

This patch fixes a warning in the compilation of mm/memory.c when
Hirokazu's 2.6.11 memory-migration patches are applied.  The warning is
due to the fact that clear_user_pages() below needs to pass a
void * in as its first argument, since, (at least on ia64),
clear_user_pages() is a macro that calls clear_page(first arg to
clear_user_pages()), and clear_page() wants a void * argument.

The change below was suggested by Christoph Lameter and both
avoids this problem and makes the code simpler.

Signed-off-by: Ray Bryant <raybry@sgi.com>

Index: linux-2.6.11-page-migration/mm/memory.c
===================================================================
--- linux-2.6.11-page-migration.orig/mm/memory.c	2005-03-24 11:24:09.000000000 -0800
+++ linux-2.6.11-page-migration/mm/memory.c	2005-03-24 15:01:23.000000000 -0800
@@ -1323,11 +1323,9 @@ static int do_wp_page(struct mm_struct *
 		goto no_new_page;
 
 	if (old_page == ZERO_PAGE(address)) {
-		if (VM_Immovable(vma)) {
-			new_page = alloc_page_vma(GFP_USER, vma, address);
-			if (new_page)
-				clear_user_page(address, address, new_page);
-		} else
+		if (VM_Immovable(vma))
+			new_page = alloc_page_vma(GFP_USER | __GFP_ZERO, vma, address);
+		else
 			new_page = alloc_zeroed_user_highpage(vma, address);
 		if (!new_page)
 			goto no_new_page;

--------------060808060407090108000106--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
