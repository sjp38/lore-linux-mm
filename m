Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 657726B0096
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:30 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so13312502obb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:30 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 06/11] mm: frontswap: make all branches of if statement in put page consistent
Date: Wed,  6 Jun 2012 12:55:10 +0200
Message-Id: <1338980115-2394-6-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Currently it has a complex structure where different things are compared
at each branch. Simplify that and make both branches look similar.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 618ef91..f2f4685 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -119,16 +119,16 @@ int __frontswap_put_page(struct page *page)
 		frontswap_succ_puts++;
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
-		frontswap_failed_puts++;
-	} else {
 		frontswap_failed_puts++;
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
