Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8E26B0082
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:25:10 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so64414pdb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:25:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pg3si35366967pdb.124.2015.04.28.09.25.08
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 09:25:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Reintroduce picky __compound_tail_refcounted()
Date: Tue, 28 Apr 2015 19:24:56 +0300
Message-Id: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew,

My patch 8d63d99a5dfb which was merged during 4.1 merge window caused
regression:

  page:ffffea0010a15040 count:0 mapcount:1 mapping:          (null) index:0x0
  flags: 0x8000000000008014(referenced|dirty|tail)
  page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
  ------------[ cut here ]------------
  kernel BUG at mm/swap.c:134!

The patch was reverted by Linus.

This VM_BUG_ON_PAGE() is bogus. The first patch explains why the assert is
wrong and removes it. The second re-introduces original patch.

Kirill A. Shutemov (2):
  mm: drop bogus VM_BUG_ON_PAGE assert in put_page() codepath
  mm: avoid tail page refcounting on non-THP compound pages

 include/linux/mm.h | 2 +-
 mm/swap.c          | 1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
