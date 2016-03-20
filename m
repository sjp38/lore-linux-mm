Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 01C3A82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:42 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id 4so106673010pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 54/71] proc: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:01 +0300
Message-Id: <1458499278-1516-55-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 2 +-
 fs/proc/vmcore.c   | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index fa95ab2d3674..31ebd7a0f8b8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -553,7 +553,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 		if (radix_tree_exceptional_entry(page))
 			mss->swap += PAGE_SIZE;
 		else
-			page_cache_release(page);
+			put_page(page);
 
 		return;
 	}
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 55bb57e6a30d..8afe10cf7df8 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -279,12 +279,12 @@ static int mmap_vmcore_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!page)
 		return VM_FAULT_OOM;
 	if (!PageUptodate(page)) {
-		offset = (loff_t) index << PAGE_CACHE_SHIFT;
+		offset = (loff_t) index << PAGE_SHIFT;
 		buf = __va((page_to_pfn(page) << PAGE_SHIFT));
 		rc = __read_vmcore(buf, PAGE_SIZE, &offset, 0);
 		if (rc < 0) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return (rc == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
 		}
 		SetPageUptodate(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
