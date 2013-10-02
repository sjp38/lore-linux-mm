Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4412D9C000A
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:06 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so947933pdj.36
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:05 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 25/26] ib: Convert mthca_map_user_db() to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:28:06 +0200
Message-Id: <1380724087-13927-26-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org

Function mthca_map_user_db() appears to call get_user_pages() without
holding mmap_sem. Fix the bug by using get_user_pages_fast() instead
which also takes care of the locking.

CC: Roland Dreier <roland@kernel.org>
CC: linux-rdma@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/infiniband/hw/mthca/mthca_memfree.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 7d2e42dd6926..c3543b27a2a7 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,8 +472,7 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages(current, current->mm, uaddr & PAGE_MASK, 1, 1, 0,
-			     pages, NULL);
+	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, 1, pages);
 	if (ret < 0)
 		goto out;
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
