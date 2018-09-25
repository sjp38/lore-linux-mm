Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A45A48E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 22:14:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e15-v6so11344253pfi.5
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 19:14:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q36-v6sor114741pgl.248.2018.09.24.19.14.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 19:14:58 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: remove unnecessary local variable addr in __get_user_pages_fast()
Date: Tue, 25 Sep 2018 10:14:48 +0800
Message-Id: <20180925021448.20265-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

The local variable *addr* in __get_user_pages_fast() is just a shadow of
*start*. Since *start* never changes after assigned to *addr*, it is fine
to replace *start* with it.

Also the meaning of [start, end] is more obvious than [addr, end] when
passed to gup_pgd_range().

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/gup.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index fc5f98069f4e..1a80775440cb 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1780,12 +1780,11 @@ bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
 {
-	unsigned long addr, len, end;
+	unsigned long len, end;
 	unsigned long flags;
 	int nr = 0;
 
 	start &= PAGE_MASK;
-	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
@@ -1807,7 +1806,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages, write)) {
 		local_irq_save(flags);
-		gup_pgd_range(addr, end, write, pages, &nr);
+		gup_pgd_range(start, end, write, pages, &nr);
 		local_irq_restore(flags);
 	}
 
-- 
2.15.1
