Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 19F5E6B0069
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 13:57:07 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so6139790pbb.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 10:57:06 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value of move_pages() syscall
Date: Sat, 28 Jul 2012 02:55:03 +0900
Message-Id: <1343411703-2720-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1343411703-2720-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1343411703-2720-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Brice Goglin <brice@myri.com>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan@kernel.org>

move_pages() syscall may return success in case that
do_move_page_to_node_array return positive value which means migration failed.
This patch changes return value of do_move_page_to_node_array
for not returning positive value. It can fix the problem.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Brice Goglin <brice@myri.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan@kernel.org>

diff --git a/mm/migrate.c b/mm/migrate.c
index f495c58..eeaf409 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1172,7 +1172,7 @@ set_status:
 	}
 
 	up_read(&mm->mmap_sem);
-	return err;
+	return err > 0 ? -EBUSY : err;
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
