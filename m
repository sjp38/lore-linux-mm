Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 727BA280724
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f53so1431115qte.15
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n7si401255qkl.43.2017.05.09.08.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:50:53 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 23/27] gfs2: clean up some filemap_* calls
Date: Tue,  9 May 2017 11:49:26 -0400
Message-Id: <20170509154930.29524-24-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

In some places, it's trying to reset the mapping error after calling
filemap_fdatawait. That's no longer required. Also, turn several
filemap_fdatawrite+filemap_fdatawait calls into filemap_write_and_wait.
That will at least return writeback errors that occur during the write
phase.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/gfs2/glops.c | 17 ++++-------------
 fs/gfs2/lops.c  |  4 +---
 fs/gfs2/super.c |  6 ++----
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/fs/gfs2/glops.c b/fs/gfs2/glops.c
index 5db59d444838..18ab54e351d6 100644
--- a/fs/gfs2/glops.c
+++ b/fs/gfs2/glops.c
@@ -145,7 +145,6 @@ static void rgrp_go_sync(struct gfs2_glock *gl)
 	struct gfs2_sbd *sdp = gl->gl_name.ln_sbd;
 	struct address_space *mapping = &sdp->sd_aspace;
 	struct gfs2_rgrpd *rgd;
-	int error;
 
 	spin_lock(&gl->gl_lockref.lock);
 	rgd = gl->gl_object;
@@ -158,9 +157,7 @@ static void rgrp_go_sync(struct gfs2_glock *gl)
 	GLOCK_BUG_ON(gl, gl->gl_state != LM_ST_EXCLUSIVE);
 
 	gfs2_log_flush(sdp, gl, NORMAL_FLUSH);
-	filemap_fdatawrite_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
-	error = filemap_fdatawait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
-	mapping_set_error(mapping, error);
+	filemap_write_and_wait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
 	gfs2_ail_empty_gl(gl);
 
 	spin_lock(&gl->gl_lockref.lock);
@@ -207,7 +204,6 @@ static void inode_go_sync(struct gfs2_glock *gl)
 {
 	struct gfs2_inode *ip = gl->gl_object;
 	struct address_space *metamapping = gfs2_glock2aspace(gl);
-	int error;
 
 	if (ip && !S_ISREG(ip->i_inode.i_mode))
 		ip = NULL;
@@ -223,14 +219,9 @@ static void inode_go_sync(struct gfs2_glock *gl)
 
 	gfs2_log_flush(gl->gl_name.ln_sbd, gl, NORMAL_FLUSH);
 	filemap_fdatawrite(metamapping);
-	if (ip) {
-		struct address_space *mapping = ip->i_inode.i_mapping;
-		filemap_fdatawrite(mapping);
-		error = filemap_fdatawait(mapping);
-		mapping_set_error(mapping, error);
-	}
-	error = filemap_fdatawait(metamapping);
-	mapping_set_error(metamapping, error);
+	if (ip)
+		filemap_write_and_wait(ip->i_inode.i_mapping);
+	filemap_fdatawait(metamapping);
 	gfs2_ail_empty_gl(gl);
 	/*
 	 * Writeback of the data mapping may cause the dirty flag to be set
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index cd7857ab1a6a..614bb974b927 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -586,9 +586,7 @@ static void gfs2_meta_sync(struct gfs2_glock *gl)
 	if (mapping == NULL)
 		mapping = &sdp->sd_aspace;
 
-	filemap_fdatawrite(mapping);
-	error = filemap_fdatawait(mapping);
-
+	error = filemap_write_and_wait(mapping);
 	if (error)
 		gfs2_io_error(gl->gl_name.ln_sbd);
 }
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 361796a84fce..675c39566ea1 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -1593,10 +1593,8 @@ static void gfs2_evict_inode(struct inode *inode)
 out_truncate:
 	gfs2_log_flush(sdp, ip->i_gl, NORMAL_FLUSH);
 	metamapping = gfs2_glock2aspace(ip->i_gl);
-	if (test_bit(GLF_DIRTY, &ip->i_gl->gl_flags)) {
-		filemap_fdatawrite(metamapping);
-		filemap_fdatawait(metamapping);
-	}
+	if (test_bit(GLF_DIRTY, &ip->i_gl->gl_flags))
+		filemap_write_and_wait(metamapping);
 	write_inode_now(inode, 1);
 	gfs2_ail_flush(ip->i_gl, 0);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
