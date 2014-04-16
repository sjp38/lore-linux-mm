Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE676B003B
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:18:41 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so8429602eek.27
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:18:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o46si28095152eem.279.2014.04.15.21.18.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:18:40 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 07/19] nfsd and VM: use PF_LESS_THROTTLE to avoid throttle
 in shrink_inactive_list.
Message-ID: <20140416040336.10604.55772.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

nfsd already uses PF_LESS_THROTTLE (and is the only user) to avoid
throttling while dirtying pages.  Use it also to avoid throttling while
doing direct reclaim as this can stall nfsd in the same way.

Also only set PF_LESS_THROTTLE when handling a 'write' request for a
local connection.  This is the only time when the throttling can cause
a problem.  In other cases we should throttle if the system is busy.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfssvc.c |    6 ------
 fs/nfsd/vfs.c    |    6 ++++++
 mm/vmscan.c      |    7 +++++--
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6af8bc2daf7d..cd24aa76e58d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -593,12 +593,6 @@ nfsd(void *vrqstp)
 	nfsdstats.th_cnt++;
 	mutex_unlock(&nfsd_mutex);
 
-	/*
-	 * We want less throttling in balance_dirty_pages() so that nfs to
-	 * localhost doesn't cause nfsd to lock up due to all the client's
-	 * dirty pages.
-	 */
-	current->flags |= PF_LESS_THROTTLE;
 	set_freezable();
 
 	/*
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6d7be3f80356..be2d7af3beee 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -913,6 +913,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	int			stable = *stablep;
 	int			use_wgather;
 	loff_t			pos = offset;
+	unsigned int		pflags;
+
+	if (rqstp->rq_local)
+		current_set_flags_nested(&pflags, PF_LESS_THROTTLE);
 
 	dentry = file->f_path.dentry;
 	inode = dentry->d_inode;
@@ -950,6 +954,8 @@ out_nfserr:
 		err = 0;
 	else
 		err = nfserrno(host_err);
+	if (rqstp->rq_local)
+		current_restore_flags_nested(&pflags, PF_LESS_THROTTLE);
 	return err;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 05de3289d031..1b7c4e44f0a1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1552,7 +1552,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * implies that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_unqueued_dirty == nr_taken || nr_immediate)
+		if ((nr_unqueued_dirty == nr_taken || nr_immediate)
+		    && !current_test_flags(PF_LESS_THROTTLE))
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
@@ -1561,7 +1562,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * is congested. Allow kswapd to continue until it starts encountering
 	 * unqueued dirty pages or cycling through the LRU too quickly.
 	 */
-	if (!sc->hibernation_mode && !current_is_kswapd())
+	if (!sc->hibernation_mode &&
+	    !current_is_kswapd() &&
+	    !current_test_flags(PF_LESS_THROTTLE))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
