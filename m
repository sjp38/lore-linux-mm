Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B03F6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 12:17:22 -0400 (EDT)
Received: by ywf7 with SMTP id 7so1763590ywf.33
        for <linux-mm@kvack.org>; Mon, 31 Oct 2011 09:17:16 -0700 (PDT)
From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [PATCH] fadvise: only initiate writeback for specified range with FADV_DONTNEED
Date: Mon, 31 Oct 2011 11:16:59 -0500
Message-Id: <1320077819-1494-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Shawn Bohrer <sbohrer@rgmadvisors.com>

Previously POSIX_FADV_DONTNEED would start writeback for the entire file
when the bdi was not write congested.  This negatively impacts
performance if the file contians dirty pages outside of the requested
range.  This change uses __filemap_fdatawrite_range() to only initiate
writeback for the requested range.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 mm/fadvise.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 8d723c9..469491e 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -117,7 +117,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		break;
 	case POSIX_FADV_DONTNEED:
 		if (!bdi_write_congested(mapping->backing_dev_info))
-			filemap_flush(mapping);
+			__filemap_fdatawrite_range(mapping, offset, endbyte,
+						   WB_SYNC_NONE);
 
 		/* First and last FULL page! */
 		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
-- 
1.7.6



---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
