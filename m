Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3142C6B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 04:09:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w50so634038wrc.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:09:41 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id b30si1421191wrd.184.2017.05.17.01.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 01:09:39 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id g12so537367wrg.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:09:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: clarify why we want kmalloc before falling backto vmallock
Date: Wed, 17 May 2017 10:09:32 +0200
Message-Id: <20170517080932.21423-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

While converting drm_[cm]alloc* helpers to kvmalloc* variants Chris
Wilson has wondered why we want to try kmalloc before vmalloc fallback
even for larger allocations requests. Let's clarify that one larger
physically contiguous block is less likely to fragment memory than many
scattered pages which can prevent more large blocks from being created.

Suggested-by: Chris Wilson <chris@chris-wilson.co.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/util.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index 464df3489903..87499f8119f2 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -357,7 +357,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
 
 	/*
-	 * Make sure that larger requests are not too disruptive - no OOM
+	 * We want to attempt a large physically contiguous block first because
+	 * it is less likely to fragment multiple larger blocks and therefore
+	 * contribute to a long term fragmentation less than vmalloc fallback.
+	 * However make sure that larger requests are not too disruptive - no OOM
 	 * killer and no allocation failure warnings as we have a fallback
 	 */
 	if (size > PAGE_SIZE) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
