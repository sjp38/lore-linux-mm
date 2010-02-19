Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3DC7C6B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 20:17:26 -0500 (EST)
From: Yehuda Sadeh <yehuda@hq.newdream.net>
Subject: [PATCH 1/1] mm: invalidate_mapping_pages checks boundaries when lock fails
Date: Thu, 18 Feb 2010 17:22:17 -0800
Message-Id: <1266542537-5040-1-git-send-email-yehuda@hq.newdream.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Yehuda Sadeh <yehuda@hq.newdream.net>, linux-btrfs@vger.kernel.org, sage@newdream.net
List-ID: <linux-mm.kvack.org>

Not sure that I'm not missing something obvious. When invalidate_mapping_pages
fails to lock the page, we continue to the next iteration, skipping the
next > end check. This can lead to a case where we invalidate a page that is
beyond the requested boundaries. Currently there are two callers that might be
affected, one is btrfs and the second one is the fadvice syscall.
Does that look right, or am I just missing something?

------

[PATCH 1/1] mm: invalidate_mapping_pages checks boundaries when lock fails

When we failed to lock the page, we continued to the next
iteration, skipping the next > end check. This might cause
throwing away a page that is beyond the requested boundaries.

Signed-off-by: Yehuda Sadeh <yehuda@hq.newdream.net>
---
 mm/truncate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 450cebd..abb67d4 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -345,11 +345,12 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				next = index;
 			next++;
 			if (lock_failed)
-				continue;
+				goto unlocked;
 
 			ret += invalidate_inode_page(page);
 
 			unlock_page(page);
+unlocked:
 			if (next > end)
 				break;
 		}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
