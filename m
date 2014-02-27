Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id C90BD6B007D
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 23:39:57 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id u56so2467163wes.3
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 20:39:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dx1si2657761wib.39.2014.02.26.20.39.55
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 20:39:56 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/3] mm/pagewalk.c: fix end address calculation in walk_page_range()
Date: Wed, 26 Feb 2014 23:39:35 -0500
Message-Id: <1393475977-3381-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When we try to walk over inside a vma, walk_page_range() tries to walk
until vma->vm_end even if a given end is before that point.
So this patch takes the smaller one as an end address.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/pagewalk.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git next-20140220.orig/mm/pagewalk.c next-20140220/mm/pagewalk.c
index 416e981243b1..b418407ff4da 100644
--- next-20140220.orig/mm/pagewalk.c
+++ next-20140220/mm/pagewalk.c
@@ -321,8 +321,9 @@ int walk_page_range(unsigned long start, unsigned long end,
 			next = vma->vm_start;
 		} else { /* inside the found vma */
 			walk->vma = vma;
-			next = vma->vm_end;
-			err = walk_page_test(start, end, walk);
+			next = min_t(unsigned long, end, vma->vm_end);
+
+			err = walk_page_test(start, next, walk);
 			if (skip_lower_level_walking(walk))
 				continue;
 			if (err)
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
