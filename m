Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 676E0900001
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:04 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so974669pdj.40
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:04 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/26] crystalhd: Convert crystalhd_map_dio() to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:50 +0200
Message-Id: <1380724087-13927-10-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Naren Sankar <nsankar@broadcom.com>, Jarod Wilson <jarod@wilsonet.com>, Scott Davilla <davilla@4pi.com>, Manu Abraham <abraham.manu@gmail.com>

CC: Naren Sankar <nsankar@broadcom.com>
CC: Jarod Wilson <jarod@wilsonet.com>
CC: Scott Davilla <davilla@4pi.com>
CC: Manu Abraham <abraham.manu@gmail.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/staging/crystalhd/crystalhd_misc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/crystalhd/crystalhd_misc.c b/drivers/staging/crystalhd/crystalhd_misc.c
index 51f698052aff..f2d350985e46 100644
--- a/drivers/staging/crystalhd/crystalhd_misc.c
+++ b/drivers/staging/crystalhd/crystalhd_misc.c
@@ -751,10 +751,7 @@ enum BC_STATUS crystalhd_map_dio(struct crystalhd_adp *adp, void *ubuff,
 		}
 	}
 
-	down_read(&current->mm->mmap_sem);
-	res = get_user_pages(current, current->mm, uaddr, nr_pages, rw == READ,
-			     0, dio->pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	res = get_user_pages_fast(uaddr, nr_pages, rw == READ, dio->pages);
 
 	/* Save for release..*/
 	dio->sig = crystalhd_dio_locked;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
