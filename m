Message-Id: <20080724141531.486682621@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:01:12 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 30/30] nfs: fix various memory recursions possible with swap over NFS.
Content-Disposition: inline; filename=nfs-alloc-recursions.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

GFP_NOFS is not enough, since swap traffic is IO, hence fall back to GFP_NOIO.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/write.c    |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -45,7 +45,7 @@ static struct kmem_cache *nfs_wdata_cach
 
 struct nfs_write_data *nfs_commitdata_alloc(void)
 {
-	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -63,7 +63,7 @@ void nfs_commit_free(struct nfs_write_da
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -72,7 +72,7 @@ struct nfs_write_data *nfs_writedata_all
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOIO);
 			if (!p->pagevec) {
 				kmem_cache_free(nfs_wdata_cachep, p);
 				p = NULL;
Index: linux-2.6/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.orig/fs/nfs/pagelist.c
+++ linux-2.6/fs/nfs/pagelist.c
@@ -27,7 +27,7 @@ static inline struct nfs_page *
 nfs_page_alloc(void)
 {
 	struct nfs_page	*p;
-	p = kmem_cache_alloc(nfs_page_cachep, GFP_KERNEL);
+	p = kmem_cache_alloc(nfs_page_cachep, GFP_NOIO);
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->wb_list);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
