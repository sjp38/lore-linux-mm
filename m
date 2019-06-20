Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C3EEC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18F9520675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="OxCTA6+F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18F9520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37FC28E0001; Thu, 20 Jun 2019 11:18:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 332658E0005; Thu, 20 Jun 2019 11:18:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BB4E8E0001; Thu, 20 Jun 2019 11:18:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED0888E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:18:54 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v11so5693015iop.7
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:18:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yst8MNat78gyvUv+78J2l6JrkJnYsEpCBtbxbwsO9x8=;
        b=Mn/mIyOhWIXgeC0yyMi6ZioGievuBMXUjoRxgwXfbT5JxUCbFiG8AMaG8erPvdGeR1
         Y55+9InGm0uO/nk7acqd5FdaT3eKWqwNQsQN0Zm6DPLIdIhDCB/qZ2Y4HSc2IlTyg1Jy
         Uky2Q5T0T4WD50pqAhlCRnuo4ZDlGYtQk4gZ/xis4jiHF7Oh5l2lzJXTgb+fXH8C5504
         zrdre5/FVa+lq70WbfU1yprzTGJNBjY1KlmwFeSKmV7SyBDQTC/yo1DWY2t2c20gS+fE
         XrrfacESR1G6gMhAro8UiFfNZt8epRs10DEo0KOJaPXNeJCkuB3xNrdzczoLPBwmUV/Y
         US+Q==
X-Gm-Message-State: APjAAAU4tiDf6C87QDFizAX3JMaBeV4hkPX1KTITBZdFtlLf8g2iuULg
	i4sDbBrn2Unz9GGqfchi4fcb/bpt2AgkFuyjLYgMDvZWmmB9uPoUobAFSwfalJA6D12fBhHzmgP
	AUvNLKlTW90AsaMIuDDu5VfE5AsH8b8lvg9ulavC8lh9uIJMeJSVS4XiKukdX6b6+uQ==
X-Received: by 2002:a6b:6611:: with SMTP id a17mr13506957ioc.179.1561043934700;
        Thu, 20 Jun 2019 08:18:54 -0700 (PDT)
X-Received: by 2002:a6b:6611:: with SMTP id a17mr13506882ioc.179.1561043933696;
        Thu, 20 Jun 2019 08:18:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561043933; cv=none;
        d=google.com; s=arc-20160816;
        b=SDDfn1MNOoK0w087G6NLLEOJIs4ztbBiAQZcloKL578NMRr7vI76+DMUxywArcsEeR
         AXr0sczNXw6HH/utu6DZAdaOErMQmra3u895A/WmkSDdPXbuYhhi8BTyhaMsphNt4f25
         vAC4x3qHy+mjNj+nJEPn2O471+/cMxqF5mgZa+Ru3e9L6s2oqbwc7gh/75CNwg36Q0QS
         3QS9fyEHQKd0n7qzlYD0ZZjz0FanitkgHYV8fsrQIG8KI4rgCD85v6wJIcaQbwukpeqz
         4gHExVVCO120Bgk31BEatFO+pon60y2xKV+ZkzT8CkKkWDORTZif1pG/FnktHPhDWRzc
         QXpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=yst8MNat78gyvUv+78J2l6JrkJnYsEpCBtbxbwsO9x8=;
        b=AFXbSiPS6AQ6fTOWFzQng7uBWgNZzpoMWAJ+wd3tSmEB7dgyIqw2HpblJDX5Sk3sXs
         Vp8Vy4wSO+6BB03HfV3YzQtzHo7TQ0LIiE0sTLBYzh84rd5hBowu+0l7Wz7dEi6NoA7O
         81A3LutF3NIPnMwD3iXvR7wKgKK2H79o0ZAuv37YV/kkwUurnp7+HweSArJlqcBbWFg0
         usglG+yXFW7d3Pnl53is8iGI8oGCV6NwEesgQLwu1KWG/E5ZRuIp8aqT5TUDGTdg0ola
         7b0gf8L4aQpinx0F+ouTE78I9tSRJPn1Ac1OoE3dVYfddcz/N8Og00+XBwaORmD72W1C
         yW9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OxCTA6+F;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor17992348iog.90.2019.06.20.08.18.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:18:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OxCTA6+F;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=yst8MNat78gyvUv+78J2l6JrkJnYsEpCBtbxbwsO9x8=;
        b=OxCTA6+FCqpeGgc5w46hByG+mh3eFlESmcXTfAhJaFakhTREe6TJQM8tjn3mlgPh1K
         xsh3D9ct0UrnDTrifSZyN/u0Ewvrl8JwH48Y/Q/cZQ76A8rELcDwwT5/BKBouEf0v92z
         gYcrSBsg/5vCi7lfjsz6nZjac5lq/RTlEDKJo=
X-Google-Smtp-Source: APXvYqxBEO4SmFYY60o3fT/y9Z8WeHnCefsDa+T4fidYk/4ZoCsyv9qbjJKjrbbvjiqri/qJpiWGwQ==
X-Received: by 2002:a6b:7f0b:: with SMTP id l11mr91998488ioq.282.1561043933293;
        Thu, 20 Jun 2019 08:18:53 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id o7sm36082ioo.81.2019.06.20.08.18.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:18:52 -0700 (PDT)
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
	Justin TerAvest <teravest@google.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH v2 2/3] jbd2: introduce jbd2_inode dirty range scoping
Date: Thu, 20 Jun 2019 09:18:38 -0600
Message-Id: <20190620151839.195506-3-zwisler@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190620151839.195506-1-zwisler@google.com>
References: <20190620151839.195506-1-zwisler@google.com>
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
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: stable@vger.kernel.org
---
 fs/jbd2/commit.c      | 23 ++++++++++++++------
 fs/jbd2/journal.c     |  2 ++
 fs/jbd2/transaction.c | 49 ++++++++++++++++++++++++-------------------
 include/linux/jbd2.h  | 22 +++++++++++++++++++
 4 files changed, 69 insertions(+), 27 deletions(-)

diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index efd0ce9489ae9..668f9021cf115 100644
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
@@ -257,12 +262,16 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
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
@@ -282,6 +291,8 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
 				&jinode->i_transaction->t_inode_list);
 		} else {
 			jinode->i_transaction = NULL;
+			jinode->i_dirty_start = 0;
+			jinode->i_dirty_end = 0;
 		}
 	}
 	spin_unlock(&journal->j_list_lock);
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

