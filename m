Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A9E5E6B003C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:14:51 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v3 07/18] ceph: use ->invalidatepage() length argument
Date: Tue,  9 Apr 2013 11:14:16 +0200
Message-Id: <1365498867-27782-8-git-send-email-lczerner@redhat.com>
In-Reply-To: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>, ceph-devel@vger.kernel.org

->invalidatepage() aop now accepts range to invalidate so we can make
use of it in ceph_invalidatepage().

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: ceph-devel@vger.kernel.org
---
 fs/ceph/addr.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 168a35a..d953afd 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -164,20 +164,20 @@ static void ceph_invalidatepage(struct page *page, unsigned int offset,
 	if (!PageDirty(page))
 		pr_err("%p invalidatepage %p page not dirty\n", inode, page);
 
-	if (offset == 0)
+	if (offset == 0 && length == PAGE_CACHE_SIZE)
 		ClearPageChecked(page);
 
 	ci = ceph_inode(inode);
-	if (offset == 0) {
-		dout("%p invalidatepage %p idx %lu full dirty page %u\n",
-		     inode, page, page->index, offset);
+	if (offset == 0 && length == PAGE_CACHE_SIZE) {
+		dout("%p invalidatepage %p idx %lu full dirty page\n",
+		     inode, page, page->index);
 		ceph_put_wrbuffer_cap_refs(ci, 1, snapc);
 		ceph_put_snap_context(snapc);
 		page->private = 0;
 		ClearPagePrivate(page);
 	} else {
-		dout("%p invalidatepage %p idx %lu partial dirty page\n",
-		     inode, page, page->index);
+		dout("%p invalidatepage %p idx %lu partial dirty page %u(%u)\n",
+		     inode, page, page->index, offset, length);
 	}
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
