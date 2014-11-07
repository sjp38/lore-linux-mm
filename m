Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id BB21C800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 14:34:46 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so4507571wgh.13
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 11:34:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cq10si4535443wib.98.2014.11.07.11.34.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Nov 2014 11:34:45 -0800 (PST)
Message-ID: <1415388857.12094.2.camel@linux-t7sj.site>
Subject: [PATCH -next] mm/rmap: calculate page offset when needed
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 07 Nov 2014 11:34:17 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>

Call page_to_pgoff() to get the page offset once we are
sure we actually need it, and any very obvious initial
function checks have passed. Trivial micro-optimization,
and potentially save some cycles.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/rmap.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index a5e9cc6..e3354b2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1633,7 +1633,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
 static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1641,6 +1641,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 	if (!anon_vma)
 		return ret;
 
+	pgoff = page_to_pgoff(page);
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
@@ -1674,7 +1675,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff;
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
@@ -1689,6 +1690,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	if (!mapping)
 		return ret;
 
+	pgoff = page_to_pgoff(page);
 	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-- 
1.8.4.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
