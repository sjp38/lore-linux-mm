Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4FDC16B0071
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:45 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so8348696eei.14
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si28130813eew.198.2014.04.15.21.19.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:44 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 16/19] VFS: use GFP_NOFS rather than GFP_KERNEL in __d_alloc.
Message-ID: <20140416040337.10604.61837.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

__d_alloc can be called with i_mutex held, so it is safer to
use GFP_NOFS.

lockdep reports this can deadlock when loop-back NFS is in use,
as nfsd may be required to write out for reclaim, and nfsd certainly
takes i_mutex.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/dcache.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index ca02c13a84aa..3651ff6185b4 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1483,7 +1483,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	struct dentry *dentry;
 	char *dname;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
+	dentry = kmem_cache_alloc(dentry_cache, GFP_NOFS);
 	if (!dentry)
 		return NULL;
 
@@ -1495,7 +1495,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	 */
 	dentry->d_iname[DNAME_INLINE_LEN-1] = 0;
 	if (name->len > DNAME_INLINE_LEN-1) {
-		dname = kmalloc(name->len + 1, GFP_KERNEL);
+		dname = kmalloc(name->len + 1, GFP_NOFS);
 		if (!dname) {
 			kmem_cache_free(dentry_cache, dentry); 
 			return NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
