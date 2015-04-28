Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 94D606B007B
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:25:09 -0400 (EDT)
Received: by pdea3 with SMTP id a3so168633209pde.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:25:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pc5si35356352pac.85.2015.04.28.09.25.08
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 09:25:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: drop bogus VM_BUG_ON_PAGE assert in put_page() codepath
Date: Tue, 28 Apr 2015 19:24:57 +0300
Message-Id: <1430238298-80442-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

My patch 8d63d99a5dfb which was merged during 4.1 merge window caused
regression:

  page:ffffea0010a15040 count:0 mapcount:1 mapping:          (null) index:0x0
  flags: 0x8000000000008014(referenced|dirty|tail)
  page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
  ------------[ cut here ]------------
  kernel BUG at mm/swap.c:134!

The problem can be reproduced by playing *two* audio files at the same
time and then stopping one of players. I used two mplayers to trigger
this.

The VM_BUG_ON_PAGE() which triggers the bug is bogus:

Sound subsystem uses compound pages for its buffers, but unlike most
__GFP_COMP sound maps compound pages to userspace with PTEs.

In our case with two players map the buffer twice and therefore elevates
page_mapcount() on tail pages by two. When one of players exits it
unmaps the VMA and drops page_mapcount() to one and try to release
reference on the page with put_page().

My commit changes which path it takes under put_compound_page(). It hits
put_unrefcounted_compound_page() where VM_BUG_ON_PAGE() is. It sees
page_mapcount() == 1. The function wrongly assumes that subpages of
compound page cannot be be mapped by itself with PTEs..

The solution is simply drop the VM_BUG_ON_PAGE().

Note: there's no need to move the check under put_page_testzero().
Allocator will check the mapcount by itself before putting on free
list.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Borislav Petkov <bp@alien8.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/swap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index a7251a8ed532..a3a0a2f1f7c3 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -131,7 +131,6 @@ void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
 		 * here, see the comment above this function.
 		 */
 		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
 		if (put_page_testzero(page_head)) {
 			/*
 			 * If this is the tail of a slab THP page,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
