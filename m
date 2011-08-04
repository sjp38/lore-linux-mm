Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D188F900137
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 23:05:28 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 3/4] sparse: using kzalloc to clean up code
Date: Thu, 4 Aug 2011 11:09:49 +0800
Message-ID: <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com, Bob Liu <lliubbo@gmail.com>

This patch using kzalloc to clean up sparse_index_alloc() and
__GFP_ZERO to clean up __kmalloc_section_memmap().

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/sparse.c |   24 +++++++-----------------
 1 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 858e1df..9596635 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -65,15 +65,12 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 
 	if (slab_is_available()) {
 		if (node_state(nid, N_HIGH_MEMORY))
-			section = kmalloc_node(array_size, GFP_KERNEL, nid);
+			section = kzalloc_node(array_size, GFP_KERNEL, nid);
 		else
-			section = kmalloc(array_size, GFP_KERNEL);
+			section = kzalloc(array_size, GFP_KERNEL);
 	} else
 		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
 
-	if (section)
-		memset(section, 0, array_size);
-
 	return section;
 }
 
@@ -636,19 +633,12 @@ static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 	struct page *page, *ret;
 	unsigned long memmap_size = sizeof(struct page) * nr_pages;
 
-	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
+	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN|__GFP_ZERO,
+					get_order(memmap_size));
 	if (page)
-		goto got_map_page;
-
-	ret = vmalloc(memmap_size);
-	if (ret)
-		goto got_map_ptr;
-
-	return NULL;
-got_map_page:
-	ret = (struct page *)pfn_to_kaddr(page_to_pfn(page));
-got_map_ptr:
-	memset(ret, 0, memmap_size);
+		ret = (struct page *)pfn_to_kaddr(page_to_pfn(page));
+	else
+		ret = vzalloc(memmap_size);
 
 	return ret;
 }
-- 
1.6.3.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
