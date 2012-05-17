Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 32A776B010A
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:51:42 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/12] nfs: Prevent page allocator recursions with swap over NFS.
Date: Thu, 17 May 2012 15:51:24 +0100
Message-Id: <1337266285-8102-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1337266285-8102-1-git-send-email-mgorman@suse.de>
References: <1337266285-8102-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate
IO, just not of any filesystem data.

The problem is that previously NOFS was correct because that avoids
recursion into the NFS code. With swap-over-NFS, it is no longer
correct as swap IO can lead to this recursion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/write.c    |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 77aa83e..8e80d71 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -29,7 +29,7 @@ static struct kmem_cache *nfs_page_cachep;
 static inline struct nfs_page *
 nfs_page_alloc(void)
 {
-	struct nfs_page	*p = kmem_cache_zalloc(nfs_page_cachep, GFP_KERNEL);
+	struct nfs_page	*p = kmem_cache_zalloc(nfs_page_cachep, GFP_NOIO);
 	if (p)
 		INIT_LIST_HEAD(&p->wb_list);
 	return p;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 21cfe71..abdbe61 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -52,7 +52,7 @@ static mempool_t *nfs_commit_mempool;
 
 struct nfs_write_data *nfs_commitdata_alloc(void)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
+	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -72,7 +72,7 @@ EXPORT_SYMBOL_GPL(nfs_commit_free);
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
+	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -81,7 +81,8 @@ struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *),
+					GFP_NOIO);
 			if (!p->pagevec) {
 				mempool_free(p, nfs_wdata_mempool);
 				p = NULL;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
