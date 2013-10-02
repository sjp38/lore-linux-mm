Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A62AD900004
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:05 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1102402pab.29
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:05 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 22/26] ib: Convert ipath_user_sdma_pin_pages() to use get_user_pages_unlocked()
Date: Wed,  2 Oct 2013 16:28:03 +0200
Message-Id: <1380724087-13927-23-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Mike Marciniszyn <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org

Function ipath_user_sdma_queue_pkts() gets called with mmap_sem held for
writing. Except for get_user_pages() deep down in
ipath_user_sdma_pin_pages() we don't seem to need mmap_sem at all. Even
more interestingly the function ipath_user_sdma_queue_pkts() (and also
ipath_user_sdma_coalesce() called somewhat later) call copy_from_user()
which can hit a page fault and we deadlock on trying to get mmap_sem
when handling that fault. So just make ipath_user_sdma_pin_pages() use
get_user_pages_unlocked() and leave mmap_sem locking for mm.

CC: Mike Marciniszyn <infinipath@intel.com>
CC: Roland Dreier <roland@kernel.org>
CC: linux-rdma@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/infiniband/hw/ipath/ipath_user_sdma.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/ipath/ipath_user_sdma.c b/drivers/infiniband/hw/ipath/ipath_user_sdma.c
index f5cb13b21445..462c9b136e85 100644
--- a/drivers/infiniband/hw/ipath/ipath_user_sdma.c
+++ b/drivers/infiniband/hw/ipath/ipath_user_sdma.c
@@ -280,8 +280,8 @@ static int ipath_user_sdma_pin_pages(const struct ipath_devdata *dd,
 	int j;
 	int ret;
 
-	ret = get_user_pages(current, current->mm, addr,
-			     npages, 0, 1, pages, NULL);
+	ret = get_user_pages_unlocked(current, current->mm, addr,
+				      npages, 0, 1, pages);
 
 	if (ret != npages) {
 		int i;
@@ -811,10 +811,7 @@ int ipath_user_sdma_writev(struct ipath_devdata *dd,
 	while (dim) {
 		const int mxp = 8;
 
-		down_write(&current->mm->mmap_sem);
 		ret = ipath_user_sdma_queue_pkts(dd, pq, &list, iov, dim, mxp);
-		up_write(&current->mm->mmap_sem);
-
 		if (ret <= 0)
 			goto done_unlock;
 		else {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
