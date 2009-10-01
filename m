Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2A16600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:30:24 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 28/31] nfs: fix various memory recursions possible with swap over NFS.
Date: Thu,  1 Oct 2009 19:40:32 +0530
Message-Id: <1254406232-16663-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate IO,
just not of any filesystem data.

The problem is that previuosly NOFS was correct because that avoids
recursion into the NFS code, it now is not, because also IO (swap) can
lead to this recursion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/write.c    |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

Index: mmotm/fs/nfs/write.c
===================================================================
--- mmotm.orig/fs/nfs/write.c
+++ mmotm/fs/nfs/write.c
@@ -48,7 +48,7 @@ static mempool_t *nfs_commit_mempool;
 
 struct nfs_write_data *nfs_commitdata_alloc(void)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
+	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -67,7 +67,7 @@ void nfs_commit_free(struct nfs_write_da
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
+	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -77,7 +77,8 @@ struct nfs_write_data *nfs_writedata_all
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *),
+					GFP_NOIO);
 			if (!p->pagevec) {
 				mempool_free(p, nfs_wdata_mempool);
 				p = NULL;
Index: mmotm/fs/nfs/pagelist.c
===================================================================
--- mmotm.orig/fs/nfs/pagelist.c
+++ mmotm/fs/nfs/pagelist.c
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
