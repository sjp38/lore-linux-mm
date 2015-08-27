Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1724D9003C7
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:20:49 -0400 (EDT)
Received: by wicgk12 with SMTP id gk12so10313332wic.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 07:20:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si4398694wjn.1.2015.08.27.07.20.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 07:20:47 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, migrate: count pages failing all retries in vmstat and tracepoint
Date: Thu, 27 Aug 2015 16:20:27 +0200
Message-Id: <1440685227-747-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

Migration tries up to 10 times to migrate pages that return -EAGAIN until it
gives up. If some pages fail all retries, they are counted towards the number
of failed pages that migrate_pages() returns. They should also be counted in
the /proc/vmstat pgmigrate_fail and in the mm_migrate_pages tracepoint.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/migrate.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index eb42671..e705324 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1152,7 +1152,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 			}
 		}
 	}
-	rc = nr_failed + retry;
+	nr_failed += retry;
+	rc = nr_failed;
 out:
 	if (nr_succeeded)
 		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
