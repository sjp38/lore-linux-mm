Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6608E6B007B
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:46:49 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so4913574wid.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:46:49 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id k3si13405714wjy.149.2015.01.08.09.46.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 09:46:36 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/12] ceph: remove call to bdi_unregister
Date: Thu,  8 Jan 2015 18:45:30 +0100
Message-Id: <1420739133-27514-10-git-send-email-hch@lst.de>
In-Reply-To: <1420739133-27514-1-git-send-email-hch@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

bdi_destroy already does all the work, and if we delay freeing the
anon bdev we can get away with just that single call.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/super.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index 50f06cd..e350cc1 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -40,17 +40,6 @@ static void ceph_put_super(struct super_block *s)
 
 	dout("put_super\n");
 	ceph_mdsc_close_sessions(fsc->mdsc);
-
-	/*
-	 * ensure we release the bdi before put_anon_super releases
-	 * the device name.
-	 */
-	if (s->s_bdi == &fsc->backing_dev_info) {
-		bdi_unregister(&fsc->backing_dev_info);
-		s->s_bdi = NULL;
-	}
-
-	return;
 }
 
 static int ceph_statfs(struct dentry *dentry, struct kstatfs *buf)
@@ -1002,11 +991,16 @@ out_final:
 static void ceph_kill_sb(struct super_block *s)
 {
 	struct ceph_fs_client *fsc = ceph_sb_to_client(s);
+	dev_t dev = s->s_dev;
+
 	dout("kill_sb %p\n", s);
+
 	ceph_mdsc_pre_umount(fsc->mdsc);
-	kill_anon_super(s);    /* will call put_super after sb is r/o */
+	generic_shutdown_super(s);
 	ceph_mdsc_destroy(fsc);
+
 	destroy_fs_client(fsc);
+	free_anon_bdev(dev);
 }
 
 static struct file_system_type ceph_fs_type = {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
