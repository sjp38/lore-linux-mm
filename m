Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id ACC466B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 18:24:56 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so418584iec.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:24:56 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id fy6si12172213icb.64.2015.02.24.15.24.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 15:24:56 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so31127306igb.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:24:56 -0800 (PST)
Date: Tue, 24 Feb 2015 15:24:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 for-4.0] mm, thp: really limit transparent hugepage
 allocation to local node
In-Reply-To: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Greg Thelen <gthelen@google.com>

Commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
node") restructured alloc_hugepage_vma() with the intent of only
allocating transparent hugepages locally when there was not an effective
interleave mempolicy.

alloc_pages_exact_node() does not limit the allocation to the single
node, however, but rather prefers it.  This is because __GFP_THISNODE is
not set which would cause the node-local nodemask to be passed.  Without
it, only a nodemask that prefers the local node is passed.

Fix this by passing __GFP_THISNODE and falling back to small pages when
the allocation fails.

Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: GFP_THISNODE actually defers compaction and reclaim entirely based on
     the combination of gfp flags.  We want to try compaction and reclaim,
     so only set __GFP_THISNODE.  We still set __GFP_NOWARN to suppress 
     oom warnings in the kernel log when we can simply fallback to small
     pages.

 mm/mempolicy.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1985,7 +1985,10 @@ retry_cpuset:
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(node, gfp, order);
+			page = alloc_pages_exact_node(node, gfp |
+							    __GFP_THISNODE |
+							    __GFP_NOWARN,
+						      order);
 			goto out;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
