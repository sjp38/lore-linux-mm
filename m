Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCE46B0253
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:26:24 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so82159978pab.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:26:24 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rm10si24272004pab.25.2016.02.01.05.26.22
        for <linux-mm@kvack.org>;
        Mon, 01 Feb 2016 05:26:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: fix bogus VM_BUG_ON_PAGE() in isolate_lru_page()
Date: Mon,  1 Feb 2016 16:26:08 +0300
Message-Id: <1454333169-121369-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454333169-121369-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454333169-121369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't care if there's a tail pages which is not on LRU. We are not
going to isolate them anyway.

Testcase:

	#include <fcntl.h>
	#include <unistd.h>
	#include <stdio.h>
	#include <sys/mman.h>
	#include <numaif.h>

	#define SIZE 0x2000

	int foo;

	int main()
	{
		int fd;
		char *p;
		unsigned long mask = 2;

		fd = open("/dev/sg0", O_RDWR);
		p = mmap(NULL, SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
		/* Faultin pages */
		foo = p[0] + p[0x1000];
		mbind(p, SIZE, MPOL_BIND, &mask, 4, MPOL_MF_MOVE | MPOL_MF_STRICT);
		return 0;
	}

MPOL_MF_STRICT makes queue_pages_test_walk() ignore !vma_megratable()
and we try to queue such pages for migration. It's good question why we
ignore !vma_megratable() for MPOL_MF_STRICT, but it's subject for a
separate patch.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Fixes: bb5b8589767a ("mm: make sure isolate_lru_page() is never called for tail page"
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb3dd37ccd7c..492fbe73420b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
 	int ret = -EBUSY;
 
 	VM_BUG_ON_PAGE(!page_count(page), page);
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(PageLRU(page) && PageTail(page), page);
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
