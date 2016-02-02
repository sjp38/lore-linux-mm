Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6716A6B0255
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 11:21:34 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so106837409pfn.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 08:21:34 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q71si2699028pfi.248.2016.02.02.08.21.33
        for <linux-mm@kvack.org>;
        Tue, 02 Feb 2016 08:21:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/2] Fix another VM_BUG_ON_PAGE(PageTail(page)) on mbind(2)
Date: Tue,  2 Feb 2016 19:20:59 +0300
Message-Id: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dmitry Vyukov reported yet another VM_BUG_ON_PAGE(PageTail(page)) bug from
isolate_lru_page().

The fisrt patch fixes the bug by filter out non migratable VMAs in
queue_pages_test_walk(). There's no point to queue pages from non-migratable
VMA even for MPOL_MF_STRICT.

The second patch replace VM_BUG_ON_PAGE() with WARN_RATELIMIT() in
isolate_lru_page(). Most attempts to isolate tail pages are not fatal, as
these pages usually are not on LRU and will not be isolated.

v2:
 - address feedback from Michal Hocko;

Kirill A. Shutemov (2):
  mempolicy: do not try to queue pages from !vma_migratable()
  mm: downgrade VM_BUG in isolate_lru_page() to warning

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
