Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id BE3316B003D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:42 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so2327991eek.24
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si14854346eeo.205.2013.12.10.07.51.41
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:42 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/18] mm: numa: Avoid unnecessary work on the failure path
Date: Tue, 10 Dec 2013 15:51:25 +0000
Message-Id: <1386690695-27380-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If a PMD changes during a THP migration then migration aborts but the
failure path is doing more work than is necessary.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/migrate.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index be787d5..a987525 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1780,7 +1780,8 @@ fail_putback:
 		putback_lru_page(page);
 		mod_zone_page_state(page_zone(page),
 			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
-		goto out_fail;
+
+		goto out_unlock;
 	}
 
 	/*
@@ -1854,6 +1855,7 @@ out_dropref:
 	}
 	spin_unlock(ptl);
 
+out_unlock:
 	unlock_page(page);
 	put_page(page);
 	return 0;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
