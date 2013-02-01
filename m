Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 186826B0012
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 05:44:08 -0500 (EST)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 08/18] gfs2: use ->invalidatepage() length argument
Date: Fri,  1 Feb 2013 11:43:34 +0100
Message-Id: <1359715424-32318-9-git-send-email-lczerner@redhat.com>
In-Reply-To: <1359715424-32318-1-git-send-email-lczerner@redhat.com>
References: <1359715424-32318-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, xfs@oss.sgi.com, Lukas Czerner <lczerner@redhat.com>

->invalidatepage() aop now accepts range to invalidate so we can make
use of it in gfs2_invalidatepage().

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/gfs2/aops.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 5bd558c..3cf3dc8 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -949,24 +949,29 @@ static void gfs2_invalidatepage(struct page *page, unsigned int offset,
 				unsigned int length)
 {
 	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
+	unsigned int stop = offset + length;
+	int partial_page = (offset || length < PAGE_CACHE_SIZE);
 	struct buffer_head *bh, *head;
 	unsigned long pos = 0;
 
 	BUG_ON(!PageLocked(page));
-	if (offset == 0)
+	if (!partial_page)
 		ClearPageChecked(page);
 	if (!page_has_buffers(page))
 		goto out;
 
 	bh = head = page_buffers(page);
 	do {
+		if (pos + bh->b_size > stop)
+			return;
+
 		if (offset <= pos)
 			gfs2_discard(sdp, bh);
 		pos += bh->b_size;
 		bh = bh->b_this_page;
 	} while (bh != head);
 out:
-	if (offset == 0)
+	if (!partial_page)
 		try_to_release_page(page, 0);
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
