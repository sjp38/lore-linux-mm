Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A37D6B0037
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 03:39:15 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so674164pbc.39
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 00:39:15 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gn4si60655790pbc.171.2013.12.06.00.39.12
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 00:39:14 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/4] mm/mempolicy: correct putback method for isolate pages if failed
Date: Fri,  6 Dec 2013 17:41:48 +0900
Message-Id: <1386319310-28016-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

queue_pages_range() isolates hugetlbfs pages and putback_lru_pages() can't
handle these. We should change it to putback_movable_pages().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index eca4a31..6d04d37 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1318,7 +1318,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
 	} else
-		putback_lru_pages(&pagelist);
+		putback_movable_pages(&pagelist);
 
 	up_write(&mm->mmap_sem);
  mpol_out:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
