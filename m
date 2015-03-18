Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B91B16B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:10:39 -0400 (EDT)
Received: by wixw10 with SMTP id w10so64563135wix.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:10:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si3854906wix.67.2015.03.18.07.10.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:10:37 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in page_cache_read
Date: Wed, 18 Mar 2015 15:09:26 +0100
Message-Id: <1426687766-518-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

page_cache_read has been historically using page_cache_alloc_cold to
allocate a new page. This means that mapping_gfp_mask is used as the
base for the gfp_mask. Many filesystems are setting this mask to
GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
however, not called from the fs layer so it doesn't need this
protection. Even ceph and ocfs2 which call filemap_fault from their
fault handlers seem to be OK because they are not taking any fs lock
before invoking generic implementation.

The protection might be even harmful. There is a strong push to fail
GFP_NOFS allocations rather than loop within allocator indefinitely with
a very limited reclaim ability. Once we start failing those requests
the OOM killer might be triggered prematurely because the page cache
allocation failure is propagated up the page fault path and end up in
pagefault_out_of_memory.

Use GFP_KERNEL mask instead because it is safe from the reclaim
recursion POV. We are already doing GFP_KERNEL allocations down
add_to_page_cache_lru path.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 968cd8e03d2e..26f62ba79f50 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1752,7 +1752,7 @@ static int page_cache_read(struct file *file, pgoff_t offset)
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = __page_cache_alloc(GFP_KERNEL|__GFP_COLD);
 		if (!page)
 			return -ENOMEM;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
