Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 46B5F82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:41 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so237543017pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id c90si10337078pfd.233.2016.03.20.11.41.52
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 65/71] binfmt: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:12 +0300
Message-Id: <1458499278-1516-66-git-send-email-kirill.shutemov@linux.intel.com>
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
 fs/binfmt_elf.c       | 2 +-
 fs/binfmt_elf_fdpic.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 7d914c67a9d0..81381cc0dd17 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2292,7 +2292,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				stop = !dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				page_cache_release(page);
+				put_page(page);
 			} else
 				stop = !dump_skip(cprm, PAGE_SIZE);
 			if (stop)
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index b1adb92e69de..083ea2bc60ab 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1533,7 +1533,7 @@ static bool elf_fdpic_dump_segments(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				res = dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				page_cache_release(page);
+				put_page(page);
 			} else {
 				res = dump_skip(cprm, PAGE_SIZE);
 			}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
