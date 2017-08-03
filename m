Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3BF36B0681
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 05:00:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r62so7784350pfj.1
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 02:00:30 -0700 (PDT)
Received: from zte.com.cn (mxhk.zte.com.cn. [63.217.80.70])
        by mx.google.com with ESMTP id k12si6174536pfb.118.2017.08.03.02.00.29
        for <linux-mm@kvack.org>;
        Thu, 03 Aug 2017 02:00:29 -0700 (PDT)
From: Wen Yang <wen.yang99@zte.com.cn>
Subject: [PATCH] mm/vmstat: fix divide error at __fragmentation_index
Date: Thu, 3 Aug 2017 17:12:00 +0800
Message-Id: <1501751520-2598-1-git-send-email-wen.yang99@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, wen.yang99@zte.com.cn, jiang.biao2@zte.com.cn

When order is -1 or too big, *1UL << order* will be 0, which will
cause divide error. Although it seems that all callers of
__fragmentation_index() will only do so with a valid order, the
patch can make it more robust.

Sugguested-by: VlastimilBabka <vbabka@suse.cz>
Signed-off-by: Wen Yang <wen.yang99@zte.com.cn>
Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
 mm/vmstat.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f7367..6f0f1ae 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -870,6 +870,9 @@ static int __fragmentation_index(unsigned int order, struct contig_page_info *in
 {
 	unsigned long requested = 1UL << order;
 
+	if (WARN_ON_ONCE(order >= MAX_ORDER))
+		return 0;
+
 	if (!info->free_blocks_total)
 		return 0;
 
-- 
2.7.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
