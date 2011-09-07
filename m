Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 38CEE6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:20:58 -0400 (EDT)
Subject: [PATCH] slub: code optimze in get_partial_node()
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1315357399.31737.49.camel@debian>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Sep 2011 10:26:36 +0800
Message-ID: <1315362396.31737.151.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

I find a way to reduce a variable in get_partial_node(). That is also
helpful for code understanding. :)

This patch base on 'slub/partial' head of penberg's tree.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/slub.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ebb3865..8f68757 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1600,7 +1600,6 @@ static void *get_partial_node(struct kmem_cache *s,
 {
 	struct page *page, *page2;
 	void *object = NULL;
-	int count = 0;
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
@@ -1613,17 +1612,16 @@ static void *get_partial_node(struct kmem_cache *s,
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
-		void *t = acquire_slab(s, n, page, count == 0);
+		void *t = acquire_slab(s, n, page, object == NULL);
 		int available;
 
 		if (!t)
 			break;
 
-		if (!count) {
+		if (!object) {
 			c->page = page;
 			c->node = page_to_nid(page);
 			stat(s, ALLOC_FROM_PARTIAL);
-			count++;
 			object = t;
 			available =  page->objects - page->inuse;
 		} else {
-- 
1.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
