Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A00F900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 07:51:11 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so2831965pdi.17
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 04:51:11 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ck1si1568255pdb.82.2014.10.29.04.51.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 29 Oct 2014 04:51:10 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE700AXNFQ2TH90@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Oct 2014 11:54:02 +0000 (GMT)
Subject: [PATCH] mm/balloon_compaction: fix deflation when compaction is
 disabled
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Wed, 29 Oct 2014 14:51:07 +0400
Message-id: <20141029115107.23071.26065.stgit@buzz>
In-reply-to: <20141028202333.GC29098@hydra.tuxags.com>
References: <20141028202333.GC29098@hydra.tuxags.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Matt Mullins <mmullins@mmlx.us>, linux-kernel@vger.kernel.org, Rafael Aquini <aquini@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, stable@vger.kernel.org

Fix for commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
("mm/balloon_compaction: redesign ballooned pages management").

If CONFIG_BALLOON_COMPACTION=n balloon_page_insert() does not link
pages with balloon and doesn't set PagePrivate flag, as a result
balloon_page_dequeue cannot get any pages because it thinks that
all of them are isolated. Without balloon compaction nobody can
isolate ballooned pages, it's safe to remove this check.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Reported-by: Matt Mullins <mmullins@mmlx.us>
Cc: Stable <stable@vger.kernel.org>	(v3.17)
---
 mm/balloon_compaction.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index b3cbe19..fcad832 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -68,11 +68,13 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 		 * to be released by the balloon driver.
 		 */
 		if (trylock_page(page)) {
+#ifdef CONFIG_BALLOON_COMPACTION
 			if (!PagePrivate(page)) {
 				/* raced with isolation */
 				unlock_page(page);
 				continue;
 			}
+#endif
 			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 			balloon_page_delete(page);
 			__count_vm_event(BALLOON_DEFLATE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
