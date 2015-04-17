Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE3E6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 14:59:43 -0400 (EDT)
Received: by widdi4 with SMTP id di4so32546541wid.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 11:59:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg10si20202944wjb.152.2015.04.17.11.59.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 11:59:41 -0700 (PDT)
Date: Fri, 17 Apr 2015 20:59:39 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] thp: cleanup how khugepaged enters freezer
Message-ID: <alpine.LNX.2.00.1504172055570.3695@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

khugepaged_do_scan() checks in every iteration whether freezing(current) 
is true, and in such case breaks out of the loop, which causes 
try_to_freeze() to be called immediately afterwards in 
khugepaged_wait_work().

If nothing else, this causes unnecessary freezing(current) test, and also 
makes the way khugepaged enters freezer a bit less obvious than necessary.

Let's just try to freeze directly, instead of splitting it into two 
(directly adjacent) phases.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---

Stumbled upon this when debugging something completely unrelated.

 mm/huge_memory.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 078832c..b3d8cd8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2799,7 +2799,7 @@ static void khugepaged_do_scan(void)
 
 		cond_resched();
 
-		if (unlikely(kthread_should_stop() || freezing(current)))
+		if (unlikely(kthread_should_stop() || try_to_freeze()))
 			break;
 
 		spin_lock(&khugepaged_mm_lock);
@@ -2820,8 +2820,6 @@ static void khugepaged_do_scan(void)
 
 static void khugepaged_wait_work(void)
 {
-	try_to_freeze();
-
 	if (khugepaged_has_work()) {
 		if (!khugepaged_scan_sleep_millisecs)
 			return;

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
