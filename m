Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEC16B030E
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 19:00:05 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id b14so77525131lfg.6
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 16:00:05 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id p21si18042523lfj.229.2016.12.22.16.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 16:00:03 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id d16so5727798lfb.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 16:00:03 -0800 (PST)
Date: Fri, 23 Dec 2016 00:59:59 +0100
From: Grygorii Maistrenko <grygoriimkd@gmail.com>
Subject: [PATCH] slub: do not merge cache if slub_debug contains a
 never-merge flag
Message-ID: <20161222235959.GC6871@lp-laptop-d>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

In case CONFIG_SLUB_DEBUG_ON=n find_mergeable() gets debug features
from commandline but never checks if there are features from the
SLAB_NEVER_MERGE set.
As a result selected by slub_debug caches are always mergeable if they
have been created without a custom constructor set or without one of the
SLAB_* debug features on.

This adds the necessary check and makes selected slab caches unmergeable
if one of the SLAB_NEVER_MERGE features is set from commandline.

Signed-off-by: Grygorii Maistrenko <grygoriimkd@gmail.com>
---
 mm/slab_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 329b03843863..7341cba8c58b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -266,6 +266,9 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 	size = ALIGN(size, align);
 	flags = kmem_cache_flags(size, flags, name, NULL);
 
+	if (flags & SLAB_NEVER_MERGE)
+		return NULL;
+
 	list_for_each_entry_reverse(s, &slab_caches, list) {
 		if (slab_unmergeable(s))
 			continue;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
