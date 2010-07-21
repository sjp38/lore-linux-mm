Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7132B6B02A6
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 22:45:11 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o6L2j8wI018178
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:08 -0700
Received: from pxi18 (pxi18.prod.google.com [10.243.27.18])
	by hpaq6.eem.corp.google.com with ESMTP id o6L2j6OO030628
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:07 -0700
Received: by pxi18 with SMTP id 18so2504448pxi.32
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:06 -0700 (PDT)
Date: Tue, 20 Jul 2010 19:45:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/6] gfs2: remove dependency on __GFP_NOFAIL 
In-Reply-To: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007201940300.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Peterson <rpeterso@redhat.com>, cluser-devel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The k[mc]allocs in dr_split_leaf() and dir_double_exhash() are failable,
so remove __GFP_NOFAIL from their masks.

Cc: Bob Peterson <rpeterso@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/gfs2/dir.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -955,7 +955,12 @@ static int dir_split_leaf(struct inode *inode, const struct qstr *name)
 	/* Change the pointers.
 	   Don't bother distinguishing stuffed from non-stuffed.
 	   This code is complicated enough already. */
-	lp = kmalloc(half_len * sizeof(__be64), GFP_NOFS | __GFP_NOFAIL);
+	lp = kmalloc(half_len * sizeof(__be64), GFP_NOFS);
+	if (!lp) {
+		error = -ENOMEM;
+		goto fail_brelse;
+	}
+
 	/*  Change the pointers  */
 	for (x = 0; x < half_len; x++)
 		lp[x] = cpu_to_be64(bn);
@@ -1063,7 +1068,9 @@ static int dir_double_exhash(struct gfs2_inode *dip)
 
 	/*  Allocate both the "from" and "to" buffers in one big chunk  */
 
-	buf = kcalloc(3, sdp->sd_hash_bsize, GFP_NOFS | __GFP_NOFAIL);
+	buf = kcalloc(3, sdp->sd_hash_bsize, GFP_NOFS);
+	if (!buf)
+		return -ENOMEM;
 
 	for (block = dip->i_disksize >> sdp->sd_hash_bsize_shift; block--;) {
 		error = gfs2_dir_read_data(dip, (char *)buf,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
