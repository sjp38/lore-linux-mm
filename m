Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0978C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 02:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E4B520693
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 02:41:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E4B520693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8B9F6B0003; Sun, 28 Apr 2019 22:41:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3B4C6B0006; Sun, 28 Apr 2019 22:41:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29F16B0007; Sun, 28 Apr 2019 22:41:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9285C6B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 22:41:25 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id 73so8491484itl.2
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 19:41:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=sj9duyL67XmzCJ+e+ZEIr1/WHqTE26rk5V9yd8bmvhg=;
        b=uBD/wgPYK1AATbyQQm2mOc5uDwpjDMhYw2cSz5EJQuVOKR+N/oB6V3zTJjAODRlY+H
         tNIh4V1i5c/TDQMa7Z+HJo+qYM4GepXzq3bJ77lEglnpPpcdVWp5ltV9us2u4PKQPrDW
         RHZtMIqvGdcRlphPpISI4g/X78Skmt8cPO2PM/whY6wFYPLElEvXzkojT9CmJMqS5yuM
         OQcmsuCuzMEp2AA9wSyCBCIa2WBNpkDtpvmDCkRiosHCJZori99OfvolabObEVGnmcHg
         7PcM9LIMOtNMi1WwSdv/il6byj149cZrZss20FR8xYEkayaPG43zR+hmiEANBUYu4v7M
         vpvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVYfbonSrOeoiq0/Tn4KkSEKug38nlcFt7YykzlAEyYAtFw/ubn
	cP4fe8dewIxv6WfZgS3QWd5loUFV2nITOKBhoVAgqqdqIyp77SClDQ4Bz7Q02ar2jEukUbD1yHc
	20XEemEMDxaT7NhVRrgEm7RElP8xyaOVGUc5LimnxrUAdA8o2NJ2XOklmxdvdO0HrfQ==
X-Received: by 2002:a24:953:: with SMTP id 80mr18390268itm.139.1556505685295;
        Sun, 28 Apr 2019 19:41:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaiCB1hClKrMGHkdbtdUN6mN06nyF2vkj0E3klVA2kDdLonKXYNkLVt2ZAkzfnY+53ieDd
X-Received: by 2002:a24:953:: with SMTP id 80mr18390219itm.139.1556505684021;
        Sun, 28 Apr 2019 19:41:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556505684; cv=none;
        d=google.com; s=arc-20160816;
        b=WJf8M/3DGqjveafMWo5hxVRxkp9KSdsH2zrDMgEtaIWNEayYYkDv/UwQFKJj5ssy1l
         I9c5hxilv8M7QI/GjmtlgkpMxd2WG3IbY2fKzEs6bZXnMRKpqnpbZdmuOHFpM/Y+iz80
         oyLfKkjTHsTdUlOn/ae149W02uQbYlP1TZlPdQdL9D4vBrSXinD50fs2QYqfWCAK00uu
         Exmo14fIYm9viWp3pxm23hizUGc4vHS8VY2N3TkFBzxBKc59r55BlNyP/tn6k0LT/8Mn
         AsBsvwL9sHO97gvbgWJB8WNFp3Iyd0O94cx5HWxowGWJY1CRggtE1t3gO1YHBT/1Cv+c
         Veng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=sj9duyL67XmzCJ+e+ZEIr1/WHqTE26rk5V9yd8bmvhg=;
        b=O6ckgMQQ8bPMYTojW8ngjGu0TmxgXMMiSTvR3A80BlkfG+SN/tkmvJLOp+8KZbiSEK
         HfrZQh6eNMRSiPhIJ7k1H2QvASV80kBvCuevpW8YGLiWVrICWSK/ODhXAWYOhV7ef+K1
         FLLabNKx6+jj1Trf4nCdmzzXNGn+aD4/+PjWh7RD8YvO0XDMnduuyeGKoNam+ZXpOWaS
         a8i5E2pJ8MUq/0E7rcJHZrcDN82YLhLrQNSVacNaRQy49LHdjIoNjyFebU9Sv0TBXWGJ
         qxzLoCJV+ZWy/8bySIkdnVRpsJzdR/SpsDWWSSkv2qPkyXfpPPMi7tUbO5IAgGls0V0L
         Dorg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id q66si19245060itb.76.2019.04.28.19.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 19:41:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TQTIYpt_1556505668;
Received: from localhost(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TQTIYpt_1556505668)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 29 Apr 2019 10:41:08 +0800
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-mm@kvack.org
Cc: tj@kernel.org,
	akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com,
	bo.liu@linux.alibaba.com
Subject: [PATCH v4 RESEND] fs/writeback: use rcu_barrier() to wait for inflight wb switches going into workqueue when umount
Date: Mon, 29 Apr 2019 10:41:08 +0800
Message-Id: <20190429024108.54150-1-jiufei.xue@linux.alibaba.com>
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

VFS: Busy inodes after unmount of vdd. Self-destruct in 5 seconds.  Have a nice day...
BUG: unable to handle kernel NULL pointer dereference at 0000000000000278
[<ffffffff8126a303>] evict+0xb3/0x180
[<ffffffff8126a760>] iput+0x1b0/0x230
[<ffffffff8127c690>] inode_switch_wbs_work_fn+0x3c0/0x6a0
[<ffffffff810a5b2e>] worker_thread+0x4e/0x490
[<ffffffff810a5ae0>] ? process_one_work+0x410/0x410
[<ffffffff810ac056>] kthread+0xe6/0x100
[<ffffffff8173c199>] ret_from_fork+0x39/0x50

Replace the synchronize_rcu() call with a rcu_barrier() to wait for all
pending callbacks to finish. And inc isw_nr_in_flight after call_rcu()
in inode_switch_wbs() to make more sense.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: stable@kernel.org
---
 fs/fs-writeback.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..b16645b417d9 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -523,8 +523,6 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 
 	isw->inode = inode;
 
-	atomic_inc(&isw_nr_in_flight);
-
 	/*
 	 * In addition to synchronizing among switchers, I_WB_SWITCH tells
 	 * the RCU protected stat update paths to grab the i_page
@@ -532,6 +530,9 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	 * Let's continue after I_WB_SWITCH is guaranteed to be visible.
 	 */
 	call_rcu(&isw->rcu_head, inode_switch_wbs_rcu_fn);
+
+	atomic_inc(&isw_nr_in_flight);
+
 	goto out_unlock;
 
 out_free:
@@ -901,7 +902,11 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 void cgroup_writeback_umount(void)
 {
 	if (atomic_read(&isw_nr_in_flight)) {
-		synchronize_rcu();
+		/*
+		 * Use rcu_barrier() to wait for all pending callbacks to
+		 * ensure that all in-flight wb switches are in the workqueue.
+		 */
+		rcu_barrier();
 		flush_workqueue(isw_wq);
 	}
 }
-- 
2.19.1.856.g8858448bb

