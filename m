Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id CDB4F6B007B
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:14:54 -0400 (EDT)
Received: by mail-yw0-f41.google.com with SMTP id 47so2065223yhr.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:14:54 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 06/10] mm: frontswap: make all branches of if statement in put page consistent
Date: Fri,  8 Jun 2012 21:15:15 +0200
Message-Id: <1339182919-11432-7-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Currently it has a complex structure where different things are compared
at each branch. Simplify that and make both branches look similar.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 1f1af0e..ee1763d 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -140,16 +140,16 @@ int __frontswap_store(struct page *page)
 		inc_frontswap_succ_stores();
 		if (!dup)
 			atomic_inc(&sis->frontswap_pages);
-	} else if (dup) {
+	} else {
 		/*
 		  failed dup always results in automatic invalidate of
 		  the (older) page from frontswap
 		 */
-		frontswap_clear(sis, offset);
-		atomic_dec(&sis->frontswap_pages);
-		inc_frontswap_failed_stores();
-	} else
 		inc_frontswap_failed_stores();
+		if (dup) {
+			frontswap_clear(sis, offset);
+			atomic_dec(&sis->frontswap_pages);
+		}
 	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
