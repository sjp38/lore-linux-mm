Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2C00A6B009E
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/12] nfs: Prevent page allocator recursions with swap over NFS.
Date: Thu, 12 Jul 2012 07:41:05 +0100
Message-Id: <1342075266-29593-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate
IO, just not of any filesystem data.

The problem is that previously NOFS was correct because that avoids
recursion into the NFS code. With swap-over-NFS, it is no longer
correct as swap IO can lead to this recursion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/write.c    |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9ef8b3c..7de1646 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -70,7 +70,7 @@ void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos)
 static inline struct nfs_page *
 nfs_page_alloc(void)
 {
-	struct nfs_page	*p = kmem_cache_zalloc(nfs_page_cachep, GFP_KERNEL);
+	struct nfs_page	*p = kmem_cache_zalloc(nfs_page_cachep, GFP_NOIO);
 	if (p)
 		INIT_LIST_HEAD(&p->wb_list);
 	return p;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 974e9c2..211ba65 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -52,7 +52,7 @@ static mempool_t *nfs_commit_mempool;
 
 struct nfs_commit_data *nfs_commitdata_alloc(void)
 {
-	struct nfs_commit_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
+	struct nfs_commit_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -70,7 +70,7 @@ EXPORT_SYMBOL_GPL(nfs_commit_free);
 
 struct nfs_write_header *nfs_writehdr_alloc(void)
 {
-	struct nfs_write_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
+	struct nfs_write_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
 	if (p) {
 		struct nfs_pgio_header *hdr = &p->header;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
