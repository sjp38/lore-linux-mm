Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id D3C739C0007
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:06 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so945343pbb.24
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:06 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 12/26] pvr2fb: Convert pvr2fb_write() to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:53 +0200
Message-Id: <1380724087-13927-13-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-fbdev@vger.kernel.org, Tomi Valkeinen <tomi.valkeinen@ti.com>, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>

CC: linux-fbdev@vger.kernel.org
CC: Tomi Valkeinen <tomi.valkeinen@ti.com>
CC: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/video/pvr2fb.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/video/pvr2fb.c b/drivers/video/pvr2fb.c
index df07860563e6..31e1345a88a8 100644
--- a/drivers/video/pvr2fb.c
+++ b/drivers/video/pvr2fb.c
@@ -686,11 +686,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 	if (!pages)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm, (unsigned long)buf,
-			     nr_pages, WRITE, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
-
+	ret = get_user_pages_fast((unsigned long)buf, nr_pages, WRITE, pages);
 	if (ret < nr_pages) {
 		nr_pages = ret;
 		ret = -EINVAL;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
