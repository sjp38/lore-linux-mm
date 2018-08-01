Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A27F6B0008
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:04:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so17805764ois.21
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:04:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e66-v6si11529738oif.85.2018.08.01.13.04.23
        for <linux-mm@kvack.org>;
        Wed, 01 Aug 2018 13:04:23 -0700 (PDT)
From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [RFC 2/2] mm: harden alloc_pages code paths against bogus nodes
Date: Wed,  1 Aug 2018 15:04:18 -0500
Message-Id: <20180801200418.1325826-3-jeremy.linton@arm.com>
In-Reply-To: <20180801200418.1325826-1-jeremy.linton@arm.com>
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org, Jeremy Linton <jeremy.linton@arm.com>

Its possible to crash __alloc_pages_nodemask by passing it
bogus node ids. This is caused by NODE_DATA() returning null
(hopefully) when the requested node is offline. We can
harded against the basic case of a mostly valid node, that
isn't online by checking for null and failing prepare_alloc_pages.

But this then suggests we should also harden NODE_DATA() like this

#define NODE_DATA(nid)         ( (nid) < MAX_NUMNODES ? node_data[(nid)] : NULL)

eventually this starts to add a bunch of generally uneeded checks
in some code paths that are called quite frequently.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 include/linux/gfp.h | 2 ++
 mm/page_alloc.c     | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index a6afcec53795..17d70271c42e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -436,6 +436,8 @@ static inline int gfp_zonelist(gfp_t flags)
  */
 static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 {
+	if (unlikely(!NODE_DATA(nid))) //VM_WARN_ON?
+		return NULL;
 	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a790ef4be74e..3a3d9ac2662a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4306,6 +4306,8 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 {
 	ac->high_zoneidx = gfp_zone(gfp_mask);
 	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
+	if (!ac->zonelist)
+		return false;
 	ac->nodemask = nodemask;
 	ac->migratetype = gfpflags_to_migratetype(gfp_mask);
 
-- 
2.14.3
