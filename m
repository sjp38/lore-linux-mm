Received: from smtp01.mail.gol.com (smtp01.mail.gol.com [203.216.5.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA08415
	for <linux-mm@kvack.org>; Sat, 20 Feb 1999 06:44:54 -0500
Message-ID: <36CEA095.D5EA37B5@earthling.net>
Date: Sat, 20 Feb 1999 20:46:29 +0900
From: Neil Booth <NeilB@earthling.net>
MIME-Version: 1.0
Subject: PATCH - bug in vfree
Content-Type: multipart/mixed; boundary="------------1EAC3CC7E991125472AB4CD3"
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------1EAC3CC7E991125472AB4CD3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Linus,

I posted this bug on the kernel mailing list last year, but it never got
fixed, probably as I didn't include a patch. I attach a patch this time
against kernel 2.2.1. The bug is rare, but can lead to kernel virtual
memory corruption.

Quick description:- vfree forgets to subtract the extra cushion page
from the size of each virtual memory area stored in vmlist when it calls
vmfree_area_pages. This means that only the  vmalloc-requested size is
allocated by vmalloc_area_pages, but the requested size PLUS the cushion
page is freed by vmfree_area_pages.

More deeply:- Close inspection of get_vm_area reveals that
(intentionally?) it does NOT insist there be a cushion page behind a VMA
that is placed in front of a previously-allocated VMA, it ONLY
guarantees that a cushion page lies in front of newly-allocated VMAs.
Thus two VMAs could be immediately adjacent without a cushion page, and
coupled with the vfree bug means that vfree-ing the first VMA also frees
the first page of the second VMA, with dire consequences.

I have described this as clearly as I can, I hope it makes sense. Alan,
this same bug also exists in 2.0.36.

Neil.
--------------1EAC3CC7E991125472AB4CD3
Content-Type: text/plain; charset=us-ascii; name="vfree-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="vfree-patch"

--- linux/mm/vmalloc.c~	Sun Jan 24 19:21:06 1999
+++ linux/mm/vmalloc.c	Sat Feb 20 20:17:11 1999
@@ -187,7 +187,7 @@
 	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
 		if (tmp->addr == addr) {
 			*p = tmp->next;
-			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
+			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size - PAGE_SIZE);
 			kfree(tmp);
 			return;
 		}

--------------1EAC3CC7E991125472AB4CD3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
