Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3016B03A5
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:40 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p187so13557214qkd.11
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t4si18022791qtg.106.2017.04.24.06.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:38 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 20/20] gfs2: clean up some filemap_* calls
Date: Mon, 24 Apr 2017 09:22:59 -0400
Message-Id: <20170424132259.8680-21-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

In some places, it's trying to reset the mapping error after calling
filemap_fdatawait. That's no longer required. Also, turn several
filemap_fdatawrite+filemap_fdatawait calls into filemap_write_and_wait.
That will at least return writeback errors that occur during the write
phase.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/gfs2/glops.c | 12 ++++--------
 fs/gfs2/lops.c  |  4 +---
 fs/gfs2/super.c |  6 ++----
 3 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/fs/gfs2/glops.c b/fs/gfs2/glops.c
index 5db59d444838..7362d19fdc4c 100644
--- a/fs/gfs2/glops.c
+++ b/fs/gfs2/glops.c
@@ -158,9 +158,7 @@ static void rgrp_go_sync(struct gfs2_glock *gl)
 	GLOCK_BUG_ON(gl, gl->gl_state != LM_ST_EXCLUSIVE);
 
 	gfs2_log_flush(sdp, gl, NORMAL_FLUSH);
-	filemap_fdatawrite_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
-	error = filemap_fdatawait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
-	mapping_set_error(mapping, error);
+	filemap_write_and_wait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
 	gfs2_ail_empty_gl(gl);
 
 	spin_lock(&gl->gl_lockref.lock);
@@ -225,12 +223,10 @@ static void inode_go_sync(struct gfs2_glock *gl)
 	filemap_fdatawrite(metamapping);
 	if (ip) {
 		struct address_space *mapping = ip->i_inode.i_mapping;
-		filemap_fdatawrite(mapping);
-		error = filemap_fdatawait(mapping);
-		mapping_set_error(mapping, error);
+		filemap_write_and_wait(mapping);
+	} else {
+		filemap_fdatawait(metamapping);
 	}
-	error = filemap_fdatawait(metamapping);
-	mapping_set_error(metamapping, error);
 	gfs2_ail_empty_gl(gl);
 	/*
 	 * Writeback of the data mapping may cause the dirty flag to be set
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index b1f9144b42c7..565ce33dec9b 100644
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
