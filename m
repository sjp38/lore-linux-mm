Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1A0FC10F04
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E9E222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:12:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="czbZs5Yh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E9E222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363508E0003; Thu, 14 Feb 2019 21:12:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 311AD8E0001; Thu, 14 Feb 2019 21:12:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2285E8E0003; Thu, 14 Feb 2019 21:12:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D91DF8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:12:40 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so5757042pgc.3
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:12:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+w0huGYiHVH98eeswxvg29eIrgG60OftvJd6Bjr+gg0=;
        b=ZT7NWI4A71AVJFttb065RjDdXsScTQWHU+3M8uAJjEbdPmuC6j3ZPxtrNbo6oJ68oK
         WKY/RYQM1diXduwI0remx/8DjyYqOU6C+wFAKi7zPC1qQRajul3zZeADdmnqE1lewf2I
         nlI+USeO2N489EdudGotFzP62UtMPmv1J44cn7bdTZX6A6+POmvWmTUOctPImXwuSt8o
         DAUVmNCxfbS/HTjjmn+XjnCZf7xSHI416mjncznAZBgVYMGhKnwDqxt9MDHwhyb0YlID
         viFeDfEXWhxZgk+OSXI06fu0CWve2Vp0V0alJgsfsOJ5jutlh6tOe0Xa9G7y+dae8VEm
         z5Yw==
X-Gm-Message-State: AHQUAuYIGQpEhmhENwm35gWYFXaCUHDgofs8Qq1ntJvrVyB9gwoWZaVQ
	hPAL8oHmGx//on52KpAKGJxprB7KkLpzmlYUDbJsVEpL/NCDttzCqPmJEtTo/rzECCl/LTJ1A+C
	G+ieRvFG65nATt3sEO6bN2hw7VF+aduMQGO/rxlqu8pu9Q1IvzYDeFHNzMZXmrwbRPw==
X-Received: by 2002:a63:6bc1:: with SMTP id g184mr3060222pgc.25.1550196760529;
        Thu, 14 Feb 2019 18:12:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCVjFKvGE9TflXaXb7+5l0GhlMeLXPk9D698mkNogFKQFctpwDddLBYJ+Sgt1P3YAzewJE
X-Received: by 2002:a63:6bc1:: with SMTP id g184mr3059639pgc.25.1550196751625;
        Thu, 14 Feb 2019 18:12:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550196751; cv=none;
        d=google.com; s=arc-20160816;
        b=EeGTC1plWxRj/Koe1iXleGN+MxBPkIPFBhXoRoIgYT/9MbrM57Q+s8Qtm7oAqtaa/Y
         OBlJfAi+CyEyFPTtYhEO9uaVXP/+Ny75n78IHD0Qck/HTk35tL9GKDMrRs/MhR2m/paW
         2dUZewOq0uQqZygKoUsei6pTHlsc/uiowuanGY7ZuNomlbnF3VLEMEjeok9/UXbZKqdj
         GLptv09HPBHfpL6wB2YdZqUDWs6teEPiG1wtif4j5YhiC9BJRgEtflmOuw+LtlIKU4l1
         Hk9LJI/dFNkWHK7yu8vn7OTem1Xa98J+sxAkBGdA1fON/aXpcV8q48exHSyXgirbS0Zs
         KfNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+w0huGYiHVH98eeswxvg29eIrgG60OftvJd6Bjr+gg0=;
        b=p2jvY3E8uyg6czKpmps+pgvg09litk8vNX9bMDGtFmcji+J+0E29foFIJNQY45caZq
         BDfONYCmlDtgENS6mlZdXaoydvrkqIu3VK2ReXo1w5nWB0mr5Y088H4XpIiv4Lx80joB
         uTnUnZICVF+sJtyErZITHw6hAe4DXcznVDzG2AOtoJHumjl4B9z5gEeHy+GUfHXbQj5G
         6xWKELniv59Bl95PNTvTg9Jn/5yeH1TTv4ABXmzVi9BOH0hwCUEd7l5Eje+7DkHxsXgw
         kvZR25syHKlN7a5fgzQQrLPA0ftqROr3sYUw+2J1WN9nRt15yBkKeM7qgiyYh75W8IOf
         i8UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=czbZs5Yh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a5si3831575pgw.155.2019.02.14.18.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 18:12:31 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=czbZs5Yh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7C55C21934;
	Fri, 15 Feb 2019 02:12:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550196751;
	bh=8b+nD2gxk3CIxUx056hPA3Oe82UM5m44h+GjOegFd0A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=czbZs5YhH1WvQy4Qa4BXqhiZ/YWE/UqMmFOReH1D5O05/2SHn2wyb65bxUtKUXq2i
	 35CQ4yobpEHsWJKhwad0SHHPTxQUS02Xb/Q3F/1WF/04K/zpFFF3YHjs7h/eAZIMnw
	 YJ0jlE7Vvjnt3d1jArYmc2NRRh2rstyhuU6WJK1w=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Sasha Levin <sashal@kernel.org>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 42/65] writeback: synchronize sync(2) against cgroup writeback membership switches
Date: Thu, 14 Feb 2019 21:10:58 -0500
Message-Id: <20190215021121.177674-42-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190215021121.177674-1-sashal@kernel.org>
References: <20190215021121.177674-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tejun Heo <tj@kernel.org>

[ Upstream commit 7fc5854f8c6efae9e7624970ab49a1eac2faefb1 ]

sync_inodes_sb() can race against cgwb (cgroup writeback) membership
switches and fail to writeback some inodes.  For example, if an inode
switches to another wb while sync_inodes_sb() is in progress, the new
wb might not be visible to bdi_split_work_to_wbs() at all or the inode
might jump from a wb which hasn't issued writebacks yet to one which
already has.

This patch adds backing_dev_info->wb_switch_rwsem to synchronize cgwb
switch path against sync_inodes_sb() so that sync_inodes_sb() is
guaranteed to see all the target wbs and inodes can't jump wbs to
escape syncing.

v2: Fixed misplaced rwsem init.  Spotted by Jiufei.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jiufei Xue <xuejiufei@gmail.com>
Link: http://lkml.kernel.org/r/dc694ae2-f07f-61e1-7097-7c8411cee12d@gmail.com
Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/fs-writeback.c                | 40 ++++++++++++++++++++++++++++++--
 include/linux/backing-dev-defs.h |  1 +
 mm/backing-dev.c                 |  1 +
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 471d863958bc..82ce6d4f7e31 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -331,11 +331,22 @@ struct inode_switch_wbs_context {
 	struct work_struct	work;
 };
 
+static void bdi_down_write_wb_switch_rwsem(struct backing_dev_info *bdi)
+{
+	down_write(&bdi->wb_switch_rwsem);
+}
+
+static void bdi_up_write_wb_switch_rwsem(struct backing_dev_info *bdi)
+{
+	up_write(&bdi->wb_switch_rwsem);
+}
+
 static void inode_switch_wbs_work_fn(struct work_struct *work)
 {
 	struct inode_switch_wbs_context *isw =
 		container_of(work, struct inode_switch_wbs_context, work);
 	struct inode *inode = isw->inode;
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct address_space *mapping = inode->i_mapping;
 	struct bdi_writeback *old_wb = inode->i_wb;
 	struct bdi_writeback *new_wb = isw->new_wb;
@@ -343,6 +354,12 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	bool switched = false;
 	void **slot;
 
+	/*
+	 * If @inode switches cgwb membership while sync_inodes_sb() is
+	 * being issued, sync_inodes_sb() might miss it.  Synchronize.
+	 */
+	down_read(&bdi->wb_switch_rwsem);
+
 	/*
 	 * By the time control reaches here, RCU grace period has passed
 	 * since I_WB_SWITCH assertion and all wb stat update transactions
@@ -435,6 +452,8 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	spin_unlock(&new_wb->list_lock);
 	spin_unlock(&old_wb->list_lock);
 
+	up_read(&bdi->wb_switch_rwsem);
+
 	if (switched) {
 		wb_wakeup(new_wb);
 		wb_put(old_wb);
@@ -475,9 +494,18 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	if (inode->i_state & I_WB_SWITCH)
 		return;
 
+	/*
+	 * Avoid starting new switches while sync_inodes_sb() is in
+	 * progress.  Otherwise, if the down_write protected issue path
+	 * blocks heavily, we might end up starting a large number of
+	 * switches which will block on the rwsem.
+	 */
+	if (!down_read_trylock(&bdi->wb_switch_rwsem))
+		return;
+
 	isw = kzalloc(sizeof(*isw), GFP_ATOMIC);
 	if (!isw)
-		return;
+		goto out_unlock;
 
 	/* find and pin the new wb */
 	rcu_read_lock();
@@ -511,12 +539,14 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	 * Let's continue after I_WB_SWITCH is guaranteed to be visible.
 	 */
 	call_rcu(&isw->rcu_head, inode_switch_wbs_rcu_fn);
-	return;
+	goto out_unlock;
 
 out_free:
 	if (isw->new_wb)
 		wb_put(isw->new_wb);
 	kfree(isw);
+out_unlock:
+	up_read(&bdi->wb_switch_rwsem);
 }
 
 /**
@@ -894,6 +924,9 @@ fs_initcall(cgroup_writeback_init);
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
+static void bdi_down_write_wb_switch_rwsem(struct backing_dev_info *bdi) { }
+static void bdi_up_write_wb_switch_rwsem(struct backing_dev_info *bdi) { }
+
 static struct bdi_writeback *
 locked_inode_to_wb_and_lock_list(struct inode *inode)
 	__releases(&inode->i_lock)
@@ -2420,8 +2453,11 @@ void sync_inodes_sb(struct super_block *sb)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
+	/* protect against inode wb switch, see inode_switch_wbs_work_fn() */
+	bdi_down_write_wb_switch_rwsem(bdi);
 	bdi_split_work_to_wbs(bdi, &work, false);
 	wb_wait_for_completion(bdi, &done);
+	bdi_up_write_wb_switch_rwsem(bdi);
 
 	wait_sb_inodes(sb);
 }
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index c31157135598..07e02d6df5ad 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -190,6 +190,7 @@ struct backing_dev_info {
 	struct radix_tree_root cgwb_tree; /* radix tree of active cgroup wbs */
 	struct rb_root cgwb_congested_tree; /* their congested states */
 	struct mutex cgwb_release_mutex;  /* protect shutdown of wb structs */
+	struct rw_semaphore wb_switch_rwsem; /* no cgwb switch while syncing */
 #else
 	struct bdi_writeback_congested *wb_congested;
 #endif
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8a8bb8796c6c..72e6d0c55cfa 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -689,6 +689,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
 	bdi->cgwb_congested_tree = RB_ROOT;
 	mutex_init(&bdi->cgwb_release_mutex);
+	init_rwsem(&bdi->wb_switch_rwsem);
 
 	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (!ret) {
-- 
2.19.1

