Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD3566B0264
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:27:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y138so34560085wme.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:27:25 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id q6si16637291wjr.172.2016.10.24.08.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 08:27:24 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d199so10354727wmd.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:27:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [Stable 4.4 - NEEDS REVIEW - 3/3] mm: filemap: fix mapping->nrpages double accounting in fuse
Date: Mon, 24 Oct 2016 17:26:05 +0200
Message-Id: <20161024152605.11707-4-mhocko@kernel.org>
In-Reply-To: <20161024152605.11707-1-mhocko@kernel.org>
References: <20161024152605.11707-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Johannes Weiner <hannes@cmpxchg.org>

Commit 3ddf40e8c31964b744ff10abb48c8e36a83ec6e7 upstream.

Commit 22f2ac51b6d6 ("mm: workingset: fix crash in shadow node shrinker
caused by replace_page_cache_page()") switched replace_page_cache() from
raw radix tree operations to page_cache_tree_insert() but didn't take
into account that the latter function, unlike the raw radix tree op,
handles mapping->nrpages.  As a result, that counter is bumped for each
page replacement rather than balanced out even.

The mapping->nrpages counter is used to skip needless radix tree walks
when invalidating, truncating, syncing inodes without pages, as well as
statistics for userspace.  Since the error is positive, we'll do more
page cache tree walks than necessary; we won't miss a necessary one.
And we'll report more buffer pages to userspace than there are.  The
error is limited to fuse inodes.

Fixes: 22f2ac51b6d6 ("mm: workingset: fix crash in shadow node shrinker caused by replace_page_cache_page()")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: stable@vger.kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/filemap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c9c19c12f61d..8675ce8a8f87 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -578,7 +578,6 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		__delete_from_page_cache(old, NULL, memcg);
 		error = page_cache_tree_insert(mapping, new, NULL);
 		BUG_ON(error);
-		mapping->nrpages++;
 
 		/*
 		 * hugetlb pages do not participate in page cache accounting.
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
