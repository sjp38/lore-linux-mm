Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45E116B0010
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 17:15:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so7341590pfn.3
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 14:15:20 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id s17-v6si4940902pgm.317.2018.10.04.14.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 14:15:19 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 1/2 -mm] mm: brk: fix unsigned compare against 0 issue
Date: Fri,  5 Oct 2018 05:14:31 +0800
Message-Id: <1538687672-17795-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, kirill.shutemov@linux.intel.com, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, colin.king@canonical.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Static analysis reported unsigned compare against 0 issue according to
Colin Ian King.

Defined an int temp variable to check the return value of __do_munmap().

Reported-by: Colin Ian King <colin.king@canonical.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
Andrew, this should be able to be folded into the original patch.

 mm/mmap.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 68dc4fb..c78f7e9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -242,17 +242,18 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	 * __do_munmap() may downgrade mmap_sem to read.
 	 */
 	if (brk <= mm->brk) {
+		int ret;
 		/*
 		 * mm->brk need to be protected by write mmap_sem, update it
 		 * before downgrading mmap_sem.
 		 * When __do_munmap fail, it will be restored from origbrk.
 		 */
 		mm->brk = brk;
-		retval = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
-		if (retval < 0) {
+		ret = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
+		if (ret < 0) {
 			mm->brk = origbrk;
 			goto out;
-		} else if (retval == 1)
+		} else if (ret == 1)
 			downgraded = true;
 		goto success;
 	}
-- 
1.8.3.1
