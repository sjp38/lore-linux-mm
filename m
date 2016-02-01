Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5416B0253
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:27:26 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so82171450pab.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:27:26 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ai6si24336546pad.181.2016.02.01.05.27.25
        for <linux-mm@kvack.org>;
        Mon, 01 Feb 2016 05:27:25 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Fix another VM_BUG_ON_PAGE(PageTail(page)) on mbind(2)
Date: Mon,  1 Feb 2016 16:26:07 +0300
Message-Id: <1454333169-121369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dmitry Vyukov reported yet another VM_BUG_ON_PAGE(PageTail(page)) bug from
isolate_lru_page().

The first patch relaxes VM_BUG_ON_PAGE(): no need to crash on tail pages
which are not on LRU. We are not going to isolate them anyway.

The second patch tries streamline logic within queue_pages_range(): no
need to scan non migratable VMAs. The patch requires more careful review.

Any of these patches should fix the issue. I think both should be applied.
The first one is subject for 4.5 as the bogus was introduced there.

Kirill A. Shutemov (2):
  mm: fix bogus VM_BUG_ON_PAGE() in isolate_lru_page()
  mempolicy: do not try to queue pages from !vma_migratable()

 mm/mempolicy.c | 14 +++++---------
 mm/vmscan.c    |  2 +-
 2 files changed, 6 insertions(+), 10 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
