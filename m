Message-ID: <422356AB.4040703@sgi.com>
Date: Mon, 28 Feb 2005 11:36:43 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: [PATCH] mm: memory migration: bug in touch_unmapped_address
Content-Type: multipart/mixed;
 boundary="------------050404050103010602050409"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Marcello Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050404050103010602050409
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hirokazu,

The length field in the call to get_user_pages() from touch_unmapped_pages()
is incorrectly specified in bytes, not pages.

As a result of this, if you use the migration code to migrate a page, then
subsequent pages (that are not necessarily currently allocated or mapped)
can be allocated and mapped as a result of the migration call.

[touch_unmapped_pages() is added by the memory migration code from the memory
hotplug patch so this is not currently part of the mainline kernel]

See attached patch for the fix.
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

--------------050404050103010602050409
Content-Type: text/plain;
 name="fix-len-param-in-touch_unmapped_address.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-len-param-in-touch_unmapped_address.patch"

The "len" parameter (4th arg) of get_user_pages() is in pages, not
bytes.  The effect of this bug is that if you migrate a page, and
if this page is followed by valid virtual addresses, but these 
pages have not yet been touched and allocated, then the migration
call will cause those pages to be touched and allocated.  The number
of pages so effected is the min of (16384, the remaining number of
pages in the vma, the number of pages required to fill out the
current pmd).

Signed-off-by: Ray Bryant <raybry@sgi.com>

Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c	2005-01-30 10:34:03.000000000 -0800
+++ linux/mm/rmap.c	2005-02-28 08:53:30.000000000 -0800
@@ -554,8 +554,7 @@ touch_unmapped_address(struct list_head 
 		vma = find_vma(v1->mm, v1->addr);
 		if (vma == NULL)
 			goto out;
-		error = get_user_pages(current, v1->mm, v1->addr, PAGE_SIZE,
-					0, 0, NULL, NULL);
+		error = get_user_pages(current, v1->mm, v1->addr, 1, 0, 0, NULL, NULL);
 		if (error < 0)
 			ret = error;
 	out:

--------------050404050103010602050409--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
