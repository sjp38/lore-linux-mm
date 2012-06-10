Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 37BD06B0071
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:12 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm19so3841564bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:11 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 06/10] mm: frontswap: make all branches of if statement in put page consistent
Date: Sun, 10 Jun 2012 12:51:04 +0200
Message-Id: <1339325468-30614-7-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
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
index e6353d9..d8dc986 100644
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
-	} else {
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
