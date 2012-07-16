Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 58A796B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:16:08 -0400 (EDT)
Received: by yenr5 with SMTP id r5so6293951yen.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:16:07 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 4] mm: fix possible incorrect return value of move_pages() syscall
Date: Tue, 17 Jul 2012 02:14:49 +0900
Message-Id: <1342458889-19090-1-git-send-email-js1304@gmail.com>
In-Reply-To: <1342455272-32703-1-git-send-email-js1304@gmail.com>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
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
index 294d52a..adabaf4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1171,7 +1171,7 @@ set_status:
 	}
 
 	up_read(&mm->mmap_sem);
-	return err;
+	return err > 0 ? -EIO : err;
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
