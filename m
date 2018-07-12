Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7795B6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 20:49:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so16048911plo.9
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:49:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m24-v6sor5915877pgn.197.2018.07.11.17.49.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 17:49:03 -0700 (PDT)
Date: Wed, 11 Jul 2018 17:48:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] thp: fix data loss when splitting a file pmd
Message-ID: <alpine.LSU.2.11.1807111741430.1106@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ashwin Chaugule <ashwinch@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

__split_huge_pmd_locked() must check if the cleared huge pmd was dirty,
and propagate that to PageDirty: otherwise, data may be lost when a huge
tmpfs page is modified then split then reclaimed.

How has this taken so long to be noticed?  Because there was no problem
when the huge page is written by a write system call (shmem_write_end()
calls set_page_dirty()), nor when the page is allocated for a write fault
(fault_dirty_shared_page() calls set_page_dirty()); but when allocated
for a read fault (which MAP_POPULATE simulates), no set_page_dirty().

Fixes: d21b9e57c74c ("thp: handle file pages in split_huge_pmd()")
Reported-by: Ashwin Chaugule <ashwinch@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <stable@vger.kernel.org> # v4.8+
---

 mm/huge_memory.c |    2 ++
 1 file changed, 2 insertions(+)

--- 4.18-rc4/mm/huge_memory.c	2018-06-16 18:48:22.029173363 -0700
+++ linux/mm/huge_memory.c	2018-07-10 20:11:29.991011603 -0700
@@ -2084,6 +2084,8 @@ static void __split_huge_pmd_locked(stru
 		if (vma_is_dax(vma))
 			return;
 		page = pmd_page(_pmd);
+		if (!PageDirty(page) && pmd_dirty(_pmd))
+			set_page_dirty(page);
 		if (!PageReferenced(page) && pmd_young(_pmd))
 			SetPageReferenced(page);
 		page_remove_rmap(page, true);
