Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 917ED6B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 04:56:15 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id a13so475268igq.9
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 01:56:15 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id g8si17063352icj.11.2014.06.06.01.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 01:56:14 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so548633igq.4
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 01:56:14 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm/vmscan.c: avoid scanning the whole targets[*] when scan_balance equals SCAN_FILE/SCAN_ANON
Date: Fri,  6 Jun 2014 16:54:26 +0800
Message-Id: <1402044866-15313-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, Chen Yucong <slaoub@gmail.com>

If (scan_balance == SCAN_FILE) is true for shrink_lruvec, then  the value of
targets[LRU_INACTIVE_ANON] and targets[LRU_ACTIVE_ANON] will be zero. As a result,
the value of 'percentage' will also be  zero, and the *whole* targets[LRU_INACTIVE_FILE]
and targets[LRU_ACTIVE_FILE] will be scanned.

For (scan_balance == SCAN_ANON), there is the same conditions stated above.

But via https://lkml.org/lkml/2013/4/10/334, we can find that the kernel does not prefer
reclaiming too many pages from the other LRU. So before recalculating the other LRU scan
count based on its original scan targets and the percentage scanning already complete, we
should need to check whether 'scan_balance' equals SCAN_FILE/SCAN_ANON.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d51f7e0..ca3f5f1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2120,6 +2120,9 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 			percentage = nr_file * 100 / scan_target;
 		}
 
+		if (targets[lru] == 0 && targets[lru + LRU_ACTIVE] == 0)
+			break;
+
 		/* Stop scanning the smaller of the LRU */
 		nr[lru] = 0;
 		nr[lru + LRU_ACTIVE] = 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
