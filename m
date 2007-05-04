Message-Id: <20070504103201.289858346@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:16 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 25/40] nfs: remove mempools
Content-Disposition: inline; filename=nfs-no-mempool.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

With the introduction of the shared dirty page accounting in .19, NFS should
not be able to surpise the VM with all dirty pages. Thus it should always be
able to free some memory. Hence no more need for mempools.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/read.c  |   15 +++------------
 fs/nfs/write.c |   27 +++++----------------------
 2 files changed, 8 insertions(+), 34 deletions(-)

Index: linux-2.6-git/fs/nfs/read.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/read.c
+++ linux-2.6-git/fs/nfs/read.c
@@ -33,13 +33,10 @@ static const struct rpc_call_ops nfs_rea
 static const struct rpc_call_ops nfs_read_full_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
-static mempool_t *nfs_rdata_mempool;
-
-#define MIN_POOL_READ	(32)
 
 struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 {
-	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_NOFS);
+	struct nfs_read_data *p = kmem_cache_alloc(nfs_rdata_cachep, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -50,7 +47,7 @@ struct nfs_read_data *nfs_readdata_alloc
 		else {
 			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
 			if (!p->pagevec) {
-				mempool_free(p, nfs_rdata_mempool);
+				kmem_cache_free(nfs_rdata_cachep, p);
 				p = NULL;
 			}
 		}
@@ -63,7 +60,7 @@ static void nfs_readdata_rcu_free(struct
 	struct nfs_read_data *p = container_of(head, struct nfs_read_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
-	mempool_free(p, nfs_rdata_mempool);
+	kmem_cache_free(nfs_rdata_cachep, p);
 }
 
 static void nfs_readdata_free(struct nfs_read_data *rdata)
@@ -590,16 +587,10 @@ int __init nfs_init_readpagecache(void)
 	if (nfs_rdata_cachep == NULL)
 		return -ENOMEM;
 
-	nfs_rdata_mempool = mempool_create_slab_pool(MIN_POOL_READ,
-						     nfs_rdata_cachep);
-	if (nfs_rdata_mempool == NULL)
-		return -ENOMEM;
-
 	return 0;
 }
 
 void nfs_destroy_readpagecache(void)
 {
-	mempool_destroy(nfs_rdata_mempool);
 	kmem_cache_destroy(nfs_rdata_cachep);
 }
Index: linux-2.6-git/fs/nfs/write.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/write.c
+++ linux-2.6-git/fs/nfs/write.c
@@ -29,9 +29,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-#define MIN_POOL_WRITE		(32)
-#define MIN_POOL_COMMIT		(4)
-
 /*
  * Local function declarations
  */
@@ -45,12 +42,10 @@ static const struct rpc_call_ops nfs_wri
 static const struct rpc_call_ops nfs_commit_ops;
 
 static struct kmem_cache *nfs_wdata_cachep;
-static mempool_t *nfs_wdata_mempool;
-static mempool_t *nfs_commit_mempool;
 
 struct nfs_write_data *nfs_commit_alloc(void)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -64,7 +59,7 @@ void nfs_commit_rcu_free(struct rcu_head
 	struct nfs_write_data *p = container_of(head, struct nfs_write_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
-	mempool_free(p, nfs_commit_mempool);
+	kmem_cache_free(nfs_wdata_cachep, p);
 }
 
 void nfs_commit_free(struct nfs_write_data *wdata)
@@ -74,7 +69,7 @@ void nfs_commit_free(struct nfs_write_da
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -85,7 +80,7 @@ struct nfs_write_data *nfs_writedata_all
 		else {
 			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
 			if (!p->pagevec) {
-				mempool_free(p, nfs_wdata_mempool);
+				kmem_cache_free(nfs_wdata_cachep, p);
 				p = NULL;
 			}
 		}
@@ -98,7 +93,7 @@ static void nfs_writedata_rcu_free(struc
 	struct nfs_write_data *p = container_of(head, struct nfs_write_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
-	mempool_free(p, nfs_wdata_mempool);
+	kmem_cache_free(nfs_wdata_cachep, p);
 }
 
 static void nfs_writedata_free(struct nfs_write_data *wdata)
@@ -1465,16 +1460,6 @@ int __init nfs_init_writepagecache(void)
 	if (nfs_wdata_cachep == NULL)
 		return -ENOMEM;
 
-	nfs_wdata_mempool = mempool_create_slab_pool(MIN_POOL_WRITE,
-						     nfs_wdata_cachep);
-	if (nfs_wdata_mempool == NULL)
-		return -ENOMEM;
-
-	nfs_commit_mempool = mempool_create_slab_pool(MIN_POOL_COMMIT,
-						      nfs_wdata_cachep);
-	if (nfs_commit_mempool == NULL)
-		return -ENOMEM;
-
 	/*
 	 * NFS congestion size, scale with available memory.
 	 *
@@ -1500,8 +1485,6 @@ int __init nfs_init_writepagecache(void)
 
 void nfs_destroy_writepagecache(void)
 {
-	mempool_destroy(nfs_commit_mempool);
-	mempool_destroy(nfs_wdata_mempool);
 	kmem_cache_destroy(nfs_wdata_cachep);
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
