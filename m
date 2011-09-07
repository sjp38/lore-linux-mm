Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F2DF06B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 20:57:37 -0400 (EDT)
Subject: [PATCH] slub Discard slab page only when node partials > minimum
 setting
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1109061914440.18646@router.home>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Sep 2011 09:03:19 +0800
Message-ID: <1315357399.31737.49.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

Unfreeze_partials may try to discard slab page, the discarding condition
should be 'when node partials number > minimum partial number setting',
not '<' in current code.

This patch base on penberg's tree's 'slub/partial' head. 

git://git.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git 

Signed-off-by: Alex Shi <alex.shi@intel.com>

---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b351480..66a5b29 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1954,7 +1954,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 
 			new.frozen = 0;
 
-			if (!new.inuse && (!n || n->nr_partial < s->min_partial))
+			if (!new.inuse && (!n || n->nr_partial > s->min_partial))
 				m = M_FREE;
 			else {
 				struct kmem_cache_node *n2 = get_node(s,
-- 
1.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
