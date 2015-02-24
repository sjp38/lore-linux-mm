Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2204E6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:24:55 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so36171913ieb.7
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:24:54 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id g7si935809icm.27.2015.02.24.14.24.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 14:24:54 -0800 (PST)
Received: by mail-ig0-f171.google.com with SMTP id h15so30736947igd.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:24:54 -0800 (PST)
Date: Tue, 24 Feb 2015 14:24:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-4.0] mm, thp: really limit transparent hugepage allocation
 to local node
Message-ID: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com>
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
 mm/mempolicy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1985,7 +1985,8 @@ retry_cpuset:
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(node, gfp, order);
+			page = alloc_pages_exact_node(node, gfp | GFP_THISNODE,
+						      order);
 			goto out;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
