Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFBA6C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88B5E205ED
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:09:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88B5E205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26A4D6B0003; Tue, 16 Apr 2019 08:09:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 218B86B0006; Tue, 16 Apr 2019 08:09:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 109D46B0007; Tue, 16 Apr 2019 08:09:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C88FF6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:09:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h69so13910974pfd.21
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 05:09:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=y07fyxmxajgoYtQ7E6WAyUN0gBd4jUo2WuxHZGq38MQ=;
        b=O3bP2hX2NsG/lT9r5t49VqeHkXFub91ArAmIuBY63hiGSGlZFkEwtcDCRtGD1nVrSd
         qb2sRLVGcFtu2X58bEMszPnzHNc6wsms2KnNtT1Ds7JaHGp3YimDUViwxqIvhTPjs3zB
         YzvZ4Xef3iNZIKIII4g7U0+olj5A3y4YhsnNkhXVzdOae/TmWzyIkZs/x6uoIIa6mo59
         CNhqbiCq/ft5z6g3zdvqveTIqV/YKm9MWulRlglbO4Im32TP2mPePEOIfqSB9mcu+msl
         hxgx731a9XohB1M184fJ8Dv67M2stHEu86M7+5jUhizF6+vS+9+aYRHHTDtMb682DIiA
         ba+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUtlKu2N1o4YU31rxgU7jrqRY0BkYVDgtanqwhDUuhEuwgIMeDM
	1Ai/D6bxqQrrNUp/ynWuG7iclA3/pQTYvUpEE1yFySqgqqtBfgh3ue2QF76v6l3/3hC45EliXf5
	BWhSfU7E4m4NpLwTM9Glva2RGaXxSw5yNJ/cSeTKMUi/GVI77iyXSwjbXtaacrX7vaw==
X-Received: by 2002:a17:902:868e:: with SMTP id g14mr36873012plo.183.1555416546290;
        Tue, 16 Apr 2019 05:09:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybAuTOf3Bwd8LGSYxP1EdriN0xbbqzBLBGSCsUCcoegdzDPW5ebzuYGmxdxE6E0Q+r/81c
X-Received: by 2002:a17:902:868e:: with SMTP id g14mr36872868plo.183.1555416544731;
        Tue, 16 Apr 2019 05:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555416544; cv=none;
        d=google.com; s=arc-20160816;
        b=i43kZHAI9Y+Mmyjg4L/kM7s+a+Uln8jei76cYcrDktGb8qUnW/Nhog/oGsTkEeUzRl
         o5KyG5SwXTwvcpoVHjmeAhn1L3Z+hawStEGIQ5RfSv31YxTdYcgu8/9CbmdtwOCYfKzy
         cFCJ1mohv5g+8sd+pw+wq6x7ilEhfgQNZXD9Lj1JGFM8WSjD22QKvkNP17C514qx80ZS
         jWLjU02+2RPUVWBdFOHK0Xg1Qquwkw0iyPJGjIWVMRXe/OjGkN024Mlcp+qWpIYcXJpG
         +WkmhScD/B+0hur8jv3Za/1BqxR7Ot7rayU1qeEd2qQoMEvaR6dicNolELvGMIiiJLpH
         7M/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=y07fyxmxajgoYtQ7E6WAyUN0gBd4jUo2WuxHZGq38MQ=;
        b=uvPGa44rzKoc3xcCV8hoOpR30qskOk9ljy48NS3Sripdg4vmEEcdIWe8edjJ18eChQ
         GuqlS0vwsMDXelwDDGpL5CcQ+QXsQJsnX8NfK9SuLHv5dLwGLGt643sHJWXZ3zDm0nDi
         FV3AMJwFzbHOo1qmQtdhniJ9pQ98bb27Nb+ehcBspPCM21DTEAyJ9JcwynvGUnZWlIH8
         BvR3mtnCN5mEvyQfjLOLqYX79rTaxYmP7rpiGCDov/gNqL9faXk62mVTquCKLLXuk1vv
         WePohOJYu97jygZc+X9nzYAJBWKUGVlRqTZmsxNwZ9goeZain8pM6e0ml45/OTD7u/xb
         llow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id k185si16035985pge.306.2019.04.16.05.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 05:09:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R221e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TPT3EXs_1555416542;
Received: from localhost(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TPT3EXs_1555416542)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Apr 2019 20:09:02 +0800
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-mm@kvack.org
Cc: tj@kernel.org,
	akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com
Subject: [PATCH v2] fs/fs-writeback: wait isw_nr_in_flight to be zero when umount
Date: Tue, 16 Apr 2019 20:09:02 +0800
Message-Id: <20190416120902.18616-1-jiufei.xue@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.856.g8858448bb
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

synchronize_rcu() didn't wait for call_rcu() callbacks, so inode wb
switch may not go to the workqueue after synchronize_rcu(). Thus
previous scheduled switches was not finished even flushing the
workqueue, which will cause a NULL pointer dereferenced followed below.

VFS: Busy inodes after unmount of vdd. Self-destruct in 5 seconds.
Have a nice day...
BUG: unable to handle kernel NULL pointer dereference at
0000000000000278
[<ffffffff8126a303>] evict+0xb3/0x180
[<ffffffff8126a760>] iput+0x1b0/0x230
[<ffffffff8127c690>] inode_switch_wbs_work_fn+0x3c0/0x6a0
[<ffffffff810a5b2e>] worker_thread+0x4e/0x490
[<ffffffff810a5ae0>] ? process_one_work+0x410/0x410
[<ffffffff810ac056>] kthread+0xe6/0x100
[<ffffffff8173c199>] ret_from_fork+0x39/0x50

Here I don't use rcu_barrier() because it will wait for all the
rcu callbacks which is not appropriate.

Changes since v1: use per-sb s_isw_nr_in_flight to ensure that
s_isw_nr_in_flight will eventually zero.

Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: stable@kernel.org
---
 fs/fs-writeback.c         | 22 +++++++++++++++-------
 fs/super.c                |  3 ++-
 include/linux/fs.h        |  2 ++
 include/linux/writeback.h |  4 ++--
 4 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..370ac3a872f8 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -237,7 +237,6 @@ static void wb_wait_for_completion(struct backing_dev_info *bdi,
 #define WB_FRN_HIST_MAX_SLOTS	(WB_FRN_HIST_THR_SLOTS / 2 + 1)
 					/* one round can affect upto 5 slots */
 
-static atomic_t isw_nr_in_flight = ATOMIC_INIT(0);
 static struct workqueue_struct *isw_wq;
 
 void __inode_attach_wb(struct inode *inode, struct page *page)
@@ -346,6 +345,7 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	struct inode_switch_wbs_context *isw =
 		container_of(work, struct inode_switch_wbs_context, work);
 	struct inode *inode = isw->inode;
+	struct super_block *sb = inode->i_sb;
 	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct address_space *mapping = inode->i_mapping;
 	struct bdi_writeback *old_wb = inode->i_wb;
@@ -456,7 +456,7 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	iput(inode);
 	kfree(isw);
 
-	atomic_dec(&isw_nr_in_flight);
+	atomic_dec(&sb->s_isw_nr_in_flight);
 }
 
 static void inode_switch_wbs_rcu_fn(struct rcu_head *rcu_head)
@@ -479,6 +479,7 @@ static void inode_switch_wbs_rcu_fn(struct rcu_head *rcu_head)
  */
 static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 {
+	struct super_block *sb = inode->i_sb;
 	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct cgroup_subsys_state *memcg_css;
 	struct inode_switch_wbs_context *isw;
@@ -523,7 +524,7 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 
 	isw->inode = inode;
 
-	atomic_inc(&isw_nr_in_flight);
+	atomic_inc(&sb->s_isw_nr_in_flight);
 
 	/*
 	 * In addition to synchronizing among switchers, I_WB_SWITCH tells
@@ -898,12 +899,19 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
  * rare occurrences and synchronize_rcu() can take a while, perform
  * flushing iff wb switches are in flight.
  */
-void cgroup_writeback_umount(void)
+void cgroup_writeback_umount(struct super_block *sb)
 {
-	if (atomic_read(&isw_nr_in_flight)) {
-		synchronize_rcu();
+	if (!atomic_read(&sb->s_isw_nr_in_flight))
+		return;
+
+	synchronize_rcu();
+
+	/*
+	 * Now no more switched can be queued for this filesystem, just
+	 * wait for inflight switches finished.
+	 */
+	while (atomic_read(&sb->s_isw_nr_in_flight))
 		flush_workqueue(isw_wq);
-	}
 }
 
 static int __init cgroup_writeback_init(void)
diff --git a/fs/super.c b/fs/super.c
index 583a0124bc39..3d5ebf60b4ee 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -248,6 +248,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+	atomic_set(&s->s_isw_nr_in_flight, 0);
 
 	s->s_count = 1;
 	atomic_set(&s->s_active, 1);
@@ -445,7 +446,7 @@ void generic_shutdown_super(struct super_block *sb)
 		sb->s_flags &= ~SB_ACTIVE;
 
 		fsnotify_sb_delete(sb);
-		cgroup_writeback_umount();
+		cgroup_writeback_umount(sb);
 
 		evict_inodes(sb);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd28e7679089..4e437e2723b9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1519,6 +1519,8 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+	atomic_t                s_isw_nr_in_flight;
 } __randomize_layout;
 
 /* Helper functions so that in most cases filesystems will
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 738a0c24874f..982299c92402 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -190,7 +190,7 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 void wbc_detach_inode(struct writeback_control *wbc);
 void wbc_account_io(struct writeback_control *wbc, struct page *page,
 		    size_t bytes);
-void cgroup_writeback_umount(void);
+void cgroup_writeback_umount(struct super_block *sb);
 
 /**
  * inode_attach_wb - associate an inode with its wb
@@ -296,7 +296,7 @@ static inline void wbc_account_io(struct writeback_control *wbc,
 {
 }
 
-static inline void cgroup_writeback_umount(void)
+static inline void cgroup_writeback_umount(struct super_block *sb)
 {
 }
 
-- 
2.19.1.856.g8858448bb

