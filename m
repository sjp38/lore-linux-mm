Date: Thu, 8 Nov 2007 07:56:33 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] nfs: use GFP_NOFS preloads for radix-tree insertion
Message-ID: <20071108065633.GB28216@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de> <20071107170923.6cf3c389.akpm@linux-foundation.org> <20071108013723.GF3227@wotan.suse.de> <20071107190254.4e65812a.akpm@linux-foundation.org> <20071108031645.GI3227@wotan.suse.de> <20071107201242.390aec38.akpm@linux-foundation.org> <20071108045404.GJ3227@wotan.suse.de> <20071107210204.62070047.akpm@linux-foundation.org> <20071108054445.GA20162@wotan.suse.de> <20071107220200.85e9cb59.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107220200.85e9cb59.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, davem@davemloft.net, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Here is the NFS version. I guess Trond should ack it before you pick it
up.

--

NFS should use GFP_NOFS mode radix tree preloads rather than GFP_ATOMIC
allocations at radix-tree insertion-time. This is important to reduce the
atomic memory requirement.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -363,15 +363,13 @@ int nfs_writepages(struct address_space 
 /*
  * Insert a write request into an inode
  */
-static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
+static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int error;
 
 	error = radix_tree_insert(&nfsi->nfs_page_tree, req->wb_index, req);
-	BUG_ON(error == -EEXIST);
-	if (error)
-		return error;
+	BUG_ON(error);
 	if (!nfsi->npages) {
 		igrab(inode);
 		if (nfs_have_delegation(inode, FMODE_WRITE))
@@ -381,7 +379,6 @@ static int nfs_inode_add_request(struct 
 	set_page_private(req->wb_page, (unsigned long)req);
 	nfsi->npages++;
 	kref_get(&req->wb_kref);
-	return 0;
 }
 
 /*
@@ -593,6 +590,13 @@ static struct nfs_page * nfs_update_requ
 		/* Loop over all inode entries and see if we find
 		 * A request for the page we wish to update
 		 */
+		if (new) {
+			if (radix_tree_preload(GFP_NOFS)) {
+				nfs_release_request(new);
+				return ERR_PTR(-ENOMEM);
+			}
+		}
+
 		spin_lock(&inode->i_lock);
 		req = nfs_page_find_request_locked(page);
 		if (req) {
@@ -603,28 +607,27 @@ static struct nfs_page * nfs_update_requ
 				error = nfs_wait_on_request(req);
 				nfs_release_request(req);
 				if (error < 0) {
-					if (new)
+					if (new) {
+						radix_tree_preload_end();
 						nfs_release_request(new);
+					}
 					return ERR_PTR(error);
 				}
 				continue;
 			}
 			spin_unlock(&inode->i_lock);
-			if (new)
+			if (new) {
+				radix_tree_preload_end();
 				nfs_release_request(new);
+			}
 			break;
 		}
 
 		if (new) {
-			int error;
 			nfs_lock_request_dontget(new);
-			error = nfs_inode_add_request(inode, new);
-			if (error) {
-				spin_unlock(&inode->i_lock);
-				nfs_unlock_request(new);
-				return ERR_PTR(error);
-			}
+			nfs_inode_add_request(inode, new);
 			spin_unlock(&inode->i_lock);
+			radix_tree_preload_end();
 			req = new;
 			goto zero_page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
