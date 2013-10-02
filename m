Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 51A919C0003
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:05 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so992782pdi.33
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:04 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/26] lustre: Convert ll_get_user_pages() to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:51 +0200
Message-Id: <1380724087-13927-11-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Greg Kroah-Hartman <greg@kroah.com>, Peng Tao <tao.peng@emc.com>, Andreas Dilger <andreas.dilger@intel.com>, hpdd-discuss@lists.01.org

CC: Greg Kroah-Hartman <greg@kroah.com>
CC: Peng Tao <tao.peng@emc.com>
CC: Andreas Dilger <andreas.dilger@intel.com>
CC: hpdd-discuss@lists.01.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/staging/lustre/lustre/llite/rw26.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 96c29ad2fc8c..7e3e0967993b 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -202,11 +202,8 @@ static inline int ll_get_user_pages(int rw, unsigned long user_addr,
 
 	OBD_ALLOC_LARGE(*pages, *max_pages * sizeof(**pages));
 	if (*pages) {
-		down_read(&current->mm->mmap_sem);
-		result = get_user_pages(current, current->mm, user_addr,
-					*max_pages, (rw == READ), 0, *pages,
-					NULL);
-		up_read(&current->mm->mmap_sem);
+		result = get_user_pages_fast(user_addr, *max_pages,
+					     (rw == READ), *pages);
 		if (unlikely(result <= 0))
 			OBD_FREE_LARGE(*pages, *max_pages * sizeof(**pages));
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
