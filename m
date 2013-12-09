Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 846746B0078
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:08:04 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so4854685pde.20
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:08:04 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id n8si6655856pax.247.2013.12.09.01.08.01
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:08:03 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 3/7] mm/mempolicy: correct putback method for isolate pages if failed
Date: Mon,  9 Dec 2013 18:10:44 +0900
Message-Id: <1386580248-22431-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

queue_pages_range() isolates hugetlbfs pages and putback_lru_pages() can't
handle these. We should change it to putback_movable_pages().

Naoya said that it is worth going into stable, because it can break
in-use hugepage list.

Cc: <stable@vger.kernel.org> # 3.12
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
