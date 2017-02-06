Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11A896B0266
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:07:36 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so18691232wjb.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:36 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w7si1055581wrb.207.2017.02.06.06.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:07:34 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id c85so22146674wmi.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:34 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/6] jbd2: make the whole kjournald2 kthread NOFS safe
Date: Mon,  6 Feb 2017 15:07:18 +0100
Message-Id: <20170206140718.16222-7-mhocko@kernel.org>
In-Reply-To: <20170206140718.16222-1-mhocko@kernel.org>
References: <20170206140718.16222-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

kjournald2 is central to the transaction commit processing. As such any
potential allocation from this kernel thread has to be GFP_NOFS. Make
sure to mark the whole kernel thread GFP_NOFS by the memalloc_nofs_save.

Suggested-by: Jan Kara <jack@suse.cz>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/jbd2/journal.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index 704139625fbe..662531a70ce1 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -206,6 +206,13 @@ static int kjournald2(void *arg)
 	wake_up(&journal->j_wait_done_commit);
 
 	/*
+	 * Make sure that no allocations from this kernel thread will ever recurse
+	 * to the fs layer because we are responsible for the transaction commit
+	 * and any fs involvement might get stuck waiting for the trasn. commit.
+	 */
+	memalloc_nofs_save();
+
+	/*
 	 * And now, wait forever for commit wakeup events.
 	 */
 	write_lock(&journal->j_state_lock);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
