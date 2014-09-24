Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 27BCB6B003A
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:03:41 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id el20so3337509lab.4
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:03:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc5si20954334lab.2.2014.09.23.19.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 19:03:39 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 24 Sep 2014 11:28:32 +1000
Subject: [PATCH 4/5] NFS: avoid waiting at all in nfs_release_page when
 congested.
Message-ID: <20140924012832.4838.7078.stgit@notabene.brown>
In-Reply-To: <20140924012422.4838.29188.stgit@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

If nfs_release_page() is called on a sequence of pages which are all
in the same file which is blocked on COMMIT, each page could
contribute a 1 second delay which could be come excessive.  I have
seen delays of as much as 208 seconds.

To keep the delay to one second, mark the bdi as write-congested
if the commit didn't finished.  Once it does finish, the
write-congested flag will be cleared by nfs_commit_release_pages().

With this, the longest total delay in try_to_free_pages that I have
seen is under 3 seconds.  With no waiting in nfs_release_page at all
I have seen delays of nearly 1.5 seconds.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c  |    9 +++++++--
 fs/nfs/write.c |    5 +++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ef5513322cf6..1243a15438d0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -470,7 +470,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 
 	/* Always try to initiate a 'commit' if relevant, but only
 	 * wait for it if __GFP_WAIT is set and the calling process is
-	 * allowed to block.  Even then, only wait 1 second.
+	 * allowed to block.  Even then, only wait 1 second and only
+	 * if the 'bdi' is not congested.
 	 * Waiting indefinitely can cause deadlocks when the NFS
 	 * server is on this machine, and there is no particular need
 	 * to wait extensively here.  A short wait has the benefit
@@ -481,9 +482,13 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 		nfs_commit_inode(mapping->host, 0);
 		if ((gfp & __GFP_WAIT) &&
 		    !current_is_kswapd() &&
-		    !(current->flags & PF_FSTRANS)) {
+		    !(current->flags & PF_FSTRANS) &&
+		    !bdi_write_congested(&nfss->backing_dev_info)) {
 			wait_on_page_bit_killable_timeout(page, PG_private,
 							  HZ);
+			if (PagePrivate(page))
+				set_bdi_congested(&nfss->backing_dev_info,
+						  BLK_RW_ASYNC);
 		}
 	}
 	/* If PagePrivate() is set, then the page is not freeable */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b5d83c7545d4..3066c7fcb565 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1638,6 +1638,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 	struct nfs_page	*req;
 	int status = data->task.tk_status;
 	struct nfs_commit_info cinfo;
+	struct nfs_server *nfss;
 
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
@@ -1671,6 +1672,10 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 	next:
 		nfs_unlock_and_release_request(req);
 	}
+	nfss = NFS_SERVER(data->inode);
+	if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
+		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
 	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
 		nfs_commit_clear_lock(NFS_I(data->inode));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
