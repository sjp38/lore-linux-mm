Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C584280254
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 09:07:57 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o2so23427834wje.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:57 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id dy10si2199684wjb.80.2016.12.15.06.07.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 06:07:55 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id j10so9964570wjb.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:55 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/9] jbd2: mark the transaction context with the scope GFP_NOFS context
Date: Thu, 15 Dec 2016 15:07:12 +0100
Message-Id: <20161215140715.12732-7-mhocko@kernel.org>
In-Reply-To: <20161215140715.12732-1-mhocko@kernel.org>
References: <20161215140715.12732-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

now that we have memalloc_nofs_{save,restore} api we can mark the whole
transaction context as implicitly GFP_NOFS. All allocations will
automatically inherit GFP_NOFS this way. This means that we do not have
to mark any of those requests with GFP_NOFS and moreover all the
ext4_kv[mz]alloc(GFP_NOFS) are also safe now because even the hardcoded
GFP_KERNEL allocations deep inside the vmalloc will be NOFS now.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/jbd2/transaction.c | 11 +++++++++++
 include/linux/jbd2.h  |  2 ++
 2 files changed, 13 insertions(+)

diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index e1652665bd93..35a5d3d76182 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -388,6 +388,11 @@ static int start_this_handle(journal_t *journal, handle_t *handle,
 
 	rwsem_acquire_read(&journal->j_trans_commit_map, 0, 0, _THIS_IP_);
 	jbd2_journal_free_transaction(new_transaction);
+	/*
+	 * Make sure that no allocations done while the transaction is
+	 * open is going to recurse back to the fs layer.
+	 */
+	handle->saved_alloc_context = memalloc_nofs_save();
 	return 0;
 }
 
@@ -466,6 +471,7 @@ handle_t *jbd2__journal_start(journal_t *journal, int nblocks, int rsv_blocks,
 	trace_jbd2_handle_start(journal->j_fs_dev->bd_dev,
 				handle->h_transaction->t_tid, type,
 				line_no, nblocks);
+
 	return handle;
 }
 EXPORT_SYMBOL(jbd2__journal_start);
@@ -1760,6 +1766,11 @@ int jbd2_journal_stop(handle_t *handle)
 	if (handle->h_rsv_handle)
 		jbd2_journal_free_reserved(handle->h_rsv_handle);
 free_and_exit:
+	/*
+	 * scope of th GFP_NOFS context is over here and so we can
+	 * restore the original alloc context.
+	 */
+	memalloc_nofs_restore(handle->saved_alloc_context);
 	jbd2_free_handle(handle);
 	return err;
 }
diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
index dfaa1f4dcb0c..606b6bce3a5b 100644
--- a/include/linux/jbd2.h
+++ b/include/linux/jbd2.h
@@ -491,6 +491,8 @@ struct jbd2_journal_handle
 
 	unsigned long		h_start_jiffies;
 	unsigned int		h_requested_credits;
+
+	unsigned int		saved_alloc_context;
 };
 
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
