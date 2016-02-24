Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 71CEC6B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 20:38:54 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id b205so15754544wmb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 17:38:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t10si671340wjf.128.2016.02.23.17.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 17:38:53 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: readahead: do not cap readahead() and MADV_WILLNEED
Date: Tue, 23 Feb 2016 17:38:47 -0800
Message-Id: <1456277927-12044-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

All readahead is currently capped to a maximum of the device readahead
limit, which defaults to 128k. For heuristics-based readahead this
makes perfect sense, too, but unfortunately the limit is also applied
to the explicit readahead() or madvise(MADV_WILLNEED) syscalls, and
128k is an awfully low limit, particularly for bigger machines. It's
not unreasonable for a user on a 100G machine to say, read this 1G
file, and read it now, I'm going to access the whole thing shortly.

Since both readahead() and MADV_WILLNEED take an explicit length
parameter, it seems weird to truncate that request quietly. Just do
what the user asked for and leave the limiting to the heuristics.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/readahead.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 20e58e8..6d182db 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -212,7 +212,6 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
 
-	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
 	while (nr_to_read) {
 		int err;
 
@@ -485,6 +484,7 @@ void page_cache_sync_readahead(struct address_space *mapping,
 
 	/* be dumb */
 	if (filp && (filp->f_mode & FMODE_RANDOM)) {
+		req_size = min(req_size, inode_to_bdi(mapping->host)->ra_pages);
 		force_page_cache_readahead(mapping, filp, offset, req_size);
 		return;
 	}
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
