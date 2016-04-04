Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBF06B0290
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 13:14:03 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id bc4so169337223lbc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 10:14:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j131si3394279wma.16.2016.04.04.10.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 10:14:00 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] mm: filemap: only do access activations on reads
Date: Mon,  4 Apr 2016 13:13:37 -0400
Message-Id: <1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Andres Freund observed that his database workload is struggling with
the transaction journal creating pressure on frequently read pages.

Access patterns like transaction journals frequently write the same
pages over and over, but in the majority of cases those pages are
never read back. There are no caching benefits to be had for those
pages, so activating them and having them put pressure on pages that
do benefit from caching is a bad choice.

Leave page activations to read accesses and don't promote pages based
on writes alone.

It could be said that partially written pages do contain cache-worthy
data, because even if *userspace* does not access the unwritten part,
the kernel still has to read it from the filesystem for correctness.
However, a counter argument is that these pages enjoy at least *some*
protection over other inactive file pages through the writeback cache,
in the sense that dirty pages are written back with a delay and cache
reclaim leaves them alone until they have been written back to
disk. Should that turn out to be insufficient and we see increased
read IO from partial writes under memory pressure, we can always go
back and update grab_cache_page_write_begin() to take (pos, len) so
that it can tell partial writes from pages that don't need partial
reads. But for now, keep it simple.

Reported-by: Andres Freund <andres@anarazel.de>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ca33816..edfec5e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2579,7 +2579,7 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 					pgoff_t index, unsigned flags)
 {
 	struct page *page;
-	int fgp_flags = FGP_LOCK|FGP_ACCESSED|FGP_WRITE|FGP_CREAT;
+	int fgp_flags = FGP_LOCK|FGP_WRITE|FGP_CREAT;
 
 	if (flags & AOP_FLAG_NOFS)
 		fgp_flags |= FGP_NOFS;
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
