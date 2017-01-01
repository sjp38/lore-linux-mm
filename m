Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2F806B0038
	for <linux-mm@kvack.org>; Sun,  1 Jan 2017 07:44:56 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id g12so162295481lfe.5
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 04:44:56 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id r4si36647151lff.18.2017.01.01.04.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jan 2017 04:44:55 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id x140so23886569lfa.2
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 04:44:54 -0800 (PST)
Date: Sun, 1 Jan 2017 13:44:51 +0100
From: Grygorii Maistrenko <grygoriimkd@gmail.com>
Subject: [PATCH v2] slub: do not merge cache if slub_debug contains a
 never-merge flag
Message-ID: <20170101124451.GA4740@lp-laptop-d>
References: <20161222235959.GC6871@lp-laptop-d>
 <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org>
 <20161223190023.GA9644@lp-laptop-d>
 <alpine.DEB.2.20.1612241708280.9536@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1612241708280.9536@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

In case CONFIG_SLUB_DEBUG_ON=n, find_mergeable() gets debug features
from commandline but never checks if there are features from the
SLAB_NEVER_MERGE set.
As a result selected by slub_debug caches are always mergeable if they
have been created without a custom constructor set or without one of the
SLAB_* debug features on.

This moves the SLAB_NEVER_MERGE check below the flags update from
commandline to make sure it won't merge the slab cache if one of the
debug features is on.

Signed-off-by: Grygorii Maistrenko <grygoriimkd@gmail.com>
Reviewed-by: Pekka Enberg <penberg@kernel.org>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/slab_common.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

New in v2:
	- (flags & SLAB_NEVER_MERGE) check is moved down below the flags update
	  as suggested by Christoph Lameter

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 329b03843863..a85a01439490 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -255,7 +255,7 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 {
 	struct kmem_cache *s;
 
-	if (slab_nomerge || (flags & SLAB_NEVER_MERGE))
+	if (slab_nomerge)
 		return NULL;
 
 	if (ctor)
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
