Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 604146B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 18:22:48 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so1853939pab.9
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 15:22:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id l4si4853648pav.405.2014.04.18.15.22.47
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 15:22:47 -0700 (PDT)
Date: Fri, 18 Apr 2014 15:22:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] get_user_pages() cleanup
Message-Id: <20140418152245.b6d41e544ff5467ec8c3df67@linux-foundation.org>
In-Reply-To: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Thu,  3 Apr 2014 17:35:17 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Here's my attempt to cleanup of get_user_pages() code in order to make it
> more maintainable.
> 
> Tested on my laptop for few hours. No crashes so far ;)
> 
> Let me know if it makes sense. Any suggestions are welcome.
> 
> Kirill A. Shutemov (5):
>   mm: move get_user_pages()-related code to separate file
>   mm: extract in_gate_area() case from __get_user_pages()
>   mm: cleanup follow_page_mask()
>   mm: extract code to fault in a page from __get_user_pages()
>   mm: cleanup __get_user_pages()
> 
>  mm/Makefile |   2 +-
>  mm/gup.c    | 638 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/memory.c | 611 ---------------------------------------------------------

Fair enough.

We don't have anything like enough #includes in the new gup.c so
there's a risk of Kconfig-dependent breakage.  I plugged in a few
obvious ones, but many more are surely missing.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/gup.c: tweaks

- include some more header files, but many are still missed
- fix some 80-col overflows by removing unneeded `inline'

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/gup.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff -puN mm/gup.c~a mm/gup.c
--- a/mm/gup.c~a
+++ a/mm/gup.c
@@ -1,3 +1,8 @@
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/err.h>
+#include <linux/spinlock.h>
+
 #include <linux/hugetlb.h>
 #include <linux/mm.h>
 #include <linux/rmap.h>
@@ -6,8 +11,8 @@
 
 #include "internal.h"
 
-static inline struct page *no_page_table(struct vm_area_struct *vma,
-		unsigned int flags)
+static struct page *no_page_table(struct vm_area_struct *vma,
+				  unsigned int flags)
 {
 	/*
 	 * When core dumping an enormous anonymous area that nobody
@@ -208,7 +213,7 @@ struct page *follow_page_mask(struct vm_
 	return follow_page_pte(vma, address, pmd, flags);
 }
 
-static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long addr)
+static int stack_guard_page(struct vm_area_struct *vma, unsigned long addr)
 {
 	return stack_guard_page_start(vma, addr) ||
 	       stack_guard_page_end(vma, addr+PAGE_SIZE);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
