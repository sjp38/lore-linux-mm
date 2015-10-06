Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1910782F6F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:24:59 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so157468986wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:24:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq6si22324796wib.110.2015.10.06.02.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:52 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 5/7] IB/mthca: Convert mthca_map_user_db() to use get_user_pages_fast()
Date: Tue,  6 Oct 2015 11:24:28 +0200
Message-Id: <1444123470-4932-6-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org

From: Jan Kara <jack@suse.cz>

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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
