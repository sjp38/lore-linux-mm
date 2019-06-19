Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6256DC31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08E802147A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Kd5Oz2z7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08E802147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64E208E0006; Wed, 19 Jun 2019 13:22:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D5578E0001; Wed, 19 Jun 2019 13:22:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49BDB8E0006; Wed, 19 Jun 2019 13:22:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B59D8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:22:26 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id h3so229164iob.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:22:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KH6uuY3bzkyxUbc/4b2whin16m+tl1CqupF/F+woU3U=;
        b=tPB/pak4ew6vC+yrmqfpi11gF8U866TyIX3D1aRxkZ3H83/RNKisj9obFbDlyWghdK
         1pR+SNvbjIfO4mhdyQHPqzHzxiE8wV2IyX+diBj36YYNkgg1U8vW4crGcDD85rVeiYGv
         +Njt11ux7TG81UL1cC9u/NlY+mfQZ9/H2icDxTfQhe1ley29uptF0/t/LdIJqCgBBH24
         KJGaBJPdERpXpvdFZ0jFBmPLdYCPZP+sRso7a+YgGHaiPvvpf2Wanf7y19Db37jaVpWv
         opb4bRrjON9dFVBGBWh/hM7TrNjKIKOTeXAAXbf4lbeeZjQ2MrSYHaQW5iYVMf5k5GPk
         FV7w==
X-Gm-Message-State: APjAAAVKDLtNdv/uez9XxVfnDIKHyczaeU5b0L4wiIyHX90yyo27jfhW
	oB+A3jYzGOQOp3hu/fd0aNk5vESIZZr5gku76E05Q4uwhVMSwgNDoYwiZsUcpkqfMnXcB4Nio3n
	jF4IH1DwgtBSIlRVtMhHjG18zrYEQXa5sd8Rkw6sWpuv3RrS29N2npHlpLIAqKLKUng==
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr10458646iog.266.1560964945802;
        Wed, 19 Jun 2019 10:22:25 -0700 (PDT)
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr10458566iog.266.1560964944565;
        Wed, 19 Jun 2019 10:22:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560964944; cv=none;
        d=google.com; s=arc-20160816;
        b=XIsf8ZTWR0GwYaW+GXkELVyh27dq250/lDga1GCUmrgxJIJuPL7fqIzcij7FA/jQTB
         XOzrMGYcwLHpVvKefpzc6nwnoJ8lkjYFnWtGjzXdA2GC507lBgKbz2EQYCAdQRascTbU
         EwywAXtgEzPOb299gt6j6GRJVtma5tfOvimqtKAkim/8zFAbDJmR04QG96esZ2KANvAe
         XswQZuVOid0HGFiauzMqz6q54+TI0Blv6N/MAwKMABU0f5YKISTdgyzzGa4fiQBMchRj
         MqTVJYxnYqB0rlgDfVb94QrzuTsZYs4fj/zu1SlbamLqCrV3wfqWP/IZaj6VTCgLtWk7
         zbRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KH6uuY3bzkyxUbc/4b2whin16m+tl1CqupF/F+woU3U=;
        b=OhkvAD3BWQ2VR9RXvyrTfIYFirTLG4MXxgU0No5dGSB6AKSQEErRwJ6g3t1CBZcVCO
         Z2I9BvDEr9PeSOryZO0CMjd9KKjfFzKO+VIi2RRMtVV02W0b0gIRp+V8nZurVIqeByTk
         AejGyBmeu9uhNEdcT4h+OLFHRFhrIe7AvwIVf4yA7HnQ/ewRFXk8oG5KcQVS52Zu/tV1
         Z4iPOpaZsI7cbfQIRn8zfs5rhG3RTBkz3HwPtKlslh2TNPp4IzhKU5iwLyiSiTCJHTe6
         +gBnGEzhD6ZbI/+D5PSr2Dzpof4YII4U6eG61C0j2itp3IRrOYXnX99JOUQoRxUDG0sE
         5OWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Kd5Oz2z7;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6sor14747223ioj.110.2019.06.19.10.22.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 10:22:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Kd5Oz2z7;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=KH6uuY3bzkyxUbc/4b2whin16m+tl1CqupF/F+woU3U=;
        b=Kd5Oz2z7qXeyCtSa5rnoVJdpJWNpsClaZxd89CZ/xkDcmmWSiK+5BTa8uuXK0wGzlX
         HseFeng1K73Mi29sPMqT3hGpGeijIqqB/kBHquDct/9T6gxMgfUzd7Afr7NZC2vPTUT5
         yHKZb9sH68tDu7jf8IcJzVR6iYUH2e9IYbFmo=
X-Google-Smtp-Source: APXvYqwPsprskH+ssIzzauAsY42Hg5rw9UX4YcvsLwyXb6tb2CUnsSBAxvqOIaGv1TSzKgEMv6cxKg==
X-Received: by 2002:a05:6638:38f:: with SMTP id y15mr99238464jap.143.1560964944144;
        Wed, 19 Jun 2019 10:22:24 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id o5sm13460441iob.7.2019.06.19.10.22.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 10:22:23 -0700 (PDT)
From: Ross Zwisler <zwisler@chromium.org>
X-Google-Original-From: Ross Zwisler <zwisler@google.com>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <zwisler@google.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: [PATCH 2/3] jbd2: introduce jbd2_inode dirty range scoping
Date: Wed, 19 Jun 2019 11:21:55 -0600
Message-Id: <20190619172156.105508-3-zwisler@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190619172156.105508-1-zwisler@google.com>
References: <20190619172156.105508-1-zwisler@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently both journal_submit_inode_data_buffers() and
journal_finish_inode_data_buffers() operate on the entire address space
of each of the inodes associated with a given journal entry.  The
consequence of this is that if we have an inode where we are constantly
appending dirty pages we can end up waiting for an indefinite amount of
time in journal_finish_inode_data_buffers() while we wait for all the
pages under writeback to be written out.

The easiest way to cause this type of workload is do just dd from
/dev/zero to a file until it fills the entire filesystem.  This can
cause journal_finish_inode_data_buffers() to wait for the duration of
the entire dd operation.

We can improve this situation by scoping each of the inode dirty ranges
associated with a given transaction.  We do this via the jbd2_inode
structure so that the scoping is contained within jbd2 and so that it
follows the lifetime and locking rules for that structure.

This allows us to limit the writeback & wait in
journal_submit_inode_data_buffers() and
journal_finish_inode_data_buffers() respectively to the dirty range for
a given struct jdb2_inode, keeping us from waiting forever if the inode
in question is still being appended to.

Signed-off-by: Ross Zwisler <zwisler@google.com>
---
 fs/jbd2/commit.c      | 26 +++++++++++++++++------
 fs/jbd2/journal.c     |  2 ++
 fs/jbd2/transaction.c | 49 ++++++++++++++++++++++++-------------------
 include/linux/jbd2.h  | 22 +++++++++++++++++++
 4 files changed, 72 insertions(+), 27 deletions(-)

diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index efd0ce9489ae9..b4b99ea6e8700 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -187,14 +187,15 @@ static int journal_wait_on_commit_record(journal_t *journal,
  * use writepages() because with dealyed allocation we may be doing
  * block allocation in writepages().
  */
-static int journal_submit_inode_data_buffers(struct address_space *mapping)
+static int journal_submit_inode_data_buffers(struct address_space *mapping,
+		loff_t dirty_start, loff_t dirty_end)
 {
 	int ret;
 	struct writeback_control wbc = {
 		.sync_mode =  WB_SYNC_ALL,
 		.nr_to_write = mapping->nrpages * 2,
-		.range_start = 0,
-		.range_end = i_size_read(mapping->host),
+		.range_start = dirty_start,
+		.range_end = dirty_end,
 	};
 
 	ret = generic_writepages(mapping, &wbc);
@@ -218,6 +219,9 @@ static int journal_submit_data_buffers(journal_t *journal,
 
 	spin_lock(&journal->j_list_lock);
 	list_for_each_entry(jinode, &commit_transaction->t_inode_list, i_list) {
+		loff_t dirty_start = jinode->i_dirty_start;
+		loff_t dirty_end = jinode->i_dirty_end;
+
 		if (!(jinode->i_flags & JI_WRITE_DATA))
 			continue;
 		mapping = jinode->i_vfs_inode->i_mapping;
@@ -230,7 +234,8 @@ static int journal_submit_data_buffers(journal_t *journal,
 		 * only allocated blocks here.
 		 */
 		trace_jbd2_submit_inode_data(jinode->i_vfs_inode);
-		err = journal_submit_inode_data_buffers(mapping);
+		err = journal_submit_inode_data_buffers(mapping, dirty_start,
+				dirty_end);
 		if (!ret)
 			ret = err;
 		spin_lock(&journal->j_list_lock);
@@ -257,15 +262,24 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
 	/* For locking, see the comment in journal_submit_data_buffers() */
 	spin_lock(&journal->j_list_lock);
 	list_for_each_entry(jinode, &commit_transaction->t_inode_list, i_list) {
+		loff_t dirty_start = jinode->i_dirty_start;
+		loff_t dirty_end = jinode->i_dirty_end;
+
 		if (!(jinode->i_flags & JI_WAIT_DATA))
 			continue;
 		jinode->i_flags |= JI_COMMIT_RUNNING;
 		spin_unlock(&journal->j_list_lock);
-		err = filemap_fdatawait_keep_errors(
-				jinode->i_vfs_inode->i_mapping);
+		err = filemap_fdatawait_range_keep_errors(
+				jinode->i_vfs_inode->i_mapping, dirty_start,
+				dirty_end);
 		if (!ret)
 			ret = err;
 		spin_lock(&journal->j_list_lock);
+
+		if (!jinode->i_next_transaction) {
+			jinode->i_dirty_start = 0;
+			jinode->i_dirty_end = 0;
+		}
 		jinode->i_flags &= ~JI_COMMIT_RUNNING;
 		smp_mb();
 		wake_up_bit(&jinode->i_flags, __JI_COMMIT_RUNNING);
diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index 43df0c943229c..288b8e7cf21c7 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2574,6 +2574,8 @@ void jbd2_journal_init_jbd_inode(struct jbd2_inode *jinode, struct inode *inode)
 	jinode->i_next_transaction = NULL;
 	jinode->i_vfs_inode = inode;
 	jinode->i_flags = 0;
+	jinode->i_dirty_start = 0;
+	jinode->i_dirty_end = 0;
 	INIT_LIST_HEAD(&jinode->i_list);
 }
 
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 8ca4fddc705fe..990e7b5062e74 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -2565,7 +2565,7 @@ void jbd2_journal_refile_buffer(journal_t *journal, struct journal_head *jh)
  * File inode in the inode list of the handle's transaction
  */
 static int jbd2_journal_file_inode(handle_t *handle, struct jbd2_inode *jinode,
-				   unsigned long flags)
+		unsigned long flags, loff_t start_byte, loff_t end_byte)
 {
 	transaction_t *transaction = handle->h_transaction;
 	journal_t *journal;
@@ -2577,26 +2577,17 @@ static int jbd2_journal_file_inode(handle_t *handle, struct jbd2_inode *jinode,
 	jbd_debug(4, "Adding inode %lu, tid:%d\n", jinode->i_vfs_inode->i_ino,
 			transaction->t_tid);
 
-	/*
-	 * First check whether inode isn't already on the transaction's
-	 * lists without taking the lock. Note that this check is safe
-	 * without the lock as we cannot race with somebody removing inode
-	 * from the transaction. The reason is that we remove inode from the
-	 * transaction only in journal_release_jbd_inode() and when we commit
-	 * the transaction. We are guarded from the first case by holding
-	 * a reference to the inode. We are safe against the second case
-	 * because if jinode->i_transaction == transaction, commit code
-	 * cannot touch the transaction because we hold reference to it,
-	 * and if jinode->i_next_transaction == transaction, commit code
-	 * will only file the inode where we want it.
-	 */
-	if ((jinode->i_transaction == transaction ||
-	    jinode->i_next_transaction == transaction) &&
-	    (jinode->i_flags & flags) == flags)
-		return 0;
-
 	spin_lock(&journal->j_list_lock);
 	jinode->i_flags |= flags;
+
+	if (jinode->i_dirty_end) {
+		jinode->i_dirty_start = min(jinode->i_dirty_start, start_byte);
+		jinode->i_dirty_end = max(jinode->i_dirty_end, end_byte);
+	} else {
+		jinode->i_dirty_start = start_byte;
+		jinode->i_dirty_end = end_byte;
+	}
+
 	/* Is inode already attached where we need it? */
 	if (jinode->i_transaction == transaction ||
 	    jinode->i_next_transaction == transaction)
@@ -2631,12 +2622,28 @@ static int jbd2_journal_file_inode(handle_t *handle, struct jbd2_inode *jinode,
 int jbd2_journal_inode_add_write(handle_t *handle, struct jbd2_inode *jinode)
 {
 	return jbd2_journal_file_inode(handle, jinode,
-				       JI_WRITE_DATA | JI_WAIT_DATA);
+			JI_WRITE_DATA | JI_WAIT_DATA, 0, LLONG_MAX);
 }
 
 int jbd2_journal_inode_add_wait(handle_t *handle, struct jbd2_inode *jinode)
 {
-	return jbd2_journal_file_inode(handle, jinode, JI_WAIT_DATA);
+	return jbd2_journal_file_inode(handle, jinode, JI_WAIT_DATA, 0,
+			LLONG_MAX);
+}
+
+int jbd2_journal_inode_ranged_write(handle_t *handle,
+		struct jbd2_inode *jinode, loff_t start_byte, loff_t length)
+{
+	return jbd2_journal_file_inode(handle, jinode,
+			JI_WRITE_DATA | JI_WAIT_DATA, start_byte,
+			start_byte + length - 1);
+}
+
+int jbd2_journal_inode_ranged_wait(handle_t *handle, struct jbd2_inode *jinode,
+		loff_t start_byte, loff_t length)
+{
+	return jbd2_journal_file_inode(handle, jinode, JI_WAIT_DATA,
+			start_byte, start_byte + length - 1);
 }
 
 /*
diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
index 5c04181b7c6d8..0e0393e7f41a4 100644
--- a/include/linux/jbd2.h
+++ b/include/linux/jbd2.h
@@ -451,6 +451,22 @@ struct jbd2_inode {
 	 * @i_flags: Flags of inode [j_list_lock]
 	 */
 	unsigned long i_flags;
+
+	/**
+	 * @i_dirty_start:
+	 *
+	 * Offset in bytes where the dirty range for this inode starts.
+	 * [j_list_lock]
+	 */
+	loff_t i_dirty_start;
+
+	/**
+	 * @i_dirty_end:
+	 *
+	 * Inclusive offset in bytes where the dirty range for this inode
+	 * ends. [j_list_lock]
+	 */
+	loff_t i_dirty_end;
 };
 
 struct jbd2_revoke_table_s;
@@ -1397,6 +1413,12 @@ extern int	   jbd2_journal_force_commit(journal_t *);
 extern int	   jbd2_journal_force_commit_nested(journal_t *);
 extern int	   jbd2_journal_inode_add_write(handle_t *handle, struct jbd2_inode *inode);
 extern int	   jbd2_journal_inode_add_wait(handle_t *handle, struct jbd2_inode *inode);
+extern int	   jbd2_journal_inode_ranged_write(handle_t *handle,
+			struct jbd2_inode *inode, loff_t start_byte,
+			loff_t length);
+extern int	   jbd2_journal_inode_ranged_wait(handle_t *handle,
+			struct jbd2_inode *inode, loff_t start_byte,
+			loff_t length);
 extern int	   jbd2_journal_begin_ordered_truncate(journal_t *journal,
 				struct jbd2_inode *inode, loff_t new_size);
 extern void	   jbd2_journal_init_jbd_inode(struct jbd2_inode *jinode, struct inode *inode);
-- 
2.22.0.410.gd8fdbe21b5-goog

