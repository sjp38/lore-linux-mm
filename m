Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6BEBF6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:39:44 -0400 (EDT)
Subject: [PATCH 2/2] slub: continue to seek slab in node partial if met a
 null page
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1315362396.31737.151.camel@debian>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>  <1315362396.31737.151.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Sep 2011 10:45:26 +0800
Message-ID: <1315363526.31737.164.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

In the per cpu partial slub, we may add a full page into node partial
list. like the following scenario:

	cpu1     		        	cpu2 
    in unfreeze_partials	           in __slab_alloc
	...
   add_partial(n, page, 1);
					alloced from cpu partial, and 
					set frozen = 1.
   second cmpxchg_double_slab()
   set frozen = 0

If it happen, we'd better to skip the full page and to seek next slab in
node partial instead of jump to other nodes.

This patch base on 'slub/partial' head of penberg's tree, and following
code optimize of get_partial_node() patch. 

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8f68757..6fca71c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1616,7 +1616,7 @@ static void *get_partial_node(struct kmem_cache *s,
 		int available;
 
 		if (!t)
-			break;
+			continue;
 
 		if (!object) {
 			c->page = page;
-- 
1.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
