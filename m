Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA066B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 17:27:12 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so3187988pad.31
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 14:27:12 -0800 (PST)
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
        by mx.google.com with ESMTPS id qh6si6294659pbb.154.2013.12.20.14.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 14:27:11 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so3206324pab.20
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 14:27:10 -0800 (PST)
From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] mm: fix build of split ptlock code
Date: Fri, 20 Dec 2013 14:28:05 -0800
Message-Id: <1387578485-11829-1-git-send-email-olof@lixom.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Olof Johansson <olof@lixom.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

Commit 597d795a2a78 ('mm: do not allocate page->ptl dynamically, if
spinlock_t fits to long') restructures some allocators that are compiled
even if USE_SPLIT_PTLOCKS arn't used. It results in compilation failure:

mm/memory.c:4282:6: error: 'struct page' has no member named 'ptl'
mm/memory.c:4288:12: error: 'struct page' has no member named 'ptl'

Add in the missing ifdef.

Fixes: 597d795a2a78 ('mm: do not allocate page->ptl dynamically, if spinlock_t fits to long')
Signed-off-by: Olof Johansson <olof@lixom.net>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index b6e211b..6768ce9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4271,7 +4271,7 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
-#if ALLOC_SPLIT_PTLOCKS
+#if USE_SPLIT_PTE_PTLOCKS && ALLOC_SPLIT_PTLOCKS
 bool ptlock_alloc(struct page *page)
 {
 	spinlock_t *ptl;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
